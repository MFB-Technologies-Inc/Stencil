// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Stencil",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15), .macCatalyst(.v15), .visionOS(.v1)],
    products: [
        .library(name: "Stencil", targets: ["Stencil"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MFB-Technologies-Inc/PathKit.git", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "Stencil",
            dependencies: [
                "PathKit",
            ],
            swiftSettings: .shared
        ),
        .testTarget(
            name: "StencilTests",
            dependencies: [
                "Stencil",
            ],
            swiftSettings: .shared
        ),
    ]
)

extension [SwiftSetting] {
    static let shared: [SwiftSetting] = [
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("ForwardTrailingClosures"),
        .enableUpcomingFeature("ImplicitOpenExistentials"),
        .enableExperimentalFeature("StrictConcurrency"),
        .enableUpcomingFeature("DisableOutwardActorInference"),
    ]
}
