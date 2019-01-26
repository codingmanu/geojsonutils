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

    let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(40.700, -73.983),
                                        latitudinalMeters: 15000,
                                        longitudinalMeters: 15000)

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapType = MKMapType.mutedStandard
        mapView.showsScale = true
        mapView.setRegion(viewRegion, animated: true)
    }

    func resetMap() {

        mapView.removeOverlays(mapOverlays)
        mapView.removeAnnotations(mapAnnotations)

        mapAnnotations.removeAll()
        mapOverlays.removeAll()

        mapView.setRegion(viewRegion, animated: true)
    }
}

// MARK: - Actions
extension ViewController {

    @IBAction func resetMapButtonTapped(_ sender: Any) {
        resetMap()
    }

    @IBAction func loadInsideOutsidePointsButtonTapped(_ sender: Any) {
        resetMap()

        let alert = UIAlertController(title: "Check",
                                      message: "Tap the pins to check if they're inside or outside the polygon.",
                                      preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)

        let bundlefile = Bundle.main.url(forResource: "polygon", withExtension: "geojson")!
        let data = try? Data(contentsOf: bundlefile)

        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(Polygon.self, from: data!)

        guard let polygon = decodedData else { return }

        let mkPoly = polygon.asMKPolygon()
        mapView.addOverlay(mkPoly)
        mapOverlays = mapView.overlays

        let pt1 = Point([-73.99643342179832, 40.63328912259067])
        let pt2 = Point([-74.01643342179832, 40.63328912259067])

        let points = [pt1, pt2]
        mapView.loadPointsAsAnnotations(points)
        mapAnnotations = mapView.annotations
    }

    @IBAction func loadNYCNeighborhoodsButtonTapped(_ sender: Any) {
        resetMap()

        // swiftlint:disable line_length
        guard let featureCollection = try? GeoJsonUtils.readFeatureCollectionFrom(file: "nyc_neighborhoods", withExtension: "geojson") else { return }
        mapView.loadFeatureCollection(featureCollection)
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

        //Return an `MKPolygonRenderer` for the `MKPolygon` in the `MKMapViewDelegate`s method
        if let polygon = overlay as? MKPolygon {
            let testlineRenderer = MKPolygonRenderer(polygon: polygon)

            testlineRenderer.fillColor = UIColor.gray.withAlphaComponent(0.5)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 1.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let polygon = mapView.overlays[0] as? MKPolygon else { return }

        if polygon.containsPoint(view.annotation!.coordinate) {
            let alert = UIAlertController(title: "Inside",
                                          message: "Selected point is inside polygon.",
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            self.present(alert, animated: true, completion: {
                view.setSelected(false, animated: true)
            })

        } else {
            let alert = UIAlertController(title: "Outside",
                                          message: "Selected point is outside polygon.",
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            self.present(alert, animated: true, completion: {
                view.setSelected(false, animated: true)
            })
        }
    }
}
