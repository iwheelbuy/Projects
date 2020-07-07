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
         name: "Nice",
         targets: [
            "DependenciesCore"
         ]
      ),
//      .library(
//         name: "Test",
//         targets: [
//            "DependenciesTests",
//            "EntwineTest"
//         ]
//      ),
   ],
   dependencies: [
      .package(url: "git@github.com:sergdort/CombineFeedback.git", from: "0.7.0"),
      .package(url: "git@github.com:tcldr/Entwine.git", from: "0.9.0"),
   ],
   targets: [
      .catcher,
      .catcherObjc,
      .core,
      .dependenciesCore,
      .dependenciesTest,
      .test,
      .testsPublishers
   ]
)

// MARK: - Dependencies

extension PackageDescription.Target {

   static var catcher: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "Catcher",
         dependencies: [
            "CatcherObjc"
         ],
         path: "Sources/Catcher",
         sources: [
            "Classes+Safely.swift"
         ]
      )
   }

   static var catcherObjc: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "CatcherObjc",
         path: "Sources/Catcher",
         sources: [
            "Classes+Safely.h",
            "Classes+Safely.m"
         ],
         publicHeadersPath: ""
      )
   }

   static var core: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "Core",
         dependencies: [
            "Catcher"
         ],
         path: "Sources/Core"
      )
   }

   static var dependenciesCore: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "DependenciesCore",
         dependencies: [
            "Core",
            "Catcher"
         ],
         path: "Sources/Dependencies",
         sources: [
            "Dependencies+Core.swift"
         ]
      )
   }

   static var dependenciesTest: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "DependenciesTest",
         dependencies: [
            "Test"
         ],
         path: "Sources/Dependencies",
         sources: [
            "Dependencies+Test.swift"
         ]
      )
   }

   static var test: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "Test",
         dependencies: [
            .product(name: "EntwineTest", package: "Entwine")
         ],
         path: "Sources/Test"
      )
   }

   static var testsPublishers: PackageDescription.Target {
      return PackageDescription.Target.testTarget(
         name: "TestsPublishers",
         dependencies: [
            "DependenciesTest"
         ],
         path: "Tests/Publishers"
      )
   }
}
