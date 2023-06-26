//
//  ParticleSystemBuilder.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

@resultBuilder
public struct ParticleSystemBuilder {
  
  public static func buildBlock<Content>(_ parts: Entity<Content>...) -> [Entity<Content>] where Content: View {
    return parts
  }
  
  static func buildEither<Content>(first component: Entity<Content>) -> [Entity<Content>] where Content: View {
    return [component]
  }
  
  static func buildEither<Content>(second component: Entity<Content>) -> [Entity<Content>] where Content: View {
    return [component]
  }
  
  static func buildArray<Content>(_ components: [Entity<Content>]) -> [Entity<Content>] where Content: View {
    return components
  }
}
