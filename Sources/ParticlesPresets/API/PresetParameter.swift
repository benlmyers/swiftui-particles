//
//  PresetParameter.swift
//
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

@propertyWrapper
public struct PresetParameter {
  
  // MARK: - Properties
  
  public let wrappedValue: Any
  
  internal var valueType: ValueType
  
  internal private(set) var name: String = ""
  internal private(set) var documentation: String?
  
  // MARK: - Methods
  
  internal mutating func setMirrorMetadata(_ name: String, _ documentation: String) {
    self.name = name
    self.documentation = documentation
  }
  
  // MARK: - Initalizers
  
  public init<T>(wrappedValue: T) {
    self.wrappedValue = wrappedValue
    if wrappedValue is Color {
      self.valueType = .color
    } else {
      fatalError("Invalid PresetParameter type.")
    }
  }
  
  // MARK: - Subtypes
  
  enum ValueType {
    case color
  }
}
