//
//  Burst.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import CoreGraphics
import SwiftUI
import Foundation

public struct Burst<E2>: Entity where E2: Entity {
  
  // MARK: - Propertiesf
  
  private var customView: AnyView
  private var withBehavior: (Particle) -> E2
  private var spawns: [(CGPoint, Color)]

  // MARK: - Initalizers
  
  /// Creates a new Burst particle.
  /// - Parameter view: The view that is used as a source layer to choose where to spawn various colored particles.
  /// - Parameter withBehavior: A closure that allows you to define the behavior of each spawned entity using Entity Modifiers on the closure parameter.
  /// - Parameter maxSpawns: The number of particles to spawn on the source layer.
  /// - Parameter ignoringColor: The color to ignore when spawning particles on the source layer. Particles will not spawn atop the ignored color.
  /// - Parameter customView: A custom view to use the the spawned particle. By default this is a circle. Keep in mind that the color appearance of each custom view will be overridden by the color in the source layer, `view`.
  public init<Base, ParticleView>(
    @ViewBuilder view: () -> Base,
    withBehavior: @escaping (Particle) -> E2,
    maxSpawns: Int = 200,
    ignoringColor: Color = .clear,
    @ViewBuilder customView: () -> ParticleView = { Circle().frame(width: 1.0, height: 1.0) }
  ) where Base: View, ParticleView: View {
    
    guard let viewImage = view().asImage()?.cgImage, let imgData = viewImage.dataProvider?.data else {
      fatalError("Particles could not convert view to image correctly. (Burst)")
    }
    
    func getPixelColorAt(x: Int, y: Int) -> Color? {
      let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imgData)
      let pixelInfo: Int = ((viewImage.width * y) + x) * 4
      let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
      let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
      let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
      let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
      print("Found color \(Int(r * 255)) \(Int(g * 255)) \(Int(b * 255)) \(Int(a * 255))")
      let color = Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
      if a == 0 || r + g + b < 0.1 { return nil }
      return color
    }
    
    var i: Int = 0
    var j: Int = 0
    var spawnPositionsUsed: [Int: Set<Int>] = [:]
    var spawns: [(CGPoint, Color)] = []
    
    while i < 99999, j < maxSpawns {
      i += 1
      let x: Int = .random(in: 0 ... viewImage.width) / 2
      let y: Int = .random(in: 0 ... viewImage.height) / 2
      if spawnPositionsUsed[x]?.contains(y) ?? false {
        continue
      }
      if let color = getPixelColorAt(x: x, y: y) {
        spawns.append((CGPoint(x: x, y: y), color))
        j += 1
      }
      if spawnPositionsUsed.keys.contains(x) {
        spawnPositionsUsed[x]!.insert(y)
      } else {
        spawnPositionsUsed[x] = .init(arrayLiteral: y)
      }
    }
    
    self.spawns = spawns
    self.customView = .init(customView())
    self.withBehavior = withBehavior
  }
  
//  public init<Base, ParticleView>(
//    @ViewBuilder view: () -> Base,
//    maxSpawns: Int = 200,
//    ignoringColor: Color = .clear,
//    @ViewBuilder customView: () -> ParticleView = { Circle().frame(width: 10.0, height: 10.0) }
//  ) {
//    self.init(view: view, withBehavior: { e in
//      e.initialVelocity(xIn: -0.5 ... 0.5, yIn: -0.5 ... 0.5)
//    }, maxSpawns: maxSpawns, ignoringColor: ignoringColor, customView: customView)
//  }
  
  // MARK: - Body Entity
  
  public var body: some Entity {
    ForEach(spawns, copiesViews: false) { spawn in
      withBehavior(
        Particle(anyView: customView)
      )
      .initialPosition(x: spawn.0.x, y: spawn.0.y)
    }
  }
}
