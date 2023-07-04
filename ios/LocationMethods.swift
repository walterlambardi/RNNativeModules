import Foundation
import React
import CoreLocation


@objc(LocationMethods)
class LocationMethods: NSObject, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationPromise: RCTPromiseResolveBlock?
  private var locationRejecter: RCTPromiseRejectBlock?


  override init() {
      super.init()
      
      locationManager = CLLocationManager()
      locationManager?.delegate = self
      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
      locationManager?.requestWhenInUseAuthorization()
  }

  @objc func getDeviceLocation(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
      locationPromise = resolve
      locationRejecter = reject
      
      DispatchQueue.global(qos: .background).async {
          self.locationManager?.startUpdatingLocation()
      }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let location = locations.last else {
          return
      }
      
      locationManager?.stopUpdatingLocation()
      
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      
      let locationData: [String: Any] = [
          "latitude": latitude,
          "longitude": longitude
      ]
      
      locationPromise?(locationData)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationManager?.stopUpdatingLocation()
      locationRejecter?("LocationError", error.localizedDescription, nil)
  }
}
