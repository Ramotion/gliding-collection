//
//  Collection.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 11/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import Foundation

// :nodoc:
extension Collection {
  subscript(safe index: Index) -> Generator.Element? {
    return index >= startIndex && index < endIndex ? self[index] : nil
  }
}
