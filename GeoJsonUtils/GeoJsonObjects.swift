//
//  GeoJSONObject.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 12/20/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

// MARK: - Coding Keys
enum GeoJSONObjectType: String, Decodable {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

enum FeatureCodingKeys: String, CodingKey {
    case type
    case id
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
    case invalidPropertyKey
}

// MARK: - Models for Feature & FeatureCollection
struct Feature: Decodable {
    var type: GeoJSONObjectType = .feature
    var id: String?
    var properties: [String: Any]
    var geometryType: GeometryType
    var geometry: Decodable
    var mkGeometry: MKShape?
    var multiMkGeometry: [MKShape]?

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: FeatureCodingKeys.self)

        if let value = try? container.decode(Double.self, forKey: .id) {
            id = String(value)
        } else {
            id = try? container.decode(String.self, forKey: .id)
        }

        properties = try container.decode(Dictionary<String, Any>.self, forKey: .properties)

        let geometryContainer = try container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .geometry)
        geometryType = try geometryContainer.decode(GeometryType.self, forKey: .type)

        // Decodes the `geometry` property with one of the possible classes
        switch geometryType {
        case .point:
            let point: Point = try container.decode(Point.self, forKey: .geometry)
            self.geometry = point
            mkGeometry = point.asMKPointAnnotation()
            if id != nil {
                mkGeometry?.title = id
            }
        case .lineString:
            let line = try container.decode(LineString.self, forKey: .geometry)
            self.geometry = line
            mkGeometry = line.asMKPolyLine()
            if id != nil {
                mkGeometry?.title = id
            }
        case .polygon:
            let polygon = try container.decode(Polygon.self, forKey: .geometry)
            self.geometry = polygon
            mkGeometry = polygon.asMKPolygon()
            if id != nil {
                mkGeometry?.title = id
            }
        case .multiPolygon:
            let multiPolygon = try container.decode(MultiPolygon.self, forKey: .geometry)
            self.geometry = multiPolygon

            multiMkGeometry = [MKShape]()

            for polygon in multiPolygon.getPolygons() {
                let mkPolygon = polygon.asMKPolygon()
                if id != nil {
                    mkPolygon.title = id
                }
                multiMkGeometry?.append(mkPolygon)
            }
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

extension Feature {

    func updateIdFromProperty(forKey key: String) throws {
        var value = id
        if let doubleValue = properties[key] as? Double {
            value = String(doubleValue)
        } else if let stringValue = properties[key] as? String {
            value = stringValue
        } else {
            throw GeoJsonObjectError.invalidPropertyKey
        }

        switch geometryType {
        case .point:
            let anno = mkGeometry as? MKPointAnnotation
            if anno != nil {
                anno!.title = value
            }
        case .lineString:
            let overlay = mkGeometry as? MKPolyline
            if overlay != nil {
                overlay!.title = value
            }
        case .polygon:
            let overlay = mkGeometry as? MKPolygon
            if overlay != nil {
                overlay!.title = value
            }
        case .multiPolygon:
            if multiMkGeometry != nil {
                for geometry in multiMkGeometry! {
                    let overlay = geometry as? MKPolygon
                    if overlay != nil {
                        overlay!.title = value
                    }
                }
            }
        default:
            break
        }
    }
}
