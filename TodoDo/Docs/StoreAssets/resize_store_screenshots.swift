import AppKit

/// 6.9인치 원본 스크린샷을 6.5/5.5 규격으로 리프레임합니다.
/// `output_raw/iphone-6.9`를 기준으로 다른 규격 원본 스크린샷을 생성합니다.

struct Target {
    let folder: String
    let width: CGFloat
    let height: CGFloat
}

let root = URL(fileURLWithPath: "/Users/kimkyeongbeom/Desktop/testprjt/TodoDo/Docs/StoreAssets/output_raw")
let sourceFolder = root.appendingPathComponent("iphone-6.9")
let targets: [Target] = [
    .init(folder: "iphone-6.5", width: 1242, height: 2688),
    .init(folder: "iphone-5.5", width: 1242, height: 2208)
]

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ResizeStoreScreenshots", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG 인코딩 실패"])
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try png.write(to: url)
}

func makeBitmap(from source: NSImage, width: CGFloat, height: CGFloat) -> NSBitmapImageRep? {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(width),
        pixelsHigh: Int(height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        return nil
    }

    let sourceSize = source.size
    let scale = max(width / sourceSize.width, height / sourceSize.height)
    let drawWidth = sourceSize.width * scale
    let drawHeight = sourceSize.height * scale

    // 스토어 스크린샷은 상단 내비게이션/타이틀 정보가 중요하므로 세로 크롭은 상단 기준으로 정렬합니다.
    let drawRect = NSRect(
        x: (width - drawWidth) / 2.0,
        y: min(0, height - drawHeight),
        width: drawWidth,
        height: drawHeight
    )

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    NSColor.black.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()
    source.draw(in: drawRect, from: .zero, operation: .copy, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()

    return bitmap
}

for index in 1...5 {
    let name = String(format: "screenshot-%02d.png", index)
    let sourceURL = sourceFolder.appendingPathComponent(name)

    guard let sourceImage = NSImage(contentsOf: sourceURL) else {
        print("❌ source not found: \(sourceURL.path)")
        continue
    }

    for target in targets {
        let outURL = root.appendingPathComponent(target.folder).appendingPathComponent(name)
        do {
            guard let outBitmap = makeBitmap(from: sourceImage, width: target.width, height: target.height) else {
                print("❌ \(target.folder)/\(name): 비트맵 생성 실패")
                continue
            }
            try writePNG(outBitmap, to: outURL)
            print("✅ \(target.folder)/\(name)")
        } catch {
            print("❌ \(target.folder)/\(name): \(error.localizedDescription)")
        }
    }
}
