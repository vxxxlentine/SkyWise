import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, LocationManagerProtocol {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var denied = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            self.location = nil
            manager.requestLocation()
        case .denied, .restricted:
            denied = true
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            location = locations.last?.coordinate
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("error location:", error)
        }
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .denied, .restricted:
            denied = true
        case .authorizedWhenInUse, .authorizedAlways: denied = false
            manager.requestLocation()
        default:
            break
        }
    }
}

protocol LocationManagerProtocol: ObservableObject {
    var location: CLLocationCoordinate2D? { get }
    var denied: Bool { get }
    func requestLocation()
}
