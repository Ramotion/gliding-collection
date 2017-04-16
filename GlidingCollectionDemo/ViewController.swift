//
//  ViewController.swift
//  GlidingCollectionDemo
//
//  Created by Abdurahim Jauzee on 04/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit
import GlidingCollection


class ViewController: UIViewController {
  
  @IBOutlet var glidingView: GlidingCollection!
  fileprivate var collectionView: UICollectionView!
  fileprivate var items = ["gloves", "boots", "bindings", "hoodie"]
  fileprivate var images: [[UIImage?]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
}

// MARK: - Setup
extension ViewController {
  
  func setup() {
    setupGlidingCollectionView()
    loadImages()
  }
  
  private func setupGlidingCollectionView() {
    glidingView.dataSource = self
    
    let nib = UINib(nibName: "CollectionCell", bundle: nil)
    collectionView = glidingView.collectionView
    collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = glidingView.backgroundColor
  }
  
  private func loadImages() {
    for item in items {
      let imageURLs = FileManager.default.fileUrls(for: "jpeg", fileName: item)
      var images: [UIImage?] = []
      for url in imageURLs {
        guard let data = try? Data(contentsOf: url) else { continue }
        let image = UIImage(data: data)
        images.append(image)
      }
      self.images.append(images)
    }
  }
  
}

// MARK: - CollectionView 🎛
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let section = glidingView.expandedItemIndex
    return images[section].count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    let section = glidingView.expandedItemIndex
    let image = images[section][indexPath.row]
    cell.imageView.image = image
    cell.contentView.clipsToBounds = true
    
    let layer = cell.layer
    let config = GlidingConfig.shared
    layer.shadowOffset = config.cardShadowOffset
    layer.shadowColor = config.cardShadowColor.cgColor
    layer.shadowOpacity = config.cardShadowOpacity
    layer.shadowRadius = config.cardShadowRadius
    
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let section = glidingView.expandedItemIndex
    let item = indexPath.item
    print("Selected item #\(item) in section #\(section)")
  }
  
}

// MARK: - Gliding Collection 🎢
extension ViewController: GlidingCollectionDatasource {
  
  func numberOfItems(in collection: GlidingCollection) -> Int {
    return items.count
  }
  
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
    return "– " + items[index]
  }
  
}
