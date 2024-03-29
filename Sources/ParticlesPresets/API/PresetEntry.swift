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
  var parameters: [PresetParameter] { get }
}

public extension PresetEntry {
  
  // MARK: - Properties
  
  /// Converts the preset into a `View` that can be used in SwiftUI.
  var view: some View {
    ParticleSystem(entity: { self })
  }
  
  // MARK: - Conformance
  
  var parameters: [PresetParameter] {
    var properties: [PresetParameter] = []
    let mirror = Mirror(reflecting: self)
    for case let (label?, value) in mirror.children {
      if let property = value as? PresetParameter {
        properties.append(property)
      }
    }
    return properties
  }
}
