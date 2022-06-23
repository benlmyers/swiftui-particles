//
//  File.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

public extension Array where Element == Color {
  
  // MARK: - Public Static Properties
  
  static var rainbow: Self {
    return [.red, .orange, .yellow, .green, .blue, .purple, .pink]
  }
}
