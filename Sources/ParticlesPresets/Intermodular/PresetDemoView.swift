//
//  PresetDemoView.swift
//
//
//  Created by Ben Myers on 4/10/24.
//

import SwiftUI

internal struct PresetDemoView<Entry>: View where Entry: PresetEntry {
  
  @State var entry: Entry
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      entry.view
      VStack(alignment: .leading) {
        ForEach(Array(entry.parameters).sorted(by: { $0.key < $1.key }), id: \.0) { pair in
          PresetParameter.Content(title: pair.key, parameter: pair.value.0, onUpdate: { v in
            switch pair.value.0 {
            case .floatRange: entry[keyPath: pair.value.1 as! WritableKeyPath<Entry, CGFloat>] = v as! CGFloat
            case .doubleRange: entry[keyPath: pair.value.1 as! WritableKeyPath<Entry, Double>] = v as! Double
            case .color: entry[keyPath: pair.value.1 as! WritableKeyPath<Entry, Color>] = v as! Color
            }
          })
        }
      }
      .padding()
    }
  }
}
