//
//  File.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

struct ParticleView<P>: View where P: Particle {
  
  let particle: P
  let bounds: CGSize
  let start: UnitPoint
  let velocity: CGVector
  let end: UnitPoint
  let duration: Double
  let forever: Bool
  let delay: Double
  
  var path: Path {
    let p1 = start.projected(to: bounds)
    let p2 = end.projected(to: bounds)
    let c = p1.translated(by: velocity)
    var result = Path()
    result.move(to: p1)
    result.addCurve(to: p2, control1: c, control2: p2)
    return result
  }

  var tMax: CGFloat { animate ? 1 : 0 }
  
  @State private var animate = false
  
  var body: some View {
    Group {
      particle.body($animate, duration: duration, delay: delay, forever: forever)
        .scaleEffect(animate ? 0.0 : 1.0)
        .modifier(MovingModifier(time: tMax, path: path, start: start.projected(to: bounds)))
        //.animation(.timingCurve(0.33, 0.50, 1.0, 1.0, duration: duration).forever(forever, autoreverses: false).delay(delay), value: tMax)
    }
    .onAppear { animate = true }
    .animation(.linear(duration: duration).delay(0.01).forever(forever, autoreverses: false).delay(delay), value: animate)
    .opacity(animate ? 1.0 : 0.0)
    .animation(.linear.delay(delay), value: animate)
  }
}
