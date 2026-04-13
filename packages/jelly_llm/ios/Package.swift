// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "jelly_llm",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "jelly-llm",
            targets: ["jelly_llm"]
        ),
    ],
    dependencies: [
        .package(path: "InferenceKit"),
    ],
    targets: [
        .target(
            name: "jelly_llm",
            dependencies: [
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXVLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ],
            path: "Classes"
        ),
    ]
)
