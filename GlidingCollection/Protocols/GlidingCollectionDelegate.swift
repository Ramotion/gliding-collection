//
//  GlidingCollectionDelegate.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 11/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import Foundation


public protocol GlidingCollectionDelegate {
  func glidingCollection(_ collection: GlidingCollection, willExpandItemAt index: Int)
  func glidingCollection(_ collection: GlidingCollection, didExpandItemAt index: Int)
  func glidingCollection(_ collection: GlidingCollection, didSelectItemAt index: Int)
}
