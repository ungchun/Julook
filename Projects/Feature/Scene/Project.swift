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
        .project(target: .labelScan, projectPath: .scene),
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
    ),
    .make(
      name: "FeatureLabelScan",
      product: .framework,
      bundleId: "com.azhy.julook.labelScan",
      sources: ["LabelScan/Sources/**"],
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
      name: "FeatureHomeTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.home.tests",
      sources: ["Home/Tests/**"],
      dependencies: [
        .target(name: .home),
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
      )
    ),
    .make(
      name: "FeatureSearchTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.search.tests",
      sources: ["Search/Tests/**"],
      dependencies: [
        .target(name: .search),
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(base: ["SWIFT_VERSION": "6.0"])
    ),
    .make(
      name: "FeatureMyMakgeolliTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.myMakgeolli.tests",
      sources: ["MyMakgeolli/Tests/**"],
      dependencies: [
        .target(name: .myMakgeolli),
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(base: ["SWIFT_VERSION": "6.0"])
    ),
    .make(
      name: "FeatureLabelScanTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.labelScan.tests",
      sources: ["LabelScan/Tests/**"],
      dependencies: [
        .target(name: .labelScan),
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(base: ["SWIFT_VERSION": "6.0"])
    ),
    .make(
      name: "FeatureTabsTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.tabs.tests",
      sources: ["Tabs/Tests/**"],
      dependencies: [
        .target(name: .tabs),
        .project(target: .core, projectPath: .core),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(base: ["SWIFT_VERSION": "6.0"])
    ),
    .make(
      name: "FeatureSplashTests",
      product: .unitTests,
      bundleId: "com.azhy.julook.splash.tests",
      sources: ["Splash/Tests/**"],
      dependencies: [
        .target(name: .splash),
        .project(target: .core, projectPath: .core),
        .external(externalDependency: .composableArchitecture)
      ],
      settings: .settings(base: ["SWIFT_VERSION": "6.0"])
    )
  ]
)
