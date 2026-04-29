import AppKit

/// App Store Connect 제출용 스크린샷 세트를 생성합니다.
/// 기존 마케팅형 결과물은 유지하고, 이 스크립트는 실제 앱 화면이 더 크게 보이는
/// 보수적인 제출형 이미지를 별도 폴더에 생성합니다.

struct SizeSpec {
    /// 출력 폴더명입니다.
    let folder: String
    /// 캔버스 가로 크기(px)입니다.
    let width: CGFloat
    /// 캔버스 세로 크기(px)입니다.
    let height: CGFloat
}

struct CopySpec {
    /// 상단 아이브로우 문구입니다.
    let eyebrow: String
    /// 메인 헤드라인입니다.
    let title: String
    /// 설명 문구입니다.
    let subtitle: String
}

struct ThemeSpec {
    /// 배경 상단 색입니다.
    let top: NSColor
    /// 배경 하단 색입니다.
    let bottom: NSColor
    /// 포인트 색입니다.
    let accent: NSColor
    /// 기본 텍스트 색입니다.
    let ink: NSColor
    /// 보조 텍스트 색입니다.
    let secondaryInk: NSColor
}

struct SubmissionLayout {
    /// 실제 앱 화면을 감싸는 프레임 폭 비율입니다.
    let frameWidthRatio: CGFloat
    /// 프레임 하단 여백 비율입니다.
    let frameBottomRatio: CGFloat
    /// 타이틀 블록의 시작 y 비율입니다.
    let titleYRatio: CGFloat
    /// 설명문 블록의 시작 y 비율입니다.
    let subtitleYRatio: CGFloat
    /// 설명문 블록의 높이 비율입니다.
    let subtitleHeightRatio: CGFloat
    /// 타이틀을 제외한 상단 텍스트 크기 보정값입니다.
    let secondaryTextScale: CGFloat
}

let root = URL(fileURLWithPath: "/Users/kimkyeongbeom/Desktop/testprjt/TodoDo/Docs/StoreAssets")
let inputRoot = root.appendingPathComponent("output_raw")
let outputRoot = root.appendingPathComponent("output_submission")

let sizes: [SizeSpec] = [
    .init(folder: "iphone-6.9", width: 1320, height: 2868),
    .init(folder: "iphone-6.5", width: 1242, height: 2688),
    .init(folder: "iphone-5.5", width: 1242, height: 2208)
]

let copies: [CopySpec] = [
    .init(
        eyebrow: "오늘 정리",
        title: "오늘 할 일을\n한눈에 확인하세요",
        subtitle: "진행 중과 완료를 분리해\n지금 해야 할 일에 더 쉽게 집중할 수 있어요."
    ),
    .init(
        eyebrow: "빠른 추가",
        title: "할 일을 빠르게\n추가할 수 있어요",
        subtitle: "제목, 마감일, 알림을 한 번에 입력하고 바로 저장할 수 있어요."
    ),
    .init(
        eyebrow: "즉시 수정",
        title: "변경된 계획도\n바로 반영하세요",
        subtitle: "수정 팝업에서 제목과 옵션을 현재 일정에 맞게 바로 업데이트할 수 있어요."
    ),
    .init(
        eyebrow: "완료 기록",
        title: "완료한 일은\n따로 관리하세요",
        subtitle: "완료 목록을 따로 보고, 필요하면 다시 진행 중으로 되돌릴 수 있어요."
    ),
    .init(
        eyebrow: "실수 줄이기",
        title: "확인 후 작업으로\n흐름을 지키세요",
        subtitle: "중요한 상태 변경 전 확인 팝업을 통해 실수를 줄이고 작업 흐름을 유지할 수 있어요."
    )
]

let themes: [ThemeSpec] = [
    .init(top: rgb(248, 251, 255), bottom: rgb(237, 244, 255), accent: rgb(55, 126, 255), ink: rgb(20, 31, 48), secondaryInk: rgb(84, 97, 118)),
    .init(top: rgb(250, 247, 255), bottom: rgb(241, 236, 255), accent: rgb(126, 91, 255), ink: rgb(31, 27, 57), secondaryInk: rgb(89, 84, 117)),
    .init(top: rgb(255, 249, 242), bottom: rgb(255, 239, 222), accent: rgb(235, 140, 48), ink: rgb(44, 33, 24), secondaryInk: rgb(107, 91, 78)),
    .init(top: rgb(246, 252, 246), bottom: rgb(231, 245, 234), accent: rgb(55, 164, 100), ink: rgb(24, 44, 31), secondaryInk: rgb(82, 104, 88)),
    .init(top: rgb(247, 249, 254), bottom: rgb(233, 238, 249), accent: rgb(77, 109, 171), ink: rgb(22, 34, 56), secondaryInk: rgb(84, 95, 117))
]

