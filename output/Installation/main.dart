import 'package:device_info_plus/device_info_plus.dart';
import 'package:esl_mobile_app/components/lm_notification.dart';
import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:esl_mobile_app/services/login_process_manager.dart';
import 'package:esl_mobile_app/styles/app_themes.dart';
import 'package:esl_mobile_app/utils/constants.dart';
import 'package:esl_mobile_app/views/Commissioning/step1_commission_macInput.dart';
import 'package:esl_mobile_app/views/Commissioning/step1_commission_macReader.dart';
import 'package:esl_mobile_app/views/Commissioning/step2_commission_eanInput.dart';
import 'package:esl_mobile_app/views/Commissioning/step2_commission_eanReader.dart';
import 'package:esl_mobile_app/views/Commissioning/step3_commission_checkout.dart';
import 'package:esl_mobile_app/views/Installation/installation_view.dart';
import 'package:esl_mobile_app/views/Installation/installation_mode_qrcode_reader.dart';
import 'package:esl_mobile_app/views/Installation/installation_mode_selector.dart';
import 'package:esl_mobile_app/views/Installation/installation_options_view.dart';
import 'package:esl_mobile_app/views/Installation/step1_installation_macInput.dart';
import 'package:esl_mobile_app/views/Installation/step1_installation_macReader.dart';
import 'package:esl_mobile_app/views/Installation/step2_installation_glnInput.dart';
import 'package:esl_mobile_app/views/Installation/step3_installation_Checkout.dart';
import 'package:esl_mobile_app/views/Login/login_view_2.dart';
import 'package:esl_mobile_app/views/Uninstallation/step1_uninstall_macInput.dart';
import 'package:esl_mobile_app/views/Uninstallation/step1_uninstall_macReader.dart';
import 'package:esl_mobile_app/views/Uninstallation/step2_uninstall_checkout.dart';
import 'package:esl_mobile_app/views/Uninstallation/uninstallation_view.dart';
import 'package:esl_mobile_app/views/Uninstallation/uninstallation_options_view.dart';
import 'package:esl_mobile_app/views/actions/step0_commissioning_actions.dart';
import 'package:esl_mobile_app/views/actions/step0_installation_actions.dart';
import 'package:esl_mobile_app/views/decommission/step1_decommission_macInput.dart';
import 'package:esl_mobile_app/views/decommission/step1_decommission_macReader.dart';
import 'package:esl_mobile_app/views/decommission/step2_decommission_checkout.dart';
import 'package:esl_mobile_app/views/installationAndCommissioning/step1_installAndCommission_macInput.dart';
import 'package:esl_mobile_app/views/installationAndCommissioning/step1_installAndCommission_macReader.dart';
import 'package:esl_mobile_app/views/installationAndCommissioning/step2_installAndCommission_glnInput.dart';
import 'package:esl_mobile_app/views/installationAndCommissioning/step3_installAndCommission_eanInput.dart';
import 'package:esl_mobile_app/views/installationAndCommissioning/step3_installAndCommission_eanReader.dart';
import 'package:esl_mobile_app/views/installationAndCommissioning/step4_installAndCommission_checkout.dart';
import 'package:esl_mobile_app/views/search/all/step1_search_all.dart';
import 'package:esl_mobile_app/views/search/byMac/step1_searchByMac_macInput.dart';
import 'package:esl_mobile_app/views/search/byMac/step1_searchByMac_macReader.dart';
import 'package:esl_mobile_app/views/search/byMac/step2_searchByMac_esl.dart';
import 'package:esl_mobile_app/views/search/byProductName/step1_search_byProductName.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/views/Home/home.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/Map/map_view.dart';
import 'package:esl_mobile_app/views/Commissioning/commissioning_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OverlayState? overlayState;
  OverlayEntry? overlayEntry;

  // ignore: unused_local_variable
  closeNotificationOverlay() {
    debugPrint('cliquei');
    overlayEntry!.remove();
  }

  pushNotificationsHandler(
      FirebaseMessaging messaging, VoidCallback callback) async {
    // Obtensão do token
    String? token = await messaging.getToken(
      vapidKey: 'Seu certificados push da Web aqui',
    );
    debugPrint('TOKEN: $token');

    await _setPushToken(token);

    // Mensagem em foreground
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint('Recebi uma mensagem enquanto estava em primeiro plano!');
        debugPrint('Dados da mensagem: ${message.data}');

        if (message.notification != null) {
          //showMyDialog(message.notification!.title, message.notification!.body);
          overlayState = Navigator.of(navigatorKey.currentContext!).overlay;
          // overlayEntry = OverlayEntry(
          //   builder: (BuildContext context) {
          //     return LmNotification(
          //       title: message.notification!.title,
          //       message: message.notification!.body,
          //       closeNotificationOverlay: callback,
          //     );
          //   },
          // );
          // overlayState?.insert(overlayEntry!);
        }
      },
    );

    // Background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Mensagem que inicializa o app
    var data = await FirebaseMessaging.instance.getInitialMessage();

    //if (data!.data["message"].length > 0) showMyDialog(data.data["message"], );
  }

  if (!kIsWeb) {
    //NESTED IF FOR A REASON: chrome does not support the instructions below
    if (!Platform.isWindows || !Platform.isLinux) {
      await Firebase.initializeApp();

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      //asking for notifications permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        //permission granted
        pushNotificationsHandler(messaging, closeNotificationOverlay);
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        //provisional notifications granted
        pushNotificationsHandler(messaging, closeNotificationOverlay);
      }
      //else, permission denied
    }
  }

  HttpOverrides.global = MyHttpOverrides();
  runApp(const ESL_Mobile_App());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint("Mensagem recebida em background: ${message.data}");
}

