import Foundation
import UIKit
import React
import CoreLocation

@objc(CustomMethods)
class CustomMethods: NSObject, CLLocationManagerDelegate {
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

  @objc static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc func getBatteryLevel(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.global(qos: .background).async {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == .unknown {
        let error = NSError(domain: "Battery Level Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Battery state is unknown"])
        reject("Battery Level Error", "Battery state is unknown", error)
        return
      }
      let batteryLevel = device.batteryLevel * 100
      resolve(Int(batteryLevel))
    }
  }

  @objc func getPhoneId(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.global(qos: .background).async {
      guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else {
        callback([""])
        return
      }
      callback([deviceID])
    }
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
