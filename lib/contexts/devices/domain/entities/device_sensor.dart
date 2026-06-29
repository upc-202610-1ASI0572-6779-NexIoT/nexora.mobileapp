class DeviceSensor {
  final String title;
  final String subtitle;
  final String value;
  final bool alert;
  final String room;
  final bool isConnected;

  DeviceSensor(
      this.title,
      this.subtitle,
      this.value,
      this.alert,
      this.room, [
      this.isConnected = true,
      ]);
}