import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBluex {
  static const MethodChannel _channel = const MethodChannel('bluetoothadapter');

  static const EventChannel _connectionStatusEventChannel =
      const EventChannel('connection_status');

  static const EventChannel _receivedMessagesEventChannel =
      const EventChannel('recieved_message_events');

  /// Initiates the Bluetooth Connection by setting up a UUID
  Future<bool> initBlutoothConnection(String uuid) async {
    return await _channel
        .invokeMethod('initBlutoothConnection', {"uuid": uuid});
  }

  /// Gets list of all the Paired Bluetooth Devices
  Future<List<BtDevice>> getDevices() async {
    List devices = await _channel.invokeMethod('getBtDevices');
    List<BtDevice> responseList = [];
    devices.forEach((element) {
      BtDevice device = BtDevice.fromJson(element);
      responseList.add(device);
    });
    return responseList;
  }

  /// Gets a Particular Paired from the list of paired devices from its Device(Mac) address
  Future<BtDevice?> getDevice(String address) async {
    Map? device =
        await _channel.invokeMethod('getBtDevice', {"address": address});
    if (device == null) {
      return null;
    }
    BtDevice btDevice = BtDevice.fromJson(device);
    return btDevice;
  }

  /// Checks the Bluetooth status and returns true if Bluetooth is turned on
  Future<bool> checkBluetooth() async {
    bool result = await _channel.invokeMethod('checkBt');
    return result;
  }

  /// Starts Bluetooth Server, now the device works as a bluetooth server
  Future<bool> startServer() async {
    bool result = await _channel.invokeMethod('startServer');
    return result;
  }

  /// Starts Bluetooth Client, now the device works as a bluetooth client
  Future<bool> startClient(String address, [bool isSecure = false]) async {
    bool result = await _channel.invokeMethod('startClient', {
      "address": address,
      "isSecure": isSecure,
    });
    return result;
  }

  void closeClient() async {
    await _channel.invokeMethod('close');
  }

  /// Sends message from client to server and vice versa, byte by byte or as a data stream
  Future<bool> sendMessage(String message, {bool? sendByteByByte}) async {
    bool result = await _channel.invokeMethod('sendMessage', {
      "message": message,
      "sendByteByByte": sendByteByByte ?? false,
    });
    return result;
  }

  /// Stream which listens to the connection status between client and server
  Stream<dynamic> connectionStatus() {
    return _connectionStatusEventChannel.receiveBroadcastStream();
  }

  /// Stream which listens messages send by client or server
  Stream<dynamic> receiveMessages() {
    return _receivedMessagesEventChannel.receiveBroadcastStream();
  }
}

/// A Data structure to hold device information of a paired bluetooth device
class BtDevice {
  late String address;
  late String name;

  BtDevice(this.address, this.name);

  BtDevice.fromJson(Map data) {
    address = data["address"];
    name = data["name"];
  }
}
