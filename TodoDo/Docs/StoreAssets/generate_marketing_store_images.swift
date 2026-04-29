import AppKit

/// TodoDo App Store 소개 이미지를 생성합니다.
/// 6.9 기준으로 촬영된 원본 스크린샷을 각 규격별 원본 위에 배치해
/// App Store 제출용 마케팅 이미지를 만듭니다.

struct SizeSpec {
    /// 출력 폴더명입니다.
    let folder: String
    /// 캔버스 가로 크기(px)입니다.
    let width: CGFloat
    /// 캔버스 세로 크기(px)입니다.
    let height: CGFloat
}

struct CopySpec {
    /// 상단 번호입니다.
    let index: String
    /// 메인 헤드라인입니다.
    let title: String
    /// 설명 문구입니다.
    let subtitle: String
    /// 좌측 기능 칩 문구입니다.
    let chip1: String
    /// 우측 기능 칩 문구입니다.
    let chip2: String
}

struct ThemeSpec {
    /// 메인 배경 상단 색입니다.
    let top: NSColor
    /// 메인 배경 하단 색입니다.
    let bottom: NSColor
    /// 강조 포인트 색입니다.
    let accent: NSColor
    /// 보조 도형 색입니다.
    let softAccent: NSColor
    /// 텍스트/프레임에 사용할 진한 색입니다.
    let ink: NSColor
}

struct LayoutSpec {
    /// 큰 번호의 Y 기준 비율입니다.
    let indexYRatio: CGFloat
    /// 타이틀의 Y 기준 비율입니다.
    let titleYRatio: CGFloat
    /// 타이틀 높이 비율입니다.
    let titleHeightRatio: CGFloat
    /// 타이틀 폭 비율입니다.
    let titleWidthRatio: CGFloat
    /// 타이틀 폰트 크기 비율입니다.
    let titleFontRatio: CGFloat
    /// 설명문과 타이틀 사이 간격 비율입니다.
    let subtitleGapRatio: CGFloat
    /// 설명문 높이 비율입니다.
    let subtitleHeightRatio: CGFloat
    /// 설명문 폰트 크기 비율입니다.
    let subtitleFontRatio: CGFloat
    /// 칩과 설명문 사이 간격 비율입니다.
    let chipGapRatio: CGFloat
    /// 칩 높이 비율입니다.
    let chipHeightRatio: CGFloat
    /// 칩 폭 비율입니다.
    let chipWidthRatio: CGFloat
    /// 칩 시작 X 추가 오프셋 비율입니다.
    let chipOffsetXRatio: CGFloat
    /// 목업 프레임 폭 비율입니다.
    let phoneWidthRatio: CGFloat
    /// 목업 하단 여백 비율입니다.
    let phoneBottomRatio: CGFloat
    /// 목업 중심 X 오프셋 비율입니다.
    let phoneCenterOffsetRatio: CGFloat
}

let root = URL(fileURLWithPath: "/Users/kimkyeongbeom/Desktop/testprjt/TodoDo/Docs/StoreAssets")
let inputRoot = root.appendingPathComponent("output_raw")
let outputRoot = root.appendingPathComponent("output")

let sizes: [SizeSpec] = [
    .init(folder: "iphone-6.9", width: 1320, height: 2868),
    .init(folder: "iphone-6.5", width: 1242, height: 2688),
    .init(folder: "iphone-5.5", width: 1242, height: 2208)
]

