//
//  EmptyEntity.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

public struct EmptyEntity: Entity {
  public typealias Body = Never
  public var body: Never { fatalError() }
}
