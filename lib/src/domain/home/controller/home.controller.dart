import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/repository/account.repository.dart';
import 'package:hanigold_admin/src/config/repository/auth.repository.dart';
import '../../auth/model/user_login.model.dart';

class HomeController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  final AccountRepository accountRepository = AccountRepository();
  final TextEditingController passwordOldController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController =
  TextEditingController();

  final Rxn<UserLoginModel> accountModel = Rxn<UserLoginModel>();
  var activeSubMenu = ''.obs;
  final box = GetStorage();
  var bottomNavIndex = 0.obs;
  RxBool showPasswordOld = true.obs;
  RxBool showPasswordNew = true.obs;

  void toggleSubMenu(String menuName) {
    if (activeSubMenu.value == menuName) {
      activeSubMenu.value = '';
    } else {
      activeSubMenu.value = menuName;
    }
  }

  bool isSubMenuOpen(String menuName) {
    return activeSubMenu.value == menuName;
  }

  Future<Map<String, dynamic>?> changePassword() async {
    if (passwordController.text == retypePasswordController.text) {
      try {
        EasyLoading.show(status: 'لطفا منتظر بمانید');
        var fetch = await authRepository.changePassword(
            box.read("mobile"),
            passwordController.text,
            passwordOldController.text,
            box.read("id") as int);
        Get.back();
        Get.snackbar(
            fetch["infos"][0]["title"], fetch["infos"][0]["description"]);
      } catch (e) {
        Get.snackbar("خطا", "خطا در تغییر رمز عبور: $e");
      } finally {
        EasyLoading.dismiss();
      }
    } else {
      Get.snackbar("رمز عبور", "عدم تطابق رمز عبور و تکرار آن");
    }
    return null;
  }

  void clearChangePasswordForm() {
    passwordController.clear();
    passwordOldController.clear();
    retypePasswordController.clear();
  }
}
