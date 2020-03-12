//
//  GeoJsonUtils.swift
//  GeoJsonUtils
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
    ///   - completion: an escaping closure with a `Result` type containing a `GJFeatureCollection` populated with the data in the file or a `GJObjectError`.
    static func readGJFeatureCollectionFrom(file: String, withExtension: String, completion: @escaping (Result<GJFeatureCollection, GJObjectError>) -> Void ) {

        guard let bundlefile = Bundle.main.url(forResource: file, withExtension: withExtension) else {
            completion(.failure(.invalidFeatureCollection))
            return
        }

        DispatchQueue.global().async {
            let data = try? Data(contentsOf: bundlefile)

            let decoder = JSONDecoder()

            do {
                let featureCollection = try decoder.decode(GJFeatureCollection.self, from: data!)
                completion(.success(featureCollection))

            } catch {
                completion(.failure(.invalidFeatureCollection))
            }
        }
    }

    /// Returns a `GJFeatureCollection` decoded from `Data`.
    ///
    /// - Parameters:
    ///   - data: the `Data` to be decoded.
    ///   - completion: an escaping closure with a `Result` type containing a `GJFeatureCollection` populated with the data in the file or a `GJObjectError`.
    static func readGJFeatureCollectionFrom(_ data: Data, completion: @escaping (Result<GJFeatureCollection, GJObjectError>) -> Void ) {

        let decoder = JSONDecoder()

        do {
            let featureCollection = try decoder.decode(GJFeatureCollection.self, from: data)
            completion(.success(featureCollection))

        } catch {
            completion(.failure(.invalidFeatureCollection))
        }

    }
}
