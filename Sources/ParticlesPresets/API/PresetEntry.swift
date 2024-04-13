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
/// Presets have a optional property, ``parameters``, which holds a dictionary of configurable parameters for the preset. By default this is empty.
/// If you choose to implement it, calling ``PresetEntry/demo(customization:debug:)`` will return a view displaying the preset with customization options.
/// This is used in the [example project](https://github.com/benlmyers/swiftui-particles/tree/main/Examples/ParticlesExample).
/// - SeeAlso: ``PresetEntry/view``
/// - SeeAlso: ``PresetParameter``
public protocol PresetEntry: Entity {
  
  /// The default instance of this entity.
  static var `default`: Self { get }
  
  /// The parameters of this entry.
  var parameters: [String: (PresetParameter, PartialKeyPath<Self>)] { get }
}

public extension PresetEntry {
  
  // MARK: - Default Implementation
  
  var parameters: [String: (PresetParameter, PartialKeyPath<Self>)] { [:] }
  
  // MARK: - Properties
  
  /// Converts the preset into a `View` that can be used in SwiftUI.
  var view: AnyView {
    .init(ParticleSystem(entity: { self })
      .statePersistent("x"))
  }
  
  /// Creates a demo where the preset can be interacted with.
  /// - Parameter customization: Whether to enable preset customization with ``PresetParameter``.
  /// - Parameter debug: Whether to enable Debug Mode in the underlying `ParticleSystem`.
  /// - Returns: The demo view, type-erased.
  /// - SeeAlso: ``PresetParameter``
  func demo(customization: Bool, debug: Bool) -> AnyView {
    .init(PresetDemoView(entry: self, customization: customization, debug: debug))
  }
}
