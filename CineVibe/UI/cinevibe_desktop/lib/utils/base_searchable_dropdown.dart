import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/model/production_company.dart';
import 'package:flutter/material.dart';

// Modern color scheme based on main.dart seed colors
class CineVibeColors {
  static const Color seedBlue = Color(0xFF004AAD);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFED8936);
  
  // Neutral colors
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceMedium = Color(0xFFE2E8F0);
  static const Color surfaceDark = Color(0xFF64748B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
}

// ---------------------------
// Searchable Multi-Select Dropdown Helper
// ---------------------------
class SearchableMultiSelectDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemText;
  final String Function(T)? itemSubtext;
  final IconData? prefixIcon;
  final String? hintText;
  final bool isError;
  final bool isSuccess;
  final double? width;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final ValueChanged<List<T>> onChanged;
  final Widget Function(T)? itemBuilder;
  final bool Function(T, String)? filterFunction;

  const SearchableMultiSelectDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.itemText,
    this.itemSubtext,
    this.prefixIcon,
    this.hintText,
    this.isError = false,
    this.isSuccess = false,
    this.width,
    this.errorText,
    this.helperText,
    this.enabled = true,
    required this.onChanged,
    this.itemBuilder,
    this.filterFunction,
  }) : super(key: key);

  @override
  State<SearchableMultiSelectDropdown<T>> createState() => _SearchableMultiSelectDropdownState<T>();
}