let copies: [CopySpec] = [
    .init(
        index: "01",
        title: "오늘 해야 할 일에\n가볍게 집중하세요",
        subtitle: "진행 중인 할 일만 깔끔하게 정리하고,\n중요한 작업부터 빠르게 처리할 수 있어요.",
        chip1: "집중 리스트",
        chip2: "간편 체크"
    ),
    .init(
        index: "02",
        title: "할 일을\n빠르게 추가하세요",
        subtitle: "팝업 한 장에서 제목, 마감일, 알림까지 입력해\n기록 흐름을 끊지 않고 바로 저장할 수 있어요.",
        chip1: "빠른 입력",
        chip2: "알림 설정"
    ),
    .init(
        index: "03",
        title: "변경된 계획도\n즉시 반영하세요",
        subtitle: "상황이 바뀌면 바로 수정하고,\n항상 최신 일정 상태를 유지할 수 있어요.",
        chip1: "즉시 편집",
        chip2: "마감 반영"
    ),
    .init(
        index: "04",
        title: "완료한 일은\n따로 모아보세요",
        subtitle: "완료 목록에서 기록을 다시 확인하고,\n필요하면 진행 중으로 자연스럽게 되돌릴 수 있어요.",
        chip1: "완료 아카이브",
        chip2: "다시 진행"
    ),
    .init(
        index: "05",
        title: "확인 흐름도\n부담 없이 제어하세요",
        subtitle: "상태 변경 전 확인 팝업으로 실수를 줄이고,\n원하는 작업 흐름에 맞게 앱을 사용할 수 있어요.",
        chip1: "확인 팝업",
        chip2: "흐름 제어"
    )
]

let themes: [ThemeSpec] = [
    .init(
        top: rgb(249, 252, 255),
        bottom: rgb(235, 244, 255),
        accent: rgb(47, 118, 255),
        softAccent: rgb(189, 219, 255),
        ink: rgb(23, 32, 50)
    ),
    .init(
        top: rgb(251, 248, 255),
        bottom: rgb(240, 233, 255),
        accent: rgb(123, 87, 255),
        softAccent: rgb(214, 195, 255),
        ink: rgb(33, 28, 58)
    ),
    .init(
        top: rgb(255, 250, 244),
        bottom: rgb(255, 238, 220),
        accent: rgb(240, 139, 45),
        softAccent: rgb(255, 213, 170),
        ink: rgb(46, 33, 25)
    ),
    .init(
        top: rgb(246, 253, 246),
        bottom: rgb(229, 245, 231),
        accent: rgb(56, 164, 92),
        softAccent: rgb(189, 232, 199),
        ink: rgb(25, 44, 31)
    ),
    .init(
        top: rgb(247, 249, 254),
        bottom: rgb(232, 237, 249),
        accent: rgb(71, 102, 161),
        softAccent: rgb(197, 210, 237),
        ink: rgb(24, 34, 55)
    )
]

