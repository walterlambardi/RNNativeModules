# React Native + Native Modules App

## Custom Packages build in Swift and Kotlin

I have developed custom packages using Swift and Kotlin to provide functionality for retrieving device information in a React Native app. These packages include methods such as getBatteryLevel, getPhoneId, getDeviceLocation, and scanQRCode, which offer different ways of accessing device-related data.

The getBatteryLevel method, available in both the Swift and Kotlin packages, returns a promise. This means that when you call this method, it will asynchronously fetch the battery level information and provide the result through a resolved promise.

On the other hand, the getPhoneId method, also available in both packages, returns the device ID through a callback. This means that you need to pass a callback function as a parameter when calling this method, and it will be invoked with the device ID as the argument.

The getDeviceLocation method is another common functionality available in both the Swift and Kotlin packages. This method retrieves the device's location and returns the result through a promise, similar to the getBatteryLevel method.

Additionally, the scanQRCode method has been added to the custom packages. This method utilizes the device camera to scan QR codes. When you invoke this method, it will activate the camera and read the QR code, providing the scanned data through a resolved promise.

```
    interface CustomMethodsProps {
      getBatteryLevel: () => Promise<number>;
      getPhoneId: (callback: (id: string) => void) => void;
      getDeviceLocation: () => Promise<Coordinates>;
      scanQRCode: () => Promise<string>;
    }
```

By utilizing these custom packages, you can easily incorporate features like retrieving battery level, device ID, device location, and scanning QR codes into your React Native app. This allows you to access important device-related information seamlessly across both Android and iOS platforms.

> This text was generated with the help of ChatGPT, a language model developed by OpenAI. However, the content of the message accurately reflects the intended meaning and conveys the desired information.
