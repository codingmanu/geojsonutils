//
//  MapKitTools.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 12/21/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

extension MKPolygon {

    func containsPoint(_ point: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let mapPoint: MKMapPoint = MKMapPoint(point)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: mapPoint)

        if polygonRenderer.path.contains(polygonViewPoint) {
            return true
        }

        return false
    }
}

extension MKMapView {
    func loadFeatureCollection(_ featureCollection: FeatureCollection) {

        for feature in featureCollection.features {

            switch feature.geometryType {
            case .point:
                guard let point = feature.geometry as? Point else { return }
                self.addAnnotation(point.asMKPointAnnotation())
            case .lineString:
                guard let line = feature.geometry as? LineString else { return }
                self.addAnnotation(line.asMKPolyLine())
            case .polygon:
                guard let polygon = feature.geometry as? Polygon else { return }
                self.addOverlay(polygon.asMKPolygon())
            case .multiPolygon:
                guard let multiPolygon = feature.geometry as? MultiPolygon else { return }
                for polygon in multiPolygon.getPolygons() {
                    let mkPoly = polygon.asMKPolygon()
                    self.addOverlay(mkPoly)
                }
            default:
                return
            }
        }
    }

    func loadPointsAsAnnotations(_ points: [Point]) {
        for point in points {
            self.addAnnotation(point.asMKPointAnnotation())
        }
    }
}