let layoutSpecs: [String: [LayoutSpec]] = [
    "iphone-6.9": [
        .init(indexYRatio: 0.79, titleYRatio: 0.64, titleHeightRatio: 0.145, titleWidthRatio: 0.60, titleFontRatio: 0.079, subtitleGapRatio: 0.046, subtitleHeightRatio: 0.066, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.042, chipWidthRatio: 0.180, chipOffsetXRatio: 0.02, phoneWidthRatio: 0.505, phoneBottomRatio: 0.036, phoneCenterOffsetRatio: 0.0),
        .init(indexYRatio: 0.79, titleYRatio: 0.64, titleHeightRatio: 0.145, titleWidthRatio: 0.55, titleFontRatio: 0.079, subtitleGapRatio: 0.043, subtitleHeightRatio: 0.068, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.042, chipWidthRatio: 0.215, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.55, phoneBottomRatio: 0.052, phoneCenterOffsetRatio: 0.07),
        .init(indexYRatio: 0.79, titleYRatio: 0.64, titleHeightRatio: 0.145, titleWidthRatio: 0.57, titleFontRatio: 0.077, subtitleGapRatio: 0.044, subtitleHeightRatio: 0.068, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.042, chipWidthRatio: 0.215, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.55, phoneBottomRatio: 0.052, phoneCenterOffsetRatio: 0.07),
        .init(indexYRatio: 0.79, titleYRatio: 0.64, titleHeightRatio: 0.145, titleWidthRatio: 0.56, titleFontRatio: 0.078, subtitleGapRatio: 0.044, subtitleHeightRatio: 0.070, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.042, chipWidthRatio: 0.215, chipOffsetXRatio: 0.03, phoneWidthRatio: 0.54, phoneBottomRatio: 0.050, phoneCenterOffsetRatio: 0.08),
        .init(indexYRatio: 0.79, titleYRatio: 0.64, titleHeightRatio: 0.160, titleWidthRatio: 0.50, titleFontRatio: 0.074, subtitleGapRatio: 0.038, subtitleHeightRatio: 0.066, subtitleFontRatio: 0.030, chipGapRatio: 0.010, chipHeightRatio: 0.042, chipWidthRatio: 0.215, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.55, phoneBottomRatio: 0.052, phoneCenterOffsetRatio: 0.07)
    ],
    "iphone-6.5": [
        .init(indexYRatio: 0.79, titleYRatio: 0.635, titleHeightRatio: 0.148, titleWidthRatio: 0.60, titleFontRatio: 0.080, subtitleGapRatio: 0.046, subtitleHeightRatio: 0.070, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.043, chipWidthRatio: 0.220, chipOffsetXRatio: 0.03, phoneWidthRatio: 0.55, phoneBottomRatio: 0.050, phoneCenterOffsetRatio: 0.08),
        .init(indexYRatio: 0.79, titleYRatio: 0.635, titleHeightRatio: 0.148, titleWidthRatio: 0.55, titleFontRatio: 0.080, subtitleGapRatio: 0.042, subtitleHeightRatio: 0.072, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.043, chipWidthRatio: 0.220, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.56, phoneBottomRatio: 0.052, phoneCenterOffsetRatio: 0.07),
        .init(indexYRatio: 0.79, titleYRatio: 0.635, titleHeightRatio: 0.148, titleWidthRatio: 0.57, titleFontRatio: 0.078, subtitleGapRatio: 0.043, subtitleHeightRatio: 0.072, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.043, chipWidthRatio: 0.220, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.56, phoneBottomRatio: 0.052, phoneCenterOffsetRatio: 0.07),
        .init(indexYRatio: 0.79, titleYRatio: 0.635, titleHeightRatio: 0.148, titleWidthRatio: 0.56, titleFontRatio: 0.079, subtitleGapRatio: 0.043, subtitleHeightRatio: 0.074, subtitleFontRatio: 0.031, chipGapRatio: 0.010, chipHeightRatio: 0.043, chipWidthRatio: 0.220, chipOffsetXRatio: 0.03, phoneWidthRatio: 0.55, phoneBottomRatio: 0.050, phoneCenterOffsetRatio: 0.08),
        .init(indexYRatio: 0.79, titleYRatio: 0.635, titleHeightRatio: 0.164, titleWidthRatio: 0.50, titleFontRatio: 0.075, subtitleGapRatio: 0.037, subtitleHeightRatio: 0.069, subtitleFontRatio: 0.030, chipGapRatio: 0.010, chipHeightRatio: 0.043, chipWidthRatio: 0.220, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.56, phoneBottomRatio: 0.052, phoneCenterOffsetRatio: 0.07)
    ],
    "iphone-5.5": [
        .init(indexYRatio: 0.785, titleYRatio: 0.625, titleHeightRatio: 0.150, titleWidthRatio: 0.61, titleFontRatio: 0.075, subtitleGapRatio: 0.048, subtitleHeightRatio: 0.076, subtitleFontRatio: 0.031, chipGapRatio: 0.011, chipHeightRatio: 0.046, chipWidthRatio: 0.225, chipOffsetXRatio: 0.03, phoneWidthRatio: 0.57, phoneBottomRatio: 0.046, phoneCenterOffsetRatio: 0.07),
        .init(indexYRatio: 0.785, titleYRatio: 0.625, titleHeightRatio: 0.150, titleWidthRatio: 0.57, titleFontRatio: 0.075, subtitleGapRatio: 0.044, subtitleHeightRatio: 0.078, subtitleFontRatio: 0.031, chipGapRatio: 0.011, chipHeightRatio: 0.046, chipWidthRatio: 0.225, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.58, phoneBottomRatio: 0.048, phoneCenterOffsetRatio: 0.06),
        .init(indexYRatio: 0.785, titleYRatio: 0.625, titleHeightRatio: 0.150, titleWidthRatio: 0.59, titleFontRatio: 0.074, subtitleGapRatio: 0.045, subtitleHeightRatio: 0.078, subtitleFontRatio: 0.031, chipGapRatio: 0.011, chipHeightRatio: 0.046, chipWidthRatio: 0.225, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.58, phoneBottomRatio: 0.048, phoneCenterOffsetRatio: 0.06),
        .init(indexYRatio: 0.785, titleYRatio: 0.625, titleHeightRatio: 0.150, titleWidthRatio: 0.58, titleFontRatio: 0.074, subtitleGapRatio: 0.045, subtitleHeightRatio: 0.082, subtitleFontRatio: 0.031, chipGapRatio: 0.011, chipHeightRatio: 0.046, chipWidthRatio: 0.225, chipOffsetXRatio: 0.03, phoneWidthRatio: 0.57, phoneBottomRatio: 0.046, phoneCenterOffsetRatio: 0.07),
        .init(indexYRatio: 0.785, titleYRatio: 0.625, titleHeightRatio: 0.172, titleWidthRatio: 0.52, titleFontRatio: 0.070, subtitleGapRatio: 0.040, subtitleHeightRatio: 0.076, subtitleFontRatio: 0.030, chipGapRatio: 0.011, chipHeightRatio: 0.046, chipWidthRatio: 0.225, chipOffsetXRatio: 0.04, phoneWidthRatio: 0.58, phoneBottomRatio: 0.048, phoneCenterOffsetRatio: 0.06)
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
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    style.lineBreakMode = lineBreak

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style
    ]

    NSString(string: text).draw(
        with: rect,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes
    )
}

