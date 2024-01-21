//
//  File.swift
//  
//
//  Created by Ben Myers on 1/21/24.
//

import Foundation
import SwiftUI

public struct Burst: Entity {
  
  private var view: AnyView = .init(EmptyView())
  
  public var body: some Entity {
    EmptyEntity()
  }
  
  public init<V>(@ViewBuilder v: () -> V) where V: View {
    self.view = AnyView(v())
  }
}
