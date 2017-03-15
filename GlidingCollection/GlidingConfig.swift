//
// GlidingCollection.swift
// GlidingCollection
//
// Created by Abdurahim Jauzee on 06/03/2017.
// Copyright (c) 2017 Ramotion Inc. All rights reserved.
//

import UIKit


public struct GlidingConfig {

  /// Shared instance of configuration. 
  /// Override this property or change it's value directly.
  public static var shared = GlidingConfig()
  
  /// Side insets of GlidiingCollection view.
  /// Only left & right side insets will take effect.
  public var sideInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: 0, right: 0)
  
  /// Duration of animation between GlidingCollection sections
  public var animationDuration: Double = 0.3
  
  /// Spacing between vertical stack of items
  public var buttonsSpacing: CGFloat = 15
  
  /// Font size of each element in vertical stack
  public var buttonsFontSize: CGFloat = 16
  
  /// Scale factor of inactive sections buttons
  public var buttonsScaleFactor: CGFloat = 0.75
  
  /// Active section button color
  public var activeButtonColor: UIColor = .darkGray
  
  /// Inactive sections buttons color
  public var inactiveButtonsColor: UIColor = .lightGray
  
  /// Space between collectionView's cells
  public var cardsSpacing: CGFloat = 30
  
  /// Size of collectionView's cells
  public var cardsSize: CGSize = CGSize(width: round(UIScreen.main.bounds.width * 0.65), height: round(UIScreen.main.bounds.height * 0.4))
  
  /// Scroll to first cell in collectionView if
  /// GlidingCollection section was changed.
  public var scrollsToFirstScroll = true

}
