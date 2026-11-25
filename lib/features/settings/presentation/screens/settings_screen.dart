import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/widgets/image_storage_section.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final languageAsync = ref.watch(languageProvider);
    final themeAsync = ref.watch(themeProvider);

    final language = languageAsync.value ?? 'system';
    final theme = themeAsync.value ?? 'system';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.languageTitle),
            subtitle: Text(l10n.languageDescription),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              key: ValueKey('language-$language'),
              initialValue: language,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l10n.systemOption),
                ),
                DropdownMenuItem(value: 'es', child: Text(l10n.spanishOption)),
                DropdownMenuItem(value: 'en', child: Text(l10n.englishOption)),
              ],
              onChanged: languageAsync.isLoading
                  ? null
                  : (value) async {
                      if (value == null) return;

                      try {
                        await ref.read(setLanguageProvider)(value);
                      } catch (error) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.languageChangeError)),
                        );
                      }
                    },
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text(l10n.themeTitle),
            subtitle: Text(l10n.themeDescription),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              key: ValueKey('theme-$theme'),
              initialValue: theme,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l10n.systemOption),
                ),
                DropdownMenuItem(value: 'light', child: Text(l10n.lightTheme)),
                DropdownMenuItem(value: 'dark', child: Text(l10n.darkTheme)),
              ],
              onChanged: themeAsync.isLoading
                  ? null
                  : (value) async {
                      if (value == null) return;

                      try {
                        await ref.read(setThemeProvider)(value);
                      } catch (error) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.themeChangeError)),
                        );
                      }
                    },
            ),
          ),
          const ImageStorageSection(),
        ],
      ),
    );
  }
}
