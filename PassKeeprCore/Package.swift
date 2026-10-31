// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PassKeeprCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "PassKeeprCore", targets: ["PassKeeprCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19"),
    ],
    targets: [
        .target(
            name: "PassKeeprCore",
            dependencies: ["ZIPFoundation"],
            path: "Sources",
            resources: [.copy("Resources/DefaultPassIcon.png")],
            swiftSettings: [.enableUpcomingFeature("BareSlashRegexLiterals")]
        ),
        .testTarget(
            name: "PassKeeprCoreTests",
            dependencies: ["PassKeeprCore"],
            path: "Tests"
        ),
    ]
)
