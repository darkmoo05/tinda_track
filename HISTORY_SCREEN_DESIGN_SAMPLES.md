# History Screen - UI & Layout Design Polish Samples

This document provides a detailed analysis of the current **Activity History Screen** in the Pocket Ledger module, lists best-practice design guidelines for both the banner and the tab/filter button elements, and presents **three distinct sample designs** complete with ASCII visual layouts and production-ready Flutter code snippets.

---

## Current Screen Analysis

### Current Layout Hierarchy
1. **AppBar (`ArchitectAppBar`)**: Logo, app title, and trailing settings icon (fixed at the top).
2. **TabBar (Fixed)**: Displays two tabs ("Transactions" and "Owner Movements").
3. **TabBarView (Scrolls)**: Inside each tab, a scrollable list containing:
   * **Banner (`ScreenHeaderCard`)**: Large gradient card with the title ("Movements"), subtitle, and a "Reports" download button.
   * **Search Bar**: A text field with search/clear actions.
   * **Wallet Filters**: Choice chips (All, GCash, Maya, On Hand).
   * **Date Range Picker**: Two large outlined buttons side-by-side ("Beginning Date", "End Date").
   * **Active Date Chips**: Chips displaying the selected beginning and ending dates.
   * **List of Transactions / Movements**: Grouped by date headers.

### Core UI/UX Issues to Address
1. **Upside-Down Hierarchy (Tabs above Banner)**: The `TabBar` is placed above the screen's main banner (`ScreenHeaderCard`). This is a UX anti-pattern because the banner acts as the screen's visual title ("Movements"). Having it scroll *inside* the tabs means the banner is duplicated on both screens and scrolls away, while the tab headers remain fixed above it. The main screen title/banner should introduce the entire view, with tabs and search filters dividing the content below it.
2. **Excessive Vertical Space (Clutter)**: On typical mobile screens, the stacked controls occupy more than 50% of the viewport height before the first transaction card is even visible:
   `AppBar` + `TabBar` + `ScreenHeaderCard` (gradient card) + `Search Bar` + `Wallet Chips` + `Date Buttons` = ~450px of vertical space. This leaves very little room for scanning actual ledger items.
3. **Redundant UI State**: The search and filter elements scroll away with the list. When scrolling down, users lose access to filtering. Placing these elements in a sticky header or condensing them is essential.
4. **Basic Aesthetics**: The current banner uses a simple two-color linear gradient, and the filter section is a mix of text fields, ChoiceChips, and multiple outlined buttons. A unified, modern design language is needed.

---

## Master UI Designer Best Practices

### 1. The Banner (Well-Balanced Design)
* **Dynamic Content over Static Text**: Rather than just displaying "Movements" in a static card, a well-balanced banner serves as a mini-dashboard, showing high-value summaries like the **Total Inflow/Outflow** for the filtered period, or the **Combined Ledger Balance**.
* **Visual Anchoring**: Use rich gradients (radial, angular, or mesh) with soft brand colors. Keep titles bold and highly readable, while secondary buttons (like Reports) use translucent semi-transparent backgrounds (`white.withValues(alpha: 0.12)`) to feel integrated rather than stuck on.
* **Proportion and Padding**: Limit vertical height to 120–140dp. Use rounded corners (16–24dp) to match modern Material 3/iOS design systems.

### 2. The Tab Button & Filters
* **Segmented Controls**: Replace traditional, full-width underline tab bars with compact segmented pill controls. They look much more premium and fit naturally beneath a header card.
* **Unified Filtering**: Group search and filtering together. Instead of having separate fields, chips, and date picker buttons spread across the layout, combine them into a single filter row or collapse them behind a "Filter" bottom sheet.
* **branded Color Accents**: Filter chips for platforms should use soft, tinted backgrounds representing the platform's brand (e.g., translucent blue for GCash, light green for Maya, soft amber for On Hand cash).

---

## SAMPLE 1: "The Integrated Dashboard & Action Hub"
### Target: Business merchants seeking clear insights and immediate actions.
### Visual Philosophy:
Combines the header banner and the overview card into a single top dashboard placed *above* the tabs. The tabs and search bar sit cleanly below it, creating a logical top-to-bottom hierarchy. Advanced filters (wallet chips and date pickers) are collapsed behind a single, elegant "Filters" trigger button to maximize vertical screen space.

### Layout Structure
```
┌─ APP BAR (Fixed) ─────────────────────────────┐
│ 👤 TindaTrack                           [⚙️]   │
├─ DASHBOARD BANNER (Fixed/Collapsible) ────────┤
│ ┌───────────────────────────────────────────┐ │
│ │  Combined Flow (This Month)               │ │
│ │  ₱45,200.00         [📥 Reports]          │ │
│ │  ───────────────────────────────────────  │ │
│ │  💳 GCash: ₱24,100  | 📱 Maya: ₱21,100     │ │
│ └───────────────────────────────────────────┘ │
├─ TAB BUTTONS (Pill Control) ──────────────────┤
│ ┌───────────────────────────────────────────┐ │
│ │ [   Transactions   ] [ Owner Movements ]  │ │
│ └───────────────────────────────────────────┘ │
├─ SEARCH & CONDENSED FILTER ROW ───────────────┤
│ ┌───────────────────────────┐ ┌───────────┐ │
│ │ 🔍 Search transactions... │ │ 🎛️ Filters │ │
│ └───────────────────────────┘ └───────────┘ │
├─ SCROLLABLE HISTORY LIST ─────────────────────┤
│   📅 TODAY                                    │
│   ┌───────────────────────────────────────┐   │
│   │ 👤 GCash Cash-In            +₱1,200   │   │
│   └───────────────────────────────────────┘   │
│   ┌───────────────────────────────────────┐   │
│   │ 👤 Cash Sale                +₱350     │   │
│   └───────────────────────────────────────┘   │
└───────────────────────────────────────────────┘
```

