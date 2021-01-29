import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';


import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '테스트용'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BleManager _bleManager = BleManager();
  String _homeScreenText = "wait";
  int _counter = 0;
  final TextEditingController _topicController =
  TextEditingController(text: 'topic');
  String qrcode = "";
  DateTime date = DateTime.now();
  String time = "";
  var httpResult = "";
  TextEditingController _inputController = new TextEditingController();
  TextEditingController _outputController = new TextEditingController();
  String message2 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Row(
                children: [
                  FlatButton(
                    child: Text('QRcode', style: TextStyle(fontSize: 24)),
                    onPressed: (){
                      final result = Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QRWidget()),
                      ).then((value) => setState(() {
                        Barcode a = value;
                        qrcode = a.code;
                      }));


                    },
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text('$qrcode'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text("\n"),
            Container(
              child: Row(
                children: [
                  FlatButton(
                    child: Text('알람', style: TextStyle(fontSize: 24)),
                    // onPressed: (),
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text('$message2'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text("\n"),
            Container(
              child: Row(
                children: [
                  FlatButton(
                    child: Text('날짜', style: TextStyle(fontSize: 24)),
                    onPressed: _datePicker,
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text("${date.toLocal()}".split(' ')[0]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text("\n"),
            Container(
              child: Row(
                children: [
                  FlatButton(
                    child: Text('시간', style: TextStyle(fontSize: 24)),
                    onPressed: _timePicker,
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text('$time'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text("\n"),
            Container(
              child: Row(
                children: [
                  FlatButton(
                    child: Text('http통신', style: TextStyle(fontSize: 24)),
                    onPressed: _httpConnection,
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                  Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            // 컨테이너 내부 하단에 8픽셀만큼 패딩 삽입
                            child: Text(
                              // 컨테이너의 자식으로 텍스트 삽입
                              "$httpResult",
                              style:
                              TextStyle(fontWeight: FontWeight.bold // 텍스트 강조 설정
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ), //----------------------------

            Text("\n"),
            Container(
              child: Row(
                children: [
                  FlatButton(
                    child: Text('블루투스', style: TextStyle(fontSize: 24)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => bluetoothWidget()),
                      );
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _datePicker() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: date, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != date)
      setState(() {
        date = picked;
      });
  }

  Future _timePicker() async {
    TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
    String _hour, _minute, _time;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
      });
    if (picked != null && picked != time)
      setState(() {
        time = _time;
      });
  }

  Future _httpConnection() async {
    String url =
        "https://maeulro.sharenshare.kr/user/alert/select/C214ACE3986F4";
    var response = await http.get(url);

    setState(() {
      // httpResult = response.statusCode;
      // httpResult = response.headers;
      httpResult = response.body;
    });
  }
}

@override
State<StatefulWidget> createState() {
  // TODO: implement createState
  throw UnimplementedError();
}


//QR코드 화면 위잿화
class QRWidget extends StatefulWidget {
  @override
  _QRHompage createState() => _QRHompage();
}
class _QRHompage extends State<QRWidget>{
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    // TODO: implement initState
    _checkPermissions;
    super.initState();

  }
  _checkPermissions() async{
    if (await Permission.camera.isGranted) {}
    else {
      Map<Permission, PermissionStatus> statuses =
      await [Permission.camera].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {

    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller?.pauseCamera();
        Navigator.pop(context, result);
      });
    });
  }
}

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
    if (Platform.isAndroid) {
      if (await Permission.location.isGranted) {}
      else {
        Map<Permission, PermissionStatus> statuses =
        await [Permission.location].request();
      }
    }
    else if (Platform.isIOS) {
      if (await Permission.location.isGranted) {}
      else {
        Map<Permission, PermissionStatus> statuses =
        await [Permission.location].request();
      }
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
        /*
        // 여러가지 정보 확인
        print("Scanned Name ${name}, RSSI ${scanResult.rssi}");
        print("\tidentifier(mac) ${scanResult.peripheral.identifier}"); //mac address
        print("\tservice UUID : ${scanResult.advertisementData.serviceUuids}");
        print("\tmanufacture Data : ${scanResult.advertisementData.manufacturerData}");
        print("\tTx Power Level : ${scanResult.advertisementData.txPowerLevel}");
        print("\t${scanResult.peripheral}");
        */
        //이미 검색된 장치인지 확인 mac 주소로 확인
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

void main() {
  runApp(MyApp());
}
