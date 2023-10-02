// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Particles",
  platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
  products: [
    .library(
      name: "Particles",
      targets: ["Particles"]),
//    .library(name: "PresetParticles", targets: ["PresetParticles"])
  ],
  dependencies: [
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Particles",
      dependencies: []),
//    .target(
//      name: "PresetParticles",
//      dependencies: ["Particles"]),
  ]
)
