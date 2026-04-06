// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoDo",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "TodoDo", targets: ["TodoDo"])
    ],
    targets: [
        .target(
            name: "TodoDo",
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
