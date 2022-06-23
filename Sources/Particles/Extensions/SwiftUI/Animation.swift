//
//  Animation.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

extension Animation {
  
  func forever(_ flag: Bool, autoreverses: Bool) -> Self {
    return flag ? self.repeatForever(autoreverses: autoreverses) : self
  }
}
