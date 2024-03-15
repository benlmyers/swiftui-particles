//
//  RenderProxy.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A proxy representing a single spawned entity's render data within a ``ParticleSystem``.
public struct RenderProxy: Equatable {
  
  typealias C = Context
  
  // MARK: - Properties
  
  private var _opacity: UInt16
  private var _hueRotation: UInt8
  private var _blur: UInt8
  #if arch(arm64)
  private var _scaleX: Float16
  private var _scaleY: Float16
  #else
  private var _scaleX: Float32
  private var _scaleY: Float32
  #endif
  private var _blendMode: Int32
  
  // MARK: - Initializers
  
  init() {
    self._opacity = .max
    self._hueRotation = .zero
    self._blur = .zero
    self._scaleX = 1
    self._scaleY = 1
    self._blendMode = GraphicsContext.BlendMode.normal.rawValue
  }
  
  // MARK: - Subtypes
  
  /// Context used to assist in updating the **rendering properties** of a spawned entity.
  /// Every ``Context`` model carries properties that may be helpful in the creation of unique particle systems.
  public struct Context {
    
    // MARK: - Properties
    
    public internal(set) var physics: PhysicsProxy
    public internal(set) var render: RenderProxy
    
    public private(set) weak var system: ParticleSystem.Data!
    
    // MARK: - Initalizers
    
    init(physics: PhysicsProxy, render: RenderProxy, system: ParticleSystem.Data) {
      self.physics = physics
      self.render = render
      self.system = system
    }
  }
}

public extension RenderProxy {
  
  /// The opacity of the particle, 0.0 to 1.0.
  var opacity: Double { get {
    Double(_opacity) / Double(UInt16.max)
  } set {
    _opacity = UInt16(clamping: Int(newValue * Double(UInt16.max)))
  }}
  
  /// The hue rotation angle of the particle.
  var hueRotation: Angle { get {
    Angle(degrees: Double(_hueRotation) * 1.41176)
  } set {
    _hueRotation = UInt8(clamping: Int(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083))))
  }}
  
  /// The blur of the particle.
  var blur: CGFloat { get {
    CGFloat(_blur) * 3.0
  } set {
    _blur = UInt8(clamping: Int(newValue / 3))
  }}
  
  /// The x- and y-scale of the particle. Default `1.0 x 1.0`.
  var scale: CGSize { get {
    CGSize(width: CGFloat(_scaleX), height: CGFloat(_scaleY))
  } set {
    _scaleX = .init(newValue.width)
    _scaleY = .init(newValue.height)
  }}
  
  /// The blending mode of the particle.
  var blendMode: GraphicsContext.BlendMode { get {
    .init(rawValue: _blendMode)
  } set {
    _blendMode = newValue.rawValue
  }}
}