### Flutter Implementation
```dart
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class Sample1DashboardHeader extends StatelessWidget {
  final VoidCallback onReportsPressed;
  final VoidCallback onFilterPressed;
  final ValueChanged<String> onSearchChanged;

  const Sample1DashboardHeader({
    super.key,
    required this.onReportsPressed,
    required this.onFilterPressed,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Dynamic Dashboard Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF0F4C81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Combined Flow (This Month)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Material(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onReportsPressed,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.download_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Reports',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '₱45,200.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wallet_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'GCash: ₱24,100  •  Maya: ₱21,100',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search ledger items...',
                        hintStyle: TextStyle(
                            fontSize: 14, color: AppColors.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 20, color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: onFilterPressed,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 20,
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
```

---

## SAMPLE 2: "The Minimalist Sleek & Sticky Header"
### Target: Busy merchants focusing on high-speed mobile scrolling.
### Visual Philosophy:
This design uses a `SliverAppBar` where the banner collapses into a sticky, minimalist navigation title as the user scrolls. The tab filters are replaced by an iOS-style segmented slide control. The date buttons are combined into a single, compact range pill ("📅 Jun 1 - Jun 7") which opens a calendar dialog when tapped.

### Layout Structure
```
┌───────────────────────────────────────────────┐
│ [←] Movements History                    [📥] │
├─ TAB SELECTION (Sticky iOS-style Control) ────┤
│ ┌───────────────────────────────────────────┐ │
│ │   [ Transactions ]     Owner Movements    │ │
│ └───────────────────────────────────────────┘ │
├─ COMPACT FILTER CHIPS ROW ────────────────────┤
│  [📅 Jun 1 - 7 ▼]  [💳 GCash]  [📱 Maya]      │
├─ SCROLLABLE HISTORY LIST ─────────────────────┤
│   📅 05 JUN 2026                              │
│   ┌───────────────────────────────────────┐   │
│   │ 🏦 GCash Cash-Out           −₱2,500   │   │
│   │ Bal: ₱12,300                          │   │
│   └───────────────────────────────────────┘   │
│   ┌───────────────────────────────────────┐   │
│   │ 📱 Maya Top-Up              +₱5,000   │   │
│   │ Bal: ₱9,800                           │   │
│   └───────────────────────────────────────┘   │
└───────────────────────────────────────────────┘
```

