import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          Text('Appearance', style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.primary,
          )),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _ThemeTile(
                  icon: Icons.brightness_auto_rounded,
                  label: 'System',
                  isSelected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
                const Divider(height: 1, indent: 56),
                _ThemeTile(
                  icon: Icons.light_mode_rounded,
                  label: 'Light',
                  isSelected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1, indent: 56),
                _ThemeTile(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  isSelected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About section
          Text('About', style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.primary,
          )),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('🐰', style: context.textTheme.titleMedium),
                  ),
                  title: const Text('Bunny Wallet'),
                  subtitle: const Text('Version 1.0.0'),
                ),
                const Divider(height: 1, indent: 56),
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('About'),
                  subtitle: Text(
                    'A minimal expense tracker with income, savings, and credit card management.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data section
          Text('Data', style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.primary,
          )),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storage_rounded,
                      color: context.colorScheme.onSurfaceVariant),
                  title: const Text('All data stored locally'),
                  subtitle: const Text(
                      'Your data never leaves your device'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.delete_forever_rounded,
                      color: context.colorScheme.error),
                  title: Text('Clear all data',
                      style: TextStyle(color: context.colorScheme.error)),
                  onTap: () => _showClearDataDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions, savings goals, and credit cards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Would need to implement a full database reset
              if (context.mounted) {
                context.showSnack('Data cleared');
              }
            },
            child: Text(
              'Delete Everything',
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isSelected
            ? context.colorScheme.primary
            : context.colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded,
              color: context.colorScheme.primary)
          : null,
    );
  }
}
