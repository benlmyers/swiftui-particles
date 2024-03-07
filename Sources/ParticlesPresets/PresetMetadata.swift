//
//  PresetMetadata.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import Foundation

/// A struct holding metadata about a developer-built particle.
public struct PresetMetadata {
  
  /// The name of the preset.
  public var name: String
  /// The package or target name holding this preset.
  public var target: String
  /// A URL pointing to where the package/target is instealled; i.e. a Github Swift Package repository.
  public var sourceURL: URL?
  /// A description of the preset. Supports Markdown format.
  public var description: String
  /// The author of the preset, usually in the format of a GitHub username.
  public var author: String
  /// A URL pointing to an image/GIF of the preset in action.
  public var previewURL: URL?
  /// An integer representing the version number of this preset.
  public var version: Int
}
