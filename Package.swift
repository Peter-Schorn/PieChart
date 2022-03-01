// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PieChart",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PieChart",
            targets: ["PieChart"]
        ),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "PieChart",
            dependencies: []
        ),
        .testTarget(
            name: "PieChartTests",
            dependencies: ["PieChart"]
        ),
    ]
)
