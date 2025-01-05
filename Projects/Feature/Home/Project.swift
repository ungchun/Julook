import ProjectDescription

let project = Project(
  name: "FeatureHome",
  targets: [
    .target(
      name: "FeatureHome",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "io.tuist.FeatureHome",
      dependencies: [
        
      ]
    )
  ]
)
