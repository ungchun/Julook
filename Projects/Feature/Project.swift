import ProjectDescription

let project = Project(
  name: "Feature",
  targets: [
    .target(
      name: "Feature",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "io.tuist.Feature",
      dependencies: [
         .project(target: "FeatureHome", path: "../Feature/Home")
      ]
    )
  ]
)
