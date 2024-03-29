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
  var onUpdate: (V) -> Void { get set }
  mutating func setMirrorMetadata(_ name: String, _ documentation: String?)
}

internal extension _PresetParameter {
  @ViewBuilder
  var view: some View {
    if let single = wrappedValue as? _PresetParameterSingleValue {
      single.view(self)
    }
  }
}

public protocol _PresetParameterSingleValue {
  func view(_ v: any _PresetParameter) -> AnyView
}
public protocol _PresetParameterRangedValue: Comparable {}

extension Color: _PresetParameterSingleValue {
  public func view(_ v: any _PresetParameter) -> AnyView {
    .init(_ColorView(parameter: v))
  }
}

fileprivate struct _ColorView: View {
  @State private var color: Color = .white
  var parameter: any _PresetParameter
  var body: some View {
    ColorPicker(parameter.name, selection: $color)
      .onChange(of: color) { c in
        (parameter as? PresetParameter<Color>)?.onUpdate(c)
      }
  }
  init(parameter: any _PresetParameter) {
    self.parameter = parameter
    if let colorParameter = parameter as? PresetParameter<Color> {
      self.color = colorParameter.wrappedValue
    }
  }
}
