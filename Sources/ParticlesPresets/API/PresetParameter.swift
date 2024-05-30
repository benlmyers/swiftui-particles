//
//  PresetParameter.swift
//
//
//  Created by Ben Myers on 4/10/24.
//

import SwiftUI

/// A preset parameter, used to configure presets.
/// For examples of usage, see ``Preset/Fire``.
/// - SeeAlso: ``Preset/Rain``
/// - SeeAlso: ``Preset/Stars``
public enum PresetParameter {
  
  /// A `CGFloat` parameter configurable within a range.
  case floatRange(CGFloat, min: CGFloat, max: CGFloat)
  /// A `Double` parameter configurable within a range.
  case doubleRange(Double, min: Double, max: Double)
  /// An `Int` parameter configurable within a range.
  case intRange(Int, min: Int, max: Int)
  /// A configurable `Color` parameter.
  @available(watchOS, unavailable)
  case color(Color)
  /// An `Angle` parameter.
  case angle(Angle)
  /// A `Bool` parameter.
  case bool(Bool)
}
