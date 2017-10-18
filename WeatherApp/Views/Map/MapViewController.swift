//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSPersistentContainer
import GoogleMaps
import UIKit

class MapViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView! {
        didSet {
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
        }
    }

    private var observer: NSKeyValueObservation!

    var persistentContainer: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        observer = observe(\.mapView.myLocation) { [unowned self] _, _ in
            self.centerInCurrentLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private methods

    private final func centerInCurrentLocation() {
        guard let location = mapView.myLocation else { return }

        let cameraPosition = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 14)
        mapView.animate(to: cameraPosition)
    }
}

extension MapViewController: GMSMapViewDelegate {

    // MARK: GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let weatherDetailViewController: WeatherDetailViewController = UIStoryboard(storyBoardName: .main).instantiateViewController()
        weatherDetailViewController.locationCoordinate = coordinate
        weatherDetailViewController.persistentContainer = persistentContainer
        navigationController?.pushViewController(weatherDetailViewController, animated: true)
    }
}

extension MapViewController: PersistentContainerSettable {}
