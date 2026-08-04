# Lingo — 스페인어 단어장

아이폰에서 사용할 수 있게 만든 설치형 웹앱(PWA)입니다. 단어장과 오답 노트는 로그인한 계정의 Supabase 서버에 저장됩니다.

## 사용 기능

- 스페인어 단어장 선택 및 새 단어 직접 추가
- 플래시카드 학습과 셔플
- 객관식/직접 입력 퀴즈
- 오답 노트
- 사이드바, 다크 모드, 학습 언어 선택 UI
- 이메일 회원가입·로그인·로그아웃
- 사진 OCR(스페인어/한국어 `단어 - 뜻` 형식)
- 스페인어 말하기 퀴즈(브라우저 음성 인식)

## 서버 연결 (필수)

1. [Supabase](https://supabase.com/)에서 새 프로젝트를 만들고, **SQL Editor**에서 [supabase-schema.sql](./supabase-schema.sql) 전체를 실행합니다.
2. Project Settings → API에서 Project URL과 **Publishable key**를 확인합니다.
3. [config.js](./config.js)의 두 값을 교체합니다. 이 파일은 Git에 올리지 않습니다.
4. Authentication → URL Configuration에 배포할 앱 주소를 Site URL 및 Redirect URLs로 등록합니다.

데이터베이스에는 사용자 본인 데이터만 읽고 쓸 수 있는 RLS 정책이 포함되어 있습니다. Publishable key는 클라이언트에 노출되어도 되지만, `service_role` 키는 절대 넣으면 안 됩니다.

## GitHub Pages 자동 배포

`.github/workflows/deploy.yml`이 `master` 브랜치에 올라갈 때마다 Pages를 자동 배포합니다. GitHub 저장소의 **Settings → Secrets and variables → Actions**에서 다음 두 Repository secrets를 추가하세요.

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

그 다음 **Settings → Pages → Source**를 `GitHub Actions`로 선택하면 됩니다. 앞으로는 GitHub에 push할 때마다 약 1~2분 뒤 최신 앱이 배포됩니다.

## 아이폰에 설치하기

1. 이 폴더를 GitHub에 올리고 GitHub Pages(또는 Vercel/Netlify)에 배포합니다.
2. 아이폰 Safari에서 배포된 주소를 엽니다.
3. 공유 버튼 → **홈 화면에 추가**를 누릅니다.

배포 전에도 PC에서 `index.html`을 브라우저로 열어 화면을 확인할 수 있습니다. 서비스 워커(오프라인 실행)는 HTTPS 배포 환경에서 동작합니다.

## 한자 필기 기능

한자를 손으로 그리는 입력 화면은 만들 수 있지만, **정답 판정**은 필기 인식 모델/API가 있어야 합니다. 이는 단순 OCR과 다른 기능이라 별도 비용·키가 필요한 서비스(예: Azure AI Vision 또는 Google Cloud Vision)를 연결한 뒤 추가하는 것이 안전합니다. 중국어 학습 모드를 열 때 함께 연결하는 것을 권장합니다.

## 다음 구현 권장 순서

1. 계정 및 클라우드 동기화
2. 단어장 공유
3. 중국어 필기 인식 퀴즈용 서버 API 연결
