// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoDo",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        // Google AdMob(iOS) SDK를 Swift Package Manager로 가져옵니다.
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            from: "13.0.0"
        )
    ],
    products: [
        .library(name: "TodoDo", targets: ["TodoDo"])
    ],
    targets: [
        .target(
            name: "TodoDo",
            dependencies: [
                // 메인 앱의 배너 광고 표시 기능에서 사용합니다.
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "TodoDo",
            exclude: ["Assets.xcassets", "README.md", "Docs", "Supporting"]
        ),
        .testTarget(
            name: "TodoDoTests",
            dependencies: ["TodoDo"],
            path: "TodoDoTests"
        )
    ]
)
