"""
네이버 뉴스 API 수집 서비스
- 섹터별 뉴스 검색 및 newsVolume/changeRate 계산
- cache_manager를 통한 캐싱으로 API 호출량 절약
"""

import os
import re
import json
import requests
import feedparser
from datetime import datetime, timezone, timedelta
from typing import List, Optional

from ..models.news_schema import NewsItem, SectorNewsResult
from openai import OpenAI
from .cache_manager import load_cache, save_cache

KST = timezone(timedelta(hours=9))

# ─────────────────────────────────────────────
# 섹터 메타데이터: 검색 키워드 매핑
# (하드코딩 데이터 → 정적 메타데이터로만 유지)
# ─────────────────────────────────────────────
SECTOR_META = {
    # IT
    "IT_1":  {"name": "반도체",       "category_id": "IT",     "category_name": "IT",       "keywords": ["반도체 주가", "반도체 주식"]},
    "IT_2":  {"name": "소프트웨어",   "category_id": "IT",     "category_name": "IT",       "keywords": ["소프트웨어 주식", "IT서비스 주가"]},
    "IT_3":  {"name": "하드웨어",     "category_id": "IT",     "category_name": "IT",       "keywords": ["하드웨어 주식", "전자부품 주가"]},
    # 헬스케어
    "HC_1":  {"name": "바이오",       "category_id": "HC",     "category_name": "헬스케어", "keywords": ["바이오 주가", "바이오 주식"]},
    "HC_2":  {"name": "제약",         "category_id": "HC",     "category_name": "헬스케어", "keywords": ["제약 주가", "제약 주식"]},
    "HC_3":  {"name": "의료기기",     "category_id": "HC",     "category_name": "헬스케어", "keywords": ["의료기기 주가"]},
    # 금융
    "FN_1":  {"name": "은행",         "category_id": "FN",     "category_name": "금융",     "keywords": ["은행 주가", "금융 주식"]},
    "FN_2":  {"name": "보험",         "category_id": "FN",     "category_name": "금융",     "keywords": ["보험 주가", "보험 주식"]},
    "FN_3":  {"name": "증권",         "category_id": "FN",     "category_name": "금융",     "keywords": ["증권 주가", "증권사 주식"]},
    # 임의소비재
    "CD_1":  {"name": "자동차",       "category_id": "CD",     "category_name": "임의소비재","keywords": ["자동차 주가", "자동차 주식"]},
    "CD_2":  {"name": "의류",         "category_id": "CD",     "category_name": "임의소비재","keywords": ["패션 의류 주가"]},
    "CD_3":  {"name": "호텔",         "category_id": "CD",     "category_name": "임의소비재","keywords": ["호텔 여행 주가"]},
    "CD_4":  {"name": "전자제품",     "category_id": "CD",     "category_name": "임의소비재","keywords": ["가전 전자제품 주가"]},
    # 필수소비재
    "CS_1":  {"name": "음식료",       "category_id": "CS",     "category_name": "필수소비재","keywords": ["식품 음료 주가"]},
    "CS_2":  {"name": "생활용품",     "category_id": "CS",     "category_name": "필수소비재","keywords": ["생활용품 주가"]},
    # 커뮤니케이션
    "CM_1":  {"name": "통신",         "category_id": "CM",     "category_name": "커뮤니케이션","keywords": ["통신 주가", "통신사 주식"]},
    "CM_2":  {"name": "미디어",       "category_id": "CM",     "category_name": "커뮤니케이션","keywords": ["미디어 방송 주가"]},
    "CM_3":  {"name": "엔터테인먼트", "category_id": "CM",     "category_name": "커뮤니케이션","keywords": ["엔터테인먼트 주가", "연예기획사 주식"]},
    # 산업재
    "IN_1":  {"name": "항공우주",     "category_id": "IN",     "category_name": "산업재",   "keywords": ["항공 주가", "방산 주식"]},
    "IN_2":  {"name": "기계",         "category_id": "IN",     "category_name": "산업재",   "keywords": ["기계 중공업 주가"]},
    "IN_3":  {"name": "건설",         "category_id": "IN",     "category_name": "산업재",   "keywords": ["건설 주가", "건설 주식"]},
    "IN_4":  {"name": "운송",         "category_id": "IN",     "category_name": "산업재",   "keywords": ["물류 운송 주가"]},
    # 에너지
    "EN_1":  {"name": "석유",         "category_id": "EN",     "category_name": "에너지",   "keywords": ["정유 석유 주가"]},
    "EN_2":  {"name": "가스",         "category_id": "EN",     "category_name": "에너지",   "keywords": ["가스 에너지 주가"]},
    "EN_3":  {"name": "대체에너지",   "category_id": "EN",     "category_name": "에너지",   "keywords": ["신재생 태양광 주가"]},
    # 소재
    "MT_1":  {"name": "화학",         "category_id": "MT",     "category_name": "소재",     "keywords": ["화학 주가", "화학 주식"]},
    "MT_2":  {"name": "금속",         "category_id": "MT",     "category_name": "소재",     "keywords": ["철강 금속 주가"]},
    "MT_3":  {"name": "광물",         "category_id": "MT",     "category_name": "소재",     "keywords": ["광물 희토류 주가"]},
    # 유틸리티
    "UT_1":  {"name": "전력",         "category_id": "UT",     "category_name": "유틸리티", "keywords": ["전력 한전 주가"]},
    "UT_2":  {"name": "도시가스",     "category_id": "UT",     "category_name": "유틸리티", "keywords": ["도시가스 주가"]},
    "UT_3":  {"name": "수도",         "category_id": "UT",     "category_name": "유틸리티", "keywords": ["수처리 환경 주가"]},
    # 부동산
    "RE_1":  {"name": "개발",         "category_id": "RE",     "category_name": "부동산",   "keywords": ["부동산 개발 주가"]},
    "RE_2":  {"name": "관리",         "category_id": "RE",     "category_name": "부동산",   "keywords": ["리츠 부동산 주가"]},
    "RE_3":  {"name": "투자",         "category_id": "RE",     "category_name": "부동산",   "keywords": ["부동산 투자 주가"]},
}

