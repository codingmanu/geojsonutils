//
//  GeoJSONObject.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 12/20/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

// MARK: - GeoJSON Object Type: Feature or FeatureCollection
enum GJObjectType: String, Codable {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

// MARK: - Coding Keys
enum GJFeatureCodingKeys: String, CodingKey {
    case type
    case id
    case properties
    case geometry
}

enum GJFeatureCollectionCodingKeys: String, CodingKey {
    case type
    case properties
    case features
}

enum GJObjectError: Error {
    case invalidFeature
    case invalidFeatureCollection
    case invalidType
    case invalidProperties
    case invalidGeometry
    case invalidFeatures
    case invalidPropertyKey
}

// MARK: - Models for Feature & FeatureCollection
struct GJFeature: Decodable {
    var type: GJObjectType = .feature
    var id: String?
    var properties: [String: Any]
    var geometryType: GJGeometryType
    var geometry: Decodable
    var mkGeometry: MKShape?
    var multiMkGeometry: [MKShape]?

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: GJFeatureCodingKeys.self)

        if let value = try? container.decode(Double.self, forKey: .id) {
            id = String(value)
        } else {
            id = try? container.decode(String.self, forKey: .id)
        }

        properties = try container.decode(Dictionary<String, Any>.self, forKey: .properties)

        let geometryContainer = try container.nestedContainer(keyedBy: GJGeometryCodingKeys.self, forKey: .geometry)
        geometryType = try geometryContainer.decode(GJGeometryType.self, forKey: .type)

        // Decodes the `geometry` property with one of the possible classes
        switch geometryType {
        case .point:
            let point: GJPoint = try container.decode(GJPoint.self, forKey: .geometry)
            self.geometry = point
            mkGeometry = point.asMKPointAnnotation()
            if id != nil {
                mkGeometry?.title = id
            }
        case .lineString:
            let line = try container.decode(GJLineString.self, forKey: .geometry)
            self.geometry = line
            mkGeometry = line.asMKPolyLine()
            if id != nil {
                mkGeometry?.title = id
            }
        case .multiLineString:
            let multiLine = try container.decode(GJMultiLineString.self, forKey: .geometry)
            self.geometry = multiLine

            mkGeometry = multiLine.asMKPolyLine()

            if id != nil {
                mkGeometry?.title = id
            }
        case .polygon:
            let polygon = try container.decode(GJPolygon.self, forKey: .geometry)
            self.geometry = polygon
            mkGeometry = polygon.asMKPolygon()
            if id != nil {
                mkGeometry?.title = id
            }
        case .multiPolygon:
            let multiPolygon = try container.decode(GJMultiPolygon.self, forKey: .geometry)
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
            throw GJGeometryError.invalidType
        }
    }
}

class GJFeatureCollection: Decodable {
    var type: GJObjectType = .featureCollection
    var features: [GJFeature]

    init(_ features: [GJFeature]) {
        self.features = features
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GJFeatureCollectionCodingKeys.self)
        type = try container.decode(GJObjectType.self, forKey: .type)
        features = try container.decode([GJFeature].self, forKey: .features)
    }

}

extension GJFeature {

    /// Turns any selected property into the `MK` Object Title
    ///
    /// - Parameter key:  _String_, defines the dictionary key to retrieve the value from.
    /// - Throws: throws _GJObjectError.invalidPropertyKey_ if the key is invalid or not found.
    func updateIdFromProperty(forKey key: String) throws {
        var value = id
        if let doubleValue = properties[key] as? Double {
            value = String(doubleValue)
        } else if let stringValue = properties[key] as? String {
            value = stringValue
        } else {
            throw GJObjectError.invalidPropertyKey
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
