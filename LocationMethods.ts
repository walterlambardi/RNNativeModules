import { NativeModules } from 'react-native';

const { LocationMethods } = NativeModules;

// The getDeviceLocation method is a function that returns a Promise of a Coordinates object.

export interface Coordinates {
  latitude: number;
  longitude: number;
}

interface LocationMethodsProps {
  getDeviceLocation: () => Promise<Coordinates>;
}

export default LocationMethods as LocationMethodsProps;
