import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/modules/auth/auth_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/auth/auth_view.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/dashboard_view.dart';
import 'package:kalayanaexpresstracker/app/modules/legal/legal_views.dart';
import 'package:kalayanaexpresstracker/app/modules/splash/splash_view.dart';

class AppRoutes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const dashboard = '/dashboard';
  static const privacyPolicy = '/privacy-policy';
  static const deleteAccount = '/delete-account';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: AppRoutes.deleteAccount,
      page: () => const DeleteAccountView(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => AuthView(),
      binding: BindingsBuilder(() => Get.lazyPut(AuthController.new)),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
