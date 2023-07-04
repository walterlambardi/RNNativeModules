//
//  CustomMethods.m
//  RNNativeModules
//
//  Created by Walter Lambardi on 30/06/2023.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(CustomMethods, NSObject)

RCT_EXTERN_METHOD(getBatteryLevel:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getPhoneId:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(scanQRCode:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
