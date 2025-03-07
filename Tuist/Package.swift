// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .framework,
    "TCACoordinators": .framework,
    "Supabase": .framework
  ]
)
#endif

let package = Package(
  name: "Julook",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.11.0"),
    .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators", from: "0.10.1"),
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.25.0")
    // Add your own dependencies here:
    // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
    // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
  ]
)
