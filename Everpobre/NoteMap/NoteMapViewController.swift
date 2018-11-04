//
//  NoteMapViewController.swift
//  Everpobre
//
//  Created by Aitor Garcia on 04/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import MapKit

protocol NoteMapViewControllerDelegate: class {
    func didChangeLocation(coordinate: CLLocationCoordinate2D)
}

class NoteMapViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: Location?
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    weak var delegate: NoteMapViewControllerDelegate?
    
    // MARK: - Init
    
    init(location: Location?) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Location"
        
        if let location = location {
            let initLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            addAnnotation(coordinate: initLocation)
            centerMap(at: initLocation)
        } else {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestWhenInUseAuthorization()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    private func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Note location"
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    private func centerMap(at coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: 1000)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func addPoint(_ sender: UILongPressGestureRecognizer) {
        let mapLocation = sender.location(in: mapView)
        let coordinates = self.mapView.convert(mapLocation, toCoordinateFrom: mapView)
        
        delegate?.didChangeLocation(coordinate: coordinates)
        
        addAnnotation(coordinate: coordinates)
    }
    
}

extension NoteMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            if let userLocation = locations.last {
                centerMap(at: userLocation.coordinate)
            }
        }
    }
}