# ─────────────────────────────────────────────
# 섹터별 주요 기업 사전 (기사에서 매칭용)
# ─────────────────────────────────────────────
COMPANY_DICT = {
    # IT
    "IT_1": ["삼성전자", "SK하이닉스", "마이크론", "TSMC", "엔비디아", "인텔", "DB하이텍", "리노공업", "한미반도체", "이오테크닉스"],
    "IT_2": ["삼성SDS", "카카오", "네이버", "NHN", "더존비즈온", "위메이드", "크래프톤", "엔씨소프트", "컴투스", "넷마블"],
    "IT_3": ["LG전자", "삼성전기", "LG이노텍", "대덕전자", "심텍", "코리아써키트", "비에이치", "파트론", "아모텍", "서울반도체"],
    # 헬스케어
    "HC_1": ["삼성바이오", "셀트리온", "SK바이오팜", "에이비엘바이오", "유한양행", "알테오젠", "HLB", "메디톡스", "리가켐바이오", "오스코텍"],
    "HC_2": ["유한양행", "녹십자", "한미약품", "대웅제약", "종근당", "JW중외제약", "일동제약", "동아ST", "보령", "광동제약"],
    "HC_3": ["오스템임플란트", "인바디", "바텍", "루트로닉", "씨젠", "레이", "솔고바이오", "뷰노", "제이시스메디칼", "디오"],
    # 금융
    "FN_1": ["KB금융", "신한지주", "하나금융", "우리금융", "기업은행", "BNK금융", "DGB금융", "JB금융", "카카오뱅크", "토스"],
    "FN_2": ["삼성생명", "삼성화재", "DB손보", "현대해상", "한화생명", "메리츠금융", "동양생명", "KB손보", "롯데손보", "흥국화재"],
    "FN_3": ["미래에셋", "삼성증권", "NH투자", "한국투자", "KB증권", "키움증권", "대신증권", "하나증권", "신한투자", "메리츠증권"],
    # 임의소비재
    "CD_1": ["현대차", "기아", "현대모비스", "만도", "한온시스템", "현대위아", "에스엘", "HL만도", "한국타이어", "넥센타이어"],
    "CD_2": ["F&F", "한세실업", "영원무역", "휠라홀딩스", "코오롱인더", "LF", "신세계인터", "한섬", "무신사", "이랜드"],
    "CD_3": ["호텔신라", "하나투어", "모두투어", "파라다이스", "GKL", "강원랜드", "롯데관광", "여기어때", "야놀자", "인터파크"],
    "CD_4": ["삼성전자", "LG전자", "쿠쿠홈시스", "위닉스", "코웨이", "쿠첸", "SK매직", "일렉트로룩스", "다이슨", "발뮤다"],
    # 필수소비재
    "CS_1": ["CJ제일제당", "오뚜기", "농심", "삼양식품", "풀무원", "동원F&B", "하이트진로", "오리온", "롯데칠성", "빙그레"],
    "CS_2": ["LG생활건강", "아모레퍼시픽", "애경산업", "깨끗한나라", "유한킴벌리", "헨켈", "P&G", "유니레버", "쿠팡", "이마트"],
    # 커뮤니케이션
    "CM_1": ["SK텔레콤", "KT", "LG유플러스", "SK브로드밴드", "KT스카이라이프", "SKT", "LGU+", "세종텔레콤", "KT클라우드", "토스"],
    "CM_2": ["CJ ENM", "제일기획", "SBS", "JTBC", "KBS", "MBC", "TV조선", "채널A", "스튜디오드래곤", "카카오엔터"],
    "CM_3": ["하이브", "SM엔터", "JYP엔터", "YG엔터", "카카오엔터", "CJ ENM", "큐브엔터", "판타지오", "에스엠", "와이지"],
    # 산업재
    "IN_1": ["한화에어로", "한국항공우주", "LIG넥스원", "현대로템", "한화시스템", "KAI", "대한항공", "아시아나", "제주항공", "티웨이항공"],
    "IN_2": ["두산에너빌", "현대중공업", "삼성중공업", "대우조선", "HD한국조선", "두산밥캣", "현대건설기계", "LS일렉트릭", "효성중공업", "현대일렉트릭"],
    "IN_3": ["현대건설", "대우건설", "GS건설", "삼성물산", "DL이앤씨", "HDC현대산업", "포스코건설", "롯데건설", "대림산업", "호반건설"],
    "IN_4": ["대한항공", "아시아나", "현대글로비스", "CJ대한통운", "한진", "팬오션", "HMM", "흥아해운", "쿠팡", "롯데글로벌"],
    # 에너지
    "EN_1": ["SK이노베이션", "에스오일", "GS칼텍스", "현대오일뱅크", "SK에너지", "한국석유", "흥구석유", "중앙에너비스", "극동유화", "S-Oil"],
    "EN_2": ["한국가스공사", "SK가스", "E1", "대성에너지", "서울가스", "삼천리", "경동도시가스", "예스코", "부산가스", "지에스이"],
    "EN_3": ["한화솔루션", "OCI", "신성이엔지", "두산퓨얼셀", "씨에스윈드", "유니슨", "에스에너지", "해줌", "한국수소산업", "SK E&S"],
    # 소재
    "MT_1": ["LG화학", "SKC", "롯데케미칼", "한화솔루션", "금호석유화학", "효성화학", "OCI", "코오롱", "SK케미칼", "대한유화"],
    "MT_2": ["포스코홀딩스", "현대제철", "고려아연", "동국제강", "세아제강", "풍산", "영풍", "TCC스틸", "KG스틸", "동국산업"],
    "MT_3": ["포스코", "고려아연", "영풍", "일진머티리얼즈", "에코프로비엠", "에코프로", "엘앤에프", "포스코퓨처엠", "천보", "나노신소재"],
    # 유틸리티
    "UT_1": ["한국전력", "한전KPS", "한전기술", "한국수력원자력", "두산에너빌리티", "LS ELECTRIC", "효성중공업", "일진전기", "대원전선", "한전산업"],
    "UT_2": ["삼천리", "서울가스", "경동도시가스", "대성에너지", "부산가스", "SK가스", "예스코", "코원에너지", "대륜E&S", "인천도시가스"],
    "UT_3": ["코웨이", "한국수처리", "자연과환경", "에코매니지먼트", "KC코트렐", "수젠텍", "에코바이오", "웰크론한텍", "한솔테크닉스", "태영건설"],
    # 부동산
    "RE_1": ["삼성물산", "현대건설", "DL이앤씨", "GS건설", "대우건설", "호반건설", "롯데건설", "제일건설", "신세계건설", "HDC현대산업"],
    "RE_2": ["맥쿼리인프라", "ESR켄달스퀘어", "SK리츠", "롯데리츠", "이리츠코크렙", "NH올원리츠", "미래에셋맵스", "제이알글로벌", "코람코에너지", "신한서부티엔디"],
    "RE_3": ["신세계프라퍼티", "이랜드리테일", "한화갤러리아", "현대백화점", "롯데쇼핑", "이마트", "신세계", "갤러리아", "AK플라자", "대형마트"],
}

