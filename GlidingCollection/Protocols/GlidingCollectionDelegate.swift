//
//  GlidingCollectionDelegate.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 11/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import Foundation

/// This delegate provides methods which can notify when transition starts/ends & when item was selected.
public protocol GlidingCollectionDelegate {
  
  /// This method will be called before starting
  /// transition from one item to another.
  ///
  /// - Parameters:
  ///   - collection: GlidingCollection
  ///   - index: Index of item that being expand.
  func glidingCollection(_ collection: GlidingCollection, willExpandItemAt index: Int)
  
  /// This method will be called when transition
  /// between items was finished.
  ///
  /// - Parameters:
  ///   - collection: GlidingCollection
  ///   - index: Index of expanded item.
  func glidingCollection(_ collection: GlidingCollection, didExpandItemAt index: Int)
  
  /// This method will be called if selected 
  /// one of the element of vertical stack.
  ///
  /// - Parameters:
  ///   - collection: GlidingCollection
  ///   - index: Index of selected item.
  func glidingCollection(_ collection: GlidingCollection, didSelectItemAt index: Int)
  
}

// This extension will make all this methods optional so you can implement just part of this protocol if you wish.
public extension GlidingCollectionDelegate {
  
  func glidingCollection(_ collection: GlidingCollection, willExpandItemAt index: Int) { }
  
  func glidingCollection(_ collection: GlidingCollection, didExpandItemAt index: Int) { }
  
  func glidingCollection(_ collection: GlidingCollection, didSelectItemAt index: Int) { }
  
}
