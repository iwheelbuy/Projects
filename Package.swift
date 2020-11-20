// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
   name: "Dependencies",
   platforms: [
      .iOS(.v13)
   ],
   products: [
      .library(
         name: "OhWhatAnApp",
         targets: [
            "Dependencies",
            "DependenciesTest"
         ]
      )
   ],
   dependencies: [
      .package(
         url: "git@github.com:sergdort/CombineFeedback.git",
         from: "0.7.0"
      ),
      .package(
         name: "Entwine",
         url: "git@github.com:tcldr/Entwine.git",
         from: "0.9.1"
      ),
      .package(
         url: "git@github.com:mattgallagher/CwlPreconditionTesting.git",
         from: "2.0.0"
      ),
      .package(
         name: "Firebase",
         url: "https://github.com/firebase/firebase-ios-sdk.git",
         from: "7.1.0"
      )
   ],
   targets: [
      .catcher,
      .catcherObjc,
      .core,
      .dependenciesCore,
      .dependenciesTest,
      .test,
      .combineTests,
      .generalTests,
      .textus
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
            "Catcher",
            "Textus",
            .product(name: "FirebaseAuth", package: "Firebase"),
            .product(name: "FirebaseCrashlytics", package: "Firebase"),
            .product(name: "FirebaseFirestore", package: "Firebase"),
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
            "Core",
            "Test"
         ],
         path: "Sources/Dependencies",
         sources: [
            "Dependencies+Test.swift"
         ]
      )
   }

   static var textus: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "Textus",
         dependencies: [
            "Core"
         ],
         path: "Sources/Textus"
      )
   }

   static var test: PackageDescription.Target {
      return PackageDescription.Target.target(
         name: "Test",
         dependencies: [
            "CwlPreconditionTesting",
            .product(name: "EntwineTest", package: "Entwine")
         ],
         path: "Sources/Test"
      )
   }

   static var combineTests: PackageDescription.Target {
      return PackageDescription.Target.testTarget(
         name: "CombineTests",
         dependencies: [
            "DependenciesTest"
         ],
         path: "Tests/Combine"
      )
   }

   static var generalTests: PackageDescription.Target {
      return PackageDescription.Target.testTarget(
         name: "GeneralTests",
         dependencies: [
            "DependenciesTest"
         ],
         path: "Tests/General"
      )
   }
}