# US 섹터 기업 사전
US_COMPANY_DICT = {
    "US_IT_1": ["Apple", "Microsoft", "NVIDIA", "AMD", "Intel", "Google", "Meta", "Amazon", "Tesla", "Netflix", "Alphabet", "Broadcom", "TSMC", "Qualcomm", "Adobe"],
    "US_IT_2": ["Meta", "Facebook", "Twitter", "X", "Snap", "Pinterest", "Reddit", "LinkedIn", "TikTok", "Discord"],
    "US_HC_1": ["Johnson & Johnson", "Pfizer", "Moderna", "AbbVie", "Merck", "Eli Lilly", "Amgen", "Gilead", "Bristol-Myers", "Novo Nordisk"],
    "US_FN_1": ["JPMorgan", "Goldman Sachs", "Morgan Stanley", "Bank of America", "Citigroup", "Wells Fargo", "BlackRock", "Charles Schwab", "Visa", "Mastercard"],
    "US_EN_1": ["ExxonMobil", "Chevron", "Shell", "BP", "ConocoPhillips", "EOG", "Pioneer", "Schlumberger", "Halliburton", "Marathon"],
    "US_CD_1": ["Tesla", "Amazon", "Nike", "Starbucks", "McDonald's", "Home Depot", "Toyota", "Ford", "GM", "Walmart"],
    "US_CS_1": ["Procter & Gamble", "Coca-Cola", "PepsiCo", "Costco", "Walmart", "Colgate", "Unilever", "Nestlé", "Mondelez", "Kraft"],
    "US_CM_1": ["AT&T", "Verizon", "T-Mobile", "Comcast", "Disney", "Netflix", "Warner Bros", "Paramount", "Spotify", "Roku"],
    "US_IN_1": ["Boeing", "Lockheed Martin", "Raytheon", "Caterpillar", "3M", "Honeywell", "GE", "UPS", "FedEx", "Deere"],
    "US_MT_1": ["Dow", "DuPont", "Linde", "Air Products", "Nucor", "Freeport-McMoRan", "Newmont", "Alcoa", "US Steel", "Cleveland-Cliffs"],
}


