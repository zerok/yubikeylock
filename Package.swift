// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "yubikeylock",
    products: [
        .executable(name: "yubikeylock",
            targets: ["yubikeylock"]),
    ],
    targets: [
        .target(name: "yubikeylock",
            dependencies: []),
    ]
)
