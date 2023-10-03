// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Particles",
  platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
  products: [
    .library(
      name: "ParticlesCore",
      targets: ["ParticlesCore"]),
    .library(name: "Particles", targets: ["Particles"])
  ],
  dependencies: [
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "ParticlesCore",
      dependencies: []),
    .target(
      name: "Particles",
      dependencies: ["ParticlesCore"]),
  ]
)
