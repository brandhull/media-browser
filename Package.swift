// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Bro",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Bro",
            path: "Sources/Bro"
        )
    ]
)
