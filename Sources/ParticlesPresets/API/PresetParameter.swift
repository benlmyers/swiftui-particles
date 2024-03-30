//
//  PresetParameter.swift
//
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

@propertyWrapper
public struct PresetParameter<P, V>: _PresetParameter where P: PresetEntry, V: Equatable {
  
  // MARK: - Properties
  
  public var wrappedValue: V
  
  /// The recommended value range of this parameter.
  public var range: (min: V, max: V)?
  
  /// The name of this parameter. Auto-generated.
  public var name: String = ""
  
  public var keyPath: KeyPath<P, V>?
  
//  public var onUpdate: (V) -> Void = { _ in }
  
  // MARK: - Methods
  
  public mutating func setMirrorMetadata(_ name: String, _ path: KeyPath<P, V>) {
    self.name = name.dropFirst().capitalized
    self.keyPath = path
  }
  
  // MARK: - Initalizers
  
  /// Defines a parameter with a default value.
  /// - parameter wrappedValue: The default value to apply.
  public init(wrappedValue: V) where V: _PresetParameterSingleValue {
    self.wrappedValue = wrappedValue
  }
  
  /// Defines a parameter with a default value in a recommended range.
  /// - parameter wrappedValue: The default value to apply.
  /// - parameter range: The recommended range.
  public init(wrappedValue: V, in range: ClosedRange<V>) where V == Float {
    self.wrappedValue = wrappedValue
    self.range = (range.lowerBound, range.upperBound)
  }
}
