//
//  View+Dissolve.swift
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
            Lattice(spacing: 1, view: { self }) { p in
              p
                .initialPosition(.center).initialVelocity(xIn: -0.01 ... 0.01, yIn: -0.01 ... 0.01)
                .transition(.twinkle)
                .lifetime(3)
            }
          }
        }
      }
    }
  }
}
