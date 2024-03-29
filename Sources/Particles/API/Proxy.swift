//
//  Proxy.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A proxy representing a single spawned entity's physics data within a ``ParticleSystem``.
public struct Proxy {
  
  // MARK: - Properties
  
  private var _x: CGFloat
  private var _y: CGFloat
  private var _inception: UInt
  private var _rotation: Double
  private var _torque: Double
  private var _randomSeed : SIMD4<Double>
  
  private var _velX: CGFloat
  private var _velY: CGFloat
  private var _accX: CGFloat
  private var _accY: CGFloat
  private var _lifetime: Double
  
  private var _opacity: Double
  private var _hueRotation: Double
  private var _blur: CGFloat
  private var _scaleX: CGFloat
  private var _scaleY: CGFloat
  private var _blendMode: Int32
  private var _rotation3d: SIMD3<Double>
  
  // MARK: - Initalizers
  
  internal init(currentFrame: UInt) {
    _x = .zero
    _y = .zero
    _velX = .zero
    _velY = .zero
    _accX = .zero
    _accY = .zero
    _rotation = .zero
    _torque = .zero
    _inception = UInt(currentFrame)
    _lifetime = 5.0
    _randomSeed = .random(in: 0.0 ... 1.0)
    _opacity = 1.0
    _hueRotation = .zero
    _blur = .zero
    _scaleX = 1
    _scaleY = 1
    _blendMode = GraphicsContext.BlendMode.normal.rawValue
    _rotation3d = .zero
  }
  
  // MARK: - Subtypes
  
  /// Context used to assist in updating the **physical properties** of a spawned entity.
  /// Every ``Context`` model carries properties that may be helpful in the creation of unique particle systems.
  public struct Context {
    
    // MARK: - Stored Properties
    
    public internal(set) var proxy: Proxy
    
    public private(set) weak var system: ParticleSystem.Data!
    
    // MARK: - Computed Properties
    
    public var timeAlive: TimeInterval {
      return (Double(system.currentFrame) - Double(proxy.inception)) / Double(system.averageFrameRate)
    }
    
    // MARK: - Initalizers
    
    internal init(proxy: Proxy, system: ParticleSystem.Data) {
      self.proxy = proxy
      self.system = system
    }
  }
}

public extension Proxy {
  
  /// The position of the entity, in pixels.
  var position: CGPoint { get {
    CGPoint(x: _x, y: _y)
  } set {
    _x = newValue.x
    _y = newValue.y
  }}
  
  /// The velocity of the entity, in pixels **per frame**.
  var velocity: CGVector { get {
    CGVector(dx: _velX, dy: _velY)
  } set {
    _velX = .init(newValue.dx)
    _velY = .init(newValue.dy)
  }}
  
  /// The acceleration of the entity, in pixels **per frame per frame**.
  var acceleration: CGVector { get {
    CGVector(dx: CGFloat(_accX), dy: CGFloat(_accY))
  } set {
    _accX = .init(newValue.dx)
    _accY = .init(newValue.dy)
  }}
  
  /// The rotation angle of the entity.
  var rotation: Angle { get {
    .degrees(_rotation)
  } set {
    _rotation = newValue.degrees.truncatingRemainder(dividingBy: 360.0)
  }}
  
  /// The rotational torque angle of the entity **per frame**.
  var torque: Angle { get {
    .degrees(_torque)
  } set {
    _torque = newValue.degrees.truncatingRemainder(dividingBy: 360.0)
  }}
  
  /// The frame number upon which the entity was created.
  var inception: Int {
    Int(_inception)
  }
  
  /// The lifetime, in seconds, of the entity.
  var lifetime: Double { get {
    Double(_lifetime)
  } set {
    _lifetime = .init(newValue)
  }}
  
  /// Four random seeds that can be used to customize the behavior of spawned particles.
  /// Each of the integer values contains a value 0.0 - 1.0.
  var seed: (Double, Double, Double, Double) {
    (_randomSeed.x, _randomSeed.y, _randomSeed.z, _randomSeed.w)
  }
  
  /// The opacity of the particle, 0.0 to 1.0.
  var opacity: Double { get {
    _opacity
  } set {
    _opacity = newValue
  }}
  
  /// The hue rotation angle of the particle.
  var hueRotation: Angle { get {
    .degrees(_hueRotation)
  } set {
    _hueRotation = newValue.degrees
  }}
  
  /// The blur of the particle.
  var blur: CGFloat { get {
    _blur
  } set {
    _blur = newValue
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
  
  var rotation3d: SIMD3<Double> { get {
    _rotation3d
  } set {
    _rotation3d = newValue
  }}
}
