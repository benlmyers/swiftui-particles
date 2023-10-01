//
//  AnyTaggedView.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

struct AnyTaggedView: Hashable {
  
  var view: AnyView
  var tag: UUID
  
  func hash(into hasher: inout Hasher) {
    return tag.hash(into: &hasher)
  }
  
  static func == (lhs: AnyTaggedView, rhs: AnyTaggedView) -> Bool {
    return lhs.tag == rhs.tag
  }
}
