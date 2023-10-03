//
//  AnyTaggedView.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

struct AnyTaggedView: Hashable {
  
  // MARK: - Properties
  
  var view: AnyView
  var tag: UUID
  
  // MARK: - Static Methods
  
  static func == (lhs: AnyTaggedView, rhs: AnyTaggedView) -> Bool {
    return lhs.tag == rhs.tag
  }
  
  // MARK: - Methods
  
  func hash(into hasher: inout Hasher) {
    return tag.hash(into: &hasher)
  }
}
