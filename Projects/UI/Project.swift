import ProjectDescription

let project = Project(
  name: "UI",
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
      name: "UI",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "io.tuist.UI",
      dependencies: []
    )
  ]
)
