//
//  LocationBrain.swift
//  moonPhaseDiary2
//
//  Created by Masahiro Yamashita on 2023/10/14.
//

import CoreLocation


class LocationBrain: NSObject, ObservableObject, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    @Published var location: CLLocation?//CLLocationCoordinate2D?
    @Published var requesting: Bool = false
    @Published var place: CLPlacemark?
    //@Published var :CLLocation

    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        request()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        request()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first//.coordinate
        let lc = CLLocation(latitude: location?.coordinate.latitude ?? 0, longitude: location?.coordinate.longitude ?? 0)
        CLGeocoder().reverseGeocodeLocation(lc) { pls, error in
            if let pl = pls?.first {
                self.place = pl
            }
        }
        
        requesting = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        requesting = false
    }
    
    private func request() {
        if (locationManager.authorizationStatus == .authorizedWhenInUse) {
            requesting = true
            locationManager.requestLocation()
        }
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> CLPlacemark? {
        let geocoder = CLGeocoder()
        do {
            let placemark = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            return placemark.first!
        } catch {
            print(error)
            return nil
        }
    }
}
