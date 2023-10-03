//
//  Extension.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import Particles
import Foundation

/// A protocol defining a pack extension.
public protocol Extension {
  
  /// The name of the extension.
  var name: String { get }
  /// The description of the extension.
  var description: String { get }
  /// The author of the extension.
  var author: String { get }
  
  /// Examples of the extension in use via particle systems.
  var examples: [ParticleSystem] { get }
}