def _filter_fake_companies(companies: List[str]) -> List[str]:
    """
    'A기업', 'B사', 'OO기업' 같은 익명/가짜 기업명을 필터링.
    실제 상장 기업명이 아닌 익명 표현을 제거한다.
    """
    if not companies:
        return []

    # 익명/가짜 기업명 패턴 (대소문자 무시)
    fake_patterns = [
        # 한글 1자 또는 알파벳 1자 + 기업/사/그룹/회사/업체
        r'^[A-Za-zㄱ-ㅎ가-힣]기업$',
        r'^[A-Za-zㄱ-ㅎ가-힣]사$',
        r'^[A-Za-zㄱ-ㅎ가-힣]그룹$',
        r'^[A-Za-zㄱ-ㅎ가-힣]회사$',
        r'^[A-Za-zㄱ-ㅎ가-힣]업체$',
        r'^[A-Za-zㄱ-ㅎ가-힣]은행$',
        r'^[A-Za-zㄱ-ㅎ가-힣]증권$',
        # OO, XX 마스킹 패턴
        r'^[OoXx○●]{2}.+$',
        r'^○○.+$',
        # "모 기업", "해당 기업", "특정 기업", "일부 기업" 등
        r'^(모|해당|특정|일부|모\s)\s?(기업|회사|업체|그룹|증권|은행)$',
        # "某企業" 같은 한자 표현
        r'^某.+$',
        # 단일 알파벳이나 단일 한글 (기업명으로는 너무 짧음)
        r'^[A-Za-zㄱ-ㅎ가-힣]$',
        # "Company A", "Firm B" 같은 영문 익명 패턴
        r'^(Company|Firm|Corp)\s+[A-Z]$',
    ]

    filtered = []
    for company in companies:
        name = company.strip()
        if not name:
            continue
        is_fake = False
        for pattern in fake_patterns:
            if re.match(pattern, name):
                is_fake = True
                break
        if not is_fake:
            filtered.append(name)

    return filtered


def _extract_companies(text: str, sector_id: str, max_count: int = 5) -> List[str]:
    """
    기사 텍스트(제목+설명)에서 관련 기업명을 매칭하여 최대 max_count개 반환.
    제목 매칭에 더 높은 점수 부여.
    """
    # 적절한 사전 선택
    if sector_id.startswith("US_"):
        companies = US_COMPANY_DICT.get(sector_id, [])
    else:
        companies = COMPANY_DICT.get(sector_id, [])

    if not companies:
        return []

    matched = []
    for company in companies:
        if company in text:
            matched.append(company)

    return matched[:max_count]


def _analyze_articles_ai_batch(
    articles_data: list[dict],
    sector_name: str,
    category_name: str,
    market: str = "KR",
    max_companies: int = 5,
) -> list[dict]:
    """
    기사들에 대해 GPT AI로 섹터 적합성 검증 + 기업명 추출 + 분류 사유 + 요약을 배치 처리.
    articles_data: [{"title": str, "description": str}, ...]
    반환: [{"is_relevant": bool, "companies": [...], "reason": str, "summary": str}, ...]
    """
    api_key = os.getenv("OPENAI_API_KEY")
    default = [{"is_relevant": True, "companies": [], "reason": "", "summary": ""} for _ in articles_data]
    if not api_key or not articles_data:
        return default

    # 기사 목록을 프롬프트용 텍스트로 변환
    article_texts = []
    for i, ad in enumerate(articles_data):
        article_texts.append(
            f"[{i+1}] 제목: {ad['title']}\n    설명: {ad['description'][:300]}"
        )
    articles_block = "\n".join(article_texts)

    if market == "KR":
        prompt = f"""당신은 금융 뉴스 분류 전문가입니다.

현재 섹터: "{sector_name}" (카테고리: {category_name})

아래 뉴스 기사들을 분석하여 각각:
1. 이 기사가 "{sector_name}" 섹터에 적합한지 판정 (is_relevant)
2. 기사에 언급된 관련 상장 기업명 추출 (최대 {max_companies}개, 공식 상장명 또는 널리 알려진 약칭)
3. 분류 판정 사유를 한 줄로 작성 (reason)
4. 기사 핵심 내용을 1-2문장으로 요약 (summary) - 반드시 완결된 문장으로, 잘리지 않게 작성

판정 기준:
- 기사의 핵심 주제가 "{sector_name}" 섹터와 직접 관련되어야 적합합니다.
- 단순히 "유가증권시장" 등의 일반적인 단어 포함은 적합 판정 근거가 아닙니다.
- 예: "증권" 섹터 → 증권사, 투자 관련 뉴스만 적합. 반도체/자동차 뉴스는 부적합.

중요 규칙:
- 기업명은 반드시 실제 상장 기업의 공식 명칭만 사용하세요.
- "A기업", "B사", "C그룹", "모 기업", "OO기업" 같은 익명·가명 표현은 절대 포함하지 마세요.
- 기사에서 실제 기업명을 특정할 수 없으면 빈 배열 []을 반환하세요.
- 요약은 반드시 완결된 문장으로 작성하고, 중간에 잘리지 않도록 하세요.

{articles_block}

반드시 아래 JSON 형식으로만 응답:
{{"results": [
  {{"is_relevant": true, "companies": ["기업1", "기업2"], "reason": "증권사 실적 관련 뉴스", "summary": "삼성증권이 2분기 실적 호조로 영업이익이 전년 대비 20% 증가했다."}},
  {{"is_relevant": false, "companies": ["삼성전자"], "reason": "반도체 업종 뉴스로 IT 섹터에 해당", "summary": "삼성전자가 차세대 반도체 공정 개발에 성공했다."}}
]}}
- results 배열 길이는 정확히 {len(articles_data)}개
- 관련 기업 없으면 빈 배열 []
- summary는 50-100자 내외의 완결된 문장
"""
    else:
        prompt = f"""You are a financial news classification expert.

Current sector: "{sector_name}" (category: {category_name})

Analyze each article below:
1. Is this article relevant to the "{sector_name}" sector? (is_relevant)
2. Extract related publicly traded company names (max {max_companies}, ticker or common name)
3. Brief one-line classification reason (reason)
4. Summarize the article in 1-2 complete sentences (summary) - must be a complete sentence, not truncated

IMPORTANT: 
- Only return real, officially listed company names. Do NOT return anonymous placeholders like "Company A", "Firm B", etc. If no real company name can be identified, return an empty array [].
- Summary must be a complete, non-truncated sentence.

{articles_block}

Respond ONLY in JSON:
{{"results": [
  {{"is_relevant": true, "companies": ["AAPL", "MSFT"], "reason": "Tech earnings report", "summary": "Apple reported strong Q2 earnings with revenue up 15% year-over-year."}},
  {{"is_relevant": false, "companies": ["XOM"], "reason": "Oil sector news, not tech", "summary": "ExxonMobil announced new drilling operations in the Gulf of Mexico."}}
]}}
- results array length must be exactly {len(articles_data)}
- Use empty array [] if no companies
- summary should be 50-150 characters, complete sentence
"""

    try:
        client = OpenAI(api_key=api_key)
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a financial news analyst. Always output valid JSON."},
                {"role": "user", "content": prompt},
            ],
            response_format={"type": "json_object"},
            timeout=30,
        )
        data = json.loads(response.choices[0].message.content)
        results = data.get("results", [])

        # 길이 검증
        if len(results) != len(articles_data):
            while len(results) < len(articles_data):
                results.append({"is_relevant": True, "companies": [], "reason": "", "summary": ""})
            results = results[:len(articles_data)]

        # 각 결과 정규화
        normalized = []
        for r in results:
            if not isinstance(r, dict):
                normalized.append({"is_relevant": True, "companies": [], "reason": "", "summary": ""})
            else:
                companies = r.get("companies", [])
                if not isinstance(companies, list):
                    companies = []
                normalized.append({
                    "is_relevant": bool(r.get("is_relevant", True)),
                    "companies": companies[:max_companies],
                    "reason": str(r.get("reason", ""))[:100],
                    "summary": str(r.get("summary", ""))[:200],
                })
        return normalized

    except Exception as e:
        return default


