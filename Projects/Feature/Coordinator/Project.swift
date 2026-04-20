import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "Coordinator",
  targets: [
    .make(
      name: "MainCoordinator",
      product: .staticLibrary,
      bundleId: "com.azhy.julook.mainCoordinator",
      sources: ["MainCoordinator/**"],
      dependencies: [
        .project(target: .tabs, projectPath: .scene),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .tcaCoordinators),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "MainCoordinatorTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.mainCoordinator.tests",
      sources: ["Tests/**"],
      dependencies: [
        .target(name: .mainCoordinator),
        .project(target: .core, projectPath: .core),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .tcaCoordinators)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
