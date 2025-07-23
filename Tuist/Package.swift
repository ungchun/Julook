// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .framework,
    "TCACoordinators": .framework,
    "FirebaseAnalytics" : .staticLibrary,
    "FirebaseCrashlytics" : .staticLibrary,
    "AmplitudeSwift" : .staticLibrary
  ]
)
#endif

let package = Package(
  name: "Julook",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.11.0"),
    .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators", from: "0.10.1"),
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.25.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.13.9")
  ]
)
