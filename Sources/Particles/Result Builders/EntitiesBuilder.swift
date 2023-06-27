//
//  ParticleSystemBuilder.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

@resultBuilder
public struct EntitiesBuilder {
  
  public static func buildBlock(_ parts: Entity...) -> [Entity] {
    return parts
  }
  
  static func buildEither(first component: Entity) -> [Entity] {
    return [component]
  }
  
  static func buildEither(second component: Entity) -> [Entity] {
    return [component]
  }
  
  static func buildArray(_ components: [Entity]) -> [Entity] {
    return components
  }
}
