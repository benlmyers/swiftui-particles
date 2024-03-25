//
//  View+Lattice.swift
//
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI

public extension View {
  
  func dissolve(if condition: Bool) -> some View {
    self.opacity(condition ? 0.0 : 1.0).boundlessOverlay(atop: true, minSize: .init(width: 300.0, height: 300.0)) {
      ZStack {
        if condition {
          ParticleSystem {
            Lattice(view: { self })
          }
        }
      }
    }
  }
  
  func explode(if condition: Bool, spacing: Int = 2) -> some View {
    self
      .opacity(condition ? 0.0 : 1.0)
      .boundlessOverlay(atop: true, minSize: .init(width: 800.0, height: 800.0)) {
      ZStack {
        ParticleSystem {
          Lattice(spacing: spacing, view: { self })
            .fixVelocity { c in
              if condition {
                return CGVector(angle: Angle.degrees(Double.random(in: 0.0 ... 360.0, seed: c.physics.seed.0)), magnitude: .random(in: 0.2 ... 0.5))
              }
              return .zero
            }
            .initialPosition(.center).initialVelocity(xIn: -0.01 ... 0.01, yIn: -0.01 ... 0.01)
            .transition(.twinkle)
            .lifetime(3)
        }
      }
      .opacity(condition ? 1 : 0)
    }
  }
}
