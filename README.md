# 포트폴리오 웹사이트

미니멀한 흰 배경의 정적 웹사이트입니다. 설치할 프로그램 없이 HTML, CSS, JS 파일만으로 동작합니다.

## 폴더 구조

```
index.html            홈 (소개, 작업 목록, About, Contact)
work/
  fusidyne.html       01 후시다인 공식몰 리뉴얼
  andhoney.html       02 앤허니 공식몰 구축
  hyraura.html        03 하이로라 브랜드 사이트 구축
  ad-creatives.html   04 동화약품 광고소재
css/style.css         디자인 (색, 글꼴, 레이아웃)
js/main.js            라이트박스, 스크롤 애니메이션
images/               사이트에 쓰는 이미지 (자동 생성, 직접 수정하지 않기)
assets/               피그마와 광고소재 원본 (사이트에 올리지 않음)
scripts/              원본 → 사이트 이미지 변환 도구
```

## 자주 하는 수정

| 바꿀 것 | 위치 |
|---|---|
| 이름 | 모든 HTML 파일의 `고연우` (찾아 바꾸기로 한 번에) |
| 이메일 | `index.html`의 `yeonbinu@gmail.com` |
| 소개 문구, 경력, 툴 | `index.html`의 About 영역 |
| 프로젝트 설명 | `work/*.html`의 Overview, Key Points |

## 이미지를 바꿨을 때

`assets/`의 원본을 교체한 뒤 아래 명령을 실행하면 `images/`가 새로 만들어집니다.

```bash
bash scripts/build-images.sh
```

개인정보가 있던 화면 3개는 이 스크립트가 해당 부분을 자동으로 가립니다.
피그마에서 예시 정보로 바꾼 이미지로 교체했다면 스크립트 안의 `개인정보 가리기` 줄을 지워주세요.

## 내 컴퓨터에서 미리보기

```bash
python3 -m http.server 8000
```

실행 후 브라우저에서 http://localhost:8000 을 엽니다.

## 게시된 주소

https://yeonbinu.github.io (GitHub 저장소: github.com/yeonbinu/yeonbinu.github.io)

수정한 내용을 사이트에 반영하려면 이 폴더에서 아래 명령을 실행합니다. 1~2분 뒤 사이트에 반영됩니다.

```bash
git add -A && git commit -m "포트폴리오 수정" && git push
```

`assets/` 원본 폴더는 `.gitignore`로 제외되어 있어 올라가지 않습니다.

## 다른 곳에 올리기

`assets/`, `scripts/`, `.build/`는 제외하고 아래만 올리면 됩니다 (약 26MB).

```
index.html  work/  css/  js/  images/
```

- **Netlify Drop** (가장 쉬움): app.netlify.com/drop 에 위 파일들이 든 폴더를 끌어다 놓기
- **GitHub Pages**: 저장소에 올린 뒤 Settings → Pages에서 켜기
- **Vercel**: 저장소를 연결하면 자동 배포
