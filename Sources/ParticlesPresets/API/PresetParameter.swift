//
//  PresetParameter.swift
//
//
//  Created by Ben Myers on 4/10/24.
//

import SwiftUI

public enum PresetParameter {
  
  case floatRange(CGFloat, min: CGFloat, max: CGFloat)
  case doubleRange(Double, min: Double, max: Double)
  case intRange(Int, min: Int, max: Int)
  
  @available(watchOS, unavailable)
  case color(Color)
  
  
}
