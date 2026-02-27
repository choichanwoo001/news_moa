# News Moa 배포 가이드 (미니 PC 서버)

## 1. 서버 준비

- Docker & Docker Compose v2 설치
- (CI/CD 사용 시) Git 저장소 클론 경로 준비

```bash
sudo mkdir -p /opt/news_moa
sudo chown $USER:$USER /opt/news_moa
git clone https://github.com/YOUR_USER/news_moa.git /opt/news_moa
cd /opt/news_moa
```

## 2. 환경 변수

```bash
cp backend/.env.example .env
# .env 수정: NAVER_CLIENT_ID, NAVER_CLIENT_SECRET 등
```

## 3. 로컬에서 직접 실행

```bash
docker compose build
docker compose up -d
```

- 웹: http://서버IP (80 포트)
- API 직접: http://서버IP:8000

## 4. CI/CD (GitHub Actions)

저장소 Secrets에 다음 추가:

| 이름 | 설명 |
|------|------|
| `SSH_HOST` | 서버 IP 또는 호스트명 |
| `SSH_USER` | SSH 로그인 사용자 |
| `SSH_PRIVATE_KEY` | SSH 개인키 전체 내용 |
| `SSH_PORT` | (선택) SSH 포트, 기본 22 |

서버에서 한 번만:

```bash
cd /opt/news_moa
git pull
cp backend/.env.example .env
# .env 편집 후
docker compose up -d
```

이후 `main` 브랜치에 push 하면 자동 배포됩니다.  
배포 경로를 바꾸려면 `.github/workflows/deploy.yml`의 `DEPLOY_PATH`를 수정하세요.

## 5. 포트 변경

80 포트를 쓰지 않을 경우 `docker-compose.yml`에서:

```yaml
web:
  ports:
    - "8080:80"  # 호스트 8080 → 컨테이너 80
```

## 6. 로그 / 재시작

```bash
docker compose logs -f
docker compose restart
docker compose down && docker compose up -d
```

## 7. 참고

- **첫 빌드**: Flutter 웹 빌드가 포함되어 있어 10~20분 정도 걸릴 수 있습니다. 이후에는 변경분만 빌드됩니다.
- **Docker Compose v1** 사용 시: `docker-compose` 명령으로 실행하고, 워크플로의 `docker compose`도 `docker-compose`로 바꾸세요.
