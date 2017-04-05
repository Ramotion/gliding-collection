[![header](/assets/header.png)](https://business.ramotion.com?utm_source=gthb&utm_medium=special&utm_campaign=gliding-collection-logo)

[![Twitter](https://img.shields.io/badge/Twitter-@Ramotion-blue.svg?style=flat)](http://twitter.com/Ramotion)
[![PodPlatform](https://img.shields.io/cocoapods/p/GlidingCollection.svg)](https://cocoapods.org/pods/GlidingCollection)
[![PodVersion](https://img.shields.io/cocoapods/v/GlidingCollection.svg)](http://cocoapods.org/pods/GlidingCollection)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/GlidingCollection.svg)](https://cdn.rawgit.com/Ramotion/gliding-collection/master/docs/index.html)

[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Ramotion/gliding-collection)
[![Codebeat](https://codebeat.co/badges/6a009992-5bf2-4730-aa35-f3b20ce7693d)](https://codebeat.co/projects/github-com-ramotion-gliding-collection)
![Swift](https://img.shields.io/badge/Swift-3.1-2ecc71.svg)

<br>

## About
This project is maintained by Ramotion, Inc.<br>
We specialize in the designing and coding of custom UI for Mobile Apps and Websites.<br><br>**Looking for developers for your project?**

<a href="https://business.ramotion.com?utm_source=gthb&utm_medium=special&utm_campaign=gliding-collection-contact-us/#Get_in_Touch" > <img src="https://github.com/Ramotion/navigation-stack/raw/master/contact_our_team@2x.png" width="150" height="30"></a>

[![animation](/assets/preview.gif)](https://dribbble.com/shots/3413329-iOS-Gliding-Collection-Open-Source)

The [iPhone mockup](https://store.ramotion.com?utm_source=gthb&utm_medium=special&utm_campaign=gliding-collection) available [here](https://store.ramotion.com?utm_source=gthb&utm_medium=special&utm_campaign=gliding-collection).
<br>

## Requirements

- iOS 8.0+
- Xcode 8
- Swift 3

<br>

## Installation
You can install `GlidingCollection` in several ways:

- Add source files to your project.

<br>

- Use [CocoaPods](https://cocoapods.org):
``` ruby
pod 'GlidingCollection'
```

<br>

- Use [Carthage](https://github.com/Carthage/Carthage):
```
github "Ramotion/gliding-collection"
```

<br>

## How to use

• Create a view controller class:

```swift
import GlidingCollection

class ViewController: UIViewController {
  let items = ["gloves", "boots", "bindings", "hoodie"]
}
```

• Drag a `UIView` onto the canvas. Change it's class to `GlidingCollection` and use autolayout constraints.

![step-2](/assets/step-2.png)

• Connect this view to your view controller class as an `@IBOutlet`.

```swift
@IBOutlet var glidingCollection: GlidingCollection!
```

• Make your view controller conform to `GlidingCollectionDatasource`. It's very similar to the `UITableView` or `UICollectionView` *datasource* protocols that you know:

```swift
extension ViewController: GlidingCollectionDatasource {

  func numberOfItems(in collection: GlidingCollection) -> Int {
    return items.count
  }

  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
    return "– " + items[index]
  }

}
```

• Make your view controller conform to `UICollectionViewDatasource`:

```swift
extension ViewController: UICollectionViewDatasource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let section = glidingView.expandedItemIndex // Value of expanded section.
    return images[section].count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    // Configure and return your cell.
    return cell
  }
  
}
```

## Customize

You can customize the appearance of `GlidingCollection` by overriding `GlidingConfig`'s `shared` instance with your own.

```swift
var config = GlidingConfig.shared
config.buttonsFont = UIFont.boldSystemFont(ofSize: 22)
config.activeButtonColor = .black
config.inactiveButtonsColor = .lightGray
GlidingConfig.shared = config
```

>🗒 All parameters with their descriptions are listed in [`GlidingConfig`](/GlidingCollection/GlidingConfig.swift).

<br>

## Notes

There is a [`GlidingCollectionDelegate`](/GlidingCollection/Protocols/GlidingCollectionDelegate.swift) protocol which can notify you when *item* in `GlidingCollection` `didSelect`, `willExpand` and `didExpand`.

If you want to achieve a parallax effect on a horizontal cards stack, you need to place your `parallax view` in a cell's `contentView` and set its `tag` to `99`.

![parallax-view](/assets/parallax-view.png)

There is a `kGlidingCollectionParallaxViewTag` constant if you want to layout a cell in code.
```swift
imageView.tag = kGlidingCollectionParallaxViewTag
```

<br>

## License

GlidingCollection is released under the MIT license.
See [LICENSE](./LICENSE) for details.

<br>

## Follow us

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/ramotion/gliding-collection)
[![Twitter Follow](https://img.shields.io/twitter/follow/ramotion.svg?style=social)](https://twitter.com/ramotion)
