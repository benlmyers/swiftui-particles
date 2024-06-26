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
@available(watchOS, unavailable)
public struct Lattice: Entity, Transparent {
  
  // MARK: - Properties
  
  private var mode: Mode = .cover
  private var customView: AnyView = AnyView(Circle().frame(width: 2.0, height: 2.0))
  private var spawns: [(CGPoint, Color)]
  private var viewSize: CGSize
  private var anchor: UnitPoint

  // MARK: - Initalizers
  
  /// Creates a new Lattice particle group, which creates a grid of colored particles atop the opaque pixels of a view.
  /// - Parameter edges: The edges to spawn particles on. Pass `[]` (default) to cover the view in particles.
  /// - Parameter spacing: Distance between each particle in the lattice.
  /// - Parameter anchor: Whether to spawn the lattice of particles relative to the view.
  /// - Parameter view: The view that is used as a source layer to choose where to spawn various colored particles.
  public init<Base>(
    hugging edges: [Edge] = [],
    spacing: CGFloat = 3.0,
    anchor: UnitPoint = .center,
    @ViewBuilder view: () -> Base
  ) where Base: View {
    if edges.isEmpty {
      self.init(mode: .cover, spacing: spacing, anchor: anchor, view: view)
    } else {
      self.init(mode: .hug(edges), spacing: spacing, anchor: anchor, view: view)
    }
  }
  
  /// Creates a new Lattice particle group, which creates a grid of colored particles atop the opaque pixels of a view.
  /// - Parameter edge: The edge to spawn particles on.
  /// - Parameter spacing: Distance between each particle in the lattice.
  /// - Parameter anchor: Whether to spawn the lattice of particles relative to the view.
  /// - Parameter view: The view that is used as a source layer to choose where to spawn various colored particles.
  public init<Base>(
    hugging edge: Edge,
    spacing: CGFloat = 3.0,
    anchor: UnitPoint = .center,
    @ViewBuilder view: () -> Base
  ) where Base: View {
    self.init(hugging: [edge], spacing: spacing, anchor: anchor, view: view)
  }
  
  @available(watchOS, unavailable)
  private init<Base>(
    mode: Mode = .cover,
    spacing: CGFloat = 3.0,
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
    
    var pixelColorCache: [String: Color] = [:]
    func getPixelColorAt(x: Int, y: Int, useCache: Bool = false) -> Color? {
      if useCache, let color = pixelColorCache["\(x)_\(y)"] { return color }
      let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imgData)
      let bpr: Int = viewImage.bytesPerRow
      let pixelInfo: Int = (bpr * y*2) + 4 * x*2
      let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
      let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
      let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
      let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
      let color = Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
      if a == 0 || r + g + b < 0.1 { return nil }
      if useCache { pixelColorCache["\(x)_\(y)"] = color }
      return color
    }
    
    self.spawns = []
    self.anchor = anchor
    self.customView = AnyView(Circle().frame(width: 2, height: 2))
    
    var newSpawns: [(CGPoint, Color)] = []
    
    switch mode {
    case .cover:
      for x in stride(from: 0.0, to: CGFloat(viewImage.width) / 2.0, by: spacing) {
        for y in stride(from: 0.0, to: CGFloat(viewImage.height) / 2.0, by: spacing) {
          if let color = getPixelColorAt(x: Int(x), y: Int(y)) {
            newSpawns.append((CGPoint(x: x, y: y), color))
          }
        }
      }
    case .hug(let array):
      let flat: [(Edge, CGPoint)] = array.flatMap({ edge in edge.points(size: viewSize, spacing: spacing).map({ point in (edge, point) }) })
      for (edge, point) in flat {
        var proxy: CGPoint = point
        while proxy.x >= 0 && proxy.x <= viewSize.width && proxy.y >= 0 && proxy.y <= viewSize.height {
          if let color = getPixelColorAt(x: Int(proxy.x), y: Int(proxy.y), useCache: true) {
            newSpawns.append((CGPoint(x: proxy.x, y: proxy.y), color))
            break
          } else {
            switch edge {
            case .top:
              proxy.y += spacing
            case .leading:
              proxy.x += spacing
            case .bottom:
              proxy.y -= spacing
            case .trailing:
              proxy.x -= spacing
            }
          }
        }
      }
    }
    
    self.spawns = newSpawns
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
  
  public func hugs(_ edges: Edge...) -> Lattice {
    var copy = self
    copy.mode = .hug(edges)
    return copy
  }
  
  public func hugs() -> Lattice {
    var copy = self
    copy.mode = .hug(.all)
    return copy
  }
  
  // MARK: - Subtypes
  
  /// How ``Lattice`` choose to generate particles.
  private enum Mode {
    /// Cover the entire view with particles.
    case cover
    /// Hug the outside edges of the view with particles.
    case hug([Edge])
  }
  
  /// A edge against which Lattice choose to generate particles.
  public enum Edge {
    /// The top edge of a view.
    case top
    /// The leading edge of a view.
    case leading
    /// The bottom edge of a view.
    case bottom
    /// The trailing edge of a view.
    case trailing
    
    fileprivate func points(size: CGSize, spacing: CGFloat) -> [CGPoint] {
      switch self {
      case .top:
        return stride(from: 0, to: size.width, by: spacing).map({ .init(x: $0, y: 0.0)})
      case .leading:
        return stride(from: 0, to: size.height, by: spacing).map({ .init(x: 0.0, y: $0)})
      case .bottom:
        return stride(from: 0, to: size.width, by: spacing).map({ .init(x: $0, y: size.height)})
      case .trailing:
        return stride(from: 0, to: size.height, by: spacing).map({ .init(x: size.width, y: $0)})
      }
    }
  }
}

@available(watchOS, unavailable)
public extension Array where Element == Lattice.Edge {
  
  /// Hugs every edge.
  static var all : Self {
    [.top, .leading, .bottom, .trailing]
  }
}
