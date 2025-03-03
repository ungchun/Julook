import ProjectDescription

let project = Project(
  name: "Julook",
  targets: [
    .target(
      name: "Julook",
      destinations: .iOS,
      product: .app,
      bundleId: "io.tuist.Julook",
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
          ],
        ]
      ),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "Feature", path: "../Feature"),
        .external(name: "ComposableArchitecture")
      ]
    ),
    .target(
      name: "julookTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "io.tuist.julookTests",
      infoPlist: .default,
      sources: ["Tests/**"],
      resources: [],
      dependencies: [.target(name: "Julook")]
    ),
  ]
)
