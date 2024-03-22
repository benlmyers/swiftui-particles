//
//  PhysicsProxy.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A proxy representing a single spawned entity's physics data within a ``ParticleSystem``.
public struct PhysicsProxy {
  
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
  }
  
  // MARK: - Subtypes
  
  /// Context used to assist in updating the **physical properties** of a spawned entity.
  /// Every ``Context`` model carries properties that may be helpful in the creation of unique particle systems.
  public struct Context {
    
    // MARK: - Stored Properties
    
    public internal(set) var physics: PhysicsProxy
    
    public private(set) weak var system: ParticleSystem.Data!
    
    // MARK: - Computed Properties
    
    public var timeAlive: TimeInterval {
      return (Double(system.currentFrame) - Double(physics.inception)) / Double(system.averageFrameRate)
    }
    
    // MARK: - Initalizers
    
    internal init(physics: PhysicsProxy, system: ParticleSystem.Data) {
      self.physics = physics
      self.system = system
    }
  }
}

public extension PhysicsProxy {
  
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
}
