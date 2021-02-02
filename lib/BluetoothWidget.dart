import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';


//블루투스 화면 위잿화
class bluetoothWidget extends StatefulWidget {
  @override
  _bluetoothHompage createState() => _bluetoothHompage();
}

//블루투스 페이지
class _bluetoothHompage extends State<bluetoothWidget> {
  BleManager _bleManager = BleManager(); //BLE 메니저
  bool _isScanning = false; //스캔 확인용
  List<BleDeviceItem> deviceList = []; //BLE 정보 저장용

  @override
  void initState() {
    init(); //BLE 초기화
  }

  void init() async {
    //BLE 생성
    await _bleManager
        .createClient(
        restoreStateIdentifier: "example-restore-state-identifier",
        restoreStateAction: (peripherals) {
          peripherals?.forEach((peripheral) {
            print("Restored peripheral: ${peripheral.name}");
          });
        })
        .catchError((e) => print("Couldn't create BLE client  $e"))
        .then((_) => _checkPermissions()) //BLE 생성 후 퍼미션 체크
        .catchError((e) => print("Permission check error $e"));
    //.then((_) => _waitForBluetoothPoweredOn())
  }

  //퍼미션 체크 및 없으면 퍼미션 동의 화면 출력
  _checkPermissions() async {
      if (await Permission.location.isGranted) {}
      else {
        Map<Permission, PermissionStatus> statuses =
        await [Permission.location].request();
      }
  }

  //스캔 ON/OFF
  void scan() async {
    if (!_isScanning) {
      deviceList.clear();
      _bleManager.startPeripheralScan().listen((scanResult) {
        // 페리페럴 항목에 이름이 있으면 그걸 사용하고
        // 없다면 어드버타이지먼트 데이터의 이름을 사용하고 그것 마져 없다면 Unknown으로 표시
        var name = scanResult.peripheral.name ??
            scanResult.advertisementData.localName ??
            "Unknown";

        var findDevice = deviceList.any((element) {
          if (element.peripheral.identifier ==
              scanResult.peripheral.identifier) {
            //이미 존재하면 기존 값을 갱신.
            element.peripheral = scanResult.peripheral;
            element.advertisementData = scanResult.advertisementData;
            element.rssi = scanResult.rssi;
            return true;
          }
          return false;
        });
        //처음 발견된 장치라면 devicelist에 추가
        if (!findDevice) {
          deviceList.add(BleDeviceItem(name, scanResult.rssi,
              scanResult.peripheral, scanResult.advertisementData));
        }
        //갱긴 적용.
        setState(() {});
      });
      //스캔중으로 변수 변경
      setState(() {
        _isScanning = true;
      });
    } else {
      //스캔중이었다면 스캔 정지
      _bleManager.stopPeripheralScan();
      setState(() {
        _isScanning = false;
      });
    }
  }

  //디바이스 리스트 화면에 출력
  list() {
    return ListView.builder(
      itemCount: deviceList.length,
      itemBuilder: (context, index) {
        return ListTile(
          //디바이스 이름과 맥주소 그리고 신호 세기를 표시한다.
          title: Text(deviceList[index].deviceName),
          subtitle: Text(deviceList[index].peripheral.identifier),
          trailing: Text("${deviceList[index].rssi}"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("블루투스"),
      ),
      body: Center(
        //디바이스 리스트 함수 호출
        child: list(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scan, //버튼이 눌리면 스캔 ON/OFF 동작
        child: Icon(_isScanning
            ? Icons.stop
            : Icons.bluetooth_searching), //_isScanning 변수에 따라 아이콘 표시 변경
      ),
    );
  }
}

//디바이스 정보 저장용 클래스
class BleDeviceItem {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;

  BleDeviceItem(
      this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}