func drawCenteredText(
    _ text: String,
    in rect: NSRect,
    font: NSFont,
    color: NSColor,
    alignment: NSTextAlignment = .center,
    lineBreak: NSLineBreakMode = .byTruncatingTail
) {
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    style.lineBreakMode = lineBreak

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style
    ]

    let attributed = NSAttributedString(string: text, attributes: attributes)
    let bounds = attributed.boundingRect(
        with: NSSize(width: rect.width, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )

    let drawRect = NSRect(
        x: rect.minX,
        y: rect.midY - bounds.height / 2.0,
        width: rect.width,
        height: bounds.height + 2
    )

    attributed.draw(
        with: drawRect,
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
}

func fitRect(sourceSize: NSSize, inside target: NSRect) -> NSRect {
    let scale = min(target.width / sourceSize.width, target.height / sourceSize.height)
    let width = sourceSize.width * scale
    let height = sourceSize.height * scale

    return NSRect(
        x: target.midX - width / 2.0,
        y: target.midY - height / 2.0,
        width: width,
        height: height
    )
}

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(
            domain: "StoreAssets",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "PNG 인코딩에 실패했습니다."]
        )
    }

    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try png.write(to: url)
}

func drawBackground(size: SizeSpec, theme: ThemeSpec) {
    let rect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
    let gradient = NSGradient(colors: [theme.top, theme.bottom])
    gradient?.draw(in: rect, angle: -90)

    fillCircle(
        NSRect(
            x: -size.width * 0.16,
            y: size.height * 0.59,
            width: size.width * 0.44,
            height: size.width * 0.44
        ),
        color: theme.softAccent.withAlphaComponent(0.22)
    )

    fillCircle(
        NSRect(
            x: size.width * 0.69,
            y: size.height * 0.77,
            width: size.width * 0.22,
            height: size.width * 0.22
        ),
        color: NSColor.white.withAlphaComponent(0.40)
    )

    fillCircle(
        NSRect(
            x: size.width * 0.73,
            y: size.height * 0.48,
            width: size.width * 0.34,
            height: size.width * 0.34
        ),
        color: theme.accent.withAlphaComponent(0.09)
    )

    fillCircle(
        NSRect(
            x: -size.width * 0.08,
            y: -size.height * 0.03,
            width: size.width * 0.28,
            height: size.width * 0.28
        ),
        color: NSColor.white.withAlphaComponent(0.22)
    )
}

