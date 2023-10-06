//
//  Extension.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Particles
import Foundation

/// A protocol defining a pack extension.
public protocol Extension {
  
  associatedtype Body
  
  /// The name of the extension.
  var name: String { get }
  /// The description of the extension.
  var description: String { get }
  /// The author of the extension.
  var author: String { get }
  
  /// Examples of the extension in use via particle systems.
  @ViewBuilder var example: Body { get }
}
