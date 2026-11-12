import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../generated/l10n/zulip_localizations.dart';
import '../model/settings.dart';
import '../notifications/receive.dart';
import 'actions.dart';
import 'app_bar.dart';
import 'icons.dart';
import 'page.dart';
import 'store.dart';
import 'text.dart';
import 'theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static AccountRoute<void> buildRoute({required BuildContext context}) {
    return MaterialAccountWidgetRoute(
      context: context, page: const SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    return Scaffold(
      appBar: ZulipAppBar(
        title: Text(zulipLocalizations.settingsPageTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SettingsCard(children: [_ThemeSetting()]),
          _SettingsCard(children: [
            const _BrowserPreferenceSetting(),
            const _VisitFirstUnreadSetting(),
            const _MarkReadOnScrollSetting(),
            if (GlobalSettingsStore.experimentalFeatureFlags.isNotEmpty)
              ListTile(
                title: Text(zulipLocalizations.experimentalFeatureSettingsPageTitle),
                trailing: const Icon(ZulipIcons.chevron_right, size: 20),
                onTap: () => Navigator.push(context,
                  ExperimentalFeaturesPage.buildRoute())),
          ]),
          // Debugging push delivery: the token is what the Firebase console's
          // "Test on device" asks for.
          const _SettingsCard(children: [_PushTokenSetting()]),
        ]));
  }
}

/// A group of settings on a rounded card, as in Kloki's settings.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: DecoratedBox(
        decoration: klokiCardDecoration(designVariables, radius: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            type: MaterialType.transparency,
            child: Column(children: children)))));
  }
}

/// The ALL CAPS heading at the top of a [_SettingsCard].
class _SettingsCardTitle extends StatelessWidget {
  const _SettingsCardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(text,
        style: TextStyle(
          color: DesignVariables.of(context).loginOrDividerText,
          fontFamily: kKlokiHeadingFontFamily,
          fontSize: 13,
          letterSpacing: 0.5,
        ).merge(weightVariableTextStyle(context, wght: 700))));
  }
}

class _PushTokenSetting extends StatelessWidget {
  const _PushTokenSetting();

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: NotificationService.instance.token,
      builder: (context, token, _) => Column(children: [
        _SettingsCardTitle(zulipLocalizations.notificationsSettingsTitle),
        ListTile(
          title: Text(zulipLocalizations.pushTokenSettingTitle),
          subtitle: SelectableText(
            token ?? zulipLocalizations.pushTokenSettingUnavailable),
          trailing: token == null ? null : const Icon(ZulipIcons.copy, size: 20),
          onTap: token == null ? null : () => PlatformActions.copyWithPopup(
            context: context,
            data: ClipboardData(text: token),
            successContent: Text(zulipLocalizations.successPushTokenCopied))),
      ]));
  }
}

class _ThemeSetting extends StatelessWidget {
  const _ThemeSetting();

  void _handleChange(BuildContext context, ThemeSetting? newThemeSetting) {
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    globalSettings.setThemeSetting(newThemeSetting);
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    return RadioGroup<ThemeSetting?>(
      groupValue: globalSettings.themeSetting,
      onChanged: (newValue) => _handleChange(context, newValue),
      child: Column(
        children: [
          _SettingsCardTitle(zulipLocalizations.themeSettingTitle),
          for (final themeSettingOption in [null, ...ThemeSetting.values])
            RadioListTile<ThemeSetting?>.adaptive(
              activeColor: DesignVariables.of(context).fabBg,
              title: Text(ThemeSetting.displayName(
                themeSetting: themeSettingOption,
                zulipLocalizations: zulipLocalizations)),
              value: themeSettingOption),
        ]));
  }
}

class _BrowserPreferenceSetting extends StatelessWidget {
  const _BrowserPreferenceSetting();

  void _handleChange(BuildContext context, bool newOpenLinksWithInAppBrowser) {
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    globalSettings.setBrowserPreference(
      newOpenLinksWithInAppBrowser ? BrowserPreference.inApp
                                   : BrowserPreference.external);
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    final openLinksWithInAppBrowser =
      globalSettings.effectiveBrowserPreference == BrowserPreference.inApp;
    return SwitchListTile.adaptive(
      activeTrackColor: DesignVariables.of(context).fabBg,
      title: Text(zulipLocalizations.openLinksWithInAppBrowser),
      value: openLinksWithInAppBrowser,
      onChanged: (newValue) => _handleChange(context, newValue));
  }
}

class _VisitFirstUnreadSetting extends StatelessWidget {
  const _VisitFirstUnreadSetting();

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    return ListTile(
      title: Text(zulipLocalizations.initialAnchorSettingTitle),
      subtitle: Text(VisitFirstUnreadSettingPage._valueDisplayName(
        globalSettings.visitFirstUnread, zulipLocalizations: zulipLocalizations)),
      trailing: const Icon(ZulipIcons.chevron_right, size: 20),
      onTap: () => Navigator.push(context,
        VisitFirstUnreadSettingPage.buildRoute()));
  }
}

class VisitFirstUnreadSettingPage extends StatelessWidget {
  const VisitFirstUnreadSettingPage({super.key});

  static WidgetRoute<void> buildRoute() {
    return MaterialWidgetRoute(page: const VisitFirstUnreadSettingPage());
  }

