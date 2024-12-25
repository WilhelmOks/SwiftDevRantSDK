// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDevRant",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6), .driverKit(.v19), .macCatalyst(.v13), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftDevRant",
            targets: ["SwiftDevRant"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/WilhelmOks/KreeRequest", .upToNextMajor(from: "2.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftDevRant",
            dependencies: ["KreeRequest"]
        ),
        .testTarget(
            name: "SwiftDevRantTests",
            dependencies: ["SwiftDevRant"]
        ),
    ]
)
