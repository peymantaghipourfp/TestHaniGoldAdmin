import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/tools/controller/setting_chat.controller.dart';

class SettingChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingChatController());
  }
}
