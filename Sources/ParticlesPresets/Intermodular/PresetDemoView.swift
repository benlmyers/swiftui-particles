//
//  PresetDemoView.swift
//
//
//  Created by Ben Myers on 4/10/24.
//

import SwiftUI
import Particles

internal struct PresetDemoView<Entry>: View where Entry: PresetEntry {
  
  @State var entry: Entry
  
  var customization: Bool
  var debug: Bool
  
  private var parameters: [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Entry>)] {
    entry.customizableParameters().sorted(by: { $0.name < $1.name })
  }
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      ParticleSystem {
        entry
      }
      .statePersistent(String(describing: type(of: Entry.self)), refreshesViews: true)
      .debug(debug)
      
#if !os(watchOS)
      
      if customization {
        LazyVGrid(columns: [.init(.adaptive(minimum: 200.0))], spacing: 8.0) {
          ForEach(parameters, id: \.name) { p in
            HStack {
              PresetParameter.Content(title: p.name, parameter: p.parameter, onUpdate: { v in
                switch p.parameter {
                case .floatRange: entry[keyPath: p.keyPath as! WritableKeyPath<Entry, CGFloat>] = v as! CGFloat
                case .doubleRange: entry[keyPath: p.keyPath as! WritableKeyPath<Entry, Double>] = v as! Double
                case .color: entry[keyPath: p.keyPath as! WritableKeyPath<Entry, Color>] = v as! Color
                case .intRange: entry[keyPath: p.keyPath as! WritableKeyPath<Entry, Int>] = Int(v as! Float)
                case .angle: entry[keyPath: p.keyPath as! WritableKeyPath<Entry, Angle>] = Angle(degrees: v as! Double)
                case .bool: entry[keyPath: p.keyPath as! WritableKeyPath<Entry, Bool>] = v as! Bool
                }
              })
              Spacer()
            }
            .padding(.horizontal, 8.0)
            .padding(.vertical, 4.0)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
          }
        }
        .padding()
        .padding(.top, debug ? 45.0 : 0.0)
      }
      
#endif
      
    }
  }
}
