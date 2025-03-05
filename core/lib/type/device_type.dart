enum DeviceType {
  unknown,
  phone,
  tablet,
  computer;

  static DeviceType fromValue(int value) {
    switch (value) {
      case 1:
        return DeviceType.phone;
      case 2:
        return DeviceType.tablet;
      case 3:
        return DeviceType.computer;
      case 0:
      default:
        return DeviceType.unknown;
    }
  }
}
