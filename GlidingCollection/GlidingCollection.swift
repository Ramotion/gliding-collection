//
//  GlidingCollection.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 06/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit


public class GlidingCollection: UIView {
  
  /// Delegate protocol.
  public var delegate: GlidingCollectionDelegate?
  
  /// Data source protocol.
  public var dataSource: GlidingCollectionDatasource? {
    didSet {
      setupVerticalStack()
    }
  }
  
  /// Index of expanded item.
  public var expandedItemIndex = 0
  
  /// Horizontal scrolling collectionView.
  public var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  
  // MARK: Private properties
  fileprivate var containerView = UIView()
  fileprivate var scaledTransform: CGAffineTransform {
    let scale = config.buttonsScaleFactor
    return CGAffineTransform(scaleX: scale, y: scale)
  }
  fileprivate var config: GlidingConfig {
    return GlidingConfig.shared
  }
  
  // Gesture related properties.
  fileprivate var gesture: UIPanGestureRecognizer!
  fileprivate var gestureStartPosition: CGPoint = .zero
  fileprivate var gestureTranslation: CGFloat = 0
  fileprivate enum Direction {
    case up, down
  }
  fileprivate var lastDirection = Direction.down
  
  fileprivate var lastExpandedItemIndex = 0
  fileprivate var animationInProcess = false
  fileprivate var animationViewsDictionary: [String: AniView] = [:]
  fileprivate var topOverlayGradient = CAGradientLayer()
  fileprivate var bottomOverlayGradient = CAGradientLayer()
  fileprivate var topViews: [UIButton] = []
  fileprivate var bottomViews: [UIButton] = []
  
  // MARK: Snapshots
  fileprivate var newRightSideSnapshot: UIView?
  fileprivate var topHalfSnapshot: UIView?
  fileprivate var topHalfSnapshotFrame: CGRect = .zero
  fileprivate var bottomHalfSnapshot: UIView?
  fileprivate var bottomHalfSnapshotFrame: CGRect = .zero
  
  // MARK: Constructor
  /// :nodoc:
  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  /// :nodoc:
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    setup()
    animateTopButtons()
    animateBottomButtons()
  }
  
}

// MARK: - Lifecycle 🌎
extension GlidingCollection: UIGestureRecognizerDelegate {
  
  /// :nodoc:
  public override func layoutSubviews() {
    super.layoutSubviews()
    containerView.frame = bounds
    
    let cardSize = config.cardsSize
    collectionView.frame = CGRect(x: 0, y: bounds.height/2 - cardSize.height/2, width: bounds.width, height: cardSize.height)
    
    animateTopButtons()
    animateBottomButtons()
    
    let topOverylayHeight = collectionView.frame.minY
    topOverlayGradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: topOverylayHeight)
    
    let bottomOverylayHeight = bounds.height - collectionView.frame.maxY
    bottomOverlayGradient.frame = CGRect(x: 0, y: collectionView.frame.maxY, width: bounds.width, height: bottomOverylayHeight)
  }
  
//  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    return true
//  }
  
}

