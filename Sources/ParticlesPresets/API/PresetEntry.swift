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
  var parameters: [String: (PresetParameter, PartialKeyPath<Self>)] { get }
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
    .init(PresetDemoView(entry: self))
  }
}