void showMyDialog(String? title, String? message) {
  Widget okButton = OutlinedButton(
    onPressed: () => Navigator.pop(navigatorKey.currentContext!),
    child: const Text('Ok'),
  );

  AlertDialog alerta = AlertDialog(
    title: Text(title ?? ''),
    content: Text(message ?? ''),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return alerta;
    },
  );
}

Future<void> _setPushToken(String? token) async {
  debugPrint('main(123): token = $token');
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (token != null) {
    debugPrint('Enviando o token para o servidor');
    CacheManagement().setNotificationToken(token);

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? brand;
    String? model;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      model = androidInfo.model;
      brand = androidInfo.brand;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      model = iosInfo.utsname.machine;
      brand = 'Apple';
    }
    //send to MainApp informations about device like employeeLeroyCode and phone token
  }
}

class ESL_Mobile_App extends StatelessWidget {
  const ESL_Mobile_App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // print("ENV: $ENV"); // ENV variable removed - now using fixed URLs
    return MaterialApp(
      theme: AppThemes().themeData,
      initialRoute: '/login',
      restorationScopeId: 'root',
      routes: {
        '/login': (context) => LoginView(),
        '/': (context) => const HomeView(),
        '/map': (context) => const LmMapView(),

        //--------------------------------- Installation and Uninstallation ---------------------------------
        '/installation': (context) => const Step0InstallationActions(),

        //Installation
        '/installation/install/macReader': (context) =>
            Step1InstallationMacReader(
              allowedBarcodeFormats: const [BarcodeFormat.code128],
            ),
        '/installation/install/macInput': (context) =>
            const Step1InstallationMacInput(),
        '/installation/install/gln': (context) => Step2InstallationGlnInput(),
        '/installation/install/checkout': (context) =>
            Step3InstallationCheckout(),

        //Uninstallation
        '/installation/uninstall/macReader': (context) =>
            Step1UninstallMacReader(
                allowedBarcodeFormats: const [BarcodeFormat.code128]),
        '/installation/uninstall/macInput': (context) =>
            const Step1UninstallMacInput(),
        '/installation/uninstall/checkout': (context) =>
            Step2UninstallationCheckout(),

    //--------------------------------- Commissioning and Decommissioning ---------------------------------
    /* PVSCL:IFCOND(Commission) */
    '/commissioning': (context) => const Step0CommissioningActions(),

    //Commissioning
    '/commissioning/commission/macReader': (context) =>
      Step1CommissionMacReader(
        allowedBarcodeFormats: const [BarcodeFormat.code128]),
    '/commissioning/commission/macInput': (context) =>
      const Step1CommissionMacInput(),
    '/commissioning/commission/eanReader': (context) =>
      Step2CommissionEanReader(
        allowedBarcodeFormats: const [BarcodeFormat.all]),
    '/commissioning/commission/eanInput': (context) =>
      Step2CommissionEanInput(),
    '/commissioning/commission/checkout': (context) =>
      Step3CommissionCheckout(),

    //Decommissioning
    '/commissioning/decommission/macReader': (context) =>
      Step1DecommissionMacReader(
        allowedBarcodeFormats: const [BarcodeFormat.code128]),
    '/commissioning/decommission/macInput': (context) =>
      Step1DecommissionMacInput(),
    '/commissioning/decommission/checkout': (context) =>
      Step2DecommissionCheckout(),
    /* PVSCL:ENDCOND */

        //--------------------------------- Installation and Commissioning ---------------------------------
        '/installNCommission/install/macReader': (context) =>
            Step1InstallAndCommissionMacReader(
                allowedBarcodeFormats: const [BarcodeFormat.code128]),
        '/installNCommission/install/macInput': (context) =>
            const Step1InstallAndCommissionMacInput(),
        '/installNCommission/install/gln': (context) =>
            Step2InstallAndCommissionGlnInput(),
        '/installNCommission/commission/eanReader': (context) =>
            Step3InstallAndCommissionEanReader(
                allowedBarcodeFormats: const [BarcodeFormat.all]),
        '/installNCommission/commission/eanInput': (context) =>
            Step3InstallAndCommissionEanInput(),
        '/installNCommission/commission/checkout': (context) =>
            Step4InstallallAndCommissionCheckout(),

        //--------------------------------- Searches ---------------------------------
        '/search/all': (context) => Step1SearchAll(),

        '/search/byProductName': (context) => Step1SearchByProductName(listingEslsFlag: false),
        '/search/byProductNameListingEsl': (context) => Step1SearchByProductName(listingEslsFlag: true),
        '/search/byMac/macReader': (context) => Step1SearchByMacMacReader(
            allowedBarcodeFormats: const [BarcodeFormat.all]),
        '/search/byMac/macInput': (context) => const Step1SearchByMacMacInput(),
        '/search/byMac/esl': (context) => Step2SearchByMac(),
      },
      navigatorKey: navigatorKey,
    );
  }
}
