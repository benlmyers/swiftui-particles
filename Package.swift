// swift-tools-version: 5.6
import PackageDescription

let package = Package(
  name: "Particles",
  platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
  products: [
    .library(name: "ParticlesPresets", targets: ["ParticlesPresets"]),
    .library(name: "Particles", targets: ["Particles"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Particles"
    ),
    .target(
      name: "ParticlesPresets",
      dependencies: ["Particles"],
      resources: [.process("Resources")]
    ),
  ]
)
