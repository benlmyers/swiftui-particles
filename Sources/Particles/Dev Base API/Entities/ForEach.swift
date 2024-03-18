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
  
  public var body: Group { .init(values: data.map({ .init(body: mapping($0)) })) }
  
  internal var data: Data
  internal var mapping: (Data.Element) -> any Entity
  internal var copiesViews: Bool
  
  // MARK: - Initalizers
  
  public init<E>(_ data: Data, copiesViews: Bool = true, @EntityBuilder mapping: @escaping (Data.Element) -> E) where E: Entity {
    self.data = data
    self.mapping = mapping
    self.copiesViews = copiesViews
  }
}
