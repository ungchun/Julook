import ProjectDescription

let project = Project(
  name: "UI",
  targets: [
    .target(
      name: "UI",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "io.tuist.UI",
      dependencies: []
    )
  ]
)