### Flutter Implementation
```dart
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class Sample2StickyHeader extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onDateRangePressed;
  final String dateRangeLabel;
  final String? activeWallet;
  final ValueChanged<String?> onWalletSelected;

  const Sample2StickyHeader({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onDateRangePressed,
    required this.dateRangeLabel,
    required this.activeWallet,
    required this.onWalletSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // iOS Segmented Sliding Tab Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildSegmentButton(
                    label: 'Transactions',
                    isSelected: selectedTab == 0,
                    onTap: () => onTabChanged(0),
                  ),
                  _buildSegmentButton(
                    label: 'Owner Movements',
                    isSelected: selectedTab == 1,
                    onTap: () => onTabChanged(1),
                  ),
                ],
              ),
            ),
          ),
          // Horizontal scrolling Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                // Combined Date Range Pill
                _buildFilterPill(
                  label: dateRangeLabel,
                  icon: Icons.calendar_month_rounded,
                  isSelected: true,
                  onTap: onDateRangePressed,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'GCash',
                  icon: Icons.account_balance_wallet_outlined,
                  isSelected: activeWallet == 'gcash',
                  onTap: () => onWalletSelected(
                      activeWallet == 'gcash' ? null : 'gcash'),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Maya',
                  icon: Icons.wallet_rounded,
                  isSelected: activeWallet == 'maya',
                  onTap: () =>
                      onWalletSelected(activeWallet == 'maya' ? null : 'maya'),
                  color: const Color(0xFF106D20),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Cash',
                  icon: Icons.payments_outlined,
                  isSelected: activeWallet == 'on_hand',
                  onTap: () => onWalletSelected(
                      activeWallet == 'on_hand' ? null : 'on_hand'),
                  color: const Color(0xFF8E6C00),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? color : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## SAMPLE 3: "The Brand-Centric Visual Ledger"
### Target: Users who love expressive, visual layouts and fast preset filters.
### Visual Philosophy:
Features a dynamic, asymmetrical diagonal split gradient banner with watermark patterns. The reports button is replaced with two quick-action download icons (PDF & Excel) directly on the banner. The wallet filter chips use customized colored borders matching the wallets (GCash blue, Maya green, On Hand amber). Date filtering is simplified into horizontal quick presets ([Today], [Yesterday], [This Week], [Custom]).

### Layout Structure
```
┌─ APP BAR (Fixed) ─────────────────────────────┐
│ 👤 History & Logs                       [⚙️]   │
├─ DYNAMIC WAVE BANNER ─────────────────────────┤
│ ┌───────────────────────────────────────────┐ │
│ │  Activity Logs     [📄 PDF]  [📊 Excel]   │ │
│ │  Total 82 entries  (Filtered View)        │ │
│ └───────────────────────────────────────────┘ │
├─ TAB BAR (Material 3 Segmented Control) ──────┤
│ ┌──────────────┐ ┌──────────────────────────┐ │
│ │ Transactions │ │      Owner Movements     │ │
│ └──────────────┘ └──────────────────────────┘ │
├─ WALLET BRAND CHIPS ROW ──────────────────────┤
│  (All)  (GCash)  (Maya)  (Cash)               │
│  Note: Custom brand border colors on chips    │
├─ QUICK DATE PRESET BAR ───────────────────────┤
│  [Today]  [Yesterday]  [This Week]  [Custom 📅]│
└───────────────────────────────────────────────┘
```

### Flutter Implementation
```dart
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class Sample3BrandHeader extends StatelessWidget {
  final VoidCallback onDownloadPdf;
  final VoidCallback onDownloadExcel;
  final int activeTab;
  final ValueChanged<int> onTabSelected;
  final String activeDatePreset;
  final ValueChanged<String> onDatePresetSelected;

  const Sample3BrandHeader({
    super.key,
    required this.onDownloadPdf,
    required this.onDownloadExcel,
    required this.activeTab,
    required this.onTabSelected,
    required this.activeDatePreset,
    required this.onDatePresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wave/Mesh Gradient Hero Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF005DAC), Color(0xFF00C9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Activity Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Filtered summary of records',
                      style: TextStyle(
                        color: Colors.white80,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Instant PDF / Excel Quick Buttons
                Row(
                  children: [
                    _buildQuickIconButton(
                      icon: Icons.picture_as_pdf_rounded,
                      tooltip: 'Export PDF',
                      onTap: onDownloadPdf,
                      bgColor: Colors.red.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickIconButton(
                      icon: Icons.table_chart_rounded,
                      tooltip: 'Export Excel',
                      onTap: onDownloadExcel,
                      bgColor: Colors.green.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Material 3 Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildVisualTabButton(
                  title: 'Transactions',
                  isSelected: activeTab == 0,
                  onTap: () => onTabSelected(0),
                ),
                const SizedBox(width: 12),
                _buildVisualTabButton(
                  title: 'Movements',
                  isSelected: activeTab == 1,
                  onTap: () => onTabSelected(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Quick Date Presets Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildPresetChip('Today'),
                const SizedBox(width: 8),
                _buildPresetChip('Yesterday'),
                const SizedBox(width: 8),
                _buildPresetChip('This Week'),
                const SizedBox(width: 8),
                _buildPresetChip('Custom 📅'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildQuickIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color bgColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildVisualTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String presetName) {
    final isSelected = activeDatePreset == presetName;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => onDatePresetSelected(presetName),
      showCheckmark: false,
      label: Text(
        presetName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
      selectedColor: AppColors.primary.withValues(alpha: 0.08),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
```

---

## Comparison Matrix

| Aspect | Sample 1: Integrated Dashboard | Sample 2: Sticky Header | Sample 3: Brand Visual Ledger |
|---|---|---|---|
| **Primary Focus** | Balanced layout hierarchy | Space efficiency & ease of scroll | Aesthetic, custom brand styling |
| **Header Position** | Fixed below AppBar | Collapsible sliver | Fixed at the top |
| **Tab Controls** | Pill segmented tabs | Sliding segment controls | Visual M3 segment buttons |
| **Filter Triggers** | Triggered bottom sheet | Horizontal scroll pills | Horizontal scroll presets |
| **Vertical Space Used** | Medium (~240px) | Low (~120px) | Medium-High (~260px) |
| **Implementation Effort**| Low-Medium | Medium | Low |

---

## Master UI Designer Recommendation

**Sample 1 (Integrated Dashboard & Action Hub)** is the recommended approach for this module.

### Why it works best:
1. **Perfect Hierarchy**: Resolves the main issue where the `TabBar` sits above the `ScreenHeaderCard`. Placing the dashboard banner above the tab views immediately gives context for the entire screen, while switching tabs correctly swaps only the list contents below it.
2. **Double Duty Utility**: Turning the static "Movements" banner into a dynamic overview card (showing monthly totals and wallet breakdowns) gives the merchant high-value information at a glance.
3. **Drastic Clutter Reduction**: By shifting advanced filters (wallet choices and calendar date range picks) into a "Filters" bottom sheet/trigger, it frees up over **200px** of vertical screen height. This allows users to view 3–4 more transaction entries immediately without scrolling.
