// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BookTrackerSupabase",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "BookTrackerSupabase",
            targets: ["App"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "Sources/App",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
