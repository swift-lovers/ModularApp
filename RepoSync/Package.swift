// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ModularAppTools",
    products: [
        .plugin(
            name: "RepoSync",
            targets: ["RepoSync"]
        ),
    ],
    targets: [
        .plugin(
            name: "RepoSync",
            capability: .command(
                intent: .custom(
                    verb: "RepoSync",
                    description: "Synchronizes remote repositories using {dev, prod}.config file"
                ),
                permissions: [
                    .allowNetworkConnections(scope: .all(ports: []), reason: "Fetching remote repositories"),
                    .writeToPackageDirectory(reason: "Fetching remote repositories"),
                ]
            )
        ),
    ]
)
