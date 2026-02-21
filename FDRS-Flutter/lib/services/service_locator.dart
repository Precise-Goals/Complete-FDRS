import 'package:get_it/get_it.dart';
import 'navigation_service.dart';
import 'auth_service.dart';
import 'location_service.dart';
import 'database_service.dart';
import 'distress_service.dart';
import 'offline_distress_queue.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => DistressService());
  locator.registerLazySingleton(() {
    final queue = OfflineDistressQueue();
    queue.startAutoFlush();
    return queue;
  });
}
