// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FixiGo",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FixiGo",
            targets: ["FixiGo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "FixiGo",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ]),
        .testTarget(
            name: "FixiGoTests",
            dependencies: ["FixiGo"]),
    ]
) 