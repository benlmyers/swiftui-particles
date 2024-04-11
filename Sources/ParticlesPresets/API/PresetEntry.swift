//
//  PresetEntry.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

/// A preset entry entity.
///
/// Preset entities have an auto-computed property, `parameters`, which hold every `@PresetParameter` property.
///
/// - seealso: ``PresetEntry/view``
public protocol PresetEntry: Entity {
  
  /// The parameters of this entry.
  var parameters: [String: PresetParameter] { get }
}

public extension PresetEntry {
  
  // MARK: - Properties
  
  /// Converts the preset into a `View` that can be used in SwiftUI.
  var view: AnyView {
    .init(ParticleSystem(entity: { self })
      .statePersistent("_ParticlesPresetEntry\(String(describing: type(of: self)))"))
  }
  
  /// Converts the presets into a demo view where parameters can be tweaked.
  var demo: AnyView {
    .init(DemoView(entry: self))
  }
}

fileprivate struct DemoView<Entry>: View where Entry: PresetEntry {
  
  @State var entry: Entry
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      entry.view
      VStack(alignment: .leading) {
        ForEach(Array(entry.parameters), id: \.0) { pair in
          _PresetParameterView(title: pair.key, parameter: pair.value, onUpdate: <#T##(any PresetEntry) -> Void#>)
          pair.value.view(title: pair.key, onUpdate: <#(any PresetEntry) -> Void#>)
        }
      }
      .padding()
    }
  }
}
