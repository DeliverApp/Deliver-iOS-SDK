// swift-tools-version:5.9
import PackageDescription


let package = Package(
    name: "DeliverSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "DeliverSDK",
            targets: ["DeliverSDK"]
        )
    ],
    targets: [
        .binaryTarget(name: "DeliverSDK", path: "./DeliverSDK.xcframework")
    ]
)
