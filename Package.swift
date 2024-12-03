// swift-tools-version:5.9
import PackageDescription


let package = Package(
    name: "DeliverSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DeliverSDK",
            type: .dynamic,
            targets: ["DeliverSDK"]
        )
    ],

    targets: [
        .target(
            name: "DeliverSDK",
            path: "DeliverSDK",
            resources: [
                .process("core/resources/fonts"),
                .process("core/Deliver.xcassets"),
            ]
        )
    ]
)

