//
//  Field.swift
//  
//
//  Created by Ben Myers on 6/27/23.
//

import SwiftUI

public class Field: Debuggable {
  
  // MARK: - Properties
  
  /// The field's bounds.
  var bounds: Shape
  /// A closure that applies a physical effect to entities within its bounds.
  var effect: Effect
  
  // MARK: - Initalizers
  
  init(bounds: Field.Shape, effect: Field.Effect) {
    self.bounds = bounds
    self.effect = effect
  }
  
  init(bounds: Field.Shape, effect: @escaping (Entity) -> Void) {
    self.bounds = bounds
    self.effect = .custom(effect)
  }
  
  // MARK: - Conformance
  
  func debug(_ context: GraphicsContext) {
    context.fill(bounds.path, with: .color(.blue.opacity(0.1)))
  }
}

extension Field {
  
  public enum Shape {
    case all
    case rect(bounds: CGRect)
    case circle(center: CGPoint, radius: CGFloat)
  }
  
  public enum Effect {
    case gravity(CGVector)
    case torque(CGFloat)
    case custom((Entity) -> Void)
  }
}

extension Field.Shape {
  var path: Path {
    switch self {
    case .all:
      return Path(.infinite)
    case .rect(let bounds):
      return Path(bounds)
    case .circle(let center, let radius):
      return Path(ellipseIn: CGRect(origin: center, size: CGSize(width: radius * 2.0, height: radius * 2.0)))
    }
  }
}

extension Field.Effect {
  var closure: (Entity) -> Void {
    switch self {
    case .gravity(let v):
      return { e in e.vel = e.vel.add(v) }
    case .torque(let t):
      return { e in e.rot += t }
    case .custom(let closure):
      return closure
    }
  }
}
