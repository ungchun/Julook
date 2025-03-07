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
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .project(target: .mainCoordinator, projectPath: .coordinator),
        .external(externalDependency: .supabase)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"],
        configurations: [
          .release(name: .release, xcconfig: "./Resources/Secrets.xcconfig")
        ]
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
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .project(target: .mainCoordinator, projectPath: .coordinator),
        .external(externalDependency: .supabase)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"],
        configurations: [
          .debug(name: .debug, xcconfig: "./Resources/Secrets.xcconfig"),
        ]
      )
    ),
  ]
)
