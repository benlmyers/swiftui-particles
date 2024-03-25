//
//  ForEach.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

/// An entity that creates several entities iterated over data elements.
/// Creating multiple entities iterated over data elements is simple with ``ForEach``; it is similar to how views are defined within SwiftUI:
/// ```
/// ForEach([Color.red, .orange, .yellow]) { color in
///   Particle {
///     Text("Hi").foregroundColor(color)
///   }
/// }
/// ```
/// Modifiers placed outside a ``ForEach`` behave like ``Group``; they are applied to the inner entities:
/// ```
/// ForEach(...) { x in ... }
///   .initialPosition(.center)
///   .initialVelocity(xIn: -1.0 ... 1.0, yIn: -1.0 ... 1.0)
/// ```
/// In the example above, the entities spawned inside the `ForEach` all spawn in the center of the screen with a random velocity.
public struct ForEach<Data>: Entity, Transparent where Data: RandomAccessCollection {
  
  // MARK: - Properties
  
  public var body: Particles.Group

  internal var data: Data
  internal var mapping: (Data.Element) -> any Entity
  internal var merges: Group.Merges?
  
  // MARK: - Initalizers
  
  /// - Parameter data: The data to iterate over.
  /// - Parameter merges: The merge rule to use when grouping entities. For more information, see ``Group/Merges``.
  /// - Parameter mapping: The mapping of data to entities.
  public init<E>(
    _ data: Data,
    merges: Group.Merges? = nil,
    @EntityBuilder mapping: @escaping (Data.Element) -> E
  ) where E: Entity {
    self.data = data
    self.mapping = mapping
    self.merges = merges
    self.body = Group(values: data.map({ .init(body: mapping($0)) }), merges: merges)
  }
}
