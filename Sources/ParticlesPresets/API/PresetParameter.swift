//
//  PresetParameter.swift
//
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

@propertyWrapper
public struct PresetParameter<V>: _PresetParameter {
  
  // MARK: - Properties
  
  public var wrappedValue: V
  
  /// The recommended value range of this parameter.
  public var range: (min: V, max: V)?
  
  /// The name of this parameter. Auto-generated.
  public var name: String = ""
  /// The documenation for this parameter. Auto-generated.
  public var documentation: String?
  
  // MARK: - Methods
  
  public mutating func setMirrorMetadata(_ name: String, _ documentation: String?) {
    self.name = name
    self.documentation = documentation
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

public protocol _PresetParameter {
  associatedtype V
  var wrappedValue: V { get set }
  var name: String { get set }
  var documentation: String? { get set }
  mutating func setMirrorMetadata(_ name: String, _ documentation: String?)
}

internal extension _PresetParameter {
  @ViewBuilder
  var view: some View {
    Text("Hi")
  }
}

public protocol _PresetParameterSingleValue {}
public protocol _PresetParameterRangedValue: Comparable {}

extension Color: _PresetParameterSingleValue {}

fileprivate struct _ColorView: View {
  @State private var color: Color = .white
  var parameter: any _PresetParameter
  var body: some View {
    ColorPicker(parameter.name, selection: $color)
  }
  init(parameter: any _PresetParameter) {
    self.parameter = parameter
    if let colorParameter = parameter as? PresetParameter<Color> {
      self.color = colorParameter.wrappedValue
    }
  }
}
