import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "Scene",
  targets: [
    .make(
      name: "FeatureTabs",
      product: .framework,
      bundleId: "com.azhy.julook.tabs",
      sources: ["Tabs/Sources/**"],
      dependencies: [
        .project(target: .home, projectPath: .scene),
        .project(target: .search, projectPath: .scene),
        .project(target: .myMakgeolli, projectPath: .scene),
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "FeatureHome",
      product: .framework,
      bundleId: "com.azhy.julook.home",
      sources: ["Home/Sources/**"],
      dependencies: [
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "FeatureSearch",
      product: .framework,
      bundleId: "com.azhy.julook.search",
      sources: ["Search/Sources/**"],
      dependencies: [
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "FeatureMyMakgeolli",
      product: .framework,
      bundleId: "com.azhy.julook.myMakgeolli",
      sources: ["MyMakgeolli/Sources/**"],
      dependencies: [
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "FeatureSplash",
      product: .framework,
      bundleId: "com.azhy.julook.splash",
      sources: ["Splash/Sources/**"],
      dependencies: [
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture),
        .external(externalDependency: .amplitude)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    )
  ]
)
