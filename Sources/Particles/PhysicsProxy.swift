//
//  PhysicsProxy.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

public struct PhysicsProxy {
  typealias C = Context
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
  public struct Context {
    var physics: PhysicsProxy
    weak private(set) var data: ParticleSystem.Data?
    init(physics: PhysicsProxy, data: ParticleSystem.Data) {
      self.physics = physics
      self.data = data
    }
  }
}

public extension PhysicsProxy {
  var position: CGPoint { get {
    CGPoint(x: (CGFloat(_x) - 250.0) / 10.0, y: (CGFloat(_y) - 250.0) / 10.0)
  } set {
    _x = UInt16(clamping: Int(newValue.x * 10.0) + 250)
    _y = UInt16(clamping: Int(newValue.y * 10.0) + 250)
  }}
  var velocity: CGVector { get {
    CGVector(dx: CGFloat(_velX), dy: CGFloat(_velY))
  } set {
    _velX = Float16(newValue.dx)
    _velY = Float16(newValue.dy)
  }}
  var acceleration: CGVector { get {
    CGVector(dx: CGFloat(_accX), dy: CGFloat(_accY))
  } set {
    _accX = Float16(newValue.dx)
    _accY = Float16(newValue.dy)
  }}
  var rotation: Angle { get {
    Angle(degrees: Double(_rotation) * 1.41176)
  } set {
    _rotation = UInt8(ceil((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  var torque: Angle { get {
    Angle(degrees: Double(_torque) * 1.41176)
  } set {
    _torque = Int8(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  var inception: Int {
    Int(_inception)
  }
  var lifetime: Double { get {
    Double(_lifetime)
  } set {
    _lifetime = Float16(newValue)
  }}
}
