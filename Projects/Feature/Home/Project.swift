import ProjectDescription

let project = Project(
  name: "FeatureHome",
  settings: .settings(
    base: ["SWIFT_VERSION": "6.0"],
    configurations: [
      .debug(
        name: "Debug"
      ),
      .release(
        name: "Release"
      ),
    ]),
  targets: [
    .target(
      name: "FeatureHome",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "io.tuist.FeatureHome",
      sources: ["Sources/**"],
      dependencies: [
        
      ]
    )
  ]
)
