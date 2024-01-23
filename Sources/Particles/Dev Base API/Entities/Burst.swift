//
//  Burst.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import Foundation
import SwiftUI

public struct Burst: Entity {
  
  internal var view: AnyView = .init(EmptyView())
  private var color: Color
  private var fillColor: Color
  private var density: Int
  
  var colorRBA: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    return color.rgba
  }

  var viewAsImage: CGImage? {
    view.asImage().cgImage
  }
  
  public var body: some Entity {
    EmptyEntity()
  }
  
  public init<V>(
    skipping backgroundColor: Color = Color.clear,
    fillingWith fillColor: Color = Color.purple,
    density particleDensity: Int = 1,
    @ViewBuilder v: () -> V
  ) where V: View {
    self.color = backgroundColor
    self.fillColor = fillColor
    self.density = particleDensity
    self.view = AnyView(v())
  }
}
