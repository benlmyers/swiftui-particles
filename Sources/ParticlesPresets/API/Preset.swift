//
//  Preset.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import Foundation

/// The base namespace for all particles presets.
/// To define new presets, see ``PresetEntry``.
/// - SeeAlso: ``ParticlesPresets/Preset/Fire``
public struct Preset {
  
  /// Every preset available, as an array of entities.
  public static var allDefaults: [(String, any PresetEntry)] {
    [
      ("Fire", Fire()),
      ("Magic", Magic()),
      ("Rain", Rain()),
      ("Smoke", Smoke()),
      ("Snow", Snow()),
      ("Stars", Stars()),
      ("Comet", Comet()),
      ("Confetti", Confetti()),
      ("Leaves", Leaves())
    ]
  }
}
