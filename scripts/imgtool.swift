// 포트폴리오 이미지 처리 도구 (macOS 기본 CoreGraphics만 사용)
//
// 사용법 (좌표는 모두 원본 이미지 기준, 왼쪽 위가 0,0):
//   imgtool resize  <in> <out.jpg> <maxWidth> [quality]
//   imgtool croptop <in> <out.jpg> <cropHeight> <outWidth> [quality]
//   imgtool mask    <in> <out.png> <x,y,w,h@sx,sy> ...   (sx,sy 위치의 색으로 사각형을 채움)
//   imgtool sample  <in> <x,y> ...                        (해당 위치의 색을 HEX로 출력)

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func fail(_ msg: String) -> Never {
    FileHandle.standardError.write((msg + "\n").data(using: .utf8)!)
    exit(1)
}

func load(_ path: String) -> CGImage {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fail("이미지를 열 수 없음: \(path)") }
    return img
}

func makeContext(_ w: Int, _ h: Int) -> CGContext {
    guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fail("컨텍스트 생성 실패") }
    ctx.interpolationQuality = .high
    return ctx
}

func save(_ img: CGImage, _ path: String, quality: Double = 0.8) {
    let isJpeg = path.lowercased().hasSuffix(".jpg") || path.lowercased().hasSuffix(".jpeg")
    let type = (isJpeg ? UTType.jpeg : UTType.png).identifier as CFString
    guard let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, type, 1, nil) else { fail("저장 실패: \(path)") }
    let opts = isJpeg ? [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary : nil
    CGImageDestinationAddImage(dest, img, opts)
    if !CGImageDestinationFinalize(dest) { fail("저장 실패: \(path)") }
}

// 흰 배경 위에 그려서 투명 영역이 JPEG에서 검게 나오지 않도록 함
func render(_ img: CGImage, srcRect: CGRect, outW: Int) -> CGImage {
    let scale = Double(outW) / srcRect.width
    let outH = Int((srcRect.height * scale).rounded())
    let ctx = makeContext(outW, outH)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: outW, height: outH))
    let fullH = Double(img.height) * scale
    // CG 좌표는 왼쪽 아래가 원점이므로 위쪽 기준 자르기를 위해 이동
    let drawY = Double(outH) - fullH + srcRect.minY * scale
    ctx.draw(img, in: CGRect(x: -srcRect.minX * scale, y: drawY, width: Double(img.width) * scale, height: fullH))
    return ctx.makeImage()!
}

func pixel(_ ctx: CGContext, _ x: Int, _ y: Int) -> (UInt8, UInt8, UInt8) {
    let p = ctx.data!.assumingMemoryBound(to: UInt8.self)
    let i = y * ctx.bytesPerRow + x * 4 // 메모리의 첫 행이 이미지의 맨 위
    return (p[i], p[i + 1], p[i + 2])
}

func nums(_ s: String) -> [Double] { s.split(separator: ",").map { Double($0) ?? 0 } }

let args = CommandLine.arguments
guard args.count >= 3 else { fail("사용법은 파일 상단 주석 참고") }
let cmd = args[1], input = args[2]
let img = load(input)

switch cmd {
case "resize":
    let maxW = Int(args[4])!, q = args.count > 5 ? Double(args[5])! : 0.8
    let outW = min(maxW, img.width)
    save(render(img, srcRect: CGRect(x: 0, y: 0, width: img.width, height: img.height), outW: outW), args[3], quality: q)

case "croptop":
    let h = min(Double(args[4])!, Double(img.height)), outW = Int(args[5])!
    let q = args.count > 6 ? Double(args[6])! : 0.8
    save(render(img, srcRect: CGRect(x: 0, y: 0, width: Double(img.width), height: h), outW: outW), args[3], quality: q)

case "mask":
    let ctx = makeContext(img.width, img.height)
    ctx.draw(img, in: CGRect(x: 0, y: 0, width: img.width, height: img.height))
    for spec in args[4...] {
        let parts = spec.split(separator: "@").map(String.init)
        let r = nums(parts[0]), s = nums(parts[1])
        let (cr, cg, cb) = pixel(ctx, Int(s[0]), Int(s[1]))
        ctx.setFillColor(CGColor(red: Double(cr) / 255, green: Double(cg) / 255, blue: Double(cb) / 255, alpha: 1))
        ctx.fill(CGRect(x: r[0], y: Double(img.height) - r[1] - r[3], width: r[2], height: r[3]))
    }
    save(ctx.makeImage()!, args[3])

case "sample":
    let ctx = makeContext(img.width, img.height)
    ctx.draw(img, in: CGRect(x: 0, y: 0, width: img.width, height: img.height))
    for spec in args[3...] {
        let p = nums(spec)
        let (r, g, b) = pixel(ctx, Int(p[0]), Int(p[1]))
        print(String(format: "%@ #%02X%02X%02X", spec, r, g, b))
    }

default:
    fail("알 수 없는 명령: \(cmd)")
}
