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
  
  var glidingView: GlidingCollection!
  var items = ["shirts", "pants", "vests", "denims", "polos", "track wear"]
  var images: [[UIImage?]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
}

// MARK: - Setup
extension ViewController {
  
  func setup() {
    setupGligingCollectionView()
    loadImages()
  }
  
  private func setupGligingCollectionView() {
    glidingView = GlidingCollection()
    glidingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    glidingView.frame = view.bounds
    glidingView.backgroundColor = #colorLiteral(red: 0.9401558042, green: 0.952983439, blue: 0.956292212, alpha: 1)
    glidingView.dataSource = self
    
    let nib = UINib(nibName: "CollectionCell", bundle: nil)
    
    let collectionView = glidingView.collectionView
    collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = glidingView.backgroundColor
    
    view.addSubview(glidingView)
  }
  
  private func loadImages() {
    for item in items {
      let imageURLs = FileManager.default.fileUrls(for: "jpg", "jpeg", fileName: item)
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
