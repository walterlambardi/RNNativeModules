import { NativeModules } from 'react-native';

const { CustomMethods } = NativeModules;

// The getBatteryLevel method is a function that returns a Promise of a number.
// The getPhoneId method takes a callback function as an argument, which will be called with a string parameter.
// The scanQRCode method is a function that returns a Promise of a string.

interface CustomMethodsProps {
  getBatteryLevel: () => Promise<number>;
  getPhoneId: (callback: (id: string) => void) => void;
  scanQRCode: () => Promise<string>;
}

export default CustomMethods as CustomMethodsProps;
