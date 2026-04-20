import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "Core",
  targets: [
    .make(
      name: "Core",
      product: .framework,
      bundleId: "com.azhy.julook.core",
      sources: ["Sources/**"],
      dependencies: [
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .supabase),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "CoreTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.core.tests",
      sources: ["Tests/**"],
      dependencies: [
        .target(name: .core),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
