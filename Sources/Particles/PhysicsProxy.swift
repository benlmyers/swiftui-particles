//
//  PhysicsProxy.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A proxy representing a single spawned entity's data within a ``ParticleSystem``.
public struct PhysicsProxy {
  
  // MARK: - Properties
  
  private var _x: UInt16
  private var _y: UInt16
  private var _velX: Float16
  private var _velY: Float16
  private var _accX: Float16
  private var _accY: Float16
  private var _rotation: UInt8
  private var _torque: Int8
  private var _inception: UInt16
  private var _lifetime: Float16
  
  // MARK: - Initalizers
  init(currentFrame: UInt16) {
    _x = .zero
    _y = .zero
    _velX = .zero
    _velY = .zero
    _accX = .zero
    _accY = .zero
    _rotation = .zero
    _torque = .zero
    _inception = currentFrame
    _lifetime = 5.0
  }
  
  // MARK: - Subtypes
  
  /// Context used to assist in updating the **physical properties** of a spawned entity.
  /// Every ``Context`` model carries properties that may be helpful in the creation of unique particle systems.
  public struct Context {
    
    // MARK: - Stored Properties
    
    var physics: PhysicsProxy
    
    public private(set) weak var system: ParticleSystem.Data?
    
    // MARK: - Initalizers
    
    init(physics: PhysicsProxy, system: ParticleSystem.Data) {
      self.physics = physics
      self.system = system
    }
  }
}

public extension PhysicsProxy {
  
  /// The position of the entity, in pixels.
  var position: CGPoint { get {
    CGPoint(x: (CGFloat(_x) - 250.0) / 10.0, y: (CGFloat(_y) - 250.0) / 10.0)
  } set {
    _x = UInt16(clamping: Int(newValue.x * 10.0) + 250)
    _y = UInt16(clamping: Int(newValue.y * 10.0) + 250)
  }}
  
  /// The velocity of the entity, in pixels **per frame**.
  var velocity: CGVector { get {
    CGVector(dx: CGFloat(_velX), dy: CGFloat(_velY))
  } set {
    _velX = Float16(newValue.dx)
    _velY = Float16(newValue.dy)
  }}
  
  /// The acceleration of the entity, in pixels **per frame per frame**.
  var acceleration: CGVector { get {
    CGVector(dx: CGFloat(_accX), dy: CGFloat(_accY))
  } set {
    _accX = Float16(newValue.dx)
    _accY = Float16(newValue.dy)
  }}
  
  /// The rotation angle of the entity.
  var rotation: Angle { get {
    Angle(degrees: Double(_rotation) * 1.41176)
  } set {
    _rotation = UInt8(ceil((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  
  /// The rotational torque angle of the entity **per frame**.
  var torque: Angle { get {
    Angle(degrees: Double(_torque) * 1.41176)
  } set {
    _torque = Int8(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  
  /// The frame number upon which the entity was created.
  var inception: Int {
    Int(_inception)
  }
  
  /// The lifetime, in seconds, of the entity.
  var lifetime: Double { get {
    Double(_lifetime)
  } set {
    _lifetime = Float16(newValue)
  }}
}