func drawTopBadge(size: SizeSpec, theme: ThemeSpec) {
    let badgeRect = NSRect(
        x: size.width * 0.08,
        y: size.height * 0.91,
        width: size.width * 0.84,
        height: size.height * 0.048
    )

    fillRounded(
        badgeRect,
        radius: badgeRect.height / 2.0,
        color: NSColor.white.withAlphaComponent(0.72),
        stroke: NSColor.white.withAlphaComponent(0.55),
        lineWidth: max(1, size.width * 0.0016)
    )

    drawCenteredText(
        "TodoDo",
        in: NSRect(
            x: badgeRect.minX + size.width * 0.03,
            y: badgeRect.minY,
            width: size.width * 0.22,
            height: badgeRect.height
        ),
        font: .systemFont(ofSize: size.width * 0.032, weight: .heavy),
        color: theme.ink,
        alignment: .left
    )

    drawCenteredText(
        "Plan • Focus • Done",
        in: NSRect(
            x: badgeRect.maxX - size.width * 0.34,
            y: badgeRect.minY,
            width: size.width * 0.30,
            height: badgeRect.height
        ),
        font: .systemFont(ofSize: size.width * 0.020, weight: .semibold),
        color: theme.ink.withAlphaComponent(0.58),
        alignment: .right
    )
}

func drawHeroText(size: SizeSpec, copy: CopySpec, theme: ThemeSpec, layout: LayoutSpec) -> (subtitleBottom: CGFloat, chipStartX: CGFloat) {
    let leftX = size.width * 0.08
    let titleWidth = size.width * layout.titleWidthRatio

    drawText(
        copy.index,
        in: NSRect(
            x: leftX,
            y: size.height * layout.indexYRatio,
            width: size.width * 0.18,
            height: size.height * 0.06
        ),
        font: .systemFont(ofSize: size.width * 0.070, weight: .bold),
        color: theme.accent
    )

    let titleRect = NSRect(
        x: leftX,
        y: size.height * layout.titleYRatio,
        width: titleWidth,
        height: size.height * layout.titleHeightRatio
    )
    drawText(
        copy.title,
        in: titleRect,
        font: .systemFont(ofSize: size.width * layout.titleFontRatio, weight: .black),
        color: theme.ink
    )

    let subtitleRect = NSRect(
        x: leftX,
        y: titleRect.minY - size.height * layout.subtitleGapRatio,
        width: titleWidth,
        height: size.height * layout.subtitleHeightRatio
    )
    drawText(
        copy.subtitle,
        in: subtitleRect,
        font: .systemFont(ofSize: size.width * layout.subtitleFontRatio, weight: .medium),
        color: theme.ink.withAlphaComponent(0.74)
    )

    return (subtitleRect.minY, leftX)
}

func drawChips(size: SizeSpec, copy: CopySpec, theme: ThemeSpec, layout: LayoutSpec, topY: CGFloat, leftX: CGFloat) {
    let chipHeight = size.height * layout.chipHeightRatio
    let chipGap = size.width * 0.022
    let chipWidth = size.width * layout.chipWidthRatio
    var chipY = topY - chipHeight - size.height * layout.chipGapRatio
    let chipStartX = leftX + size.width * layout.chipOffsetXRatio
    var chip1Rect = NSRect(x: chipStartX, y: chipY, width: chipWidth, height: chipHeight)
    var chip2Rect = NSRect(x: chip1Rect.maxX + chipGap, y: chipY, width: chipWidth, height: chipHeight)

    // 첫 번째 6.9 소개 이미지는 예시처럼 칩을 폰 하단 좌우로 분리 배치합니다.
    if size.folder == "iphone-6.9", copy.index == "01" {
        chipY = 100
        let expandedChipWidth = chipWidth * 1.18
        let expandedChipHeight = chipHeight * 1.08
        chip1Rect = NSRect(
            x: size.width * 0.09,
            y: chipY,
            width: expandedChipWidth,
            height: expandedChipHeight
        )
        chip2Rect = NSRect(
            x: size.width - (size.width * 0.09) - expandedChipWidth,
            y: chipY,
            width: expandedChipWidth,
            height: expandedChipHeight
        )
    }

    fillRounded(
        chip1Rect,
        radius: chipHeight / 2.0,
        color: NSColor.white.withAlphaComponent(0.82),
        stroke: NSColor.white.withAlphaComponent(0.68),
        lineWidth: max(1, size.width * 0.0015)
    )
    fillRounded(
        chip2Rect,
        radius: chipHeight / 2.0,
        color: NSColor.white.withAlphaComponent(0.82),
        stroke: NSColor.white.withAlphaComponent(0.68),
        lineWidth: max(1, size.width * 0.0015)
    )

    drawCenteredText(
        copy.chip1,
        in: chip1Rect.insetBy(dx: size.width * 0.02, dy: 0),
        font: .systemFont(ofSize: size.width * 0.026, weight: .semibold),
        color: theme.ink
    )
    drawCenteredText(
        copy.chip2,
        in: chip2Rect.insetBy(dx: size.width * 0.02, dy: 0),
        font: .systemFont(ofSize: size.width * 0.026, weight: .semibold),
        color: theme.ink
    )
}

