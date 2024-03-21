//
//  ModifiedEntity.swift
//  
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

internal struct ModifiedEntity<E>: Entity where E: Entity {
  
  var body: E
  
  private var birthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)?
  private var updatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)?
  private var birthRender: ((RenderProxy.Context) -> RenderProxy)?
  private var updateRender: ((RenderProxy.Context) -> RenderProxy)?
  
  init(
    entity: E,
    onBirthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onUpdatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onBirthRender: ((RenderProxy.Context) -> RenderProxy)? = nil,
    onUpdateRender: ((RenderProxy.Context) -> RenderProxy)? = nil
  ) {
    self.body = entity
    self.birthPhysics = onBirthPhysics
    self.updatePhysics = onUpdatePhysics
    self.birthRender = onBirthRender
    self.updateRender = onUpdateRender
  }
  
  func _onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    let performanceTimer = PerformanceTimer(title: "PHYSICS BIRTH")
    guard let data = context.system else { return body._onPhysicsBirth(context) }
    guard let birthPhysics else { return body._onPhysicsBirth(context) }
    let newContext: PhysicsProxy.Context = .init(physics: body._onPhysicsBirth(context), system: data)
    performanceTimer.calculateElapsedTime()
    return birthPhysics(newContext)
  }
  
  func _onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    let performanceTimer = PerformanceTimer(title: "PHYSICS PROXY UPDATE")
    guard let data = context.system else { return body._onPhysicsUpdate(context) }
    guard let updatePhysics else { return body._onPhysicsUpdate(context) }
    let newContext: PhysicsProxy.Context = .init(physics: body._onPhysicsUpdate(context), system: data)
    performanceTimer.calculateElapsedTime()
    return updatePhysics(newContext)
  }
  
  func _onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    let performanceTimer = PerformanceTimer(title: "PHYSICS RENDER BIRTH")
    guard let data = context.system else { return body._onRenderBirth(context) }
    guard let birthRender else { return body._onRenderBirth(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: body._onRenderBirth(context), system: data)
    performanceTimer.calculateElapsedTime()
    return birthRender(newContext)
  }
  
  func _onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    let performanceTimer = PerformanceTimer(title: "PHYSICS RENDER UPDATE")
    guard let data = context.system else { return body._onRenderUpdate(context) }
    guard let updateRender else { return body._onRenderUpdate(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: body._onRenderUpdate(context), system: data)
    performanceTimer.calculateElapsedTime()
    return updateRender(newContext)
  }
}

struct PerformanceTimer {
  var startTime = CFAbsoluteTimeGetCurrent()
  var title: String
  static var callMap: [String: Int] = [:]
  static var timeMap: [String: TimeInterval] = [:]
  
  func calculateElapsedTime(
    subTitle: String = "",
    prints: Bool = false,
    enabling: Bool = false
  ) {
    if enabling {
      let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
      if prints {
        print("Time elapsed for \(title) \(subTitle): \(timeElapsed) s.")
      }
      DispatchQueue.main.async {
        if let c = Self.callMap[title] {
          Self.callMap[title] = c + 1
        } else {
          Self.callMap[title] = 0
        }
        if let t = Self.timeMap[title] {
          Self.timeMap[title] = t + Double(timeElapsed)
        } else {
          Self.timeMap[title] = 0
        }
      }
    }
  }
  
  static func printCallMap(resets: Bool = false) {
    print("Total Calls: \(callMap.sorted { $0.value > $1.value})")
    print("Total Time Spent: \(timeMap.sorted { $0.value > $1.value })")
    if resets {
      Self.callMap = [:]
      Self.timeMap = [:]
    }
  }
}
