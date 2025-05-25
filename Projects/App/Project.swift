import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

fileprivate let commonScripts: [TargetScript] = [
    .post(
      script: """
        ROOT_DIR=\(ProcessInfo.processInfo.environment["TUIST_ROOT_DIR"] ?? "")
        "${ROOT_DIR}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"

        """,
      name: "Firebase Crashlytics",
      inputPaths: [
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
        "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"
      ],
      basedOnDependencyAnalysis: false
    )
]

let project = Project.make(
  name: "App",
  targets: [
    .make(
      name: "Julook",
      product: .app,
      bundleId: "com.azhy.julook",
      infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      scripts: commonScripts,
      dependencies: [
        .project(target: .core, projectPath: .core),
        .project(target: .designSystem, projectPath: .designSystem),
        .project(target: .splash, projectPath: .scene),
        .project(target: .mainCoordinator, projectPath: .coordinator),
        .external(externalDependency: .firebaseAnalytics),
        .external(externalDependency: .firebaseCrashlytics)
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "6.0"],
        configurations: [
            .debug(name: .debug, xcconfig: "./Resources/Secrets.xcconfig"),
            .release(name: .release, xcconfig: "./Resources/Secrets.xcconfig")
        ]
      )
    )
  ]
)

//    .make(
//      name: "Dev-Julook",
//      product: .app,
//      bundleId: "com.azhy.julook-dev",
//      infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
//      sources: ["Sources/**"],
//      resources: ["Resources/**"],
//      dependencies: [
//        .project(target: .core, projectPath: .core),
//        .project(target: .designSystem, projectPath: .designSystem),
//        .project(target: .splash, projectPath: .scene),
//        .project(target: .mainCoordinator, projectPath: .coordinator),
//        .external(externalDependency: .firebaseAnalytics),
//        .external(externalDependency: .firebaseCrashlytics)
//      ],
//      settings: .settings(
//        base: ["SWIFT_VERSION": "6.0"],
//        configurations: [
//          .debug(name: .debug, xcconfig: "./Resources/Secrets.xcconfig"),
//        ]
//      )
//    )
