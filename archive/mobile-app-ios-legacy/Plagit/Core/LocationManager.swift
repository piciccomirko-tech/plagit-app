//
//  LocationManager.swift
//  Plagit
//
//  CoreLocation wrapper for real-time user location.
//  Persists coordinates to profile once per session when first acquired.
//

import Foundation
import CoreLocation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    var latitude: Double?
    var longitude: Double?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var hasLocation: Bool { latitude != nil && longitude != nil }

    /// Called once when coordinates are first acquired in a session.
    /// Set by the active root view to persist coords to the appropriate profile.
    var onLocationAcquired: ((Double, Double) -> Void)?

    private let manager = CLLocationManager()
    private var hasPersisted = false

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else {
            requestPermission()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude

        // Persist once per session
        if !hasPersisted {
            hasPersisted = true
            onLocationAcquired?(loc.coordinate.latitude, loc.coordinate.longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently handle — UI will show "enable location" state
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