def _generate_sector_briefing(
    sector_name: str,
    category_name: str,
    articles: List[NewsItem],
    market: str = "KR",
) -> Optional[str]:
    """
    해당 섹터 뉴스 목록을 바탕으로 AI 한 줄 브리핑 생성.
    반환: 한 줄 문자열 (50~80자 내외) 또는 실패 시 None
    """
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key or not articles:
        return None

    # 최대 5개 기사 제목·요약만 사용
    snippets = []
    for i, a in enumerate(articles[:5]):
        summary = (a.summary or a.description or "")[:150]
        snippets.append(f"[{i+1}] {a.title}\n    {summary}")
    block = "\n".join(snippets)

    if market == "KR":
        prompt = f"""당신은 금융 뉴스 브리퍼입니다.

아래는 "{sector_name}"({category_name}) 섹터의 최근 뉴스 제목·요약입니다.
이 내용만 바탕으로, 이 섹터가 지금 왜 주목받는지 한 문장으로 요약해주세요.

규칙:
- 50~80자 내외의 한 문장으로만 작성
- 구체적 키워드(기업명·이슈)를 포함할 것
- "~한 상황", "~에 주목" 등으로 마무리

뉴스:
{block}

한 줄 브리핑만 출력하고 다른 설명은 하지 마세요."""
    else:
        prompt = f"""You are a financial news briefer.

Below are recent headlines/summaries for the "{sector_name}" ({category_name}) sector.
In one sentence (about 15-25 words), summarize why this sector is in the spotlight right now.

Rules:
- One sentence only, no extra explanation
- Include concrete keywords (companies, themes)

News:
{block}

Output only the one-line briefing."""

    try:
        client = OpenAI(api_key=api_key)
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a concise financial news briefer. Output only the requested one-line text."},
                {"role": "user", "content": prompt},
            ],
            max_tokens=120,
            timeout=15,
        )
        text = (response.choices[0].message.content or "").strip()
        return text[:120] if text else None
    except Exception as e:
        print(f"[SectorBriefing] 생성 실패 ({sector_name}): {e}")
        return None


def _strip_html(text: str) -> str:
    """HTML 태그 및 엔티티 제거"""
    import html
    clean = re.compile('<.*?>')
    text = re.sub(clean, '', text)
    return html.unescape(text)


def _call_naver_news(keyword: str, display: int = 10, start: int = 1) -> dict:
    """
    네이버 뉴스 검색 API 호출 (1회).
    반환: {"items": [...], "total": 전체 검색 결과 수}
    실패 시: {"items": [], "total": 0}
    start: 검색 시작 위치 (1부터 시작, 최대 1000)
    """
    client_id     = os.getenv("NAVER_CLIENT_ID")
    client_secret = os.getenv("NAVER_CLIENT_SECRET")

    if not client_id or not client_secret:
        print("[NaverAPI] 환경변수 NAVER_CLIENT_ID / NAVER_CLIENT_SECRET 없음")
        return {"items": [], "total": 0}

    url = "https://openapi.naver.com/v1/search/news.json"
    headers = {
        "X-Naver-Client-Id":     client_id,
        "X-Naver-Client-Secret": client_secret,
    }
    params = {
        "query":   keyword,
        "display": display,
        "start":   start,
        "sort":    "date",  # 최신순
    }

    try:
        response = requests.get(url, headers=headers, params=params, timeout=8)
        response.raise_for_status()
        data = response.json()
        return {
            "items": data.get("items", []),
            "total": data.get("total", 0),
        }
    except Exception as e:
        print(f"[NaverAPI] 호출 오류 (keyword={keyword}): {e}")
        return {"items": [], "total": 0}


