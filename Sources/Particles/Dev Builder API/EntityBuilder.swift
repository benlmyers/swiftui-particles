//
//  EntityBuilder.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

/// A result builder used to build entities.
/// If multiple entities are passed, an ``Group`` is returned.
@resultBuilder
public struct EntityBuilder {
  
  public static func buildExpression<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E1, E2>(_ c1: E1, _ c2: E2) -> Group where E1: Entity, E2: Entity {
    Group(values: [.init(body: c1), .init(body: c2)])
  }
  
  public static func buildBlock<E1, E2, E3>(_ c1: E1, _ c2: E2, _ c3: E3) -> Group where E1: Entity, E2: Entity, E3: Entity {
    Group(values: [.init(body: c1), .init(body: c2), .init(body: c3)])
  }
  
  public static func buildBlock<E1, E2, E3, E4>(
    _ c1: E1, _ c2: E2, _ c3: E3, _ c4: E4
  ) -> some Entity where E1: Entity, E2: Entity, E3: Entity, E4: Entity {
    Group(values: [.init(body: c1), .init(body: c2), .init(body: c3), .init(body: c4)])
  }
  
//  public static func buildIf<T>(_ content: T) -> EmptyEntity where T: Entity {
//    return .init()
//  }
  
  public static func buildEither<T>(first: T) -> Group where T: Entity {
    return .init(values: [.init(body: first), .init(body: EmptyEntity())])
  }

  public static func buildEither<F>(second: F) -> Group where F: Entity {
    return .init(values: [.init(body: EmptyEntity()), .init(body: second)])
  }
}
