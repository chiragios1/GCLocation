// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GCLocation",
    platforms: [
        .iOS("15.5"),
        
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GCLocation",
            targets: ["GCLocation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.0"),
        
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.0"),
       
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.0.0"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.1.0")
        

       
       
        


        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GCLocation",
            dependencies: [.product(name: "Alamofire", package: "Alamofire"),
                           .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                           .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                           .product(name: "Reachability", package: "Reachability.swift"),
                           .product(name: "ZipArchive", package: "ZipArchive")
                           
                           
            ], path: "Sources"),
        .testTarget(
            name: "GCLocationTests",
            dependencies: ["GCLocation"]),
    ]
)
