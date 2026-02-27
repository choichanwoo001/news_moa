# News Moa AI Backend

## Setup

1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Environment Variables**:
    - Open `.env` file.
    - Fill in your API Key:
        - `OPENAI_API_KEY`: for GPT-4o.
        - `NAVER_CLIENT_ID` & `NAVER_CLIENT_SECRET`: for Korean news search.

## Run

```bash
uvicorn backend.main:app --reload
```

## API Documentation

Once running, visit: http://127.0.0.1:8000/docs

## Endpoints

-   `GET /news/search?query=Tesla&source=google`
-   `GET /news/search?query=삼성전자&source=naver`
