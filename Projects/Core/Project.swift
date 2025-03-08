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
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .supabase)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