// MARK: - Setup ⛏
fileprivate extension GlidingCollection {
  
  func setup() {
    addSubview(containerView)
    setupCollectionView()
    setupVerticalStack()
    setupPanGesture()
    setupGradientOverlays()
  }
  
  private func setupCollectionView() {
    let layout = GlidingLayout()
    layout.itemSize = config.cardsSize
    layout.minimumLineSpacing = config.cardsSpacing
    layout.scrollDirection = .horizontal
    let insets = config.sideInsets
    let rightInset = UIScreen.main.bounds.width - config.cardsSize.width
    layout.sectionInset = UIEdgeInsets(top: 0, left: insets.left, bottom: 0, right: rightInset)
    layout.delegate = self
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    containerView.insertSubview(collectionView, at: 0)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.delaysContentTouches = true
  }
  
  fileprivate func setupVerticalStack() {
    guard
      let source = dataSource,
      source.numberOfItems(in: self) > 0 else {
        return
    }
    
    for i in 0..<source.numberOfItems(in: self) {
      let isTopTitle = i <= expandedItemIndex
      let title = source.glidingCollection(self, itemAtIndex: i).uppercased()
      
      let button = UIButton()
      button.contentHorizontalAlignment = .left
      
      let color = isTopTitle ? config.activeButtonColor : config.inactiveButtonsColor
      button.setTitleColor(color, for: .normal)
      button.setTitle(title, for: .normal)
      button.titleLabel?.font = config.buttonsFont
      button.layer.anchorPoint = CGPoint(x: 0, y: 0)
      button.transform = scaledTransform
      
      isTopTitle ? topViews.append(button) : bottomViews.append(button)
      containerView.insertSubview(button, at: 0)
      button.addTarget(self, action: #selector(didTapped(_:)), for: .touchUpInside)
    }
    
  }

  private func setupGradientOverlays() {
    topOverlayGradient.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
    
    bottomOverlayGradient.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
    
    layer.addSublayer(topOverlayGradient)
    layer.addSublayer(bottomOverlayGradient)
  }
  
  private func setupPanGesture() {
    gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    gesture.delegate = self
    addGestureRecognizer(gesture)
  }
  
}

// MARK: - Actions ⚡
extension GlidingCollection {
  
  // MARK: Public
  
  /// Expand GlidingCollection
  ///
  /// - Parameters:
  ///   - index: target index
  ///   - animated: animate changes
  public func expand(at index: Int, animated: Bool = true) {
    guard
      index != expandedItemIndex,
      let source = dataSource,
      index < source.numberOfItems(in: self), index >= 0 else {
        return
    }
    
    delegate?.glidingCollection(self, willExpandItemAt: index)
    
    collectionView.isUserInteractionEnabled = false
    
    let duration: Double = config.animationDuration
    let direction: Direction = index > expandedItemIndex ? .up : .down
    let up = direction == .up
    let bounds = self.bounds
    let minX = config.sideInsets.left
    let space = config.cardsSpacing
    let cellFrame = CGRect(x: minX, y: collectionView.frame.minY, width: config.cardsSize.width, height: config.cardsSize.height)
    

    var delay: Double = 0
    if animationInProcess {
      delay = duration / 3.5
      
      for subview in subviews where subview.tag == AnimationItem.newRightSide.tag {
        let layer = subview.layer
        let position = layer.presentation()?.position ?? CGPoint(x: cellFrame.maxX, y: cellFrame.minY)
        layer.removeAllAnimations()
        layer.position = position
        let newPosition = CGPoint(x: bounds.width, y: cellFrame.minY)
        let newValue = AnimationValue.position(newPosition)
        animate(subview, newValue: newValue, item: AnimationItem.newRightSide, duration: duration * 1.2, delay: 0, index: lastExpandedItemIndex)
      }
      
      lastExpandedItemIndex = expandedItemIndex
    }
    
    lastDirection = direction
    
    let oldRightSideSnapshotView = UIImageView()
    let oldCellSnapshotView = UIImageView()
    
    let newCellWrapperView = UIView()
    let newCellSnapshotView = UIImageView()
    let newRightSideSnapshotView = UIImageView()
    
    let unified = topViews + bottomViews
    let movingItem = unified[safe: index]
    topViews = Array(unified.prefix(through: index))
    bottomViews = index + 1 < unified.count ? Array(unified.suffix(from: index + 1)) : []
    
    // Set new expanded index
    let oldIndex = expandedItemIndex
    expandedItemIndex = index
    
    var paths = collectionView.indexPathsForVisibleItems.sorted {
      $0.item < $1.item
    }
    
    var cellIndex = 0
    var oldCellFrame = CGRect.zero
    for path in paths {
      guard let cell = collectionView.cellForItem(at: path) else { continue }
      cell.alpha = 1
      let offset = collectionView.contentOffset.x
      var frame = cell.frame
      frame.origin.x -= offset
      if frame.minX > 0 {
        oldCellFrame = frame
        break
      }
      cellIndex += 1
    }
    
    
    // MARK: Snapshot of old cell
    if let path = paths[safe: cellIndex], let cell = collectionView.cellForItem(at: path) {
      UIGraphicsBeginImageContextWithOptions(cell.frame.size, true, 0)
      if let context = UIGraphicsGetCurrentContext() {
        cell.layer.render(in: context)
      }
      oldCellSnapshotView.image = UIGraphicsGetImageFromCurrentImageContext()
      addSubview(oldCellSnapshotView)
      oldCellSnapshotView.frame = oldCellFrame
      UIGraphicsEndImageContext()
      oldCellSnapshotView.tag = AnimationItem.oldCell.tag
    }
    
    // MARK: Snapshot of right side of collectionView
    if let path = paths[safe: cellIndex + 1], let cell = collectionView.cellForItem(at: path), !animationInProcess {
      UIGraphicsBeginImageContextWithOptions(cell.bounds.size, true, 0)
      if let context = UIGraphicsGetCurrentContext() {
        cell.layer.render(in: context)
      }
      oldRightSideSnapshotView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      addSubview(oldRightSideSnapshotView)
      oldRightSideSnapshotView.frame = CGRect(x: oldCellFrame.maxX + space, y: cellFrame.minY, width: cellFrame.width, height: cellFrame.height)
      oldRightSideSnapshotView.tag = AnimationItem.oldRightSide.tag
    }
    
    
    // MARK: Reload collection view & force to layout
    if collectionView.numberOfItems(inSection: 0) > 0 {
      let path = IndexPath(item: 0, section: 0)
      collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
    }
    collectionView.reloadData()
    collectionView.layoutIfNeeded()
    
    paths = self.collectionView.indexPathsForVisibleItems.sorted {
      $0.item < $1.item
    }
    
    collectionView.visibleCells.forEach { $0.alpha = 1 }
    
    // MARK: Snapshot of new cell
    if let path = paths.first, let cell = collectionView.cellForItem(at: path) {
      UIGraphicsBeginImageContextWithOptions(cellFrame.size, true, 0)
      if let context = UIGraphicsGetCurrentContext() {
        cell.layer.render(in: context)
      }
      newCellSnapshotView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      newCellWrapperView.addSubview(newCellSnapshotView)
      newCellWrapperView.isUserInteractionEnabled = false
      addSubview(newCellWrapperView)
      
      let imageViewOriginY = up ? -cellFrame.height : 0
      let wrapperViewOriginY = up ? cellFrame.maxY : cellFrame.minY
      newCellSnapshotView.frame = CGRect(x: 0, y: imageViewOriginY, width: cellFrame.width, height: cellFrame.height)
      newCellWrapperView.clipsToBounds = true
      newCellWrapperView.frame = CGRect(x: minX, y: wrapperViewOriginY, width: 0, height: 0)
      
      newCellWrapperView.tag = AnimationItem.newCellWrapper.tag
      newCellSnapshotView.tag = AnimationItem.newCell.tag
    }
    
    // MARK: Snapshot of right side of collectionView
    if let path = paths[safe: 1], let cell = collectionView.cellForItem(at: path) {
      UIGraphicsBeginImageContextWithOptions(cell.bounds.size, true, 0)
      if let context = UIGraphicsGetCurrentContext() {
        cell.layer.render(in: context)
      }
      newRightSideSnapshotView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      addSubview(newRightSideSnapshotView)
      newRightSideSnapshotView.frame = CGRect(x: bounds.maxX, y: cellFrame.minY, width: cell.bounds.width, height: cell.bounds.height)
      newRightSideSnapshotView.tag = AnimationItem.newRightSide.tag
    }
    
    collectionView.visibleCells.forEach { $0.alpha = 0 }
    
    // MARK: Animate old cell out
    let oldCellLayer = oldCellSnapshotView.layer
    var oldCellNewBounds = oldCellLayer.bounds
    oldCellNewBounds.size = .zero
    oldCellLayer.anchorPoint = up ? CGPoint(x: 0, y: 0) : CGPoint(x: 0, y: 1)
    oldCellLayer.position = up ? CGPoint(x: minX, y: cellFrame.minY) : CGPoint(x: minX, y: cellFrame.maxY)
    let oldCellNewBoundsValue = AnimationValue.bounds(oldCellNewBounds)
    animate(oldCellSnapshotView, newValue: oldCellNewBoundsValue, item: .oldCell, delay: delay, index: index)
    
    // MARK: Animate old right cell off-screen
    let oldRightSideLayer = oldRightSideSnapshotView.layer
    oldRightSideLayer.anchorPoint = .zero
    oldRightSideLayer.position = CGPoint(x: cellFrame.maxX + space, y: cellFrame.minY)
    let oldRightSideNewPosition = CGPoint(x: bounds.width, y: cellFrame.minY)
    let oldRightSideNewValue = AnimationValue.position(oldRightSideNewPosition)
    animate(oldRightSideSnapshotView, newValue: oldRightSideNewValue, item: .oldRightSide, index: index)
    
    // MARK: Animate buttons
    UIView.animate(withDuration: duration, delay: duration/5, options: .curveEaseInOut, animations: {
      up ? self.animateBottomButtons() : self.animateTopButtons()
    }, completion: nil)
    
    if up, let movingButton = unified[safe: index], abs(oldIndex - index) <= 1 {
      UIView.animate(withDuration: duration, delay: duration/3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
        if up {
          let insets = self.config.sideInsets
          movingButton.frame = CGRect(x: insets.left, y: self.collectionView.frame.minY - 40, width: bounds.width - insets.left - insets.right, height: 30)
        }
      }, completion: nil)
      
      UIView.animate(withDuration: duration, delay: duration/2, options: UIViewAnimationOptions.curveEaseInOut, animations: {
        self.animateTopButtons()
      }, completion: nil)
    } else {
      UIView.animate(withDuration: duration, delay: duration/4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
        up ? self.animateTopButtons() : self.animateBottomButtons()
      }, completion: nil)
    }
    
    // MARK: Animate buttons textColor
    for button in unified {
      UIView.transition(with: button, duration: duration/2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
        let color = button === movingItem ? self.config.activeButtonColor : self.config.inactiveButtonsColor
        button.setTitleColor(color, for: UIControlState.normal)
      }, completion: nil)
    }
    
    // MARK: Animate cell snapshot wrapper
    let newCellAnimationDelay = duration / 3.7 + delay
    let newCellWrapperLayer = newCellWrapperView.layer
    newCellWrapperLayer.anchorPoint = up ? CGPoint(x: 0, y: 1) : CGPoint(x: 0, y: 0)
    newCellWrapperLayer.position = up ? CGPoint(x: minX, y: cellFrame.maxY) : CGPoint(x: minX, y: cellFrame.minY)
    newCellWrapperLayer.bounds = .zero
    var newCellWrapperNewBounds = CGRect.zero
    newCellWrapperNewBounds.size = cellFrame.size
    let newCellWrapperNewBoundsValue = AnimationValue.bounds(newCellWrapperNewBounds)
    animate(newCellWrapperView, newValue: newCellWrapperNewBoundsValue, item: .newCellWrapper, delay: newCellAnimationDelay, index: index)
    
    // MARK: Animate cell snapshot
    let newCellSnapshotLayer = newCellSnapshotView.layer
    newCellSnapshotLayer.anchorPoint = up ? CGPoint(x: 0, y: 1) : CGPoint(x: 0, y: 0)
    newCellSnapshotLayer.position = up ? CGPoint(x: 0, y: cellFrame.height) : CGPoint(x: 0, y: 0)
    var newCellSnapshotNewBounds = CGRect.zero
    newCellSnapshotNewBounds.size = cellFrame.size
    let newCellSnapshotNewBoundsValue = AnimationValue.bounds(newCellSnapshotNewBounds)
    newCellSnapshotLayer.bounds = .zero
    animate(newCellSnapshotView, newValue: newCellSnapshotNewBoundsValue, item: .newCell, delay: newCellAnimationDelay, index: index)
    
    // MARK: Animate new right side
    let position = CGPoint(x: cellFrame.maxX + space, y: cellFrame.minY)
    let newRightSideLayer = newRightSideSnapshotView.layer
    newRightSideLayer.anchorPoint = .zero
    newRightSideLayer.position = CGPoint(x: bounds.width, y: cellFrame.minY)
    let newRightSideNewValue = AnimationValue.position(position)
    let newRightSideDelay = duration + newCellAnimationDelay
    animate(newRightSideSnapshotView, newValue: newRightSideNewValue, item: .newRightSide, duration: config.animationDuration * 2, delay: newRightSideDelay, index: index)
    self.newRightSideSnapshot = newRightSideSnapshotView
    
    animationInProcess = true
  }
  
  /// Expand next item in list
  public func expandNext() {
    expand(at: expandedItemIndex + 1)
  }
  
  /// Expand previous item in list
  public func expandPrevious() {
    expand(at: expandedItemIndex - 1)
  }
  
  // MARK: Private
  @objc fileprivate func didTapped(_ button: UIButton) {
    let unifiedButtons = topViews + bottomViews
    guard let index = unifiedButtons.index(of: button) else { return }
    delegate?.glidingCollection(self, didSelectItemAt: index)
    expand(at: index)
  }
  
  fileprivate func resetViews() {
    // Remove temporary layer
    newRightSideSnapshot = nil
    
    // Unhide visibleCells
    collectionView.visibleCells.forEach { $0.alpha = 1 }
    
    // Remove all snapshot layers
    let tags = AnimationItem.all.map { $0.tag }
    for subview in subviews {
      if tags.contains(subview.tag) {
        subview.removeFromSuperview()
      }
    }
    
    // Set new index to temporary property
    lastExpandedItemIndex = expandedItemIndex
  }
  
  @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: self)
    let velocity = gesture.velocity(in: self)
    
    switch gesture.state {
    case .began:
      gestureStartPosition = location
      
    case .changed:
      let translation = gesture.translation(in: self)
      let up = location.y > gestureStartPosition.y
      
      let range = abs(location.y - gestureStartPosition.y)
      let decelerating = collectionView.isDecelerating
      let numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
      if (expandedItemIndex == 0 && up) || (expandedItemIndex == numberOfItems - 1 && !up), !animationInProcess, !decelerating {
        let y = collectionView.frame.minY
        
        // Set initial values
        if gestureTranslation == 0 {
          gestureTranslation = y
          
          // Update snapshots if needed
          if topHalfSnapshot == nil || bottomHalfSnapshot == nil {
            snapshotTopAndBottom()
          }
        }
        
        
        if let snapshot = up ? bottomHalfSnapshot : topHalfSnapshot {
          if !snapshot.isDescendant(of: containerView) {
            containerView.addSubview(snapshot)
          }
          var frame = snapshot.frame
          frame.origin.y += translation.y / 4.5
          
          // Animate frame changing to avoid flickering
          UIView.animate(withDuration: 0.1) {
            snapshot.frame = frame
          }
        }
      
        // Hide views
        collectionView.isHidden = true
        (bottomViews + topViews).forEach { $0.isHidden = true }
        
        gesture.setTranslation(.zero, in: self)
      } else {
        guard gestureTranslation == 0 else { break }
        if range > 100 || abs(velocity.y) > 300 && abs(velocity.x) < 300 {
          up ? self.expandPrevious() : self.expandNext()
          gesture.isEnabled = false
          gesture.isEnabled = true
          self.gestureStartPosition = .zero
        }
      }
    case .ended, .failed, .cancelled: resetContainersFrames()
    default: break
    }
    
  }
  
  fileprivate func snapshotTopAndBottom() {
    let size = CGSize(width: bounds.width, height: bounds.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    containerView.drawHierarchy(in: bounds, afterScreenUpdates: false)
    let snapshot = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    
    UIGraphicsEndImageContext()
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let topButtonFrame = topViews.first?.frame ?? CGRect.zero
    let topButtonOriginY = topButtonFrame.origin.y
    bottomHalfSnapshotFrame = CGRect(x: 0, y: topButtonOriginY, width: bounds.width, height: size.height)
    let point = CGPoint(x: 0, y: -bottomHalfSnapshotFrame.origin.y)
    snapshot.draw(at: point)
    bottomHalfSnapshot = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
    bottomHalfSnapshot?.frame = bottomHalfSnapshotFrame
    UIGraphicsEndImageContext()
    
    let topSize = CGSize(width: bounds.width, height: bounds.height - collectionView.frame.minY)
    UIGraphicsBeginImageContextWithOptions(topSize, false, 0)
    containerView.drawHierarchy(in: bounds, afterScreenUpdates: false)
    topHalfSnapshotFrame = CGRect(x: 0, y: 0, width: topSize.width, height: topSize.height)
    topHalfSnapshot = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
    topHalfSnapshot?.frame = topHalfSnapshotFrame
    UIGraphicsEndImageContext()
  }
  
}

