//
//  ContourLattice.swift
//  
//
//  Created by Demirhan Mehmet Atabey on 7.04.2024.
//
//

import Vision
import SwiftUI
import Foundation
import CoreGraphics

/// A lattice entity group that 'imitates' a view by creating a grid of colored particles.
///
/// You can customize the behavior of each particle to create neat effects on your views:
/// ```
/// Lattice(spacing: 3) {
///   Text("Hello, World!").font(.title).fontWeight(.bold)
/// } withBehavior: { p in
///   p
///     .initialVelocity(xIn: -0.05 ... 0.05, yIn: -0.05 ... 0.05)
///     .lifetime(4)
///     .initialAcceleration(y: 0.0002)
/// } customView: {
///   Circle().frame(width: 3.0, height: 3.0)
/// }
/// ```
public struct ContourLattice: Entity, Transparent {
  
  // MARK: - Properties
  
  private var customView: AnyView = AnyView(Circle().frame(width: 2.0, height: 2.0))
  private var spawns: [(CGPoint, Color)]
  private var viewSize: CGSize
  private var color: Color
  private var originView: AnyView
  var image: CGImage
  // MARK: - Initalizers
  
  /// Creates a new Lattice particle group, which creates a grid of colored particles atop the opaque pixels of a view.
  /// - Parameter spacing: Distance between each particle in the lattice.
  /// - Parameter view: The view that is used as a source layer to choose where to spawn various colored particles.
  public init<Base>(
    spacing: Int = 2,
    color: Color = .red,
    @ViewBuilder view: () -> Base
  ) where Base: View {
    guard let viewImage = view().asImage()?.cgImage else {
      fatalError("Particles could not convert view to image correctly. (ContourLattice)")
    }
    self.image = viewImage

    self.spawns = []
    viewSize = .init(width: viewImage.width / 2, height: viewImage.height / 2)
    self.color = color
    self.customView = AnyView(Circle().frame(width: 1, height: 1))
    self.originView = AnyView(view())
    let points = self.getContourPoints(for: viewImage)
    
    for point in points {
      let modifiedPoint = CGPoint(x: point.x * (viewSize.width), y: point.y * (viewSize.height))
      self.spawns.append((modifiedPoint, color))
    }
  }
  
  // MARK: - Body Entity
  
  public var body: some Entity {
    Group {
      ForEach(spawns, merges: .views) { spawn in
        Particle(anyView: customView)
          .initialOffset(x: spawn.0.x, y: spawn.0.y)
          .colorOverlay(spawn.1)
      }
    }
  }
  
  // MARK: - Modifiers
  
  public func customView<V>(@ViewBuilder view: () -> V) -> ContourLattice where V: View {
    var copy = self
    copy.customView = .init(view())
    return copy
  }
  
  func getContourPoints(for image: CGImage) -> [CGPoint] {
    let inputImage = CIImage(cgImage: image)
    
    let contourRequest = VNDetectContoursRequest.init()
    contourRequest.revision = VNDetectContourRequestRevision1
    contourRequest.contrastAdjustment = 1.0
    contourRequest.detectsDarkOnLight = true
    contourRequest.maximumImageDimension = 512
    
    let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])
    try! requestHandler.perform([contourRequest])
    let contoursObservation = contourRequest.results?.first!
    let topLevelContour = contoursObservation?.topLevelContours.first
    
    var contour: VNContour?
    if (topLevelContour?.childContourCount ?? 0) > 0 {
      contour = topLevelContour?.childContours[0]
    } else {
      contour = topLevelContour
    }
    let path = contour?.normalizedPath
    return path?.points ?? []
  }
}

/// Extension to collect CGPath points
extension CGPath {
  /// this is a computed property, it will hold the points we want to extract
  var points: [CGPoint] {
     /// this is a local transient container where we will store our CGPoints
     var arrPoints: [CGPoint] = []
     self.applyWithBlock { element in
        switch element.pointee.type
        {
        case .moveToPoint, .addLineToPoint:
          arrPoints.append(element.pointee.points.pointee)
        case .addQuadCurveToPoint:
          arrPoints.append(element.pointee.points.pointee)
          arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
        case .addCurveToPoint:
          arrPoints.append(element.pointee.points.pointee)
          arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
          arrPoints.append(element.pointee.points.advanced(by: 2).pointee)
        default:
          break
        }
     }
    return arrPoints
  }
}
