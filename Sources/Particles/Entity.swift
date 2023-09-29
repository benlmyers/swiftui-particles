//
//  Entity.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Foundation

public class Entity: Identifiable, Hashable, Equatable {
  
  /// The entity's ID.
  public private(set) var id: UUID = UUID()
  /// The parent of the entity.
  public private(set) weak var parent: Entity?
  /// The children of the entity.
  public internal(set) var children: Set<Entity?> = .init()
  
  weak var system: ParticleSystem.Data?
  
  // MARK: - Initalizers
  
  init() {}
  
  // MARK: - Conformance
  
  public static func == (lhs: Entity, rhs: Entity) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    return id.hash(into: &hasher)
  }
  
  // MARK: - Methods
  
  func supply(system: ParticleSystem.Data) {
    self.system = system
  }
}
