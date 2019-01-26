//
//  GeoJsonUtils.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 1/23/19.
//  Copyright © 2019 codingManu. All rights reserved.
//

import Foundation

class GeoJsonUtils {

    static func readFeatureCollectionFrom(file: String, withExtension: String) throws -> FeatureCollection {

        guard let bundlefile = Bundle.main.url(forResource: file, withExtension: withExtension) else {
            throw GeoJsonObjectError.invalidFeatureCollection
        }
        
        let data = try? Data(contentsOf: bundlefile)

        let decoder = JSONDecoder()
        var decodedData: FeatureCollection

        do {
            decodedData = try decoder.decode(FeatureCollection.self, from: data!)
            return decodedData

        } catch let error {

            print(error.localizedDescription)
            throw GeoJsonObjectError.invalidFeatureCollection
        }
    }

    static func readFeatureCollectionFrom(_ data: Data) throws -> FeatureCollection {

        let decoder = JSONDecoder()
        var decodedData: FeatureCollection

        do {
            decodedData = try decoder.decode(FeatureCollection.self, from: data)
            return decodedData

        } catch let error {

            print(error.localizedDescription)
            throw GeoJsonObjectError.invalidFeatureCollection
        }

    }
}
