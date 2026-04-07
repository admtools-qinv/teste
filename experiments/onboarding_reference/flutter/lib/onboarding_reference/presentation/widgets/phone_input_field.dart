import 'package:flutter/material.dart';

import '../../data/countries.dart';
import '../../models/country.dart';
import '../../theme/qinvweb3_tokens.dart';
import 'phone_mask_formatter.dart';

class PhoneInputField extends StatefulWidget {
  final Country? initialCountry;
  final FocusNode? focusNode;
  final bool enabled;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const PhoneInputField({
    super.key,
    this.initialCountry,
    this.focusNode,
    this.enabled = true,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late Country _selected;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCountry ??
        allCountries.firstWhere((c) => c.code == 'US');
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(PhoneInputField old) {
    super.didUpdateWidget(old);
    if (widget.initialCountry != null &&
        widget.initialCountry!.code != old.initialCountry?.code) {
      setState(() => _selected = widget.initialCountry!);
    }
  }

  void _onFocusChange() {
    if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    final digits = widget.controller.text.replaceAll(RegExp(r'[^\d]'), '');
    widget.onChanged?.call('${_selected.dialCode}$digits');
  }

  Future<void> _openPicker() async {
    final result = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(selected: _selected),
    );
    if (result != null && mounted) {
      setState(() {
        _selected = result;
        widget.controller.clear();
      });
      _notifyChanged();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
        border: Border.all(
          color: _hasFocus
              ? QInvWeb3Tokens.primaryLight
              : const Color(0x1AFFFFFF),
          width: _hasFocus ? 1.5 : 1.0,
        ),
        color: const Color(0x12FFFFFF),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: QInvWeb3Tokens.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Country selector button
          _CountrySelectorButton(
            country: _selected,
            enabled: widget.enabled,
            onTap: widget.enabled ? _openPicker : null,
          ),
          // Divider
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          // Number input
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              keyboardAppearance: Brightness.dark,
              enabled: widget.enabled,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => widget.onSubmitted?.call(),
              onChanged: (_) => _notifyChanged(),
              inputFormatters: _selected.phoneMask != null
                  ? [PhoneMaskFormatter(_selected.phoneMask!)]
                  : null,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: QInvWeb3Tokens.fontSizeInput,
                fontWeight: FontWeight.w400,
                color: QInvWeb3Tokens.textHeading,
                height: 1.25,
                letterSpacing: 0.1,
              ),
              decoration: InputDecoration(
                hintText: _selected.phoneMask?.replaceAll('#', '0') ?? '000000000',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                hintStyle: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeInputHint,
                  fontWeight: FontWeight.w400,
                  color: QInvWeb3Tokens.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Country selector button ──────────────────────────────────────

class _CountrySelectorButton extends StatelessWidget {
  final Country country;
  final bool enabled;
  final VoidCallback? onTap;

  const _CountrySelectorButton({
    required this.country,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              country.dialCode,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: QInvWeb3Tokens.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: QInvWeb3Tokens.textMuted.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Country picker bottom sheet ──────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  final Country selected;

  const _CountryPickerSheet({required this.selected});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<Country> _filtered = allCountries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? allCountries
          : allCountries
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.dialCode.contains(q) ||
                  c.code.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF252528),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Select country',
                style: TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: QInvWeb3Tokens.textHeading,
                ),
              ),
              const SizedBox(height: 12),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  keyboardAppearance: Brightness.dark,
                  onChanged: _onSearch,
                  style: const TextStyle(
                    fontFamily: QInvWeb3Tokens.fontUI,
                    fontSize: 14,
                    color: QInvWeb3Tokens.textHeading,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search country or code...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: QInvWeb3Tokens.textMuted,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: const TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: 14,
                      color: QInvWeb3Tokens.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final country = _filtered[i];
                    final isSelected = country.code == widget.selected.code;
                    return ListTile(
                      onTap: () => Navigator.pop(context, country),
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? QInvWeb3Tokens.primaryLight
                              : QInvWeb3Tokens.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        country.dialCode,
                        style: TextStyle(
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: 13,
                          color: isSelected
                              ? QInvWeb3Tokens.primaryLight
                              : QInvWeb3Tokens.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
