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
public struct ForEach<T>: Entity {
  
  // MARK: - Properties
  
  public var body: Group { .init(values: data.map({ .init(body: mapping($0)) })) }
  
  internal var data: [T]
  internal var mapping: (T) -> any Entity
  
  // MARK: - Initalizers
  
  public init<E>(_ data: [T], @EntityBuilder mapping: @escaping (T) -> E) where E: Entity {
    self.data = data
    self.mapping = mapping
  }
}