def _calc_change_rate(articles: List[NewsItem]) -> float:
    """
    뉴스 제목에서 긍정/부정 단어 빈도로 간단한 감성 점수 계산.
    반환: -5.0 ~ +5.0 범위의 float
    """
    positive_words = ["상승", "급등", "호재", "수주", "성장", "흑자", "신고가", "확대", "개선", "돌파"]
    negative_words = ["하락", "급락", "악재", "손실", "적자", "위기", "감소", "부진", "하향", "경고"]

    pos = sum(
        1 for a in articles
        for w in positive_words if w in a.title
    )
    neg = sum(
        1 for a in articles
        for w in negative_words if w in a.title
    )

    total = pos + neg
    if total == 0:
        return 0.0

    # 범위: -5 ~ +5 (히트맵 색상용)
    score = ((pos - neg) / total) * 5.0
    return round(score, 2)


def _extract_rising_keywords(articles: List[NewsItem], max_keywords: int = 8) -> List[str]:
    """
    섹터 내 기사에서 관련 기업(키워드) 빈도를 집계해 급상승 키워드 목록 반환.
    """
    from collections import Counter
    counter: Counter[str] = Counter()
    for a in articles:
        for c in (a.related_companies or []):
            name = (c or "").strip()
            if len(name) >= 2:  # 한 글자 제외
                counter[name] += 1
    return [w for w, _ in counter.most_common(max_keywords)]


def fetch_sector_news(sector_id: str, display: int = 10, page: int = 1) -> Optional[SectorNewsResult]:
    """
    단일 섹터의 뉴스를 캐시 우선으로 가져옴.
    캐시 미스 시 네이버 API 호출 후 캐시 저장.
    page: 페이지 번호 (1부터 시작)
    """
    if sector_id not in SECTOR_META:
        print(f"[NewsCollector] 알 수 없는 sector_id: {sector_id}")
        return None

    cache_key = f"sector_{sector_id}_{page}"
    cached = load_cache(cache_key)
    if cached:
        return SectorNewsResult(**cached)

    # 캐시 미스 → API 호출
    meta     = SECTOR_META[sector_id]
    keyword  = meta["keywords"][0]   # 첫 번째 키워드 사용
    start    = (page - 1) * display + 1   # 네이버 API start 파라미터
    api_result = _call_naver_news(keyword, display=display, start=start)
    raw_items  = api_result["items"]
    total_count = api_result["total"]   # 해당 키워드의 전체 뉴스 수

    # 1단계: 기사 파싱 + 사전 매칭
    parsed_articles = []
    for item in raw_items:
        title = _strip_html(item.get("title", ""))
        desc  = _strip_html(item.get("description", ""))
        dict_companies = _extract_companies(title + " " + desc, sector_id)
        parsed_articles.append({
            "title": title,
            "description": desc,
            "link": item.get("link", ""),
            "pubDate": item.get("pubDate", ""),
            "original_link": item.get("originallink"),
            "dict_companies": dict_companies,
        })

    # 2단계: AI 배치 분석 (섹터 검증 + 기업명 + 분류 사유)
    ai_input = [{"title": p["title"], "description": p["description"]} for p in parsed_articles]
    ai_results = _analyze_articles_ai_batch(
        ai_input, meta["name"], meta["category_name"], market="KR"
    )

    # 3단계: AI 결과 병합 + 부적합 기사 필터링
    articles: List[NewsItem] = []
    for parsed, ai in zip(parsed_articles, ai_results):
        if not ai["is_relevant"]:
            continue

        # 기업명: 사전 매칭 결과 우선, 없으면 AI 결과 사용 + 가짜 기업명 필터링
        companies = parsed["dict_companies"] if parsed["dict_companies"] else _filter_fake_companies(ai["companies"])
        articles.append(NewsItem(
            title       = parsed["title"],
            link        = parsed["link"],
            description = parsed["description"],
            pubDate     = parsed["pubDate"],
            source      = "Naver",
            original_link = parsed["original_link"],
            related_companies = companies,
            ai_classification_reason = ai["reason"] if ai["reason"] else None,
            summary     = ai["summary"] if ai.get("summary") else None,
        ))

    # 히트맵 크기: API가 반환한 전체 뉴스 수 (실제 기사는 display개만 표시용)
    news_volume  = float(total_count) if total_count > 0 else float(len(articles))
    change_rate  = _calc_change_rate(articles)
    cached_at    = datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S")
    sector_briefing = _generate_sector_briefing(
        meta["name"], meta["category_name"], articles, market="KR"
    ) if articles else None
    rising_keywords = _extract_rising_keywords(articles)

    result = SectorNewsResult(
        sector_id     = sector_id,
        sector_name   = meta["name"],
        category_id   = meta["category_id"],
        category_name = meta["category_name"],
        articles      = articles,
        news_volume   = news_volume,
        change_rate   = change_rate,
        cached_at     = cached_at,
        sector_briefing = sector_briefing,
        rising_keywords = rising_keywords,
    )

    # 캐시 저장 (Pydantic → dict)
    save_cache(cache_key, result.model_dump())
    return result


def fetch_all_sectors(display: int = 10) -> List[SectorNewsResult]:
    """
    전체 섹터 뉴스 수집 (캐시 활용).
    한 번 호출 시 최대 30 API 호출 발생 (캐시 미스인 섹터만).
    """
    results = []
    for sector_id in SECTOR_META:
        result = fetch_sector_news(sector_id, display=display)
        if result:
            results.append(result)
    return results


