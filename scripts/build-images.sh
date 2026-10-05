#!/bin/bash
# assets/ 의 원본 이미지를 사이트용 이미지(images/)로 변환합니다.
# 원본을 교체한 뒤 이 스크립트를 다시 실행하면 사이트 이미지가 새로 만들어집니다.
#   bash scripts/build-images.sh
set -e
cd "$(dirname "$0")/.."

T=.build/imgtool
mkdir -p .build
if [ ! -x "$T" ] || [ scripts/imgtool.swift -nt "$T" ]; then
  echo "이미지 도구 컴파일 중..."
  swiftc -O scripts/imgtool.swift -o "$T"
fi

rm -rf images .build/masked
mkdir -p .build/masked

# ── 개인정보 가리기 ──────────────────────────────────────────
# 피그마에서 예시 정보로 바꾼 이미지로 원본을 교체했다면 해당 줄을 지워주세요.
M=.build/masked
$T mask assets/web-renewal/pc/06-order.jpg $M/fusidyne-pc-06.png "450,1150,640,30@1080,1165"
$T mask assets/web-new-2/pc/06-order.png $M/andhoney-pc-06.png "430,135,570,92@1010,205"
$T mask assets/web-new-2/mobile/05b-signup-complete.png $M/andhoney-mo-05b.png "108,625,520,150@40,700"

src() { # 가린 버전이 있으면 그것을, 없으면 원본을 사용
  local key=$1 orig=$2
  if [ -f "$M/$key.png" ]; then echo "$M/$key.png"; else echo "$orig"; fi
}

# ── 웹사이트 화면 ────────────────────────────────────────────
# project 폴더명 → 사이트 이미지 폴더명
build_project() {
  local from=$1 to=$2
  mkdir -p images/$to/thumbs

  for f in assets/$from/pc/*; do
    local name=$(basename "${f%.*}") num=$(basename "$f" | cut -d- -f1)
    local in=$(src "$to-pc-$num" "$f")
    $T resize  "$in" images/$to/pc-$name.jpg 1440 0.82
    $T croptop "$in" images/$to/thumbs/pc-$name.jpg 1200 960 0.8
  done

  if [ -d assets/$from/mobile ]; then
    for f in assets/$from/mobile/*; do
      local name=$(basename "${f%.*}") num=$(basename "$f" | cut -d- -f1)
      local in=$(src "$to-mo-$num" "$f")
      $T resize "$in" images/$to/mo-$name.jpg 780 0.82
    done
  fi

  # 대표 이미지: 메인 화면 첫 화면 영역
  $T croptop assets/$from/pc/01-main.* images/$to/cover.jpg 1080 1600 0.85
  echo "  $to 완료"
}

echo "웹사이트 화면 변환 중..."
build_project web-renewal fusidyne
build_project web-new-1 hyraura
build_project web-new-2 andhoney

# ── 광고소재 ────────────────────────────────────────────────
echo "광고소재 변환 중..."
mkdir -p images/ads
for f in assets/ad-creatives/*.png; do
  $T resize "$f" images/ads/$(basename "${f%.*}").jpg 1080 0.85
done

echo "완료: $(find images -name '*.jpg' | wc -l | tr -d ' ')개 이미지, 총 $(du -sh images | cut -f1)"
