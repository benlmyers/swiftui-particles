//
//  Burst.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import Foundation
import SwiftUI

public struct Burst: Entity {
  
  // MARK: - Properties
  
  internal var imagePixels: [(x: Int, y: Int)] = []
  internal var view: AnyView = .init(EmptyView())
  internal var viewAsImage: CGImage? = nil
  internal var color: Color?
  
  /// Color in RGBA format.
  var colorRBA: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
    return color?.rgba
  }
  /// CFData of the image.
  private var imgData: CFData? {
    viewAsImage?.dataProvider?.data
  }
  
  // MARK: - Body Entity
  
  public var body: some Entity {
    Emitter {
      ForEach(imagePixels) { pixel in
        Particle {
          Circle()
            .fill(Color.toColor(from: getPixelColor(x: pixel.0, y: pixel.1)))
            .frame(width: 1, height: 1)
        }
        .initialPosition(x: CGFloat(pixel.x), y: CGFloat(pixel.y))
      }
    }
  }
  
  public init<V>(
    color: Color? = nil,
    particle: (Particle) -> () = { _ in },
    view: () -> AnyView = { AnyView(Circle().frame(width: 1, height:1)) },
    @ViewBuilder v: () -> V
  ) where V: View {
    self.color = color
    self.view = AnyView(v())
    self.viewAsImage = v().asImage().cgImage
    guard let viewAsImage else {
      print("Particles can not convert view to image correctly. No drawing operations performed")
      return
    }
    for width in 0..<viewAsImage.width {
      for height in 0..<viewAsImage.height {
        imagePixels.append((width, height))
      }
    }
  }
  
  private func getPixelColor(x: Int, y: Int) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    guard let viewAsImage else { return ( 0,0,0,0 ) }
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imgData)
    let pixelInfo: Int = ((viewAsImage.width * y) + x) * 4
    
    let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
    let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
    let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
    let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
    
    return (r, g, b, a)
  }
}
