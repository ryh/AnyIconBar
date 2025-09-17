import ProjectDescription

let project = Project(
    name: "AnyIconBar",
    targets: [
        .target(
            name: "AnyIconBar",
            destinations: .macOS,
            product: .app,
            bundleId: "dev.tuist.AnyIconBar",
            deploymentTargets: .macOS("15.0"),
            infoPlist: .default,
            buildableFolders: [
                "AnyIconBar/Sources",
                "AnyIconBar/SymbolPicker",
                "AnyIconBar/Resources",
            ],
            headers: .headers(
                public: [],
                private: ["AnyIconBar/CBridge/*.h"],
                project: []
            ),
            dependencies: [],
            settings: .settings(
                base: [
                    "SWIFT_OBJC_BRIDGING_HEADER": "$(SRCROOT)/AnyIconBar/CBridge/TouchBarPrivateApi-Bridging.h",
                    "OTHER_LDFLAGS": "-F/System/Library/PrivateFrameworks -framework DFRFoundation"
                ]
            )
        ),
        .target(
            name: "AnyIconBarTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "dev.tuist.AnyIconBarTests",
            infoPlist: .default,
            buildableFolders: [
                "AnyIconBar/Tests"
            ],
            dependencies: [.target(name: "AnyIconBar")]
        ),
    ]
)
