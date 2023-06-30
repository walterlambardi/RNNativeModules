import {
  Text,
  SafeAreaView,
  Pressable,
  StyleSheet,
  PermissionsAndroid,
  Platform,
  View,
} from 'react-native';
import React, { useState } from 'react';
import CustomMethod, { Coordinates } from './CustomMethod';

const App = () => {
  const [batteryLevel, setBatteryLevel] = useState<number | null>(null);
  const [phoneId, setPhoneId] = useState<string>('');
  const [qrCode, setQrCode] = useState<string>('');
  const [deviceLocation, setDeviceLocation] = useState<Coordinates | null>(
    null,
  );

  const getCurrentLocation = () =>
    CustomMethod?.getDeviceLocation()
      .then((location: Coordinates) => setDeviceLocation(location))
      .catch((error: any) => {
        console.error('Error:', error);
        setDeviceLocation(null);
      });

  const requestLocation = async () => {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        );
        if (granted === PermissionsAndroid.RESULTS.GRANTED) {
          getCurrentLocation();
        } else {
          console.log('Location permission denied.');
        }
      } catch (err) {
        console.warn(err);
      }
    } else {
      getCurrentLocation();
    }
  };

  const handlePress = () => {
    CustomMethod?.getBatteryLevel()
      .then((value: number) => {
        setBatteryLevel(value);
      })
      .catch(e => console.log(e));
    CustomMethod?.getPhoneId(setPhoneId);
  };

  const handlePressScanQR = () =>
    CustomMethod?.scanQRCode()
      .then(qrcde => setQrCode(qrcde))
      .catch(e => console.error('Error', e));

  return (
    <SafeAreaView>
      <Text style={styles.title}>React Native App with Native Modules</Text>

      {(batteryLevel ||
        phoneId.length > 0 ||
        deviceLocation ||
        qrCode.length > 0) && (
        <View style={styles.dataContainer}>
          {batteryLevel && <Text>Battery Level: {batteryLevel}</Text>}
          {phoneId.length > 0 && <Text>Phone Id: {phoneId}</Text>}
          {deviceLocation && (
            <Text>Device Location: {JSON.stringify(deviceLocation)}</Text>
          )}
          {qrCode.length > 0 && <Text>QR Scan result: {qrCode}</Text>}
        </View>
      )}

      <Pressable onPress={handlePress} style={styles.btn}>
        <Text>GET BATTERY LEVEL AND PHONE ID</Text>
      </Pressable>

      <Pressable onPress={requestLocation} style={styles.btn}>
        <Text>GET LOCATION</Text>
      </Pressable>

      <Pressable onPress={handlePressScanQR} style={styles.btn}>
        <Text>SCAN QR</Text>
      </Pressable>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  title: {
    fontSize: 20,
    color: 'black',
    marginTop: 20,
    textAlign: 'center',
  },
  dataContainer: {
    marginHorizontal: 20,
    marginTop: 20,
    height: 'auto',
    borderWidth: 1,
    borderColor: 'gray',
    borderRadius: 10,
    padding: 10,
  },
  btn: {
    height: 40,
    marginHorizontal: 20,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#b3def3ac',
    borderRadius: 10,
    marginTop: 20,
  },
});

export default App;