  static String _valueDisplayName(VisitFirstUnreadSetting value, {
    required ZulipLocalizations zulipLocalizations,
  }) {
    return switch (value) {
      VisitFirstUnreadSetting.always =>
        zulipLocalizations.initialAnchorSettingFirstUnreadAlways,
      VisitFirstUnreadSetting.conversations =>
        zulipLocalizations.initialAnchorSettingFirstUnreadConversations,
      VisitFirstUnreadSetting.never =>
        zulipLocalizations.initialAnchorSettingNewestAlways,
    };
  }

  void _handleChange(BuildContext context, VisitFirstUnreadSetting? value) {
    if (value == null) return; // TODO(log); can this actually happen? how?
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    globalSettings.setVisitFirstUnread(value);
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(zulipLocalizations.initialAnchorSettingTitle)),
      body: RadioGroup<VisitFirstUnreadSetting>(
        groupValue: globalSettings.visitFirstUnread,
        onChanged: (newValue) => _handleChange(context, newValue),
        child: Column(children: [
          ListTile(title: Text(zulipLocalizations.initialAnchorSettingDescription)),
          for (final value in VisitFirstUnreadSetting.values)
            RadioListTile<VisitFirstUnreadSetting>.adaptive(
              activeColor: DesignVariables.of(context).fabBg,
              title: Text(_valueDisplayName(value,
                zulipLocalizations: zulipLocalizations)),
              value: value),
        ])));
  }
}

class _MarkReadOnScrollSetting extends StatelessWidget {
  const _MarkReadOnScrollSetting();

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    return ListTile(
      title: Text(zulipLocalizations.markReadOnScrollSettingTitle),
      subtitle: Text(MarkReadOnScrollSettingPage._valueDisplayName(
        globalSettings.markReadOnScroll, zulipLocalizations: zulipLocalizations)),
      trailing: const Icon(ZulipIcons.chevron_right, size: 20),
      onTap: () => Navigator.push(context,
        MarkReadOnScrollSettingPage.buildRoute()));
  }
}

class MarkReadOnScrollSettingPage extends StatelessWidget {
  const MarkReadOnScrollSettingPage({super.key});

  static WidgetRoute<void> buildRoute() {
    return MaterialWidgetRoute(page: const MarkReadOnScrollSettingPage());
  }

  static String _valueDisplayName(MarkReadOnScrollSetting value, {
    required ZulipLocalizations zulipLocalizations,
  }) {
    return switch (value) {
      MarkReadOnScrollSetting.always =>
        zulipLocalizations.markReadOnScrollSettingAlways,
      MarkReadOnScrollSetting.conversations =>
        zulipLocalizations.markReadOnScrollSettingConversations,
      MarkReadOnScrollSetting.never =>
        zulipLocalizations.markReadOnScrollSettingNever,
    };
  }

  static String? _valueDescription(MarkReadOnScrollSetting value, {
    required ZulipLocalizations zulipLocalizations,
  }) {
    return switch (value) {
      MarkReadOnScrollSetting.always => null,
      MarkReadOnScrollSetting.conversations =>
        zulipLocalizations.markReadOnScrollSettingConversationsDescription,
      MarkReadOnScrollSetting.never => null,
    };
  }

  void _handleChange(BuildContext context, MarkReadOnScrollSetting? value) {
    if (value == null) return; // TODO(log); can this actually happen? how?
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    globalSettings.setMarkReadOnScroll(value);
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(zulipLocalizations.markReadOnScrollSettingTitle)),
      body: RadioGroup<MarkReadOnScrollSetting>(
        groupValue: globalSettings.markReadOnScroll,
        onChanged: (newValue) => _handleChange(context, newValue),
        child: Column(children: [
          ListTile(title: Text(zulipLocalizations.markReadOnScrollSettingDescription)),
          for (final value in MarkReadOnScrollSetting.values)
            RadioListTile<MarkReadOnScrollSetting>.adaptive(
              activeColor: DesignVariables.of(context).fabBg,
              title: Text(_valueDisplayName(value,
                zulipLocalizations: zulipLocalizations)),
              subtitle: () {
                final result = _valueDescription(value,
                  zulipLocalizations: zulipLocalizations);
                return result == null ? null : Text(result);
              }(),
              value: value),
        ])));
  }
}

class ExperimentalFeaturesPage extends StatelessWidget {
  const ExperimentalFeaturesPage({super.key});

  static WidgetRoute<void> buildRoute() {
    return MaterialWidgetRoute(page: const ExperimentalFeaturesPage());
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final globalSettings = GlobalStoreWidget.settingsOf(context);
    final flags = GlobalSettingsStore.experimentalFeatureFlags;
    assert(flags.isNotEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Text(zulipLocalizations.experimentalFeatureSettingsPageTitle)),
      body: Column(children: [
        ListTile(
          title: Text(zulipLocalizations.experimentalFeatureSettingsWarning)),
        for (final flag in flags)
          SwitchListTile.adaptive(
            activeTrackColor: DesignVariables.of(context).fabBg,
            title: Text(flag.name), // no i18n; these are developer-facing settings
            value: globalSettings.getBool(flag),
            onChanged: (value) => globalSettings.setBool(flag, value)),
      ]));
  }
}
