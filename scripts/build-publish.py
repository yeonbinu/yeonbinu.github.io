# 온라인 게시용 홈 페이지를 만듭니다 (.build/publish/index.html).
# 게시 서비스가 <html>, <head>, <body> 틀을 자동으로 씌우기 때문에 그 태그만 걷어냅니다.
import re, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
src = (root / "index.html").read_text(encoding="utf-8")

head = re.search(r"<head>(.*?)</head>", src, re.S).group(1)
body = re.search(r"<body>(.*?)</body>", src, re.S).group(1)
# 틀에 이미 들어있는 charset, viewport 메타는 제외
head = re.sub(r'\s*<meta (charset|name="viewport")[^>]*>', "", head)

out = root / ".build" / "publish" / "index.html"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(head.strip() + "\n\n" + body.strip() + "\n", encoding="utf-8")
print(out)
