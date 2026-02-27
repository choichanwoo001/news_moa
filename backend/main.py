"""
News Moa FastAPI 백엔드
네이버 뉴스 API 기반 섹터별 히트맵 데이터 제공
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from typing import List
from pathlib import Path
import os
import requests

# .env 경로를 main.py 기준으로 명시 (프로젝트 루트에서 실행해도 찾을 수 있도록)
_env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(_env_path)

from backend.models.news_schema import (
    NewsItem,
    SectorNewsResult,
    HeatmapResponse,
)
from backend.services.news_collector import (
    fetch_sector_news,
    fetch_all_sectors,
    fetch_naver_news,
    SECTOR_META,
    fetch_us_sector_news,
    fetch_all_us_sectors,
    US_SECTOR_META,
)
from backend.services.cache_manager import (
    clear_cache,
    cache_stats,
    get_ttl,
    is_market_hours,
)
from backend.services.heatmap_service import build_heatmap_response

app = FastAPI(
    title="News Moa API",
    description="네이버 뉴스 기반 주식 섹터 히트맵 서비스",
    version="2.0.0",
)

# Flutter 앱 연결용 CORS 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─────────────────────────────────────────────
# 기본 엔드포인트
# ─────────────────────────────────────────────

@app.get("/")
def root():
    return {
        "message": "News Moa API is Running",
        "version": "2.0.0",
        "docs": "/docs",
    }


# ─────────────────────────────────────────────
# 히트맵 데이터
# ─────────────────────────────────────────────

@app.get("/news/heatmap", response_model=HeatmapResponse)
def get_heatmap(market: str = "KR"):
    """
    전체 섹터 히트맵 데이터 반환.
    - market=KR: 네이버 뉴스 API (캐시 + 병렬 호출)
    - market=US: Google News RSS (무료, 호출 제한 없음)
    """
    try:
        return build_heatmap_response(market)
    except ValueError as e:
        raise HTTPException(status_code=503, detail=str(e))


# ─────────────────────────────────────────────
# 섹터별 뉴스
# ─────────────────────────────────────────────

@app.get("/news/sector/{sector_id}", response_model=SectorNewsResult)
def get_sector_news(sector_id: str, page: int = 1):
    """
    특정 섹터의 뉴스 목록 반환 (캐시 우선).
    KR 섹터 (IT_1 등) 또는 US 섹터 (US_IT_1 등) 자동 인식.
    page: 페이지 번호 (1부터 시작, 기본값 1)
    """
    # US_ 접두사로 자동 인식
    if sector_id.startswith("US_"):
        if sector_id not in US_SECTOR_META:
            raise HTTPException(status_code=404, detail=f"알 수 없는 US 섹터: {sector_id}")
        result = fetch_us_sector_news(sector_id, display=10, page=page)
    else:
        if sector_id not in SECTOR_META:
            raise HTTPException(status_code=404, detail=f"알 수 없는 KR 섹터: {sector_id}")
        result = fetch_sector_news(sector_id, display=10, page=page)

    if not result:
        raise HTTPException(status_code=503, detail="뉴스를 가져오는 데 실패했습니다.")

    return result



@app.get("/news/sectors")
def list_sectors(market: str = "KR"):
    """사용 가능한 섹터 ID 목록 반환"""
    if market.upper() == "US":
        return list(US_SECTOR_META.keys())
    return list(SECTOR_META.keys())


@app.get("/debug/naver-test")
def debug_naver_test(query: str = "반도체 주가"):
    """디버깅: 네이버 API raw 호출 결과 확인"""
    client_id     = os.getenv("NAVER_CLIENT_ID")
    client_secret = os.getenv("NAVER_CLIENT_SECRET")

    debug_info = {
        "client_id_exists": bool(client_id),
        "client_id_preview": (client_id[:4] + "...") if client_id else None,
        "client_secret_exists": bool(client_secret),
        "query": query,
    }

    if not client_id or not client_secret:
        debug_info["error"] = "환경변수 누락"
        return debug_info

    url = "https://openapi.naver.com/v1/search/news.json"
    headers = {
        "X-Naver-Client-Id":     client_id,
        "X-Naver-Client-Secret": client_secret,
    }
    params = {"query": query, "display": 3, "sort": "date"}

    try:
        response = requests.get(url, headers=headers, params=params, timeout=10)
        debug_info["status_code"] = response.status_code
        debug_info["response_body"] = response.json()
    except Exception as e:
        debug_info["error"] = str(e)

    return debug_info


# ─────────────────────────────────────────────
# 캐시 관리
# ─────────────────────────────────────────────

@app.post("/cache/refresh")
def refresh_all_cache(background_tasks: BackgroundTasks):
    """
    전체 캐시 강제 갱신 (백그라운드 실행).
    관리자용 - 앱 시작 시 또는 수동 트리거 시 사용.
    """
    def _refresh():
        clear_cache()
        fetch_all_sectors(display=10)
        print("[Cache] 전체 캐시 갱신 완료")

    background_tasks.add_task(_refresh)
    return {"message": "백그라운드에서 전체 캐시 갱신 중..."}


@app.delete("/cache/{sector_id}")
def clear_sector_cache(sector_id: str):
    """특정 섹터 캐시 삭제"""
    if sector_id not in SECTOR_META:
        raise HTTPException(status_code=404, detail=f"알 수 없는 섹터: {sector_id}")
    clear_cache(f"sector_{sector_id}")
    return {"message": f"{sector_id} 캐시 삭제 완료"}


@app.delete("/cache")
def clear_all_cache():
    """전체 캐시 삭제"""
    clear_cache()
    return {"message": "전체 캐시 삭제 완료"}


@app.get("/cache/stats")
def get_cache_stats():
    """캐시 현황 및 API 호출 전략 정보 반환"""
    stats = cache_stats()
    ttl = get_ttl()
    sector_count = len(SECTOR_META)
    calls_per_refresh = sector_count  # 캐시 미스 시 섹터당 1회
    refreshes_per_day = (24 * 60) // (ttl // 60)
    estimated_daily_calls = calls_per_refresh * refreshes_per_day

    return {
        **stats,
        "sector_count": sector_count,
        "estimated_daily_api_calls": estimated_daily_calls,
        "naver_daily_limit": 2500,
        "usage_ratio": f"{(estimated_daily_calls / 2500) * 100:.1f}%",
    }


# ─────────────────────────────────────────────
# 레거시 엔드포인트 (하위 호환)
# ─────────────────────────────────────────────

@app.get("/news/search", response_model=List[NewsItem])
def search_news(query: str):
    """기존 검색 엔드포인트 (캐시 없음, 직접 호출)"""
    items = fetch_naver_news(query, display=5)
    if not items:
        raise HTTPException(status_code=503, detail="뉴스 검색 실패")
    return items
