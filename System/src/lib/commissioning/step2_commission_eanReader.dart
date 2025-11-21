// ignore_for_file: avoid_unnecessary_containers

import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:esl_mobile_app/components/lm_home_card.dart';
import 'package:esl_mobile_app/components/my_solid_button.dart';
import 'package:esl_mobile_app/models/actionArguments/commission_arguments.dart';
import 'package:esl_mobile_app/views/Commissioning/step2_commission_eanInput.dart';
import 'package:esl_mobile_app/views/notifications/notifications_view.dart';
import 'package:esl_mobile_app/views/operations_view.dart';
import 'package:esl_mobile_app/components/cmp_navigation_bar.dart';
import 'package:esl_mobile_app/views/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../../../services/barcode_scanner/barcode_detector_painter.dart';
import '../../../../../styles/app_themes.dart';

class Step2CommissionEanReader extends StatefulWidget {
  Step2CommissionEanReader({Key? key,
    this.customPaint,
    //this.onImage,
    required this.allowedBarcodeFormats,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);

  CustomPaint? customPaint;

  //final Function(InputImage inputImage)? onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  List<BarcodeFormat> allowedBarcodeFormats;

  @override
  State<StatefulWidget> createState() => _Step2CommissionEanReaderState();
}

class _Step2CommissionEanReaderState extends State<Step2CommissionEanReader> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  //
  bool _canProcess = true;
  bool _isBusy = false;
  String? _text;
  late BarcodeScanner _barcodeScanner;
  bool barcodeFound = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  var args = CommissioningArguments();

  @override
  Widget build(BuildContext context) {
    args = ModalRoute
        .of(context)!
        .settings
        .arguments as CommissioningArguments;
    _barcodeScanner = BarcodeScanner(formats: widget.allowedBarcodeFormats);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comissionar produto", style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                _liveFeedBody(),
                Container(
                  height: 3,
                  color: MyColorStyles.danger600,
                ),
              ],),
            Text('Escaneie o código de barras do produto',
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall,
                textAlign: TextAlign.center),
            // const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: Image.asset(
                  'assets/esl/esl_ean_scan_indicator.png',
                  height: 250,
                  width: 250,
                ),
              ),
            ]),
            // const SizedBox(height: 20),
            Text(
              'OU',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: MySolidButton(
              buttonLabel: Text('Digite o código manualmente'),
              onPressedCallBack: () async =>
              {
                //await _stopLiveFeed(),
                if (context.mounted) {
                  Navigator.of(context).pushNamed(
                    '/commissioning/commission/eanInput',
                    arguments: args,
                  ),
                }
              }),
        ),
      ),
    );
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();

    var size = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
        height: 180,
        width: double.infinity,
        color: Colors.black,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Container(
                width: size/3,
                height: size / _controller!.value.aspectRatio,
                child: CameraPreview(
                  _controller!,
                  //child: widget.customPaint,
                ),
              ),
            ),
          ),
        )
      // Stack(
      //   fit: StackFit.expand,
      //   children: <Widget>[
      //     Center(
      //       child: _changingCameraLens
      //           ? const Center(
      //         child: Text('Changing camera lens'),
      //       )
      //           : CameraPreview(
      //         _controller!,
      //         //child: widget.customPaint,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,

      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    onImage(inputImage);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble() * 1, image.height.toDouble() * 1),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  void onImage(InputImage inputImage) {
    if (barcodeFound) return;
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final barcodes = _barcodeScanner.processImage(inputImage);
    barcodes.then((value) async {
      if (barcodeFound) return;
      var rtrn;
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = BarcodeDetectorPainter(
          value,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          widget.initialCameraLensDirection,
        );
        widget.customPaint = CustomPaint(painter: painter);
        if (value.isNotEmpty && mounted) {
          rtrn = value.first.rawValue;
          barcodeFound = true;

          //await _stopLiveFeed();
          if (context.mounted) {
            //Navigator.of(context).pop(rtrn);
            if (context.mounted && rtrn != null ) {
              debugPrint(rtrn);
              print(rtrn);
              Navigator.of(context).pushNamed(
                '/commissioning/commission/checkout',
                arguments: CommissioningArguments(
                  macAddress: args.macAddress,
                  ean: rtrn,
                ),
              );
            }
          }
        }
      } else {
        String text = 'Barcodes found: ${value.length}\n\n';
        for (final barcode in value) {
          text += 'Barcode: ${barcode.rawValue}\n\n';
          //await _stopLiveFeed();
          if (context.mounted) {
            /*Navigator.of(context).pushNamed(
                '/labelActions/placeLabel/glnReader',
                arguments: barcode.rawValue ?? '');*/
          }
        }
        _text = text;
        // TODO: set _customPaint to draw boundingRect on top of image
        widget.customPaint = null;
      }
    });

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future _stopLiveFeed() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller?.stopImageStream();
      await _controller?.dispose();
    }

    _controller = null;
  }
}

const kLabelStyleNormal = TextStyle(
  color: Color(0xFF808080),
  fontWeight: FontWeight.w300,
  fontFamily: 'Roboto',
  fontSize: 18,
);