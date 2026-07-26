import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/account/model/account.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/topic.model.dart';
import 'package:hanigold_admin/src/domain/tools/controller/setting_chat.controller.dart';
import 'package:hanigold_admin/src/domain/tools/model/admin_chat_topic.model.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';

import '../../../widget/app_drawer.widget.dart';
import '../../../widget/chat_floating_button.widget.dart';
import '../../../widget/custom_appbar1.widget.dart';
import '../../../widget/custom_dropdown.widget.dart';

enum _SettingChatBreakpoint { mobile, tablet, desktop }

_SettingChatBreakpoint _breakpointFor(double width) {
  if (width < 600) {
    return _SettingChatBreakpoint.mobile;
  }
  if (width < 1024) {
    return _SettingChatBreakpoint.tablet;
  }
  return _SettingChatBreakpoint.desktop;
}

String _topicDropdownValue(TopicModel topic) {
  return '${topic.topicId}:${topic.title ?? '—'} (${topic.code ?? ''})';
}

TopicModel? _topicFromDropdownValue(
    String? value,
    List<TopicModel> available,
    ) {
  if (value == null || !value.contains(':')) {
    return null;
  }
  final topicId = int.tryParse(value.split(':').first);
  if (topicId == null) {
    return null;
  }
  for (final topic in available) {
    if (topic.topicId == topicId) {
      return topic;
    }
  }
  return null;
}

class SettingChatView extends StatefulWidget {
  const SettingChatView({super.key});

  @override
  State<SettingChatView> createState() => _SettingChatViewState();
}

class _SettingChatViewState extends State<SettingChatView> {
  bool _mobileShowingTopics = false;

  void _openMobileTopics() {
    if (!_mobileShowingTopics) {
      setState(() => _mobileShowingTopics = true);
    }
  }

