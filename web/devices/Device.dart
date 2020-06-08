import 'dart:convert';
import 'dart:core';
import 'Server.dart';
import 'UPS.dart';

/// class Device
/// Represents a manageable device.
/// Stores a device's unique id, hostname, ip address and status on a given time.
class Device {

  ///Properties
  String deviceId;
  //String deviceName;
  String ipAddress;
  var lastChecked;
  bool active = false;

  ///Construtors
  Device(String id, /*String name,*/ String ip) {
    deviceId = id;
    //deviceName = name;
    ipAddress = ip;
  }

  Device.withStatus(String id, /*String name,*/ String ip, bool active) {
    deviceId = id;
    //deviceName = name;
    ipAddress = ip;
    active = active;
  }

  ///fromJSON()
  ///Factory constructor that parses a JSON to build a Device instance.
  factory Device.fromJSON(Map<String,dynamic> jsonContents) {
    
    if (!jsonContents.containsKey('device_type') || !jsonContents.containsKey('device_id') ||/* !jsonContents.containsKey('device_name') ||*/ !jsonContents.containsKey('device_ip') || !jsonContents.containsKey('device_status') ) {
      throw Exception('JSON received doesnt contain all required keys!');
    }

    if (jsonContents['device_type'] == 'server') {
      return Server.withStatus(
        jsonContents['device_id'],
        //jsonContents['device_name'],
        jsonContents['ip'],
        jsonContents['device_status']);
    }
    else if (jsonContents['device_type'] == 'ups') {
      if (!jsonContents.containsKey('device_charge')) {
        throw Exception('JSON doesnt contain device charge key!');
      }
      return UPS.withStatus(
        jsonContents['device_id'],
       // jsonContents['device_name'],
        jsonContents['ip'],
        jsonContents['device_charge'],
        jsonContents['device_status']);
    }
    else {
      throw Exception('Invalid device type on JSON!');
    }
  }

  ///Methods
  
  void updateDevice(var lastChecked,) {
    
  }


  ///stateAsText()
  ///Returns state value as a text for display.
  String stateAsText() {
    if (active) {
      return 'Ativo';
    } else {
      return 'Inativo';
    }
  }

  ///Getters/Setters
  void setActive(bool val) {
    active = val;
  }

}
