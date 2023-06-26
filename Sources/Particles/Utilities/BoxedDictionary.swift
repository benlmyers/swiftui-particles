//
//  BoxedDictionary.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import Foundation

class BoxedDictionary<K, V> where K: Hashable {
  var dict: [K: V] = [:]
}
