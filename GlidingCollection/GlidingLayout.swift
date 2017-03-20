//
// GlidingCollection.swift
// GlidingCollection
//
// Created by Abdurahim Jauzee on 06/03/2017.
// Copyright (c) 2017 Ramotion Inc. All rights reserved.
//

import UIKit


public class GlidingLayout: UICollectionViewFlowLayout {
  
  public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
    guard let collectionView = self.collectionView else {
      return proposedContentOffset
    }
    
    let pageWidth = itemSize.width + minimumLineSpacing
    
    let rawPageValue = collectionView.contentOffset.x / pageWidth
    let currentPage = velocity.x > 0 ? floor(rawPageValue) : ceil(rawPageValue)
    let nextPage = velocity.x > 0 ? ceil(rawPageValue) : floor(rawPageValue)
    let pannedLessThanPage = abs(1 + currentPage - rawPageValue) > 0.3
    let flicked = abs(velocity.x) > 0.3
    
    var offset = proposedContentOffset
    if pannedLessThanPage && flicked {
      offset.x = nextPage * pageWidth
    } else {
      offset.x = round(rawPageValue) * pageWidth
    }
    
    return offset
  }
 
  
}
