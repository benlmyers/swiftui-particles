//
//  Field.swift
//
//
//  Created by Ben Myers on 6/27/23.
//

import SwiftUI

public class Field: Entity {
  
  public typealias Tag = String
  public typealias Effect = (Entity) -> Void

  // MARK: - Properties

  /// The field's bounds.
  @Configured public internal(set) var bounds: Bounds
  
  var tag: Tag
  
  var effect: Effect

  // MARK: - Initalizers
  
  public init(bounds: Bounds, tag: Tag, effect: @escaping Effect) {
    self.bounds = bounds
    self.tag = tag
    self.effect = effect
    super.init()
  }
  
  // MARK: - Overrides
  
  override func update() {
    super.update()
    $bounds.update(in: self)
    guard let system else {
      return
    }
    guard let index = system.entities.firstIndex(of: self) else {
      return
    }
    let count = system.entities.count
    for i in index + 1 ..< count where i < index && i < count {
      let entity: Entity = system.entities[i]
      // Skip field effects
      if entity is Field {
        continue
      }
      // Update using effects
      effect(entity)
    }
  }

  // MARK: - Subtypes
  
  public enum Bounds {
    case all
    case rect(bounds: CGRect)
    case circle(center: CGPoint, radius: CGFloat)
  }
}

extension Field.Bounds {

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
