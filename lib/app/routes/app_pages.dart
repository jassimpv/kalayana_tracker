import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/modules/auth/auth_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/auth/auth_view.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/dashboard_view.dart';
import 'package:kalayanaexpresstracker/app/modules/legal/legal_views.dart';
import 'package:kalayanaexpresstracker/app/modules/splash/splash_view.dart';
import 'app_routes.dart';

export 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.helpSupport, page: () => const HelpSupportView()),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsView(),
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
