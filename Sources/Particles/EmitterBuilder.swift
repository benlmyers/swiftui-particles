//
//  EmitterBuilder.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

@resultBuilder
public struct EmitterBuilder {
  
  public static func buildBlock<Content>(_ parts: Content...) -> [Content] where Content: View {
    return parts
  }
  
  static func buildEither<Content>(first component: Content) -> [Content] where Content: View {
    return [component]
  }
  
  static func buildEither<Content>(second component: Content) -> [Content] where Content: View {
    return [component]
  }
  
  static func buildArray<Content>(_ components: [Content]) -> [Content] where Content: View {
    return components
  }
}
