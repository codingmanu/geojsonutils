# GeoJsonUtils

#### Library to read, parse and transform GeoJSON data into Swift and MapKit objects.

![iOS-CI](https://github.com/codingmanu/GeoJsonUtils/workflows/iOS-CI/badge.svg?branch=develop)
![Swift Version](https://img.shields.io/badge/Swift-5-brightgreen.svg)
![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg) 
![Plaform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
---

### Made in Swift 5
Requires Xcode 10.2.

### Installation
Drop in the GeoJsonUtils folder to your Xcode project (make sure to enable "Copy items if needed" and "Create groups").

### Usage:

Reading functions have been refactored to use closures to avoid clogging the main thread on large datasets.

#### Loading from file (Bundle):
```swift
    GeoJsonUtils.readGJFeatureCollectionFromFileInBundle(file: "nyc_neighborhoods",
                                                   withExtension: "geojson") { [unowned self] (result) in
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let featureCollection):
            self.mapView.loadGJFeatureCollection(featureCollection)
        }
    }
```

#### Loading from file (path):
```swift
    guard let path = URL(...).path else { return }

    GeoJsonUtils.readGJFeatureCollectionFromFileAt(path: path) { [unowned self] (result) in
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let featureCollection):
            self.mapView.loadGJFeatureCollection(featureCollection)
        }
    }
```

#### Loading from Data:
```swift
    let data = Data() {...}

    GeoJsonUtils.readGJFeatureCollectionFrom(data) { [unowned self] (result) in
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let featureCollection):
            self.mapView.loadGJFeatureCollection(featureCollection)
        }
    }
```

### ChangeLog
- At [ChangeLog](https://github.com/codingManu/GeoJsonUtils/wiki/CHANGELOG) wiki page

### License

GeoJsonUtils is released under the MIT license. See LICENSE for details.
