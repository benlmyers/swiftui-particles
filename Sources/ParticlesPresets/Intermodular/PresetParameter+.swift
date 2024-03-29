//
//  PresetParameter+.swift
//
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

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
