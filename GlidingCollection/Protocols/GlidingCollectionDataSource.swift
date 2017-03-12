//
//  GlidingCollectionDataSource.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 11/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import Foundation


public protocol GlidingCollectionDatasource {
  func numberOfItems(in collection: GlidingCollection) -> Int
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String
}