# ─── 하위 호환성: 기존 main.py에서 사용하던 함수 유지 ────────────────────
def fetch_naver_news(query: str, display: int = 10):
    """기존 호환용 래퍼"""
    from ..models.news_schema import NewsItem as _NewsItem
    api_result = _call_naver_news(query, display=display)
    raw = api_result["items"]
    result = []
    for item in raw:
        result.append(_NewsItem(
            title       = _strip_html(item.get("title", "")),
            link        = item.get("link", ""),
            description = _strip_html(item.get("description", "")),
            pubDate     = item.get("pubDate", ""),
            source      = "Naver",
            original_link = item.get("originallink"),
        ))
    return result


# ═══════════════════════════════════════════════
# 미국 시장 (Google News RSS) — API 호출량 제한 없음
# ═══════════════════════════════════════════════

US_SECTOR_META = {
    # Technology
    "US_IT_1":  {"name": "Semiconductors",    "category_id": "US_IT",   "category_name": "Technology",       "keywords": ["semiconductor stocks"]},
    "US_IT_2":  {"name": "Software",          "category_id": "US_IT",   "category_name": "Technology",       "keywords": ["software technology stocks"]},
    "US_IT_3":  {"name": "Hardware",           "category_id": "US_IT",   "category_name": "Technology",       "keywords": ["hardware tech stocks"]},
    # Healthcare
    "US_HC_1":  {"name": "Biotech",            "category_id": "US_HC",   "category_name": "Healthcare",       "keywords": ["biotech stocks"]},
    "US_HC_2":  {"name": "Pharma",             "category_id": "US_HC",   "category_name": "Healthcare",       "keywords": ["pharma stocks"]},
    "US_HC_3":  {"name": "Medical Devices",    "category_id": "US_HC",   "category_name": "Healthcare",       "keywords": ["medical device stocks"]},
    # Finance
    "US_FN_1":  {"name": "Banking",            "category_id": "US_FN",   "category_name": "Finance",          "keywords": ["banking stocks Wall Street"]},
    "US_FN_2":  {"name": "Insurance",          "category_id": "US_FN",   "category_name": "Finance",          "keywords": ["insurance stocks"]},
    "US_FN_3":  {"name": "Investment",         "category_id": "US_FN",   "category_name": "Finance",          "keywords": ["investment brokerage stocks"]},
    # Consumer Discretionary
    "US_CD_1":  {"name": "Automotive",         "category_id": "US_CD",   "category_name": "Consumer Disc.",    "keywords": ["automotive EV stocks"]},
    "US_CD_2":  {"name": "Retail",             "category_id": "US_CD",   "category_name": "Consumer Disc.",    "keywords": ["retail consumer stocks"]},
    "US_CD_3":  {"name": "Luxury",             "category_id": "US_CD",   "category_name": "Consumer Disc.",    "keywords": ["luxury goods stocks"]},
    # Consumer Staples
    "US_CS_1":  {"name": "Food & Beverage",    "category_id": "US_CS",   "category_name": "Consumer Staples",  "keywords": ["food beverage stocks"]},
    "US_CS_2":  {"name": "Household",          "category_id": "US_CS",   "category_name": "Consumer Staples",  "keywords": ["household products stocks"]},
    # Communication
    "US_CM_1":  {"name": "Telecom",            "category_id": "US_CM",   "category_name": "Communication",     "keywords": ["telecom stocks"]},
    "US_CM_2":  {"name": "Media",              "category_id": "US_CM",   "category_name": "Communication",     "keywords": ["media streaming stocks"]},
    "US_CM_3":  {"name": "Entertainment",      "category_id": "US_CM",   "category_name": "Communication",     "keywords": ["entertainment stocks"]},
    # Industrials
    "US_IN_1":  {"name": "Aerospace",          "category_id": "US_IN",   "category_name": "Industrials",       "keywords": ["aerospace defense stocks"]},
    "US_IN_2":  {"name": "Machinery",          "category_id": "US_IN",   "category_name": "Industrials",       "keywords": ["machinery industrial stocks"]},
    "US_IN_3":  {"name": "Construction",       "category_id": "US_IN",   "category_name": "Industrials",       "keywords": ["construction stocks"]},
    # Energy
    "US_EN_1":  {"name": "Oil & Gas",          "category_id": "US_EN",   "category_name": "Energy",            "keywords": ["oil gas stocks"]},
    "US_EN_2":  {"name": "Renewables",         "category_id": "US_EN",   "category_name": "Energy",            "keywords": ["renewable energy stocks"]},
    # Materials
    "US_MT_1":  {"name": "Chemicals",          "category_id": "US_MT",   "category_name": "Materials",         "keywords": ["chemicals stocks"]},
    "US_MT_2":  {"name": "Metals & Mining",    "category_id": "US_MT",   "category_name": "Materials",         "keywords": ["metals mining stocks"]},
    # Utilities
    "US_UT_1":  {"name": "Electric",           "category_id": "US_UT",   "category_name": "Utilities",         "keywords": ["electric utility stocks"]},
    "US_UT_2":  {"name": "Water",              "category_id": "US_UT",   "category_name": "Utilities",         "keywords": ["water utility stocks"]},
    # Real Estate
    "US_RE_1":  {"name": "REITs",              "category_id": "US_RE",   "category_name": "Real Estate",       "keywords": ["REIT real estate stocks"]},
    "US_RE_2":  {"name": "Development",        "category_id": "US_RE",   "category_name": "Real Estate",       "keywords": ["real estate development stocks"]},
}


