//
//  Axis.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

func randomAxis() -> (CGFloat, CGFloat, CGFloat) {
  return (CGFloat(Int.random(in: 0...1)), CGFloat(Int.random(in: 0...1)), CGFloat(Int.random(in: 0...1)))
}
