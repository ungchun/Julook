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
      resources: ["Resources/**"],
      scripts: [
        .pre(
          script: """
          if which swiftgen >/dev/null; then
            cd "${SRCROOT}/../.."
            swiftgen config run --config swiftgen.yml
          else
            echo "warning: SwiftGen not installed — run 'brew install swiftgen'"
          fi
          """,
          name: "SwiftGen",
          basedOnDependencyAnalysis: false
        )
      ],
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
