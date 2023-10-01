//
//  Configured.swift
//
//
//  Created by Ben Myers on 9/29/23.
//

import SwiftUI
import Foundation

@propertyWrapper public class Configured<T> {
  
  public typealias Behavior = (PhysicalEntity) -> T?
  
  public internal(set) var wrappedValue: T
  public internal(set) var inheritsFromParent: Bool = true
  
  private var initialValue: T
  
  private var spawnBehavior: Behavior = { _ in return nil }
  private var updateBehavior: Behavior = { _ in return nil }
  
  public var projectedValue: Configured<T> {
    return self
  }
  
  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
    self.initialValue = wrappedValue
    self.spawnBehavior = { _ in return nil }
  }
  
  public func fix(to constant: T) {
    self.updateBehavior = { _ in
      return constant
    }
  }
  
  public func bind(to binding: Binding<T>) {
    self.updateBehavior = { _ in
      return binding.wrappedValue
    }
  }
  
  public func setSpawnBehavior(to behavior: @escaping Behavior) {
    self.spawnBehavior = behavior
  }
  
  public func setUpdateBehavior(to behavior: @escaping Behavior) {
    self.updateBehavior = behavior
  }
  
  func update(in entity: PhysicalEntity) {
    if let newValue = updateBehavior(entity) {
      wrappedValue = newValue
    }
  }
  
  func copy(parentValue: T? = nil, in entity: PhysicalEntity) -> Configured<T> {
    let copy = Configured<T>.init(wrappedValue: parentValue ?? initialValue)
    copy.updateBehavior = updateBehavior
    copy.spawnBehavior = spawnBehavior
    copy.inheritsFromParent = inheritsFromParent
    if copy.inheritsFromParent, let parentValue {
      copy.wrappedValue = parentValue
    }
    if let spawnVal = spawnBehavior(entity) {
      copy.wrappedValue = spawnVal
    }
    return copy
  }
}
