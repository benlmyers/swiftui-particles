//
//  ForEach.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

public struct ForEach<T>: Entity {
  
  // MARK: - Properties
  
  public var body: Group { .init(values: data.map({ .init(body: mapping($0)) })) }
  internal var data: [T]
  internal var mapping: (T) -> any Entity
  
  // MARK: - Initalizers
  
  public init<E>(in data: [T], @EntityBuilder mapping: @escaping (T) -> E) where E: Entity {
    self.data = data
    self.mapping = mapping
  }
}
