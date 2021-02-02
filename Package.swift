// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "URLSessionMock",
    products: [
        .library(name: "URLSessionMock", targets: ["URLSessionMock"]),
    ],
    targets: [
        .target(name: "URLSessionMock"),
    ]
)
