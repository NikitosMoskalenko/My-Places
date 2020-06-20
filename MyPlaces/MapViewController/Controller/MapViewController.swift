//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Nikita Moskalenko on 6/12/20.
//  Copyright © 2020 Nikita Moskalenko. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// MARK: MapViewControllerDelegate implementation

protocol MapViewControllerDelegate {
    func sendAddresFromTheMap(to label: String?)
}

final class MapViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let mapManager = MapManager()
    private let annotationIdentifier = "annotationIdentifier"
    private var previousLocation: CLLocation? {
        didSet {
            mapManager.startTreckingUserLocation(for: mapView,
                                                 and: previousLocation,
                                                 clouser: {(currenLocation) in
                                                    self.previousLocation = currenLocation
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                        self.mapManager.showUserLocation(mapView: self.mapView)
                                                    }
            })
        }
    }
    
    // MARK: Public properties

    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = PlaceCellModel()
    var incomeSegueIdentifire = ""

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setUpMap()
    }
    
    // MARK: - Private methods

    private func setUpMap() {
        goButton.isHidden = true
        mapManager.checkLocationServices(mapView: mapView, idetifier: incomeSegueIdentifire) {
            mapManager.locationManager.delegate = self
        }
        guard incomeSegueIdentifire == "showPlace" else { return }
        mapManager.setUpPlaceMark(place: place, mapView: mapView)
        goButton.isHidden = false
        mapPinImage.isHidden = true
        addressLabel.isHidden = true
        doneButton.isHidden = true
    }
    
    // MARK: - @IBActions
    
    @IBAction func centerViewInUserLocation(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        mapViewControllerDelegate?.sendAddresFromTheMap(to: addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func getAwayButton(_ sender: Any) {
        mapManager.getDiractions(mapView: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        
        return renderer
    }
}

// MARK: - Extensions

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return MKAnnotationView() }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        guard annotationView == nil else { return MKAnnotationView() }
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        annotationView?.canShowCallout = true
        
        guard let imageData = place.imageData else { return MKAnnotationView() }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(data: imageData)
        annotationView?.rightCalloutAccessoryView = imageView

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifire == "showPlace", previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(center) { (placeMarks, error) in
            guard let error = error else { return }
            guard let placeMarks = placeMarks else { return }
            print(error)
            let placeMark =  placeMarks.first
            let streetTitle = placeMark?.thoroughfare
            let buildNumber = placeMark?.subThoroughfare
            
            DispatchQueue.main.async {
                guard let nonOptionalStreetTitle = streetTitle else { return }
                guard let nonOptionalBuildNumber = buildNumber else { return }
                if nonOptionalBuildNumber.count != 0, nonOptionalStreetTitle.count != 0 {
                    self.addressLabel.text = "\(nonOptionalStreetTitle), \(nonOptionalBuildNumber)"
                } else if nonOptionalStreetTitle.count != 0 {
                    self.addressLabel.text = "\(nonOptionalStreetTitle)"
                } else {
                    self.addressLabel.text = " "
                }
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAutorization(mapView: mapView, incomeSegueIdentifire: incomeSegueIdentifire)
    }
}
