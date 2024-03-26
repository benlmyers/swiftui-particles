//
//  PresetEntry.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

/// A protocol defining a preset as being an official Entry.
/// Any preset conforming to this protocol must include a value of type ``PresetMetadata`` provided by the preset's developer.
public protocol PresetEntry: Entity {
  
  /// The metadata for this preset.
  /// For more information, see ``PresetEntry``.
  var metadata: PresetMetadata { get }
}


public extension PresetEntry {
  
  /// Converts the preset into a `View` that can be used in SwiftUI.
  func makeView() -> some View {
    EmptyView()
  }
}