class _SearchableMultiSelectDropdownState<T> extends State<SearchableMultiSelectDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isOpen = false;
  List<T> _filteredItems = [];
  List<T> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
    _filteredItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(SearchableMultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selectedItems = List.from(widget.selectedItems);
    }
    if (oldWidget.items != widget.items) {
      _filteredItems = List.from(widget.items);
      _filterItems();
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        if (widget.filterFunction != null) {
          return widget.filterFunction!(item, query);
        }
        return widget.itemText(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleItem(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
    widget.onChanged(_selectedItems);
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
    widget.onChanged(_selectedItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: widget.isError 
                ? CineVibeColors.errorRed 
                : widget.isSuccess 
                    ? CineVibeColors.successGreen 
                    : CineVibeColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        
        // Dropdown Container
        Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.isError 
                ? CineVibeColors.errorRed.withOpacity(0.05)
                : widget.isSuccess 
                    ? CineVibeColors.successGreen.withOpacity(0.05)
                    : CineVibeColors.surfaceLight,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: widget.isError 
                  ? CineVibeColors.errorRed 
                  : widget.isSuccess 
                      ? CineVibeColors.successGreen 
                      : CineVibeColors.surfaceMedium,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Selected Items Display
              if (_selectedItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedItems.map((item) => _buildSelectedChip(item)).toList(),
                  ),
                ),
              
              // Search Input and Dropdown Toggle
              InkWell(
                onTap: widget.enabled ? () => setState(() => _isOpen = !_isOpen) : null,
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          color: widget.isError 
                              ? CineVibeColors.errorRed 
                              : widget.isSuccess 
                                  ? CineVibeColors.successGreen 
                                  : CineVibeColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          _selectedItems.isEmpty 
                              ? (widget.hintText ?? 'Select items...')
                              : '${_selectedItems.length} item(s) selected',
                          style: TextStyle(
                            color: _selectedItems.isEmpty 
                                ? CineVibeColors.textTertiary 
                                : CineVibeColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedItems.isNotEmpty)
                        GestureDetector(
                          onTap: widget.enabled ? _clearSelection : null,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: CineVibeColors.textTertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: CineVibeColors.textTertiary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: widget.isError 
                            ? CineVibeColors.errorRed 
                            : widget.isSuccess 
                                ? CineVibeColors.successGreen 
                                : CineVibeColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Dropdown Content
              if (_isOpen)
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: CineVibeColors.surfaceLight,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: CineVibeColors.surfaceMedium,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Input
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (value) => _filterItems(),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              color: CineVibeColors.textTertiary,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: CineVibeColors.textSecondary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: CineVibeColors.surfaceMedium),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: CineVibeColors.surfaceMedium),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: CineVibeColors.seedBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      
                      // Items List
                      Flexible(
                        child: _filteredItems.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No items found',
                                  style: TextStyle(
                                    color: CineVibeColors.textTertiary,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  final isSelected = _selectedItems.contains(item);
                                  
                                  return InkWell(
                                    onTap: widget.enabled ? () => _toggleItem(item) : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? CineVibeColors.seedBlue.withOpacity(0.1)
                                            : Colors.transparent,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: CineVibeColors.surfaceMedium.withOpacity(0.5),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                            color: isSelected 
                                                ? CineVibeColors.seedBlue 
                                                : CineVibeColors.textTertiary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: widget.itemBuilder != null
                                                ? widget.itemBuilder!(item)
                                                : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        widget.itemText(item),
                                                        style: TextStyle(
                                                          color: CineVibeColors.textPrimary,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      if (widget.itemSubtext != null) ...[
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          widget.itemSubtext!(item),
                                                          style: TextStyle(
                                                            color: CineVibeColors.textSecondary,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Error/Helper Text
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: TextStyle(
                color: widget.errorText != null 
                    ? CineVibeColors.errorRed 
                    : CineVibeColors.textSecondary,
                fontSize: 13,
                fontWeight: widget.errorText != null ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedChip(T item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CineVibeColors.seedBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CineVibeColors.seedBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.itemText(item),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CineVibeColors.seedBlue,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _toggleItem(item),
            child: Icon(
              Icons.close,
              size: 14,
              color: CineVibeColors.seedBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// Convenience Widget for Actor Selection
// ---------------------------
class ActorSearchableDropdown extends StatelessWidget {
  final List<Actor> actors;
  final List<Actor> selectedActors;
  final ValueChanged<List<Actor>> onChanged;
  final String? errorText;
  final bool enabled;

  const ActorSearchableDropdown({
    Key? key,
    required this.actors,
    required this.selectedActors,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchableMultiSelectDropdown<Actor>(
      label: 'Actors',
      items: actors,
      selectedItems: selectedActors,
      itemText: (actor) => '${actor.firstName} ${actor.lastName}',
      itemSubtext: (actor) => 'ID: ${actor.id}',
      prefixIcon: Icons.person_outline,
      hintText: 'Select actors...',
      errorText: errorText,
      enabled: enabled,
      onChanged: onChanged,
      itemBuilder: (actor) => Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: CineVibeColors.seedBlue.withOpacity(0.1),
            child: Text(
              '${actor.firstName[0]}${actor.lastName[0]}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CineVibeColors.seedBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${actor.firstName} ${actor.lastName}',
                  style: const TextStyle(
                    color: CineVibeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'ID: ${actor.id}',
                  style: const TextStyle(
                    color: CineVibeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// Convenience Widget for Production Company Selection
// ---------------------------
class ProductionCompanySearchableDropdown extends StatelessWidget {
  final List<ProductionCompany> companies;
  final List<ProductionCompany> selectedCompanies;
  final ValueChanged<List<ProductionCompany>> onChanged;
  final String? errorText;
  final bool enabled;

  const ProductionCompanySearchableDropdown({
    Key? key,
    required this.companies,
    required this.selectedCompanies,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchableMultiSelectDropdown<ProductionCompany>(
      label: 'Production Companies',
      items: companies,
      selectedItems: selectedCompanies,
      itemText: (company) => company.name,
      itemSubtext: (company) => company.country ?? 'No country',
      prefixIcon: Icons.business_outlined,
      hintText: 'Select production companies...',
      errorText: errorText,
      enabled: enabled,
      onChanged: onChanged,
      itemBuilder: (company) => Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CineVibeColors.warningOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              size: 16,
              color: CineVibeColors.warningOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    color: CineVibeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  company.country ?? 'No country',
                  style: const TextStyle(
                    color: CineVibeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
