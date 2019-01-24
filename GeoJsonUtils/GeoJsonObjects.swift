//
//  GeoJSONObject.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 12/20/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation

// MARK: - Coding Keys
enum GeoJSONObjectType: String, Decodable {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

enum FeatureCodingKeys: String, CodingKey {
    case type
    case properties
    case geometry
}

enum FeatureCollectionCodingKeys: String, CodingKey {
    case type
    case properties
    case features
}

enum GeoJsonObjectError: Error {
    case invalidFeature
    case invalidFeatureCollection
    case invalidType
    case invalidProperties
    case invalidGeometry
    case invalidFeatures
}

// MARK: - Models for Feature & FeatureCollection
struct Feature: Decodable {
    var type: GeoJSONObjectType = .feature
    var properties: [String: Any]
    var geometryType: GeometryType
    var geometry: Decodable

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: FeatureCodingKeys.self)
        properties = try container.decode(Dictionary<String, Any>.self, forKey: .properties)

        let geometryContainer = try container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .geometry)
        geometryType = try geometryContainer.decode(GeometryType.self, forKey: .type)

        // Overwrites the `geometry` property with one of the possible classes
        switch geometryType {
        case .point:
            self.geometry = try container.decode(Point.self, forKey: .geometry)
        case .lineString:
            self.geometry = try container.decode(LineString.self, forKey: .geometry)
        case .polygon:
            self.geometry = try container.decode(Polygon.self, forKey: .geometry)
        case .multiPolygon:
            self.geometry = try container.decode(MultiPolygon.self, forKey: .geometry)
        default:
            throw GeometryError.invalidType
        }
    }
}

class FeatureCollection: Decodable {
    var type: GeoJSONObjectType = .featureCollection
    var features: [Feature]

    init(_ features: [Feature]) {
        self.features = features
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FeatureCollectionCodingKeys.self)
        type = try container.decode(GeoJSONObjectType.self, forKey: .type)
        features = try container.decode([Feature].self, forKey: .features)
    }

}
