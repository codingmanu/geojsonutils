//
//  ViewController.swift
//  GeoJsonUtilsApp
//
//  Created by Manuel S. Gomez on 1/24/19.
//  Copyright © 2019 codingManu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var mapOverlays = [MKOverlay]()
    var mapAnnotations = [MKAnnotation]()

    let newYorkViewRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(40.700, -73.983),
                                        latitudinalMeters: 15000,
                                        longitudinalMeters: 15000)

    let floridaViewRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(27.1527116979525, -80.8674058699175),
                                               latitudinalMeters: 500000,
                                               longitudinalMeters: 500000)

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapType = MKMapType.mutedStandard
        mapView.showsScale = true
        mapView.setRegion(newYorkViewRegion, animated: true)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnMap(_:)))
        mapView.addGestureRecognizer(tap)

        testLine()
    }

    func testLine() {
        let bundlefile = Bundle.main.url(forResource: "track_points", withExtension: "geojson")!
        let data = try? Data(contentsOf: bundlefile)

        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(GJFeatureCollection.self, from: data!)

        guard let features = decodedData?.features else { return }

        let points = features.map { (feature) -> GJPoint in
            // swiftlint:disable force_cast
            return feature.geometry as! GJPoint
        }

        if points.count > 0 {

            let line = GJLineString(points)
            mapView.addOverlay(line.asMKPolyLine())
        }
    }

    func resetMap() {

        mapView.removeOverlays(mapOverlays)
        mapView.removeAnnotations(mapAnnotations)

        mapAnnotations.removeAll()
        mapOverlays.removeAll()
    }

    func setFloridaRegion() {
        mapView.setRegion(floridaViewRegion, animated: true)
    }

    func setNewYorkRegion() {
        mapView.setRegion(newYorkViewRegion, animated: true)
    }
}

// MARK: - Actions
extension ViewController {

    @IBAction func resetMapButtonTapped(_ sender: Any) {
        resetMap()
    }

    @IBAction func loadInsideOutsidePointsButtonTapped(_ sender: Any) {
        resetMap()
        setNewYorkRegion()

        let alert = UIAlertController(title: "Check",
                                      message: "Tap the pins to check if they're inside or outside the polygon.",
                                      preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)

        let bundlefile = Bundle.main.url(forResource: "polygon", withExtension: "geojson")!
        let data = try? Data(contentsOf: bundlefile)

        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(GJPolygon.self, from: data!)

        guard let polygon = decodedData else { return }

        let mkPoly = polygon.asMKPolygon()
        mapView.addOverlay(mkPoly)
        mapOverlays = mapView.overlays

        let pt1 = GJPoint([-73.99643342179832, 40.63328912259067])
        let pt2 = GJPoint([-74.01643342179832, 40.63328912259067])

        let points = [pt1, pt2]
        mapView.loadGJPointsAsAnnotations(points)
        mapAnnotations = mapView.annotations
    }

    @IBAction func loadNYCNeighborhoodsButtonTapped(_ sender: Any) {
        resetMap()
        setNewYorkRegion()

        // swiftlint:disable line_length
        guard let featureCollection = try? GeoJsonUtils.readGJFeatureCollectionFrom(file: "nyc_neighborhoods", withExtension: "geojson") else { return }

        for feature in featureCollection.features {
            try? feature.updateIdFromProperty(forKey: "ntaname")
        }

        mapView.loadGJFeatureCollection(featureCollection)
        mapOverlays = mapView.overlays
    }

    @IBAction func loadFloridaTrailButtonTapped(_ sender: Any) {
        resetMap()
        setFloridaRegion()

        // swiftlint:disable line_length
        guard let featureCollection = try? GeoJsonUtils.readGJFeatureCollectionFrom(file: "trail", withExtension: "geojson") else { return }

        for feature in featureCollection.features {
            try? feature.updateIdFromProperty(forKey: "Trail_Name")
        }

        mapView.loadGJFeatureCollection(featureCollection)
        mapOverlays = mapView.overlays
    }

    @IBAction func twitterButtonTapped(_ sender: Any) {

        let screenName =  "codingmanu"
        let appURL = URL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = URL(string: "https://twitter.com/\(screenName)")!

        let application = UIApplication.shared

        if application.canOpenURL(appURL) {
            application.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Renderer customization & touch detection
extension ViewController {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyLine = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyLine)

            testlineRenderer.strokeColor = .red
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }

        if let polygon = overlay as? MKPolygon {
            let testPolygonRenderer = MKPolygonRenderer(polygon: polygon)

            testPolygonRenderer.fillColor = UIColor.gray.withAlphaComponent(0.5)
            testPolygonRenderer.strokeColor = .blue
            testPolygonRenderer.lineWidth = 1.0
            return testPolygonRenderer
        }
        fatalError("Other overlay types found...")
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let polygon = mapView.overlays[0] as? MKPolygon else { return }

        if polygon.containsCoordinate(view.annotation!.coordinate) {
            let alert = UIAlertController(title: "Inside",
                                          message: "Selected point is inside polygon.",
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            self.present(alert, animated: true, completion: {
                mapView.deselectAnnotation(view.annotation, animated: true)
            })

        } else {
            let alert = UIAlertController(title: "Outside",
                                          message: "Selected point is outside polygon.",
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            self.present(alert, animated: true, completion: {
                mapView.deselectAnnotation(view.annotation, animated: true)
            })
        }
    }

    @objc func didTapOnMap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        let rect = mapView.squareAroundCoordinate(coordinate, withScaleFactor: 0.15)

        if mapView.annotations(in: rect).count == 0 {
            let polygons: [MKPolygon] = mapView.overlays.filter { (overlay) -> Bool in
                    overlay is MKPolygon
                } as! [MKPolygon]
            // swiftlint:disable:previous force_cast

            for polygon in polygons {
                if polygon.containsCoordinate(coordinate) {
                    if polygon.title != nil {
                        let alert = UIAlertController(title: "Neighborhood",
                                                      message: "\n\(polygon.title!)\n",
                            preferredStyle: UIAlertController.Style.alert)

                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