  void _closeMobileTopics() {
    if (_mobileShowingTopics) {
      setState(() => _mobileShowingTopics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingChatController>();

    return Scaffold(
      appBar: CustomAppbar1(
        title: 'تنظیمات موضوعات چت',
        onBackTap: () => Get.toNamed('/home'),
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final breakpoint = _breakpointFor(width);
          final outerPadding = switch (breakpoint) {
            _SettingChatBreakpoint.mobile => 8.0,
            _SettingChatBreakpoint.tablet => 12.0,
            _SettingChatBreakpoint.desktop => 20.0,
          };

          if (breakpoint == _SettingChatBreakpoint.mobile &&
              _mobileShowingTopics) {
            return _buildBodyShell(
              breakpoint: breakpoint,
              outerPadding: outerPadding,
              child: _buildMobileTopicsScreen(controller),
            );
          }

          return _buildBodyShell(
            breakpoint: breakpoint,
            outerPadding: outerPadding,
            child: switch (breakpoint) {
              _SettingChatBreakpoint.mobile =>
                  _buildMobileAccountsScreen(controller),
              _SettingChatBreakpoint.tablet =>
                  _buildTabletLayout(controller, isLandscape: width > 700),
              _SettingChatBreakpoint.desktop =>
                  _buildDesktopLayout(controller),
            },
          );
        },
      ),
      floatingActionButton: const ChatFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBodyShell({
    required _SettingChatBreakpoint breakpoint,
    required double outerPadding,
    required Widget child,
  }) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgHaniGold.png'),
          fit: BoxFit.contain,
          opacity: 0.06,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(outerPadding),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.secondaryColor.withAlpha(200),
              borderRadius: BorderRadius.circular(
                breakpoint == _SettingChatBreakpoint.mobile ? 12 : 16,
              ),
              border: Border.all(color: AppColor.dividerColor.withAlpha(80)),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(SettingChatController controller) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildAccountsPanel(controller, compact: false)),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: AppColor.dividerColor.withAlpha(100),
        ),
        Expanded(flex: 3, child: _buildTopicsPanel(controller, compact: false)),
      ],
    );
  }

  Widget _buildTabletLayout(
      SettingChatController controller, {
        required bool isLandscape,
      }) {
    if (isLandscape) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildAccountsPanel(controller, compact: true),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColor.dividerColor.withAlpha(100),
          ),
          Expanded(
            flex: 3,
            child: _buildTopicsPanel(controller, compact: true),
          ),
        ],
      );
    }

    return Column(
      children: [
        Flexible(
          flex: 5,
          child: _buildAccountsPanel(controller, compact: true),
        ),
        Divider(height: 1, color: AppColor.dividerColor.withAlpha(100)),
        Flexible(
          flex: 6,
          child: _buildTopicsPanel(controller, compact: true),
        ),
      ],
    );
  }

  Widget _buildMobileAccountsScreen(SettingChatController controller) {
    return _buildAccountsPanel(
      controller,
      compact: true,
      onAccountSelected: (account) async {
        await controller.selectAccount(account);
        _openMobileTopics();
      },
    );
  }

  Widget _buildMobileTopicsScreen(SettingChatController controller) {
    return Obx(() {
      final selected = controller.selectedAccount.value;
      if (selected == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _closeMobileTopics();
        });
        return _emptyState(
          icon: Icons.touch_app_outlined,
          message: 'ابتدا یک کاربر انتخاب کنید',
          compact: true,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMobileTopicsAppBar(selected),
          Expanded(
            child: _buildTopicsPanel(
              controller,
              compact: true,
              showHeader: false,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMobileTopicsAppBar(AccountModel selected) {
    return Material(
      color: AppColor.backGroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: _closeMobileTopics,
              tooltip: 'بازگشت به لیست کاربران',
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.buttonColor,
                size: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.name ?? '—',
                    style: AppTextStyle.bodyTextBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    selected.code != null && selected.code!.isNotEmpty
                        ? 'کد: ${selected.code}'
                        : 'مدیریت موضوعات',
                    style: AppTextStyle.bodyText.copyWith(
                      fontSize: 12,
                      color: AppColor.textColorSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsPanel(
      SettingChatController controller, {
        required bool compact,
        Future<void> Function(AccountModel account)? onAccountSelected,
      }) {
    final padding = compact ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            icon: Icons.people_outline,
            title: 'کاربران ادمین',
            subtitle: compact
                ? 'کاربر را انتخاب کنید'
                : 'یک کاربر را برای مدیریت موضوعات انتخاب کنید',
            compact: compact,
          ),
          SizedBox(height: compact ? 10 : 12),
          TextField(
            controller: controller.accountSearchController,
            style: AppTextStyle.bodyText,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'جستجو بر اساس نام یا کد...',
              hintStyle: AppTextStyle.bodyText.copyWith(
                color: AppColor.textColorSecondary,
                fontSize: compact ? 13 : null,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColor.iconViewColor,
              ),
              filled: true,
              fillColor: AppColor.backGroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(compact ? 10 : 12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: compact ? 10 : 12,
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Expanded(child: Obx(() => _buildAccountsBody(
            controller,
            compact: compact,
            onAccountSelected: onAccountSelected,
          ))),
        ],
      ),
    );
  }

  Widget _buildAccountsBody(
      SettingChatController controller, {
        required bool compact,
        Future<void> Function(AccountModel account)? onAccountSelected,
      }) {
    switch (controller.accountsState.value) {
      case SettingChatPageState.loading:
        return const Center(child: HaniGoldLoading.large());
      case SettingChatPageState.error:
        return _errorState(
          message: controller.accountsError.value.isNotEmpty
              ? controller.accountsError.value
              : 'خطا در بارگذاری کاربران',
          onRetry: controller.fetchAccounts,
          compact: compact,
        );
      case SettingChatPageState.empty:
        return _emptyState(
          icon: Icons.person_off_outlined,
          message: 'کاربری یافت نشد',
          compact: compact,
        );
      case SettingChatPageState.list:
        final accounts = controller.filteredAccounts;
        if (accounts.isEmpty) {
          return _emptyState(
            icon: Icons.search_off,
            message: 'نتیجه‌ای برای جستجو یافت نشد',
            compact: compact,
          );
        }
        return ListView.separated(
          padding: EdgeInsets.only(bottom: compact ? 8 : 0),
          itemCount: accounts.length,
          separatorBuilder: (_, __) => SizedBox(height: compact ? 6 : 8),
          itemBuilder: (context, index) {
            final account = accounts[index];
            return Obx(() {
              final isSelected =
                  controller.selectedAccount.value?.id == account.id;
              return _AccountListTile(
                key: ValueKey(account.id),
                account: account,
                isSelected: isSelected,
                compact: compact,
                onTap: () async {
                  if (onAccountSelected != null) {
                    await onAccountSelected(account);
                  } else {
                    await controller.selectAccount(account);
                  }
                },
              );
            });
          },
        );
    }
  }

  Widget _buildTopicsPanel(
      SettingChatController controller, {
        required bool compact,
        bool showHeader = true,
      }) {
    return Padding(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Obx(() {
        final selected = controller.selectedAccount.value;
        if (selected == null) {
          return _emptyState(
            icon: Icons.touch_app_outlined,
            message: compact
                ? 'یک کاربر انتخاب کنید'
                : 'برای مشاهده و مدیریت موضوعات، یک کاربر انتخاب کنید',
            compact: compact,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              _sectionHeader(
                icon: Icons.forum_outlined,
                title: 'موضوعات ${selected.name ?? ''}',
                subtitle: selected.code != null && selected.code!.isNotEmpty
                    ? 'کد: ${selected.code}'
                    : 'مدیریت موضوعات اختصاص‌یافته',
                compact: compact,
              ),
              SizedBox(height: compact ? 12 : 16),
            ],
            _buildAssignTopicBar(controller, compact: compact),
            SizedBox(height: compact ? 12 : 16),
            Expanded(
              child: _buildAssignedTopicsBody(controller, compact: compact),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAssignTopicBar(
      SettingChatController controller, {
        required bool compact,
      }) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: AppColor.backGroundColor,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(color: AppColor.dividerColor.withAlpha(80)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackControls = constraints.maxWidth < 420;

          return Obx(() {
            final available = controller.availableTopicsToAssign;
            final isLoadingTopics = controller.isLoadingAllTopics.value;
            final isAssigning = controller.isAssigning.value;
            final canAssign = !isAssigning &&
                !isLoadingTopics &&
                controller.topicToAssign.value != null &&
                available.isNotEmpty;

            final topicItems =
            available.map(_topicDropdownValue).toList();
            final selectedTopic = controller.topicToAssign.value;
            final selectedTopicValue = selectedTopic != null &&
                available.any((topic) => topic.topicId == selectedTopic.topicId)
                ? _topicDropdownValue(selectedTopic)
                : null;
            final dropdownEnabled =
                !isLoadingTopics && !isAssigning && topicItems.isNotEmpty;

            final dropdown = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /*Text(
                  'افزودن موضوع جدید',
                  style: AppTextStyle.labelText.copyWith(
                    fontSize: compact ? 12 : null,
                    color: AppColor.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 6),*/
                CustomDropdownWidget(
                  items: topicItems,
                  selectedValue: selectedTopicValue,
                  enabledChange: dropdownEnabled,
                  showHintText: true,
                  backgroundColor: AppColor.backGroundColor2,
                  borderColor: AppColor.dividerColor.withAlpha(100),
                  borderRadius: 10,
                  hideUnderline: true,
                  onChanged: dropdownEnabled
                      ? (value) {
                    controller.topicToAssign.value =
                        _topicFromDropdownValue(value, available);
                  }
                      : null,
                ),
              ],
            );

            final addButton = SizedBox(
              width: stackControls ? double.infinity : null,
              child: ElevatedButton.icon(
                onPressed: canAssign ? controller.assignSelectedTopic : null,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: stackControls ? 16 : 20,
                      vertical: compact ? 12 : 14,
                    ),
                  ),
                  backgroundColor:
                  WidgetStateProperty.all(AppColor.buttonColor),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                icon: isAssigning
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  isAssigning ? 'در حال افزودن...' : 'افزودن',
                  style: AppTextStyle.bodyText.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 13 : null,
                  ),
                ),
              ),
            );

            if (stackControls) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dropdown,
                  const SizedBox(height: 10),
                  addButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: dropdown),
                const SizedBox(width: 12),
                addButton,
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildAssignedTopicsBody(
      SettingChatController controller, {
        required bool compact,
      }) {
    return Obx(() {
      switch (controller.assignedTopicsState.value) {
        case SettingChatPageState.loading:
          return const Center(child: HaniGoldLoading.large());
        case SettingChatPageState.error:
          return _errorState(
            message: controller.assignedTopicsError.value.isNotEmpty
                ? controller.assignedTopicsError.value
                : 'خطا در بارگذاری موضوعات',
            onRetry: () {
              final id = controller.selectedAccount.value?.id;
              if (id != null) {
                controller.fetchAssignedTopics(id.toString());
              }
            },
            compact: compact,
          );
        case SettingChatPageState.empty:
          return _emptyState(
            icon: Icons.topic_outlined,
            message: 'هنوز موضوعی برای این کاربر ثبت نشده است',
            compact: compact,
          );
        case SettingChatPageState.list:
          return ListView.separated(
            padding: EdgeInsets.only(bottom: compact ? 12 : 0),
            itemCount: controller.assignedTopics.length,
            separatorBuilder: (_, __) => SizedBox(height: compact ? 6 : 8),
            itemBuilder: (context, index) {
              final topic = controller.assignedTopics[index];
              return Obx(() {
                final isDeleting =
                    controller.deletingTopicId.value == topic.id;
                return _AssignedTopicTile(
                  key: ValueKey(topic.id),
                  topic: topic,
                  isDeleting: isDeleting,
                  compact: compact,
                  onDelete: () => _confirmDelete(controller, topic, compact),
                );
              });
            },
          );
      }
    });
  }

  Future<void> _confirmDelete(
      SettingChatController controller,
      AdminChatTopicModel topic,
      bool compact,
      ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColor.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: compact ? 20 : 40),
        title: Text('حذف موضوع', style: AppTextStyle.largeTitleText),
        content: Text(
          'آیا از حذف موضوع «${topic.topicTitle ?? ''}» اطمینان دارید؟',
          style: AppTextStyle.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'انصراف',
              style: AppTextStyle.bodyText.copyWith(
                color: AppColor.textColorSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.errorColor,
            ),
            child: Text(
              'حذف',
              style: AppTextStyle.bodyText.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.removeAssignedTopic(topic);
    }
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool compact,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColor.primaryColor, size: compact ? 22 : 26),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: compact
                    ? AppTextStyle.mediumBodyTextBold
                    : AppTextStyle.largeTitleText,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyle.bodyText.copyWith(
                  color: AppColor.textColorSecondary,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
    required bool compact,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: compact ? 44 : 56,
              color: AppColor.iconViewColor.withAlpha(140),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyle.bodyText.copyWith(
                color: AppColor.textColorSecondary,
                fontSize: compact ? 13 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState({
    required String message,
    required VoidCallback onRetry,
    required bool compact,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColor.errorColor,
              size: compact ? 40 : 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyle.bodyText.copyWith(
                color: AppColor.errorColor,
                fontSize: compact ? 13 : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColor.buttonColor),
              label: Text(
                'تلاش مجدد',
                style: AppTextStyle.bodyText.copyWith(
                  color: AppColor.buttonColor,
                  fontSize: compact ? 13 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountListTile extends StatelessWidget {
  const _AccountListTile({
    super.key,
    required this.account,
    required this.isSelected,
    required this.onTap,
    required this.compact,
  });

  final AccountModel account;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColor.buttonColor.withAlpha(50)
          : AppColor.backGroundColor,
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
            border: Border.all(
              color: isSelected
                  ? AppColor.buttonColor
                  : AppColor.dividerColor.withAlpha(60),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 16 : 18,
                backgroundColor: isSelected
                    ? AppColor.buttonColor
                    : AppColor.iconViewColor.withAlpha(60),
                child: Icon(
                  Icons.person,
                  color: isSelected ? Colors.white : AppColor.iconViewColor,
                  size: compact ? 18 : 20,
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name ?? '—',
                      style: AppTextStyle.bodyTextBold.copyWith(
                        fontSize: compact ? 13 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (account.code != null && account.code!.isNotEmpty)
                      Text(
                        account.code!,
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: compact ? 11 : 12,
                          color: AppColor.textColorSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColor.buttonColor,
                  size: compact ? 20 : 22,
                )
              else if (compact)
                const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColor.iconViewColor,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignedTopicTile extends StatelessWidget {
  const _AssignedTopicTile({
    super.key,
    required this.topic,
    required this.isDeleting,
    required this.onDelete,
    required this.compact,
  });

  final AdminChatTopicModel topic;
  final bool isDeleting;
  final VoidCallback onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColor.backGroundColor,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(color: AppColor.dividerColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.topic_outlined,
            color: AppColor.primaryColor,
            size: compact ? 20 : 22,
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.topicTitle ?? '—',
                  style: AppTextStyle.bodyTextBold.copyWith(
                    fontSize: compact ? 13 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (topic.topicCode != null && topic.topicCode!.isNotEmpty)
                  Text(
                    topic.topicCode!,
                    style: AppTextStyle.bodyText.copyWith(
                      fontSize: compact ? 11 : 12,
                      color: AppColor.textColorSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: isDeleting ? null : onDelete,
            tooltip: 'حذف موضوع',
            visualDensity:
            compact ? VisualDensity.compact : VisualDensity.standard,
            icon: isDeleting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.delete_outline, color: AppColor.errorColor),
          ),
        ],
      ),
    );
  }
}
