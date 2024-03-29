//
//  PresetParameter+.swift
//
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

internal extension PresetParameter {
  
  @ViewBuilder
  var view: some View {
    switch valueType {
    case .color:
      _C(parameter: self)
    }
  }
}

fileprivate struct _C: View {
  @State private var color: Color
  var parameter: PresetParameter
  var body: some View {
    ColorPicker(parameter.name, selection: $color)
  }
  init(parameter: PresetParameter) {
    self.parameter = parameter
    self.color = parameter.wrappedValue as? Color ?? .white
  }
}
