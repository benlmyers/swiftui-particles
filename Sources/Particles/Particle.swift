//
//  Particle.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI

public struct Particle: Entity {
  public var body = EmptyEntity()
  internal var view: AnyView
  public init<V>(@ViewBuilder view: () -> V) where V: View {
    self.view = .init(view())
  }
}