// MARK: - Animations
private typealias AniView = (view: UIView, animation: CAAnimation)

private enum AnimationValue {
  case bounds(CGRect)
  case position(CGPoint)
  
  var key: String {
    switch self {
    case .bounds(_): return "bounds"
    case .position(_): return "position"
    }
  }
}


private enum AnimationItem: String {
  case oldCell, oldRightSide
  case newCell, newCellWrapper, newRightSide
  
  static var all: [AnimationItem] {
    return [AnimationItem.oldCell, .oldRightSide, .newCell, .newCellWrapper, .newRightSide]
  }
  
  var tag: Int {
    switch self {
    case .oldCell: return 1
    case .oldRightSide: return 2
    case .newCell: return 3
    case .newCellWrapper: return 4
    case .newRightSide: return 5
    }
  }
}


extension GlidingCollection: CAAnimationDelegate {
  
  fileprivate func speedUp(_ layer: CALayer, reverse: Bool) {
    let time = CACurrentMediaTime()
    let timeOffset = layer.convertTime(time, from: nil)
    layer.timeOffset = timeOffset
    layer.beginTime = CACurrentMediaTime()
    layer.speed = reverse ? -2.0 : 3.0
  }
  
  @discardableResult
  fileprivate func animate(_ view: UIView, newValue: AnimationValue, item: AnimationItem, duration: Double? = nil, delay: Double = 0, index: Int) -> CAAnimation {
    let key = newValue.key
    let layer = view.layer
    let animation = CABasicAnimation(keyPath: key)
    
    switch newValue {
    case .bounds(let toBounds):
      animation.fromValue = NSValue(cgRect: layer.bounds)
      animation.toValue = NSValue(cgRect: toBounds)
      layer.bounds = toBounds
    case .position(let toPosition):
      animation.fromValue = NSValue(cgPoint: layer.position)
      animation.toValue = NSValue(cgPoint: toPosition)
      layer.position = toPosition
    }
    
    animation.isRemovedOnCompletion = false
    animation.fillMode = kCAFillModeBackwards
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    animation.duration = duration ?? config.animationDuration
    animation.delegate = self
    animation.beginTime = CACurrentMediaTime() + delay
    
    let animationId = "\(item.rawValue),\(index)"
    animation.setValue(animationId, forKey: "id")
    
    animationViewsDictionary[animationId] = (view: view, animation: animation)
    layer.name = "snapshotLayer"
    
    layer.add(animation, forKey: animationId)
    return animation
  }
  
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    
    if let id = anim.value(forKey: "id") as? String, let aniview = animationViewsDictionary[id] {
      let components = id.components(separatedBy: ",")
      let index = Int(components[safe: 1] ?? "") ?? 0
      let item = AnimationItem(rawValue: components.first ?? "") ?? AnimationItem.oldCell
      
      if index != expandedItemIndex, item != .newRightSide {
        aniview.view.removeFromSuperview()
      }
      
      switch item {
      case .oldRightSide:
        collectionView.isUserInteractionEnabled = true
        
      case .newCell where index == expandedItemIndex && aniview.animation.beginTime == anim.beginTime:
        let paths = collectionView.indexPathsForVisibleItems.sorted { $0.0.item < $0.1.item }
        guard let path = paths.first, let cell = collectionView.cellForItem(at: path) else {
          break
        }
        cell.alpha = 1
        aniview.view.removeFromSuperview()
        
      case .newRightSide where index == expandedItemIndex && aniview.animation.beginTime == anim.beginTime:
        resetViews()
        animationInProcess = false
      default: break
      }
    }
  }
  
  fileprivate func animateTopButtons() {
    let buttonHeight = config.buttonsFont.pointSize * 1.2
    var minY = collectionView.frame.minY - buttonHeight
    let insets = config.sideInsets
    var topFrame = CGRect(x: insets.left, y: 0, width: bounds.width - insets.left - insets.right, height: buttonHeight)
    for button in topViews.reversed() {
      if button === topViews.last {
        button.transform = .identity
      } else {
        button.transform = scaledTransform
      }
      topFrame.origin.y = minY - config.buttonsSpacing
      button.frame = topFrame
      minY -= buttonHeight + config.buttonsSpacing
    }
  }
  
  fileprivate func animateBottomButtons() {
    var maxY = collectionView.frame.maxY
    let insets = config.sideInsets
    let buttonHeight = config.buttonsFont.pointSize * 1.2
    var topFrame = CGRect(x: insets.left, y: 0, width: bounds.width - insets.left - insets.right, height: buttonHeight)
    for button in bottomViews {
      button.transform = scaledTransform
      topFrame.origin.y = maxY + config.buttonsSpacing
      button.frame = topFrame
      maxY = button.frame.maxY
    }
  }
  
  fileprivate func resetContainersFrames() {
    UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
      self.topHalfSnapshot?.frame = self.topHalfSnapshotFrame
      self.bottomHalfSnapshot?.frame = self.bottomHalfSnapshotFrame
    }, completion: { _ in
      guard self.gesture.state != UIGestureRecognizerState.changed else { return }
      self.gestureTranslation = 0
      self.collectionView.isHidden = false
      (self.topViews + self.bottomViews).forEach { $0.isHidden = false }
      self.topHalfSnapshot?.removeFromSuperview()
      self.bottomHalfSnapshot?.removeFromSuperview()
      self.topHalfSnapshot = nil
      self.bottomHalfSnapshot = nil
    })
  }
  
  fileprivate func hideNewCell(hide: Bool) {
    let path = IndexPath(item: 1, section: 0)
    let newAlpha: CGFloat = hide ? 0 : 1
    if let cell = collectionView.cellForItem(at: path), cell.alpha != newAlpha {
      cell.alpha = newAlpha
    }
  }
  
  fileprivate func getAniview(of item: AnimationItem, at index: Int) -> AniView? {
    let id = "\(item.rawValue),\(index)"
    return animationViewsDictionary[id]
  }
  
}

// MARK: - GlidingLayoutDelegate
extension GlidingCollection: GlidingLayoutDelegate {
  
  func collectionViewDidScroll() {
    for cell in collectionView.visibleCells where cell.alpha == 0 {
      cell.alpha = 1
    }
    guard animationInProcess else { return }
    let tags = AnimationItem.all.map { $0.tag }
    for subview in subviews {
      if tags.contains(subview.tag) {
        subview.removeFromSuperview()
      }
    }
  }
  
}
