//
//  Item.swift
//  
//
//  Created by Ben Myers on 6/28/23.
//

import SwiftUI

public class Item: Debuggable {
  
  // MARK: - Properties
  
  /// A reference to the entity's parent system's data.
  var data: ParticleSystem.Data?
  
  // MARK: - Initalizers
  
  init() {}
  
  // MARK: - Conformance
  
  func debug(_ context: GraphicsContext) {
    // Do nothing
  }
}
