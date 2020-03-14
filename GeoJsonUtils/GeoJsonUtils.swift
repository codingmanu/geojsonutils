//
//  GeoJsonUtils.swift
//  GeoJsonUtils
//
//  Created by Manuel S. Gomez on 1/23/19.
//  Copyright © 2019 codingManu. All rights reserved.
//

import Foundation

class GeoJsonUtils {

    ///
    /// Returns a `GJFeatureCollection` decoded from a file's path.
    /// - Parameters:
    ///   - path: The path for the file to read.
    ///   - completion: Escaping closure with a `Result` type containing a `GJFeatureCollection` populated with the data in the file or a `GJError`.
    ///
    static func readGJFeatureCollectionFrom(path: String, completion: @escaping (Result<GJFeatureCollection, GJError>) -> Void ) {

        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: path) == false {
            completion(.failure(.readingFile))
        } else {
            guard let data = fileManager.contents(atPath: path) else {
                completion(.failure(.readingData))
                return
            }
            readGJFeatureCollectionFrom(data, completion: completion)
        }
    }

    ///
    /// Returns a `GJFeatureCollection` decoded from a file in the App's Bundle.
    ///
    /// - Parameters:
    ///   - file: The resource file name **WITHOUT** extension.
    ///   - withExtension: The resource file extension.
    ///   - completion: Escaping closure with a `Result` type containing a `GJFeatureCollection` populated with the data in the file or a `GJError`.
    ///
    static func readGJFeatureCollectionFromBundle(file: String, withExtension: String, completion: @escaping (Result<GJFeatureCollection, GJError>) -> Void ) {

        guard let bundlefile = Bundle.main.url(forResource: file, withExtension: withExtension) else {
            completion(.failure(.readingFile))
            return
        }

        guard let data = try? Data(contentsOf: bundlefile) else {
            completion(.failure(.readingData))
            return
        }

        readGJFeatureCollectionFrom(data, completion: completion)
    }

    ///
    /// Returns a `GJFeatureCollection` decoded from `Data`.
    ///
    /// - Parameters:
    ///   - data: The `Data` to be decoded.
    ///   - completion: Escaping closure with a `Result` type containing a `GJFeatureCollection` populated with the data in the file or a `GJError`.
    ///
    static func readGJFeatureCollectionFrom(_ data: Data, completion: @escaping (Result<GJFeatureCollection, GJError>) -> Void ) {

        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let decoder = JSONDecoder()

                let featureCollection = try decoder.decode(GJFeatureCollection.self, from: data)
                completion(.success(featureCollection))

            } catch {
                completion(.failure(.decoding))
            }
        }
    }
}
