import '../entities/device_sensor.dart';

abstract class DevicesRepository {
  Future<List<DeviceSensor>> getDevices();
}
