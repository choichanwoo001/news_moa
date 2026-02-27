"""
캐시 관리자 - 네이버 API 일일 2,500회 제한 대응
전략: 파일 기반 TTL 캐시
- 장중 (09:00~15:30 KST): TTL 30분
- 장외 시간: TTL 60분
"""

import os
import json
import time
from datetime import datetime, timezone, timedelta
from typing import Optional, Any

CACHE_DIR = os.path.join(os.path.dirname(__file__), "..", "cache")

# 한국 시간대 (UTC+9)
KST = timezone(timedelta(hours=9))

# TTL 설정 (초 단위)
MARKET_HOURS_TTL = 30 * 60    # 장중: 30분
OFF_HOURS_TTL    = 60 * 60    # 장외: 60분


def _ensure_cache_dir():
    os.makedirs(CACHE_DIR, exist_ok=True)


def is_market_hours() -> bool:
    """한국 주식 시장 운영 시간 (평일 09:00 ~ 15:30 KST) 여부 반환"""
    now = datetime.now(KST)
    if now.weekday() >= 5:   # 토(5), 일(6)
        return False
    market_open  = now.replace(hour=9,  minute=0,  second=0, microsecond=0)
    market_close = now.replace(hour=15, minute=30, second=0, microsecond=0)
    return market_open <= now <= market_close


def get_ttl() -> int:
    """현재 시장 상황에 따른 TTL 반환 (초)"""
    return MARKET_HOURS_TTL if is_market_hours() else OFF_HOURS_TTL


def _cache_path(key: str) -> str:
    _ensure_cache_dir()
    # 파일명에 사용할 수 없는 문자 제거
    safe_key = key.replace("/", "_").replace("\\", "_")
    return os.path.join(CACHE_DIR, f"{safe_key}.json")


def load_cache(key: str) -> Optional[Any]:
    """
    캐시에서 데이터 로드.
    만료된 경우 None 반환.
    """
    path = _cache_path(key)
    if not os.path.exists(path):
        return None

    try:
        with open(path, "r", encoding="utf-8") as f:
            cached = json.load(f)

        saved_at = cached.get("saved_at", 0)
        ttl = get_ttl()
        if time.time() - saved_at > ttl:
            return None   # 캐시 만료

        return cached.get("data")

    except Exception as e:
        print(f"[CacheManager] 캐시 읽기 오류 ({key}): {e}")
        return None


def save_cache(key: str, data: Any) -> None:
    """데이터를 캐시에 저장"""
    path = _cache_path(key)
    try:
        payload = {
            "saved_at": time.time(),
            "data": data
        }
        with open(path, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"[CacheManager] 캐시 저장 오류 ({key}): {e}")


def clear_cache(key: Optional[str] = None) -> None:
    """
    특정 키 또는 전체 캐시 삭제.
    key=None 이면 전체 삭제.
    """
    _ensure_cache_dir()
    if key:
        path = _cache_path(key)
        if os.path.exists(path):
            os.remove(path)
    else:
        for filename in os.listdir(CACHE_DIR):
            if filename.endswith(".json"):
                os.remove(os.path.join(CACHE_DIR, filename))
        print("[CacheManager] 전체 캐시 삭제 완료")


def cache_stats() -> dict:
    """캐시 현황 통계 반환"""
    _ensure_cache_dir()
    files = [f for f in os.listdir(CACHE_DIR) if f.endswith(".json")]
    ttl = get_ttl()
    now = time.time()
    valid = 0
    expired = 0
    for filename in files:
        path = os.path.join(CACHE_DIR, filename)
        try:
            with open(path, "r", encoding="utf-8") as f:
                cached = json.load(f)
            if now - cached.get("saved_at", 0) <= ttl:
                valid += 1
            else:
                expired += 1
        except Exception:
            expired += 1

    return {
        "total_files": len(files),
        "valid": valid,
        "expired": expired,
        "current_ttl_minutes": ttl // 60,
        "is_market_hours": is_market_hours(),
    }
