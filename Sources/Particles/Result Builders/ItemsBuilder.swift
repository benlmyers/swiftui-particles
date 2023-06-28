//
//  ItemsBuilder.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

@resultBuilder
public struct ItemsBuilder {
  
  public static func buildBlock(_ parts: Item...) -> [Item] {
    return parts
  }
  
  static func buildEither(first component: Item) -> [Item] {
    return [component]
  }
  
  static func buildEither(second component: Item) -> [Item] {
    return [component]
  }
  
  static func buildArray(_ components: [Item]) -> [Item] {
    return components
  }
}
