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
  
  @available(watchOS, unavailable)
  case color(Color)
  
  
}
