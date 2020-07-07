// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
   name: "Dependencies",
   platforms: [
      .iOS(.v13),
   ],
   products: [
      .library(
         name: "Dependencies",
         targets: [
            "Dependencies"
         ]
      ),
   ],
   dependencies: [
      .package(url: "git@github.com:sergdort/CombineFeedback.git", from: "0.7.0"),
      .package(url: "git@github.com:tcldr/Entwine.git", from: "0.9.0"),
   ],
   targets: [
      .target(
         name: "Dependencies",
         dependencies: [
            "Catcher",
         ],
         path: "Sources/Core"
      ),
      .testTarget(
         name: "DependenciesTests",
         dependencies: [
            "Dependencies",
            .product(name: "EntwineTest", package: "Entwine")
         ],
         path: "Tests"
      ),
      .catcher,
      .catcherObjc
   ]
)

// MARK: - Catcher

extension PackageDescription.Target {

   static var catcher: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "Catcher",
         dependencies: [
            "CatcherObjc"
         ],
         path: "Sources/Catcher",
         exclude: [
            "Classes+Safely.h",
            "Classes+Safely.m"
         ]
      )
   }

   static var catcherObjc: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "CatcherObjc",
         dependencies: [
         ],
         path: "Sources/Catcher",
         exclude: [
            "Classes+Safely.swift"
         ],
         publicHeadersPath: ""
      )
   }
}
