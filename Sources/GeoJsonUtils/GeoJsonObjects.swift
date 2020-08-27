//
//  GeoJSONObject.swift
//  GeoJsonUtils
//
//  Created by Manuel S. Gomez on 12/20/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

// MARK: - GeoJSON Object Types
public enum GJObjectType: String, Codable {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

// MARK: - Coding Keys
public enum GJFeatureCodingKeys: String, CodingKey {
    case type
    case id
    case properties
    case geometry
}

public enum GJFeatureCollectionCodingKeys: String, CodingKey {
    case type
    case properties
    case features
}

public enum GJObjectError: Error {
    case invalidFeature
    case invalidFeatureCollection
    case invalidType
    case invalidProperties
    case invalidGeometry
    case invalidFeatures
    case invalidPropertyKey
}

public enum GJError: Error {
    case readingFile
    case readingData
    case decoding
}

// MARK: - Models for Feature & FeatureCollection
public class GJFeature: Decodable {

    /// Feature Properties
    public var type: GJObjectType = .feature
    public var id: String?
    public var properties: [String: Any]
    public var geometryType: GJGeometryType
    public var geometry: Decodable

    /// Lazy MapKit Geometries
    lazy public var mkGeometry: MKShape? = {
        return buildMKGeometry()
    }()

    lazy public var multiMkGeometry: [MKShape]? = {
        return buildMultiMKGeometry()
    }()

    /// Init / Decoding
    public required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: GJFeatureCodingKeys.self)

        if let doubleIdValue = try? container.decode(Double.self, forKey: .id) {
            id = String(doubleIdValue)
        } if let intIdValue = try? container.decode(Int.self, forKey: .id) {
            id = String(intIdValue)
        } else {
            id = try? container.decode(String.self, forKey: .id)
        }

        properties = (try? container.decode(Dictionary<String, Any>.self, forKey: .properties)) ?? [:]

        let geometryContainer = try container.nestedContainer(keyedBy: GJGeometryCodingKeys.self, forKey: .geometry)
        geometryType = try geometryContainer.decode(GJGeometryType.self, forKey: .type)

        /// Decodes the `geometry` property with one of the possible classes and tries to assign an `id` to mkGeometry or each multiMkGeometry item.
        switch geometryType {
        case .point:
            let point: GJPoint = try container.decode(GJPoint.self, forKey: .geometry)
            self.geometry = point

        case .multiPoint:
            let multiPoint = try container.decode(GJMultiPoint.self, forKey: .geometry)
            self.geometry = multiPoint

        case .lineString:
            let line = try container.decode(GJLineString.self, forKey: .geometry)
            self.geometry = line

        case .multiLineString:
            let multiLine = try container.decode(GJMultiLineString.self, forKey: .geometry)
            self.geometry = multiLine

        case .polygon:
            let polygon = try container.decode(GJPolygon.self, forKey: .geometry)
            self.geometry = polygon

        case .multiPolygon:
            let multiPolygon = try container.decode(GJMultiPolygon.self, forKey: .geometry)
            self.geometry = multiPolygon
        }
    }
}

public class GJFeatureCollection: Decodable {
    public var type: GJObjectType = .featureCollection
    public var features: [GJFeature]

    init(_ features: [GJFeature]) {
        self.features = features
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GJFeatureCollectionCodingKeys.self)
        type = try container.decode(GJObjectType.self, forKey: .type)

        features = try container.decode(FailableDecodableArray<GJFeature>.self, forKey: .features).elements
    }

}

// MARK: - MapKit integration
public extension GJFeature {

    /// MapKit entity builder for single geometries. Adds the `id` as the MapKit object title.
    private func buildMKGeometry() -> MKShape? {

        var mkGeometry = MKShape()

        switch self.geometryType {
        case .point:
            guard let point: GJPoint = self.geometry as? GJPoint else { return nil }
            mkGeometry = point.asMKPointAnnotation()
            if id != nil {
                mkGeometry.title = id
            }
        case .lineString:
            guard let line: GJLineString = self.geometry as? GJLineString else { return nil }
            mkGeometry = line.asMKPolyLine()
            if id != nil {
                mkGeometry.title = id
            }
        case .polygon:
            guard let polygon: GJPolygon = self.geometry as? GJPolygon else { return nil }

            mkGeometry = polygon.asMKPolygon()
            if id != nil {
                mkGeometry.title = id
            }
        default:
            return nil
        }
        return mkGeometry
    }

    /// MapKit entity builder for multi-geometries. Adds the `id` as the MapKit objects title.
    private func buildMultiMKGeometry() -> [MKShape]? {

        var multiMkGeometry = [MKShape]()

        switch self.geometryType {
        case .multiPoint:
            guard let multiPoint: GJMultiPoint = self.geometry as? GJMultiPoint else { return nil }

            for annotation in multiPoint.asMKPointAnnotationArray() {
                if id != nil {
                    annotation.title = id
                }
                multiMkGeometry.append(annotation)
            }

        case .multiLineString:
            guard let multiLine: GJMultiLineString = self.geometry as? GJMultiLineString else { return nil }

            for lineString in multiLine.asMKPolyLineArray() {
                if id != nil {
                    lineString.title = id
                }
                multiMkGeometry.append(lineString)
            }

        case .multiPolygon:
            guard let multiPolygon: GJMultiPolygon = self.geometry as? GJMultiPolygon else { return nil }

            for polygon in multiPolygon.getPolygons() {
                let mkPolygon = polygon.asMKPolygon()
                if id != nil {
                    mkPolygon.title = id
                }
                multiMkGeometry.append(mkPolygon)
            }

        default:
            return nil
        }
        return multiMkGeometry
    }

    /// Turns any selected property into the `MK` Object Title
    ///
    /// - Parameter key:  _String_, defines the dictionary key to retrieve the value from.
    /// - Throws: throws _GJObjectError.invalidPropertyKey_ if the key is invalid or not found.
    func updateTitleFromProperty(forKey key: String) throws {
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
            guard let annotation = self.mkGeometry as? MKPointAnnotation else { return }
            annotation.title = value

        case .multiPoint:
            guard let multiMkGeometry = self.multiMkGeometry else { return }

            for geometry in multiMkGeometry {
                guard let annotation = geometry as? MKPointAnnotation else { return }
                annotation.title = value
            }

        case .lineString:
            guard let overlay = self.mkGeometry as? MKPolyline else { return }
            overlay.title = value

        case .multiLineString:
            guard let multiMkGeometry = self.multiMkGeometry else { return }

            for geometry in multiMkGeometry {
                guard let overlay = geometry as? MKPolyline else { return }
                overlay.title = value
            }

        case .polygon:
            guard let overlay = self.mkGeometry as? MKPolygon else { return }
            overlay.title = value

        case .multiPolygon:
            guard let multiMkGeometry = self.multiMkGeometry else { return }
            for geometry in multiMkGeometry {
                guard let overlay = geometry as? MKPolygon else { return }
                overlay.title = value
            }
        }
    }
}
