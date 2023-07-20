//
//  LifetimeBound.swift
//  
//
//  Created by Ben Myers on 7/20/23.
//

import SwiftUI
import Foundation

public struct LifetimeBound<T> {
  
  /// A value determined by lifetime.
  var closure: (Double) -> T
}

public extension LifetimeBound where T == CGFloat {
  
  /// Gradual decrease from `initialVal` to `0.0`.
  static func gradualDecrease(from initialVal: T = 1.0) -> LifetimeBound {
    LifetimeBound { t in clamp(initialVal - initialVal * CGFloat(t), min: 0.0, max: initialVal) }
  }
  
  /// Gradual increase from `0.0` to `finalVal`.
  static func gradualIncrease(to finalVal: T = 1.0) -> LifetimeBound {
    LifetimeBound { t in clamp(finalVal * CGFloat(t), min: 0.0, max: finalVal) }
  }
  
  static func inAndOut(in range: ClosedRange<T> = 0.0 ... 1.0, strength: UInt = 2) -> LifetimeBound {
    LifetimeBound { t in range.lowerBound + (range.upperBound - range.lowerBound) * clamp(1 - pow((2 * t - 1), 2 * Double(strength)), min: 0.0, max: 1.0)}
  }
  
  /// Gradual decrease during last 10% of lifetime.
  static func decreaseOut(from initialVal: T = 1.0) -> LifetimeBound {
    decreaseAfter(0.9, from: initialVal)
  }
  
  /// Fade out during the last ratio of time.
  static func decreaseAfter(_ start: Double, from initialVal: T = 1.0) -> LifetimeBound {
    LifetimeBound { t in clamp((initialVal / (1.0 - start)) - (initialVal / (1.0 - start)) * t, min: 0.0, max: 1.0) }
  }
}

public extension LifetimeBound where T == Angle {
  
  static func gradualRotate(to finalVal: T = .degrees(360.0)) -> LifetimeBound {
    LifetimeBound { t in Angle(degrees: finalVal.degrees * t) }
  }
  
  static func constantIncrease(rate: Double = 1.0) -> LifetimeBound {
    LifetimeBound { t in Angle(degrees: 360.0 * rate * t) }
  }
  
  static func rampedIncrease(rate: Double = 1.0) -> LifetimeBound {
    LifetimeBound { t in Angle(degrees: rate * 0.1 * pow(t, 1.2) )}
  }
}

fileprivate func clamp<T>(_ value: T, min: T, max: T) -> T where T: Comparable {
  if value < min {
    return min
  }
  if value > max {
    return max
  }
  return value
}