let submissionLayouts: [String: [SubmissionLayout]] = [
    "iphone-6.9": [
        .init(frameWidthRatio: 0.655, frameBottomRatio: 0.014, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.064, secondaryTextScale: 1.30),
        .init(frameWidthRatio: 0.655, frameBottomRatio: 0.014, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.064, secondaryTextScale: 1.30),
        .init(frameWidthRatio: 0.655, frameBottomRatio: 0.014, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.064, secondaryTextScale: 1.30),
        .init(frameWidthRatio: 0.655, frameBottomRatio: 0.014, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.064, secondaryTextScale: 1.30),
        .init(frameWidthRatio: 0.655, frameBottomRatio: 0.014, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.064, secondaryTextScale: 1.30)
    ],
    "iphone-6.5": [
        .init(frameWidthRatio: 0.645, frameBottomRatio: 0.018, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.062, secondaryTextScale: 1.22),
        .init(frameWidthRatio: 0.645, frameBottomRatio: 0.018, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.062, secondaryTextScale: 1.22),
        .init(frameWidthRatio: 0.645, frameBottomRatio: 0.018, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.062, secondaryTextScale: 1.22),
        .init(frameWidthRatio: 0.645, frameBottomRatio: 0.018, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.062, secondaryTextScale: 1.22),
        .init(frameWidthRatio: 0.645, frameBottomRatio: 0.018, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.062, secondaryTextScale: 1.22)
    ],
    "iphone-5.5": [
        .init(frameWidthRatio: 0.600, frameBottomRatio: 0.016, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.060, secondaryTextScale: 1.14),
        .init(frameWidthRatio: 0.600, frameBottomRatio: 0.016, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.060, secondaryTextScale: 1.14),
        .init(frameWidthRatio: 0.600, frameBottomRatio: 0.016, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.060, secondaryTextScale: 1.14),
        .init(frameWidthRatio: 0.600, frameBottomRatio: 0.016, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.060, secondaryTextScale: 1.14),
        .init(frameWidthRatio: 0.600, frameBottomRatio: 0.016, titleYRatio: 0.705, subtitleYRatio: 0.650, subtitleHeightRatio: 0.060, secondaryTextScale: 1.14)
    ]
]

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> NSColor {
    NSColor(calibratedRed: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func fillRounded(_ rect: NSRect, radius: CGFloat, color: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = roundedRect(rect, radius: radius)
    color.setFill()
    path.fill()

    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

func fillCircle(_ rect: NSRect, color: NSColor) {
    let path = NSBezierPath(ovalIn: rect)
    color.setFill()
    path.fill()
}

func drawText(
    _ text: String,
    in rect: NSRect,
    font: NSFont,
    color: NSColor,
    alignment: NSTextAlignment = .left,
    lineBreak: NSLineBreakMode = .byWordWrapping
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = lineBreak

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]

    NSString(string: text).draw(
        with: rect,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes
    )
}

func fitRect(sourceSize: NSSize, inside target: NSRect) -> NSRect {
    let scale = min(target.width / sourceSize.width, target.height / sourceSize.height)
    let width = sourceSize.width * scale
    let height = sourceSize.height * scale

    return NSRect(
        x: target.midX - width / 2,
        y: target.midY - height / 2,
        width: width,
        height: height
    )
}

func mapScreenshotRect(
    x: CGFloat,
    yTop: CGFloat,
    width: CGFloat,
    height: CGFloat,
    sourceSize: NSSize,
    targetRect: NSRect
) -> NSRect {
    let scale = targetRect.width / sourceSize.width
    return NSRect(
        x: targetRect.minX + (x * scale),
        y: targetRect.maxY - ((yTop + height) * scale),
        width: width * scale,
        height: height * scale
    )
}

func drawSystemSymbol(
    _ name: String,
    in rect: NSRect,
    color: NSColor,
    pointSize: CGFloat,
    weight: NSFont.Weight = .regular
) {
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    guard
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
    else {
        return
    }

    let tinted = NSImage(size: image.size)
    tinted.lockFocus()
    let imageRect = NSRect(origin: .zero, size: image.size)
    image.draw(in: imageRect)
    color.set()
    imageRect.fill(using: .sourceAtop)
    tinted.unlockFocus()
    tinted.draw(in: rect)
}

func drawEnhancedMainScreenshot(
    sourceSize: NSSize,
    fittedRect: NSRect
) {
    let white = NSColor.white
    let ink = rgb(17, 17, 17)
    let secondary = rgb(148, 148, 155)
    let accent = rgb(255, 149, 0)
    let blue = rgb(0, 122, 255)
    let blueFill = rgb(0, 122, 255, 0.14)

    // 요약 카드 숫자를 실제로 더 많은 TODO가 있는 상태처럼 보강합니다.
    let summaryDigitCoverRect = mapScreenshotRect(
        x: 94,
        yTop: 456,
        width: 56,
        height: 96,
        sourceSize: sourceSize,
        targetRect: fittedRect
    )
    white.setFill()
    NSBezierPath(rect: summaryDigitCoverRect).fill()

    let summaryDigitRect = mapScreenshotRect(
        x: 94,
        yTop: 455,
        width: 56,
        height: 92,
        sourceSize: sourceSize,
        targetRect: fittedRect
    )
    drawText(
        "4",
        in: summaryDigitRect,
        font: .systemFont(ofSize: summaryDigitRect.height * 0.72, weight: .heavy),
        color: ink
    )

    let extraRows: [(title: String, yTop: CGFloat)] = [
        ("발표 자료 검토", 1610),
        ("장보기 메모 정리", 1888)
    ]

    for row in extraRows {
        let circleRect = mapScreenshotRect(
            x: 122,
            yTop: row.yTop + 10,
            width: 52,
            height: 52,
            sourceSize: sourceSize,
            targetRect: fittedRect
        )

        let circlePath = NSBezierPath(ovalIn: circleRect)
        circlePath.lineWidth = max(2, circleRect.width * 0.08)
        secondary.setStroke()
        circlePath.stroke()

        let titleRect = mapScreenshotRect(
            x: 218,
            yTop: row.yTop,
            width: 520,
            height: 60,
            sourceSize: sourceSize,
            targetRect: fittedRect
        )
        drawText(
            row.title,
            in: titleRect,
            font: .systemFont(ofSize: titleRect.height * 0.92, weight: .semibold),
            color: ink
        )

        let statusRect = mapScreenshotRect(
            x: 218,
            yTop: row.yTop + 64,
            width: 180,
            height: 36,
            sourceSize: sourceSize,
            targetRect: fittedRect
        )
        drawText(
            "진행 중",
            in: statusRect,
            font: .systemFont(ofSize: statusRect.height * 1.04, weight: .bold),
            color: accent
        )

        let editBubbleRect = mapScreenshotRect(
            x: 1088,
            yTop: row.yTop + 2,
            width: 110,
            height: 110,
            sourceSize: sourceSize,
            targetRect: fittedRect
        )
        fillCircle(editBubbleRect, color: blueFill)

        let editSymbolRect = editBubbleRect.insetBy(dx: editBubbleRect.width * 0.24, dy: editBubbleRect.height * 0.24)
        drawSystemSymbol(
            "square.and.pencil",
            in: editSymbolRect,
            color: blue,
            pointSize: editSymbolRect.height * 0.82,
            weight: .bold
        )
    }
}

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "AppStoreSubmissionImages", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG 인코딩 실패"])
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try png.write(to: url)
}

func drawBackground(size: SizeSpec, theme: ThemeSpec) {
    let fullRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
    let gradient = NSGradient(colors: [theme.top, theme.bottom])
    gradient?.draw(in: fullRect, angle: -90)

    fillCircle(
        NSRect(x: -size.width * 0.12, y: size.height * 0.66, width: size.width * 0.34, height: size.width * 0.34),
        color: theme.accent.withAlphaComponent(0.08)
    )
    fillCircle(
        NSRect(x: size.width * 0.72, y: size.height * 0.09, width: size.width * 0.34, height: size.width * 0.34),
        color: theme.accent.withAlphaComponent(0.08)
    )
    fillCircle(
        NSRect(x: size.width * 0.70, y: size.height * 0.77, width: size.width * 0.18, height: size.width * 0.18),
        color: NSColor.white.withAlphaComponent(0.45)
    )
}

func screenshotFrame(for size: SizeSpec, screenshotSize: NSSize, layout: SubmissionLayout) -> NSRect {
    let inset = size.width * 0.020
    let frameWidth = size.width * layout.frameWidthRatio
    let innerWidth = frameWidth - (inset * 2)
    let screenshotAspect = screenshotSize.height / screenshotSize.width
    let innerHeight = innerWidth * screenshotAspect
    let frameHeight = innerHeight + (inset * 2)

    return NSRect(
        x: (size.width - frameWidth) / 2.0,
        y: size.height * layout.frameBottomRatio,
        width: frameWidth,
        height: frameHeight
    )
}

for size in sizes {
    let inputFolder = inputRoot.appendingPathComponent(size.folder)
    let outputFolder = outputRoot.appendingPathComponent(size.folder)

    for index in 1...5 {
        let fileName = String(format: "screenshot-%02d.png", index)
        let inputURL = inputFolder.appendingPathComponent(fileName)
        let outputURL = outputFolder.appendingPathComponent(fileName)

        guard let screenshot = NSImage(contentsOf: inputURL) else {
            print("❌ missing screenshot: \(inputURL.path)")
            continue
        }

        let copy = copies[index - 1]
        let theme = themes[index - 1]
        guard let layout = submissionLayouts[size.folder]?[safe: index - 1] else {
            print("❌ missing layout: \(size.folder)/\(fileName)")
            continue
        }

        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            print("❌ bitmap init failed: \(size.folder)/\(fileName)")
            continue
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        drawBackground(size: size, theme: theme)

        let logoRect = NSRect(
            x: size.width * 0.08,
            y: size.height * 0.91,
            width: size.width * 0.18,
            height: size.height * 0.035
        )
        drawText(
            "TodoDo",
            in: logoRect,
            font: .systemFont(ofSize: size.width * 0.030 * layout.secondaryTextScale, weight: .heavy),
            color: theme.ink
        )

        let eyebrowRect = NSRect(
            x: size.width * 0.08,
            y: size.height * 0.83,
            width: size.width * 0.22,
            height: size.height * 0.03
        )
        drawText(
            copy.eyebrow.uppercased(),
            in: eyebrowRect,
            font: .systemFont(ofSize: size.width * 0.020 * layout.secondaryTextScale * ((size.folder == "iphone-6.9" || size.folder == "iphone-6.5" || size.folder == "iphone-5.5") ? 1.16 : 1.0), weight: .bold),
            color: theme.accent,
            lineBreak: .byTruncatingTail
        )

        let titleFontRatio: CGFloat = size.folder == "iphone-5.5" ? 0.073 : 0.078
        let titleRect = NSRect(
            x: size.width * 0.08,
            y: size.height * layout.titleYRatio,
            width: size.width * 0.72,
            height: size.height * 0.12
        )
        drawText(
            copy.title,
            in: titleRect,
            font: .systemFont(ofSize: size.width * titleFontRatio, weight: .black),
            color: theme.ink
        )

        let subtitleRect = NSRect(
            x: size.width * 0.08,
            y: size.height * layout.subtitleYRatio,
            width: size.width * 0.72,
            height: size.height * layout.subtitleHeightRatio
        )
        drawText(
            copy.subtitle,
            in: subtitleRect,
            font: .systemFont(ofSize: size.width * 0.029 * layout.secondaryTextScale, weight: .medium),
            color: theme.secondaryInk
        )

        let frameRect = screenshotFrame(for: size, screenshotSize: screenshot.size, layout: layout)
        let shadowRect = frameRect.offsetBy(dx: 0, dy: -size.height * 0.012)
        fillRounded(shadowRect, radius: size.width * 0.030, color: theme.ink.withAlphaComponent(0.12))

        fillRounded(
            frameRect,
            radius: size.width * 0.030,
            color: NSColor.white.withAlphaComponent(0.94),
            stroke: NSColor.white.withAlphaComponent(0.95),
            lineWidth: max(2, size.width * 0.002)
        )

        let screenshotInset = size.width * 0.020
        let screenshotRect = frameRect.insetBy(dx: screenshotInset, dy: screenshotInset)
        let fittedScreenshotRect = fitRect(sourceSize: screenshot.size, inside: screenshotRect)

        let screenshotClip = roundedRect(screenshotRect, radius: size.width * 0.024)
        NSGraphicsContext.saveGraphicsState()
        screenshotClip.addClip()
        screenshot.draw(
            in: fittedScreenshotRect,
            from: NSRect(origin: .zero, size: screenshot.size),
            operation: .copy,
            fraction: 1.0
        )

        if size.folder == "iphone-6.9", index == 1 {
            drawEnhancedMainScreenshot(
                sourceSize: screenshot.size,
                fittedRect: fittedScreenshotRect
            )
        }
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.restoreGraphicsState()

        do {
            try writePNG(bitmap, to: outputURL)
            print("✅ \(size.folder)/\(fileName)")
        } catch {
            print("❌ write failed: \(outputURL.path) \(error.localizedDescription)")
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
