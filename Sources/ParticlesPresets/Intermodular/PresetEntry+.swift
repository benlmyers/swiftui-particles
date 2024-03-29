//
//  PresetEntry+.swift
//  
//
//  Created by Ben Myers on 3/29/24.
//

import SwiftUI
import Foundation

internal extension PresetEntry {
  
  func makeDemo() -> some View {
    ZStack(alignment: .topLeading) {
      self.view
      VStack(alignment: .leading) {
        ForEach(parameters, id: \.name) { parameter in
          HStack {
            Text(parameter.name)
            AnyView(parameter.view)
          }
        }
      }
      .padding()
    }
  }
}
