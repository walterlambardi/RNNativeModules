//
//  LocationMethods.m
//  RNNativeModules
//
//  Created by Walter Lambardi on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(LocationMethods, NSObject)

RCT_EXTERN_METHOD(getDeviceLocation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
