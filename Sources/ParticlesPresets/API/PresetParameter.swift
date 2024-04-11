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
  case color(Color)
}

struct _PresetParameterView<Entry>: View where Entry: PresetEntry {
  
  var title: String
  var parameter: PresetParameter
  
  var onUpdate: (Entry) -> Entry {
    switch parameter {
    case .floatRange(let d, let min, let max):
      return {
        guard var copy = $0 as? 
        copy
      }
    case .doubleRange(let d, let min, let max):
      return { return $0 }
    case .color(let d):
      return { return $0 }
    }
  }
  
  var body: some View {
    switch parameter {
    case .floatRange(let d, let min, let max):
      _NumericRangeView(title: title, defaultValue: d, minValue: min, maxValue: max)
    case .doubleRange(let d, let min, let max):
      _NumericRangeView(title: title, defaultValue: d, minValue: min, maxValue: max)
    case .color(let d):
      _ColorView(title: title, defaultValue: d)
    }
  }
}

fileprivate struct _NumericRangeView<T>: View where T: BinaryFloatingPoint, T.Stride: BinaryFloatingPoint {
  @State private var selected: T = .zero
  var title: String
  var defaultValue: T
  var minValue: T
  var maxValue: T
  var body: some View {
    Slider(value: $selected, in: minValue ... maxValue, label: { Text(title) })
      .onAppear {
        selected = defaultValue
      }
      .onChange(of: selected) { v in
        
      }
  }
}

@available(watchOS, unavailable)
fileprivate struct _ColorView: View {
  @State private var selected: Color = .white
  var title: String
  var defaultValue: Color
  var body: some View {
    ColorPicker(title, selection: $selected)
      .onAppear {
        selected = defaultValue
      }
  }
}
