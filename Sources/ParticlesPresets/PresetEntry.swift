//
//  PresetEntry.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import Foundation

/// A protocol defining a preset as being an official Entry.
/// Any preset conforming to this protocol must include a value of type ``PresetMetadata`` provided by the preset's developer.
protocol PresetEntry {
  
  /// The metadata for this preset.
  /// For more information, see ``PresetEntry``.
  var metadata: PresetMetadata { get }
}
