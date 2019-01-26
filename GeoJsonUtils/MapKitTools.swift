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
                self.loadPointFeatureAsAnnotation(feature)
            case .lineString:
                self.loadLineStringFeatureAsOverlay(feature)
            case .polygon:
                self.loadPolygonFeatureAsOverlay(feature)
            case .multiPolygon:
                self.loadMultiPolygonFeatureAsOverlay(feature)
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

    func loadPointFeatureAsAnnotation(_ feature: Feature) {
        if feature.geometryType == .point {
            guard let point = feature.geometry as? Point else { return }

            let anno = MKPointAnnotation()
            anno.coordinate = point.asCLLocationCoordinate2D()

            if feature.id != nil {
                if let titleString = feature.id as? String {
                    anno.title = titleString
                }

                if let titleDouble = feature.id as? Double {
                    anno.title = String(titleDouble)
                }
            }

            self.addAnnotation(anno)
        }
    }

    func loadLineStringFeatureAsOverlay(_ feature: Feature) {
        if feature.geometryType == .lineString {
            guard let line = feature.geometry as? LineString else { return }
            let overlay = line.asMKPolyLine()

            if feature.id != nil {
                if let titleString = feature.id as? String {
                    overlay.title = titleString
                }

                if let titleDouble = feature.id as? Double {
                    overlay.title = String(titleDouble)
                }
            }

            self.addOverlay(overlay)
        }
    }

    func loadPolygonFeatureAsOverlay(_ feature: Feature) {
        if feature.geometryType == .polygon {
            guard let polygon = feature.geometry as? Polygon else { return }
            let overlay = polygon.asMKPolygon()

            if feature.id != nil {
                if let titleString = feature.id as? String {
                    overlay.title = titleString
                }

                if let titleDouble = feature.id as? Double {
                    overlay.title = String(titleDouble)
                }
            }

            self.addOverlay(overlay)
        }
    }

    func loadMultiPolygonFeatureAsOverlay(_ feature: Feature){
        if feature.geometryType == .multiPolygon {
            guard let multiPolygon = feature.geometry as? MultiPolygon else { return }
            for polygon in multiPolygon.getPolygons() {
                let overlay = polygon.asMKPolygon()

                if feature.id != nil {
                    if let titleString = feature.id as? String {
                        overlay.title = titleString
                    }

                    if let titleDouble = feature.id as? Double {
                        overlay.title = String(titleDouble)
                    }
                }
            }
        }
    }
}
