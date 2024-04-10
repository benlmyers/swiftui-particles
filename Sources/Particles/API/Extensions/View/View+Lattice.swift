//
//  View+Lattice.swift
//
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI

@available(watchOS, unavailable)
public extension View {
  
  /// Dissolves the view into several tiny particles when `condition` is set to `true`.
  /// - parameter condition: The condition to check against. If `true`, the view will dissolve into particles.
  func dissolve(if condition: Bool) -> some View {
    self.opacity(condition ? 0 : 1.0).boundlessOverlay(atop: true) {
      ZStack {
        if condition {
          ParticleSystem {
            Lattice(view: { self })
          }
        }
      }
    }
  }
  
  /// Bursts the view into several tiny particles when `condition` is set to `true`.
  /// - parameter condition: The condition to check against. If `true`, the view will dissolve into particles.
  func burst(if condition: Bool) -> some View {
    self
      .opacity(condition ? 0.0 : 1.0)
      .boundlessOverlay(atop: true) {
      ZStack {
        ParticleSystem {
          Lattice(view: { self })
            .fixVelocity { c in
              if condition {
                return CGVector(angle: Angle.degrees(Double.random(in: 0.0 ... 360.0, seed: c.proxy.seed.0)), magnitude: .random(in: 0.2 ... 0.5))
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
