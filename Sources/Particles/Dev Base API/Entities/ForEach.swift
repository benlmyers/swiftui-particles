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
public struct ForEach<Data>: Entity where Data: RandomAccessCollection {
  
  // MARK: - Properties
  
  public var body: Group { .init(values: data.map({ .init(body: mapping($0)) }), merges: merges) }
  
  internal var data: Data
  internal var mapping: (Data.Element) -> any Entity
  internal var merges: Group.Merges?
  
  // MARK: - Initalizers
  
  /// - Parameter data: The data to iterate over.
  /// - Parameter copy: The type of data to copy while iterating over elements. Used to optimize the particle system. See ``Group/CopyLevel``.
  /// - Parameter mapping: The mapping of data to Entity behavior.
  public init<E>(_ data: Data, merges: Group.Merges? = nil, @EntityBuilder mapping: @escaping (Data.Element) -> E) where E: Entity {
    self.data = data
    self.mapping = mapping
    self.merges = merges
  }
}