func shouldDrawChipsAbovePhone(size: SizeSpec, copy: CopySpec) -> Bool {
    size.folder == "iphone-6.9" && copy.index == "01"
}

func drawPhone(size: SizeSpec, screenshot: NSImage, theme: ThemeSpec, layout: LayoutSpec) {
    let frameWidth = size.width * layout.phoneWidthRatio
    let sourceAspect = screenshot.size.height / screenshot.size.width
    let frameHeight = frameWidth * sourceAspect
    let frame = NSRect(
        x: ((size.width - frameWidth) / 2.0) + size.width * layout.phoneCenterOffsetRatio,
        y: size.height * layout.phoneBottomRatio,
        width: frameWidth,
        height: frameHeight
    )

    let shadowRect = frame.offsetBy(dx: 0, dy: -size.height * 0.010)
    fillRounded(
        shadowRect,
        radius: frame.width * 0.085,
        color: theme.ink.withAlphaComponent(0.15)
    )

    fillRounded(
        frame,
        radius: frame.width * 0.085,
        color: NSColor.white,
        stroke: NSColor.white.withAlphaComponent(0.88),
        lineWidth: max(2, size.width * 0.0022)
    )

    let bezel = frame.width * 0.014
    let screenRect = frame.insetBy(dx: bezel, dy: bezel)
    let screenPath = roundedRect(screenRect, radius: screenRect.width * 0.070)

    NSGraphicsContext.saveGraphicsState()
    screenPath.addClip()

    let fitted = fitRect(sourceSize: screenshot.size, inside: screenRect)
    screenshot.draw(
        in: fitted,
        from: NSRect(origin: .zero, size: screenshot.size),
        operation: .copy,
        fraction: 1.0
    )

    NSGraphicsContext.restoreGraphicsState()

    let glareRect = NSRect(
        x: frame.minX + frame.width * 0.03,
        y: frame.minY + frame.height * 0.52,
        width: frame.width * 0.10,
        height: frame.height * 0.38
    )

    let glarePath = NSBezierPath()
    glarePath.move(to: NSPoint(x: glareRect.minX, y: glareRect.minY))
    glarePath.curve(
        to: NSPoint(x: glareRect.maxX, y: glareRect.maxY),
        controlPoint1: NSPoint(x: glareRect.minX + glareRect.width * 0.25, y: glareRect.minY + glareRect.height * 0.30),
        controlPoint2: NSPoint(x: glareRect.maxX - glareRect.width * 0.20, y: glareRect.maxY - glareRect.height * 0.20)
    )
    glarePath.lineWidth = max(8, size.width * 0.010)
    NSColor.white.withAlphaComponent(0.18).setStroke()
    glarePath.stroke()
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

        let copy = copies[index - 1]
        let theme = themes[index - 1]
        guard let layout = layoutSpecs[size.folder]?[safe: index - 1] else {
            print("❌ missing layout: \(size.folder)/\(fileName)")
            continue
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        drawBackground(size: size, theme: theme)
        drawTopBadge(size: size, theme: theme)

        let heroLayout = drawHeroText(size: size, copy: copy, theme: theme, layout: layout)
        let drawChipsAbovePhone = shouldDrawChipsAbovePhone(size: size, copy: copy)

        if drawChipsAbovePhone == false {
            drawChips(
                size: size,
                copy: copy,
                theme: theme,
                layout: layout,
                topY: heroLayout.subtitleBottom,
                leftX: heroLayout.chipStartX
            )
        }

        drawPhone(size: size, screenshot: screenshot, theme: theme, layout: layout)

        if drawChipsAbovePhone {
            drawChips(
                size: size,
                copy: copy,
                theme: theme,
                layout: layout,
                topY: heroLayout.subtitleBottom,
                leftX: heroLayout.chipStartX
            )
        }

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
