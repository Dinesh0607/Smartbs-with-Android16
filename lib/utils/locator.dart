import 'package:get_it/get_it.dart';

import 'firebase_utility.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseUtility());
}
