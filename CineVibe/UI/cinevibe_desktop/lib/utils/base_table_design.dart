import 'package:flutter/material.dart';

class BaseTableDesign extends StatelessWidget {
  final double width;
  final double height;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? emptyState;
  final IconData? emptyIcon;
  final String? emptyText;
  final String? emptySubtext;
  final String? title;
  final IconData? icon;
  final List<double>? columnWidths;

  const BaseTableDesign({
    super.key,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    this.emptyState,
    this.emptyIcon,
    this.emptyText,
    this.emptySubtext,
    this.title,
    this.icon,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = rows.isEmpty;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: isEmpty ? _buildEmptyState() : _buildTableContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF004AAD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF004AAD).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                emptyIcon ?? Icons.table_chart_outlined,
                size: 48,
                color: const Color(0xFF004AAD),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyText ?? 'No Data Available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (emptySubtext != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtext!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableContent() {
    return Column(
      children: [
        // Modern header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF004AAD).withOpacity(0.05),
                const Color(0xFFF7B61B).withOpacity(0.02),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004AAD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF004AAD).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon!,
                    color: const Color(0xFF004AAD),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Data Table',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rows.length} ${rows.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.table_chart,
                      size: 16,
                      color: const Color(0xFF004AAD),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Table View',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF004AAD),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Table content
        Expanded(
          child: _buildModernTable(),
        ),
      ],
    );
  }

  Widget _buildModernTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                columnSpacing: 24,
                horizontalMargin: 20,
                headingRowHeight: 60,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: _buildModernColumns(),
                rows: _buildModernRows(),
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return const Color(0xFF004AAD).withOpacity(0.05);
                  }
                  return null;
                }),
                dataTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                headingTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF004AAD),
                  letterSpacing: 0.5,
                ),
                dividerThickness: 0,
                border: TableBorder.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildModernColumns() {
    return columns.asMap().entries.map((entry) {
      int index = entry.key;
      DataColumn column = entry.value;
      
      Widget columnLabel = Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: column.label,
      );
      
      // Apply custom width if specified
      if (columnWidths != null && index < columnWidths!.length) {
        columnLabel = SizedBox(
          width: columnWidths![index],
          child: columnLabel,
        );
      }
      
      return DataColumn(
        label: columnLabel,
      );
    }).toList();
  }

  List<DataRow> _buildModernRows() {
    return rows.asMap().entries.map((entry) {
      int index = entry.key;
      DataRow row = entry.value;
      
      return DataRow(
        onSelectChanged: row.onSelectChanged,
        color: WidgetStateProperty.resolveWith<Color?>((states) {
          // Alternate row colors
          if (index % 2 == 0) {
            return const Color(0xFFF8FAFC);
          }
          return null;
        }),
        cells: row.cells.asMap().entries.map((cellEntry) {
          int cellIndex = cellEntry.key;
          DataCell cell = cellEntry.value;
          
          Widget cellContent = Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            alignment: cellIndex == 1 ? Alignment.center : Alignment.centerLeft,
            child: cell.child,
          );
          
          // Apply custom width if specified
          if (columnWidths != null && cellIndex < columnWidths!.length) {
            cellContent = SizedBox(
              width: columnWidths![cellIndex],
              child: cellContent,
            );
          }
          
          return DataCell(
            cellContent,
          );
        }).toList(),
      );
    }).toList();
  }
}
