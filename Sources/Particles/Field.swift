//
//  Field.swift
//
//
//  Created by Ben Myers on 6/27/23.
//

import SwiftUI

public class Field: Entity {
  
  typealias Tag = String

  // MARK: - Properties

  /// The field's bounds.
  @Configured public internal(set) var bounds: Bounds
  
  var tag: Tag

  // MARK: - Initalizers

//  public init(bounds: Field.Shape, effect: Field.Effect) {
//    self.bounds = bounds
//    self.effect = effect
//    super.init()
//  }
//
//  public init(bounds: Field.Shape, effect: @escaping (Entity) -> Void) {
//    self.bounds = bounds
//    self.effect = .custom(effect)
//    super.init()
//  }

  // MARK: - Overrides
  
  // MARK: - Subtypes
  
  public class Bounds {
    
  }
}

extension Field {

  public enum Shape {
    case all
    case rect(bounds: CGRect)
    case circle(center: CGPoint, radius: CGFloat)
  }

  public enum Effect {
//    case gravity(CGVector)
//    case torque(Angle)
//    @available(*, deprecated, message: "Still under development. Avoid using.")
//    case bounce
//    case destroy
//    case custom((Entity) -> Void)
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

  func contains(_ point: CGPoint) -> Bool {
    switch self {
    case .all:
      return true
    case .rect(let bounds):
      return bounds.contains(point)
    case .circle(let center, let radius):
      return center.distance(to: point) <= radius
    }
  }
}
