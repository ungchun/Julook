import ProjectDescription

let project = Project(
    name: "julook",
    targets: [
        .target(
            name: "julook",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.julook",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["julook/Sources/**"],
            resources: ["julook/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "julookTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.julookTests",
            infoPlist: .default,
            sources: ["julook/Tests/**"],
            resources: [],
            dependencies: [.target(name: "julook")]
        ),
    ]
)
