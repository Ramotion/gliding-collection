//
// GlidingCollection.swift
// GlidingCollection
//
// Created by Abdurahim Jauzee on 06/03/2017.
// Copyright (c) 2017 Ramotion Inc. All rights reserved.
//


import UIKit

/// :nodoc:
protocol GlidingLayoutDelegate {
  func collectionViewDidScroll()
}

class GlidingLayout: UICollectionViewFlowLayout {
  
  var delegate: GlidingLayoutDelegate?
  
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
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
 
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    delegate?.collectionViewDidScroll()
    return true
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
    guard GlidingConfig.shared.isParallaxEnabled else { return attributes }
    let transformed = attributes.map { transformLayoutAttributes($0) }
    return transformed
  }
  
  private func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    
    guard let collectionView = self.collectionView else { return attributes }
    
    let startOffset = (attributes.frame.origin.x - collectionView.contentOffset.x - sectionInset.left) / attributes.frame.width
    let maxScale: CGFloat = 1.2
    let minScale: CGFloat = 1.0
    
    let divided = abs(startOffset) / 10
    let scale = max(minScale, min(maxScale, 1.0 + divided))
    
    if let contentView = collectionView.cellForItem(at: attributes.indexPath)?.contentView, let parallaxView = contentView.viewWithTag(99) {
      parallaxView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
  
    return attributes
  }
  
}
