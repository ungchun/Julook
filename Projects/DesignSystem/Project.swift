import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "DesignSystem",
  targets: [
    .make(
      name: "DesignSystem",
      product: .framework,
      bundleId: "com.azhy.julook.designSystem",
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [ ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
