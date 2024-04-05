//
//  Lattice.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Foundation
import CoreGraphics

/// A lattice entity group that 'imitates' a view by creating a grid of colored particles.
///
/// You can customize the behavior of each particle to create neat effects on your views:
/// ```
/// Lattice(spacing: 3) {
///   Text("Hello, World!").font(.title).fontWeight(.bold)
/// } withBehavior: { p in
///   p
///     .initialVelocity(xIn: -0.05 ... 0.05, yIn: -0.05 ... 0.05)
///     .lifetime(4)
///     .initialAcceleration(y: 0.0002)
/// } customView: {
///   Circle().frame(width: 3.0, height: 3.0)
/// }
/// ```
public struct Lattice: Entity, Transparent {
  
  // MARK: - Properties
  
  private var customView: AnyView = AnyView(Circle().frame(width: 2.0, height: 2.0))
  private var spawns: [(CGPoint, Color)]
  private var viewSize: CGSize
  private var anchor: UnitPoint

  // MARK: - Initalizers
  
  /// Creates a new Lattice particle group, which creates a grid of colored particles atop the opaque pixels of a view.
  /// - Parameter spacing: Distance between each particle in the lattice.
  /// - Parameter anchor: Whether to spawn the lattice of particles relative to the view.
  /// - Parameter view: The view that is used as a source layer to choose where to spawn various colored particles.
  public init<Base>(
    spacing: Int = 3,
    anchor: UnitPoint = .center,
    @ViewBuilder view: () -> Base
  ) where Base: View {
    #if os(iOS)
    let s = 0.66
    #else
    let s = 1.0
    #endif
    guard let viewImage = view().scaleEffect(s).background(Color.black).asImage()?.cgImage, let imgData = viewImage.dataProvider?.data else {
      fatalError("Particles could not convert view to image correctly. (Burst)")
    }
    viewSize = .init(width: viewImage.width / 2, height: viewImage.height / 2)
    func getPixelColorAt(x: Int, y: Int) -> Color? {
      let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imgData)
      let bpr: Int = viewImage.bytesPerRow
      let pixelInfo: Int = (bpr * y*2) + 4 * x*2
      let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
      let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
      let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
      let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
      let color = Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
      if a == 0 || r + g + b < 0.1 { return nil }
      return color
    }
    var spawns: [(CGPoint, Color)] = []
    for x in stride(from: 0, to: viewImage.width / 2, by: spacing) {
      for y in stride(from: 0, to: viewImage.height / 2, by: spacing) {
        if let color = getPixelColorAt(x: x, y: y) {
          spawns.append((CGPoint(x: x, y: y), color))
        }
      }
    }
    self.spawns = spawns
    self.anchor = anchor
    self.customView = AnyView(Circle().frame(width: 2, height: 2))
  }
  
  // MARK: - Body Entity
  
  public var body: some Entity {
    ForEach(spawns, merges: .views) { spawn in
      Particle(anyView: customView)
        .initialOffset(x: spawn.0.x - viewSize.width * anchor.x, y: spawn.0.y - viewSize.height * anchor.y)
        .colorOverlay(spawn.1)
    }
  }
  
  // MARK: - Modifiers
  
  public func customView<V>(@ViewBuilder view: () -> V) -> Lattice where V: View {
    var copy = self
    copy.customView = .init(view())
    return copy
  }
}
