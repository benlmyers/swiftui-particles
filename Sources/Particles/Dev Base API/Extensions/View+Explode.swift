//
//  View+Explode.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI

extension View {
  public func explode(if condition: Bool) -> some View {
    self.opacity(condition ? 0.0 : 1.0).boundlessOverlay(atop: true, minSize: .init(width: 300.0, height: 300.0)) {
      ZStack {
        ParticleSystem {
          Lattice(spacing: 2, view: { self }) { p in
            p
              .fixVelocity { c in
                if condition {
                  return CGVector(angle: Angle.degrees(Double.random(in: 0.0 ... 360.0, seed: c.physics.seed.0)), magnitude: 0.7)
                }
                return .zero
              }
              .initialPosition(.center).initialVelocity(xIn: -0.01 ... 0.01, yIn: -0.01 ... 0.01)
              .transition(.twinkle)
              .lifetime(3)
          }
        }
      }
    }
  }
}
