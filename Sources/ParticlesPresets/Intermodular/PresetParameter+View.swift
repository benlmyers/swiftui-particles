//
//  PresetParameter+.swift
//
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

internal extension PresetParameter {
  
  struct Content: View {
    
    var title: String
    var parameter: PresetParameter
    
    var onUpdate: (Any) -> Void
    
    var body: some View {
      switch parameter {
      case .floatRange(let d, let min, let max):
        _NumericRangeView(title: title, defaultValue: d, minValue: min, maxValue: max, onUpdate: onUpdate)
      case .doubleRange(let d, let min, let max):
        _NumericRangeView(title: title, defaultValue: d, minValue: min, maxValue: max, onUpdate: onUpdate)
      case .color(let d):
        #if os(watchOS)
        EmptyView()
        #else
        _ColorView(title: title, defaultValue: d, onUpdate: onUpdate)
        #endif
      case .intRange(let d, let min, let max):
        _NumericRangeView(title: title, defaultValue: Float(d), minValue: Float(min), maxValue: Float(max), onUpdate: onUpdate)
      }
    }
    
    private struct _NumericRangeView<T>: View where T: BinaryFloatingPoint, T.Stride: BinaryFloatingPoint {
      @State private var selected: T = .zero
      var title: String
      var defaultValue: T
      var minValue: T
      var maxValue: T
      var onUpdate: (Any) -> Void
      var body: some View {
        Slider(value: $selected, in: minValue ... maxValue, label: { Text(title) })
          .onAppear {
            selected = defaultValue
          }
          .onChange(of: selected) { v in
            onUpdate(v)
          }
      }
    }

    @available(watchOS, unavailable)
    private struct _ColorView: View {
      @State private var selected: Color = .white
      var title: String
      var defaultValue: Color
      var onUpdate: (Any) -> Void
      var body: some View {
        ColorPicker(title, selection: $selected)
          .onAppear {
            selected = defaultValue
          }
          .onChange(of: selected) { v in
            onUpdate(v)
          }
      }
    }

  }
}
