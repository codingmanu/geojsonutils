## Made in Swift 4.2
Requires Xcode 10 and Swift 4.2.

## Installation
Drop in the GeoJsonUtils folder to your Xcode project (make sure to enable "Copy items if needed" and "Create groups").

## Usage with Code
Loading from data:
```swift
    let decodedData = try? decoder.decode(FeatureCollection.self, from: data)
    guard let featureCollection = decodedData else { return }
    mapView.loadFeatureCollection(featureCollection)
```

\* Play with the demo app for a sample.

## ChangeLog
- At [ChangeLog](https://github.com/codingManu/GeoJsonUtils/wiki/CHANGELOG) wiki page

## License

GeoJsonUtils is released under the MIT license. See LICENSE for details.