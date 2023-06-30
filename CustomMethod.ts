import { NativeModules } from 'react-native';

const { CustomMethods } = NativeModules;

export interface Coordinates {
  latitude: number;
  longitude: number;
}
interface CustomMethodsProps {
  getBatteryLevel: () => Promise<number>;
  getPhoneId: (callback: (id: string) => void) => void;
  getDeviceLocation: () => Promise<Coordinates>;
}

export default CustomMethods as CustomMethodsProps;