def _call_google_news_rss(keyword: str, max_items: int = 10) -> dict:
    """
    Google News RSS로 영문 뉴스 검색. 무료, API 키 불필요, 호출 제한 없음.
    반환: {"items": [...], "total": RSS 피드 전체 항목 수}
    """
    base_url = "https://news.google.com/rss/search"
    rss_url = f"{base_url}?q={keyword}&hl=en-US&gl=US&ceid=US:en"

    try:
        feed = feedparser.parse(rss_url)
        total_entries = len(feed.entries)  # RSS 피드 전체 항목 수
        items = []
        for entry in feed.entries[:max_items]:
            items.append({
                "title":       entry.get("title", ""),
                "link":        entry.get("link", ""),
                "description": entry.get("summary", entry.get("title", "")),
                "pubDate":     entry.get("published", ""),
                "source":      "Google News",
            })
        return {"items": items, "total": total_entries}
    except Exception as e:
        print(f"[GoogleRSS] 호출 오류 (keyword={keyword}): {e}")
        return {"items": [], "total": 0}


def _calc_us_change_rate(articles: List[NewsItem]) -> float:
    """영문 뉴스 제목 기반 감성 점수 계산"""
    positive_words = ["surge", "soar", "rally", "gain", "rise", "jump", "boom", "record", "growth", "bullish"]
    negative_words = ["drop", "fall", "plunge", "crash", "decline", "loss", "bear", "slump", "tumble", "warning"]

    pos = sum(1 for a in articles for w in positive_words if w.lower() in a.title.lower())
    neg = sum(1 for a in articles for w in negative_words if w.lower() in a.title.lower())

    total = pos + neg
    if total == 0:
        return 0.0
    return round(((pos - neg) / total) * 5.0, 2)


def fetch_us_sector_news(sector_id: str, display: int = 10, page: int = 1) -> Optional[SectorNewsResult]:
    """
    미국 단일 섹터 뉴스 (Google News RSS + 캐시).
    page: 페이지 번호 (1부터 시작)
    """
    if sector_id not in US_SECTOR_META:
        print(f"[NewsCollector] 알 수 없는 US sector_id: {sector_id}")
        return None

    cache_key = f"us_sector_{sector_id}_{page}"
    cached = load_cache(cache_key)
    if cached:
        return SectorNewsResult(**cached)

    meta = US_SECTOR_META[sector_id]
    keyword = meta["keywords"][0]
    # Google RSS는 start 파라미터 미지원 → offset으로 슬라이싱
    offset = (page - 1) * display
    api_result = _call_google_news_rss(keyword, max_items=offset + display)
    all_items   = api_result["items"]
    total_count = api_result["total"]   # RSS 피드 전체 항목 수
    raw_items   = all_items[offset:]    # 현재 페이지에 해당하는 항목만

    # 1단계: 기사 파싱 + 사전 매칭
    parsed_articles = []
    for item in raw_items:
        title = _strip_html(item.get("title", ""))
        desc  = _strip_html(item.get("description", ""))
        dict_companies = _extract_companies(title + " " + desc, sector_id)
        parsed_articles.append({
            "title": title,
            "description": desc,
            "link": item.get("link", ""),
            "pubDate": item.get("pubDate", ""),
            "original_link": item.get("link"),
            "dict_companies": dict_companies,
        })

    # 2단계: AI 배치 분석
    ai_input = [{"title": p["title"], "description": p["description"]} for p in parsed_articles]
    ai_results = _analyze_articles_ai_batch(
        ai_input, meta["name"], meta["category_name"], market="US"
    )

    # 3단계: AI 결과 병합 + 부적합 기사 필터링
    articles: List[NewsItem] = []
    for parsed, ai in zip(parsed_articles, ai_results):
        if not ai["is_relevant"]:
            continue

        companies = parsed["dict_companies"] if parsed["dict_companies"] else _filter_fake_companies(ai["companies"])
        articles.append(NewsItem(
            title       = parsed["title"],
            link        = parsed["link"],
            description = parsed["description"],
            pubDate     = parsed["pubDate"],
            source      = "Google News",
            original_link = parsed["original_link"],
            related_companies = companies,
            ai_classification_reason = ai["reason"] if ai["reason"] else None,
            summary     = ai["summary"] if ai.get("summary") else None,
        ))

    news_volume = float(total_count) if total_count > 0 else float(len(articles))
    change_rate = _calc_us_change_rate(articles)
    cached_at   = datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S")
    sector_briefing = _generate_sector_briefing(
        meta["name"], meta["category_name"], articles, market="US"
    ) if articles else None
    rising_keywords = _extract_rising_keywords(articles)

    result = SectorNewsResult(
        sector_id     = sector_id,
        sector_name   = meta["name"],
        category_id   = meta["category_id"],
        category_name = meta["category_name"],
        articles      = articles,
        news_volume   = news_volume,
        change_rate   = change_rate,
        cached_at     = cached_at,
        sector_briefing = sector_briefing,
        rising_keywords = rising_keywords,
    )

    save_cache(cache_key, result.model_dump())
    return result


def fetch_all_us_sectors(display: int = 10) -> List[SectorNewsResult]:
    """전체 미국 섹터 뉴스 수집 (Google News RSS + 캐시)"""
    results = []
    for sector_id in US_SECTOR_META:
        result = fetch_us_sector_news(sector_id, display=display)
        if result:
            results.append(result)
    return results

