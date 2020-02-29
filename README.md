# GeoJSONUtils

#### Library to read, parse and transform GeoJSON data into Swift and MapKit objects.

![iOS-CI](https://github.com/codingmanu/GeoJsonUtils/workflows/iOS-CI/badge.svg?branch=develop)
![Swift Version](https://img.shields.io/badge/Swift-5-brightgreen.svg)
![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg) 
![Plaform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
---

### Made in Swift 5
Requires Xcode 10.2 and Swift 5.

### Installation
Drop in the GeoJsonUtils folder to your Xcode project (make sure to enable "Copy items if needed" and "Create groups").

### Usage with Code
Loading from file:
```swift
    guard let featureCollection = try? GeoJsonUtils.readGJFeatureCollectionFrom(file: "nyc_neighborhoods",
                                                                                withExtension: "geojson") else { return }
    mapView.loadGJFeatureCollection(featureCollection)
```

\* Play with the demo app for a sample.

### ChangeLog
- At [ChangeLog](https://github.com/codingManu/GeoJsonUtils/wiki/CHANGELOG) wiki page

### License

GeoJsonUtils is released under the MIT license. See LICENSE for details.
