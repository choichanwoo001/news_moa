from pydantic import BaseModel
from typing import List, Optional


class NewsItem(BaseModel):
    title: str
    link: str
    description: str
    pubDate: str
    source: str
    original_link: Optional[str] = None
    content: Optional[str] = None
    related_companies: List[str] = []     # 기사에 언급된 관련 기업 (최대 5개)
    ai_classification_reason: Optional[str] = None  # AI 분류 사유
    summary: Optional[str] = None  # AI 생성 요약 (1-2문장)


class AIAnalysisResult(BaseModel):

    category_level_1: str
    category_level_2: str
    sentiment_label: str
    sentiment_score: int
    sentiment_reason: str
    related_companies: List[str]
    summary: List[str]


class ProcessedNews(NewsItem):
    analysis: Optional[AIAnalysisResult] = None


# 섹터별 뉴스 결과 모델
class SectorNewsResult(BaseModel):
    sector_id: str
    sector_name: str
    category_id: str
    category_name: str
    articles: List[NewsItem]
    news_volume: float       # 뉴스 건수 (히트맵 크기 결정)
    change_rate: float       # 긍정/부정 비율 기반 수치 (히트맵 색상 결정)
    cached_at: Optional[str] = None   # 캐시 저장 시각
    sector_briefing: Optional[str] = None   # AI 생성 섹터 한 줄 브리핑
    rising_keywords: List[str] = []   # 섹터 내 급상승 키워드 (관련 기업/키워드 빈도 기반)


# 전체 히트맵 응답 모델
class CategoryHeatmap(BaseModel):
    category_id: str
    category_name: str
    sub_sectors: List[SectorNewsResult]
    total_volume: float
    avg_change_rate: float


class HeatmapResponse(BaseModel):
    market: str              # "KR" or "US"
    updated_at: str
    categories: List[CategoryHeatmap]
