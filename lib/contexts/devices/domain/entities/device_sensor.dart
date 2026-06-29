class DeviceSensor {
  final String title;
  final String subtitle;
  final String value;
  final bool alert;
  final String room;
  final bool isConnected;
  final String lastSeen;
  final String sensorType;

  DeviceSensor(
      this.title,
      this.subtitle,
      this.value,
      this.alert,
      this.room, [
      this.isConnected = true,
      this.lastSeen = 'Just now',
      this.sensorType = 'Unknown',
      ]);
}