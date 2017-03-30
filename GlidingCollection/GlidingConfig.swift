//
// GlidingCollection.swift
// GlidingCollection
//
// Created by Abdurahim Jauzee on 06/03/2017.
// Copyright (c) 2017 Ramotion Inc. All rights reserved.
//

import UIKit

/// Configuration struct. 
/// Override `shared` property to apply new configuration.
public struct GlidingConfig {

  /// Shared instance of configuration. 
  /// Override this property or change values directly.
  public static var shared = GlidingConfig()
  
  /// Side insets of GlidiingCollection view.
  /// Only left & right side insets will take effect.
  public var sideInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
  
  /// Duration of animation between GlidingCollection sections.
  public var animationDuration: Double = 0.3
  
  /// Spacing between vertical stack of items.
  public var buttonsSpacing: CGFloat = 15
  
  /// Font of each element in vertical stack.
  public var buttonsFont = UIFont.systemFont(ofSize: 16)
  
  /// Scale factor of inactive sections buttons.
  public var buttonsScaleFactor: CGFloat = 0.65
  
  /// Active section button color.
  public var activeButtonColor: UIColor = .darkGray
  
  /// Inactive sections buttons color.
  public var inactiveButtonsColor: UIColor = .lightGray
  
  /// Space between collectionView's cells.
  public var cardsSpacing: CGFloat = 30
  
  /// Size of collectionView's cells.
  public var cardsSize = CGSize(width: round(UIScreen.main.bounds.width * 0.65), height: round(UIScreen.main.bounds.height * 0.45))
  
  /// Apply parallax effect to horizontal cards.
  public var isParallaxEnabled = true
  
  /// Shadow color.
  public var cardShadowColor = UIColor.black
  
  /// Shadow offset: width - horizontal; height - vertical.
  public var cardShadowOffset = CGSize(width: 0, height: 5)
  
  /// Shadow radius or blur.
  public var cardShadowRadius: CGFloat = 7
  
  /// Shadow opacity.
  public var cardShadowOpacity: Float = 0.3

}
