// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StudyTodoApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "StudyTodoApp", targets: ["StudyTodoApp"])
    ],
    targets: [
        .target(
            name: "StudyTodoApp",
            path: "StudyTodoApp",
            exclude: ["Assets.xcassets", "README.md", "Docs", "Supporting"]
        ),
        .testTarget(
            name: "StudyTodoAppTests",
            dependencies: ["StudyTodoApp"],
            path: "StudyTodoAppTests"
        )
    ]
)
