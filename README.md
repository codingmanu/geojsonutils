## Made in Swift 5
Requires Xcode 10.2 and Swift 5.

## Installation
Drop in the GeoJsonUtils folder to your Xcode project (make sure to enable "Copy items if needed" and "Create groups").

## Usage with Code
Loading from file:
```swift
    guard let featureCollection = try? GeoJsonUtils.readGJFeatureCollectionFrom(file: "nyc_neighborhoods",
                                                                                withExtension: "geojson") else { return }
    mapView.loadGJFeatureCollection(featureCollection)
```

\* Play with the demo app for a sample.

## ChangeLog
- At [ChangeLog](https://github.com/codingManu/GeoJsonUtils/wiki/CHANGELOG) wiki page

## License

GeoJsonUtils is released under the MIT license. See LICENSE for details.
