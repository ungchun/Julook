import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "App",
  targets: [
    .make(
      name: "Prod-Julook",
      product: .app,
      bundleId: "com.azhy.julook",
      infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "Feature", path: "../Feature")
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "Dev-Julook",
      product: .app,
      bundleId: "com.azhy.julook-dev",
      infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "Feature", path: "../Feature")
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
  ]
)
