import { NativeModules } from 'react-native';

const { LocationMethods } = NativeModules;

// The getBatteryLevel method is a function that returns a Promise of a number.
// The getPhoneId method takes a callback function as an argument, which will be called with a string parameter.
// The getDeviceLocation method is a function that returns a Promise of a Coordinates object.
// The scanQRCode method is a function that returns a Promise of a string.

export interface Coordinates {
  latitude: number;
  longitude: number;
}

interface LocationMethodsProps {
  getDeviceLocation: () => Promise<Coordinates>;
}

export default LocationMethods as LocationMethodsProps;
