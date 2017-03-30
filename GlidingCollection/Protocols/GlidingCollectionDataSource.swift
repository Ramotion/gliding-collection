//
//  GlidingCollectionDataSource.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 11/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import Foundation

/// Datasource protocol of GlidingCollection.
public protocol GlidingCollectionDatasource {
  
  /// Number of items in vertical stack of items.
  ///
  /// - Parameter collection: GlidingCollection
  /// - Returns: number of items in stack
  func numberOfItems(in collection: GlidingCollection) -> Int
  
  /// Item at given index.
  ///
  /// - Parameters:
  ///   - collection: GlidingCollection
  ///   - index: index of item
  /// - Returns: item title
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String
  
}
