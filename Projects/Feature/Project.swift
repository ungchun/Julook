import ProjectDescription

let project = Project(
  name: "Feature",
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
