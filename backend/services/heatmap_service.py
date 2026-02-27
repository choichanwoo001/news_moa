"""
히트맵 응답 생성 서비스.
- KR/US 시장별 섹터 병렬 조회
- 카테고리별 집계 후 HeatmapResponse 반환
"""

import asyncio
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone, timedelta
from typing import List

from backend.models.news_schema import (
    SectorNewsResult,
    CategoryHeatmap,
    HeatmapResponse,
)
from backend.services.news_collector import (
    fetch_sector_news,
    fetch_us_sector_news,
    SECTOR_META,
    US_SECTOR_META,
)

KST = timezone(timedelta(hours=9))


def build_heatmap_response(market: str) -> HeatmapResponse:
    """
    동기 버전: 현재 FastAPI 라우트가 동기이므로
    asyncio.run으로 비동기 로직 실행.
    """
    return asyncio.run(_fetch_and_aggregate(market.upper()))


async def build_heatmap_response_async(market: str) -> HeatmapResponse:
    """비동기 버전 (필요 시 라우트를 async로 변경 후 사용)."""
    return await _fetch_and_aggregate(market.upper())


async def _fetch_and_aggregate(market: str) -> HeatmapResponse:
    is_us = market == "US"
    sector_meta = US_SECTOR_META if is_us else SECTOR_META
    fetch_fn = fetch_us_sector_news if is_us else fetch_sector_news

    loop = asyncio.get_event_loop()
    with ThreadPoolExecutor(max_workers=10) as executor:
        tasks = [
            loop.run_in_executor(executor, fetch_fn, sector_id, 10)
            for sector_id in sector_meta
        ]
        results = await asyncio.gather(*tasks, return_exceptions=True)

    all_sectors: List[SectorNewsResult] = [
        r for r in results
        if isinstance(r, SectorNewsResult)
    ]

    if not all_sectors:
        raise ValueError("뉴스 데이터를 가져올 수 없습니다.")

    category_map: dict = {}
    for sector in all_sectors:
        cat_id = sector.category_id
        if cat_id not in category_map:
            category_map[cat_id] = {
                "category_id": cat_id,
                "category_name": sector.category_name,
                "sub_sectors": [],
            }
        category_map[cat_id]["sub_sectors"].append(sector)

    categories: List[CategoryHeatmap] = []
    for cat_id, cat_data in category_map.items():
        subs = cat_data["sub_sectors"]
        total_vol = sum(s.news_volume for s in subs)
        avg_rate = sum(s.change_rate for s in subs) / len(subs) if subs else 0.0
        categories.append(CategoryHeatmap(
            category_id=cat_data["category_id"],
            category_name=cat_data["category_name"],
            sub_sectors=subs,
            total_volume=total_vol,
            avg_change_rate=round(avg_rate, 2),
        ))

    return HeatmapResponse(
        market=market,
        updated_at=datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S"),
        categories=categories,
    )
