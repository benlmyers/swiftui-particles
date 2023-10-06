//
//  Confetti.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Particles

public struct Confetti: Extension {

  public var name: String = "Confetti"
  public var description: String = "An extension used to create fun confetti particle effects."
  public var author: String = "Particles"
  
  public var example: some View {
    Confetti.System()
  }
}
