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
  var parameters: [any _PresetParameter] { get }
}

public extension PresetEntry {
  
  // MARK: - Properties
  
  /// Converts the preset into a `View` that can be used in SwiftUI.
  var view: some View {
    ParticleSystem(entity: { self })
      .statePersistent("_ParticlesPresetEntry\(String(describing: type(of: self)))")
  }
  
  /// Converts the presets into a demo view where parameters can be tweaked.
  var demo: some View {
    DemoView(entry: self)
  }
  
  // MARK: - Conformance
  
  var parameters: [any _PresetParameter] {
    var properties: [any _PresetParameter] = []
    let mirror = Mirror(reflecting: self)
    for case let (label?, value) in mirror.children {
      if var property = value as? any _PresetParameter {
        let cr = (value as? CustomReflectable).debugDescription
        property.setMirrorMetadata(label, cr)
        properties.append(property)
      }
    }
    return properties
  }
}

fileprivate struct DemoView<Preset>: View where Preset: PresetEntry {
  
  @State var entry: Preset
  @State var refresh: Bool = false
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      entry.view
      VStack(alignment: .leading) {
        ForEach(entry.parameters, id: \.name) { parameter in
          AnyView(parameter.view)
            .onAppear {
//              parameter.o = { v in refresh.toggle() }
            }
        }
      }
      .padding()
    }
  }
}
