//
//  NodeInitializable.swift
//
//
//  Created by Ben Myers on 10/1/23.
//

import Foundation

protocol NodeInitializable {
}

extension NodeInitializable {
  internal static func write<K>(keyPath: AnyKeyPath, object: K, value: Any?) {
      let path = keyPath as? ReferenceWritableKeyPath<K, Self> // use ReferenceWritableKeyPath for classes and WritableKeyPath for structs
      object[keyPath: path!] = value as! Self // or any other conversion to convert the value you have to the type you want

  }
}
