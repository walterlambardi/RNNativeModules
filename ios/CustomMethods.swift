import Foundation
import UIKit
import React
import CoreLocation
import AVFoundation


@objc(CustomMethods)
class CustomMethods: NSObject, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationPromise: RCTPromiseResolveBlock?
  private var locationRejecter: RCTPromiseRejectBlock?

  private var captureSession: AVCaptureSession?
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  private var qrCodeFrameView: UIView?
  private var scanQRCodeResolve: RCTPromiseResolveBlock?

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


  @objc func scanQRCode(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
      let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
      let error = NSError(domain: "QRCodeScannerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])
      switch authorizationStatus {
      case .authorized:
          startQRCodeScanning(resolve: resolve, reject: reject)
      case .notDetermined:
          AVCaptureDevice.requestAccess(for: .video) { granted in
              DispatchQueue.main.async {
                  if granted {
                      self.startQRCodeScanning(resolve: resolve, reject: reject)
                  } else {
                      // Camera access denied, reject the promise
                      reject("QRCodeScannerError", "Camera access denied", error)
                  }
              }
          }
      default:
          // Camera access denied, reject the promise
          reject("QRCodeScannerError", "Camera access denied", error)
      }
  }
  
  private func startQRCodeScanning(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
      guard let captureDevice = AVCaptureDevice.default(for: .video) else {
          let error = NSError(domain: "QRCodeScannerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to access the device's camera"])
          reject("QRCodeScannerError", "Failed to access the device's camera", error)
          return
      }
      
      do {
          let input = try AVCaptureDeviceInput(device: captureDevice)
          captureSession = AVCaptureSession()
          captureSession?.addInput(input)
          
          let captureMetadataOutput = AVCaptureMetadataOutput()
          captureSession?.addOutput(captureMetadataOutput)
          
          captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
          captureMetadataOutput.metadataObjectTypes = [.qr]
          
          videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
          videoPreviewLayer?.videoGravity = .resizeAspectFill
          
          let rootViewController = UIApplication.shared.keyWindow?.rootViewController
          videoPreviewLayer?.frame = rootViewController?.view.bounds ?? CGRect.zero
          rootViewController?.view.layer.addSublayer(videoPreviewLayer!)
          
          qrCodeFrameView = UIView()
          qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
          qrCodeFrameView?.layer.borderWidth = 2
          rootViewController?.view.addSubview(qrCodeFrameView!)
          rootViewController?.view.bringSubviewToFront(qrCodeFrameView!)
          
          captureSession?.startRunning()
          
          // Store the resolve block to be used later when scanning is successful
          scanQRCodeResolve = resolve
      } catch {
          let error = NSError(domain: "QRCodeScannerError", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
          reject("QRCodeScannerError", error.localizedDescription, error)
      }
  }
  
  @objc
  func stopScanning() {
      captureSession?.stopRunning()
      captureSession = nil
      videoPreviewLayer?.removeFromSuperlayer()
      qrCodeFrameView?.removeFromSuperview()
  }
}

extension CustomMethods: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
      if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
          let stringValue = metadataObject.stringValue {
          stopScanning()
          let scannedQRCodeData: [String: Any] = [
              "value": stringValue
          ]
          // Resolve the promise with the scanned QR code data
          scanQRCodeResolve?(scannedQRCodeData)
      }
  }
}