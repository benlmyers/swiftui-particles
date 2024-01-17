//
//  Entity+Render.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  func opacity(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.opacity *= value
      return p
    })
  }
  
  func opacity(_ value: @escaping (RenderProxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.opacity *= value(context)
      return p
    })
  }
  
  func hueRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdateRender: { context in
      var p = context.render
      p.hueRotation = angle
      return p
    })
  }
  
  func hueRotation(_ angle: @escaping (RenderProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdateRender: { context in
      var p = context.render
      p.hueRotation = angle(context)
      return p
    })
  }
  
  func blur(_ size: CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.blur = size
      return p
    })
  }
  
  func blur(_ size: @escaping (RenderProxy.Context) -> CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.blur = size(context)
      return p
    })
  }
  
  func scale(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      if let x {
        p.scale.width *= x
      }
      if let y {
        p.scale.height *= y
      }
      return p
    })
  }
  
  func scale(x: @escaping (RenderProxy.Context) -> CGFloat?, y: @escaping (RenderProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      if let x = x(context) {
        p.scale.width *= x
      }
      if let y = y(context) {
        p.scale.height *= y
      }
      return p
    })
  }
  
  func scale(_ size: CGFloat) -> some Entity {
    self.scale(x: size, y: size)
  }
  
  func scale(_ size: @escaping (RenderProxy.Context) -> CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      let s = size(context)
      p.scale.width *= s
      p.scale.height *= s
      return p
    })
  }
}
