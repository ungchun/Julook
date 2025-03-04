import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "Feature",
  targets: [
    .make(
      name: "Feature",
      product: .framework,
      bundleId: "com.azhy.julook.feature",
      dependencies: [
        .project(target: "FeatureHome", path: "../Feature/Home")
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
