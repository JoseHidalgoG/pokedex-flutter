import 'package:flutter/material.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class CatalogMultiSelectDialog<T> extends StatefulWidget {
  const CatalogMultiSelectDialog({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.labelOf,
  });

  final String title;
  final List<T> options;
  final Set<T> selectedValues;
  final String Function(T) labelOf;

  @override
  State<CatalogMultiSelectDialog<T>> createState() =>
      _CatalogMultiSelectDialogState<T>();
}

class _CatalogMultiSelectDialogState<T>
    extends State<CatalogMultiSelectDialog<T>> {
  late final Set<T> _selection;

  @override
  void initState() {
    super.initState();
    _selection = Set<T>.of(widget.selectedValues);
  }

  void _toggle(T value, bool selected) {
    setState(() {
      if (selected) {
        _selection.add(value);
      } else {
        _selection.remove(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.catalogSelectedCount(_selection.length)),
              ),
              const SizedBox(height: 8),
              for (final option in widget.options)
                CheckboxListTile(
                  key: ValueKey('catalog-option-$option'),
                  title: Text(widget.labelOf(option)),
                  value: _selection.contains(option),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    _toggle(option, value ?? false);
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('catalog-selection-clear'),
          onPressed: _selection.isEmpty
              ? null
              : () {
                  setState(_selection.clear);
                },
          child: Text(l10n.catalogClearSelection),
        ),
        TextButton(
          key: const ValueKey('catalog-selection-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.catalogCancelSelection),
        ),
        FilledButton(
          key: const ValueKey('catalog-selection-apply'),
          onPressed: () {
            Navigator.of(context).pop(Set<T>.unmodifiable(_selection));
          },
          child: Text(l10n.catalogApplySelection),
        ),
      ],
    );
  }
}
