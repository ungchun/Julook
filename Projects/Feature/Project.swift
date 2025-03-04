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
        .target(name: "FeatureHome")
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "FeatureHome",
      product: .framework,
      bundleId: "com.azhy.julook.feature.home",
      sources: ["Home/Sources/**"],
      dependencies: [
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
