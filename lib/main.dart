import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

	const keyApplicationId = 'mgZxSlg9mZb4r0dFNStqE7gn1w8C1CD9aIt3cE2K';
	const keyClientKey = 'dqMKX5IMEdFFGjQUvWzQCIBMkhH0o3yk441zCRrl';
	const keyParseServerUrl = 'https://parseapi.back4app.com';

	await Parse().initialize(
		keyApplicationId,
		keyParseServerUrl,
		clientKey: keyClientKey,
		autoSendSessionId: true,
	);

	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}