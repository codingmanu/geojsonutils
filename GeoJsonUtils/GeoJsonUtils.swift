//
//  GeoJsonUtils.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 1/23/19.
//  Copyright © 2019 codingManu. All rights reserved.
//

import Foundation

class GeoJsonUtils {

    /// Returns a `GJFeatureCollection` decoded from a file.
    ///
    /// - Parameters:
    ///   - file: the resource file name _WITHOUT_ extension.
    ///   - withExtension: the resource file extension.
    /// - Returns: a GJFeatureCollection populated with the data in the file.
    /// - Throws: `GJObjectError.invalidFeatureCollection` if it can't read the collection from the decoded data.
    static func readGJFeatureCollectionFrom(file: String, withExtension: String) throws -> GJFeatureCollection {

        guard let bundlefile = Bundle.main.url(forResource: file, withExtension: withExtension) else {
            throw GJObjectError.invalidFeatureCollection
        }
        
        let data = try? Data(contentsOf: bundlefile)

        let decoder = JSONDecoder()
        var decodedData: GJFeatureCollection

        do {
            decodedData = try decoder.decode(GJFeatureCollection.self, from: data!)
            return decodedData

        } catch let error {
            print(error.localizedDescription)
            throw GJObjectError.invalidFeatureCollection
        }
    }

    /// Returns a `GJFeatureCollection` decoded from `Data`.
    ///
    /// - Parameter data: the `Data` to be decoded.
    /// - Returns: a GJFeatureCollection populated with the data in the file.
    /// - Throws: `GJObjectError.invalidFeatureCollection` if it can't read the collection from the decoded data.
    static func readGJFeatureCollectionFrom(_ data: Data) throws -> GJFeatureCollection {

        let decoder = JSONDecoder()
        var decodedData: GJFeatureCollection

        do {
            decodedData = try decoder.decode(GJFeatureCollection.self, from: data)
            return decodedData

        } catch let error {

            print(error.localizedDescription)
            throw GJObjectError.invalidFeatureCollection
        }

    }
}
