// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
   name: "Dependencies",
   platforms: [
      .macOS(.v10_15),
      .iOS(.v13),
      .tvOS(.v13),
      .watchOS(.v6)
   ],
   products: [
      // Products define the executables and libraries produced by a package, and make them visible to other packages.
      .library(
         name: "Dependencies",
         targets: [
            "Dependencies"
         ]
      ),
   ],
   dependencies: [
      .package(url: "git@github.com:tcldr/Entwine.git", from: "0.9.0")
   ],
   targets: [
      // Targets are the basic building blocks of a package. A target can define a module or a test suite.
      // Targets can depend on other targets in this package, and on products in packages which this package depends on.
      .target(
         name: "Dependencies",
         dependencies: [
            "Catcher"
         ],
         path: "Sources/Core"
      ),
      .testTarget(
         name: "DependenciesTests",
         dependencies: [
            "Dependencies",
            "Entwine"
         ]
      ),
      .catcher,
      .catcherObjc
   ]
)

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
