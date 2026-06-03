# PARTIES SCREEN - Visual Quick Reference

## Quick Overview of 3 Samples

### SAMPLE 1: "Simple & Friendly" ✨
```
┌──────────────────────────────┐
│  Your People                 │
│  Manage customers & partners │
├──────────────────────────────┤
│  👥 12 People saved          │
│  ✓ 10 Verified (83%)         │
│  ⚠ 2 Waiting to verify       │
├──────────────────────────────┤
│  🔍 Search...                │
├──────────────────────────────┤
│  All | ✓ Verified | ⚠ Pending│
├──────────────────────────────┤
│ 👤 John Doe         [✓]      │
│   09123456789                │
│   Joined: March 2025         │
│   [Edit] [Delete] [History]  │
├──────────────────────────────┤
│ 👤 Jane Smith       [⏳]     │
│   09987654321                │
│   Joined: February 2025      │
│   [Edit] [Delete] [Status]   │
├──────────────────────────────┤
│    [+ Add New Person]        │
└──────────────────────────────┘
```

**Key Features:**
- Simple, friendly language
- Visual status indicators
- Quick stats (not complex charts)
- Category filters
- Clear action buttons

**Best For:** Most users, beginners, personal use

---

### SAMPLE 2: "Business Professional" 💼
```
┌──────────────────────────────┐
│  Parties Management          │
│  Last Updated: 2 hours ago   │
├──────────────────────────────┤
│  Total    Verified  Pending  │
│   12        10        2      │
│  100%      83%      17%      │
│                              │
│  [+ New] [Import] [Export]   │
├──────────────────────────────┤
│  Show: All | Verified |...   │
│  Sort: [Newest ▼]            │
│  Search: [Search...]         │
├──────────────────────────────┤
│ ☐ Name   Account  Status     │
│ ☐ John   09123*   ✓ Verified │
│ ☐ Jane   09987*   ⏳ Pending  │
│ ☐ Bob    09111*   ✓ Verified │
│ [2 selected] [Batch Delete]  │
├──────────────────────────────┤
│  Verification Queue          │
│  ⏳ 2 People Waiting         │
│  [Review Queue →]            │
└──────────────────────────────┘
```

**Key Features:**
- Professional dashboard
- Table-style list with sorting
- Batch operations
- Advanced filters
- Data-focused stats

**Best For:** Business owners, accountants, power users

---

### SAMPLE 3: "Guided & Progressive" 🎯
```
┌──────────────────────────────┐
│  👥 Parties                  │
│  ℹ️ Tip: Add your regular... │
│  [×]                         │
├──────────────────────────────┤
│  🎯 Getting Started          │
│  ✓ 1. Add a person          │
│  → 2. Enter account          │
│    3. Verify info            │
│  Progress: 33% [████░░░░]    │
│  [Continue →]                │
├──────────────────────────────┤
│  👥 Total    ✓ Verified     │
│  0 people    0 (add first!)  │
├──────────────────────────────┤
│  Step 1 of 3: Basic Info     │
│  What's their name?          │
│  [Name input]                │
│  ◉ Customer ○ Supplier      │
│  [Next →]                    │
├──────────────────────────────┤
│  Nobody Here Yet! 👋         │
│  [Add First Person]          │
│  [Upload CSV/Excel]          │
└──────────────────────────────┘
```

**Key Features:**
- Onboarding tooltips
- Step-by-step wizard
- Progress indicators
- Contextual help
- Friendly tone

**Best For:** New users, first-time setup, onboarding

---

## Key Wording Improvements Across All Samples

### Language Simplification
```
Current Term              →  Better Term
─────────────────────────────────────────
"Registered Parties"      →  "Your People"
"ACTIVE ENTITIES"         →  (Remove entirely)
"Manage parties"          →  "Manage customers & partners"
"Account Number"          →  "Their account"
"JOIN DATE"               →  "Joined"
"AWAITING VERIFICATION"   →  "Waiting to verify"
"Verification Rate"       →  "X Verified (XX%)"
"NoPartiesSaved"          →  "Nobody Here Yet!"
```

### Friendlier Labels
- ✓ Verified (instead of status badge)
- ⏳ Waiting to verify (instead of "pending")
- 👥 People / Customers (instead of "parties")
- Their account (instead of "account number")
- Add New Person (instead of "ADD PARTY")
- Joined March 2025 (instead of just date)

### Action Buttons
```
Sample 1 (Simple):
- [Edit] [Delete] [View History]

Sample 2 (Professional):
- [Edit] [Delete] [View Details] + Batch options

Sample 3 (Guided):
- [Next →] [Skip] [Learn More]
```

---

## Color & Visual Guide

### Status Indicators
```
✓ Verified      → Green (#106D20) + Checkmark
⏳ Pending       → Orange (#FF9800) + Hourglass  
❌ Failed       → Red (#BA1A1A) + X mark
○ Inactive      → Gray (#BDBDBD) + Circle
```

### Component Styling
```
Cards:
- Background: White (#FFFFFF)
- Border: Light Gray (#E0E0E0)
- Rounded: 8-12px
- Padding: 16px

Buttons:
- Primary: Blue (#005DAC) with white text
- Secondary: Outlined with blue border
- Danger: Red background
- Size: 44px minimum touch target

Text:
- Headings: Manrope, bold, 20-24px
- Body: Inter, regular, 14-16px
- Labels: Inter, 12px, gray
- Contrast: 4.5:1 minimum for accessibility
```

---

## Implementation Decision Tree

```
Start: Choose your Party Screen design

│
├─ Are you a first-time builder?
│  └─→ YES: Start with SAMPLE 1 (Simple & Friendly)
│         - Easy to code
│         - Easy to test
│         - Easy to improve
│
├─ Do you need advanced features now?
│  └─→ YES: Start with SAMPLE 2 (Business Professional)
│         - Sorting/filtering
│         - Batch operations
│         - Export/import
│
├─ Do you want user guidance/onboarding?
│  └─→ YES: Add SAMPLE 3 (Guided & Progressive)
│         - Add tooltips layer
│         - Implement wizard
│         - Add help modals
│
└─ RECOMMENDATION:
   ✓ Start with Sample 1 core
   ✓ Add Sample 2 filters & sorting
   ✓ Layer Sample 3 on first visit
   = Best balanced experience
```

---

## Before Implementing - Questions to Answer

1. **Primary Users**: Who will use this most?
   - [ ] Beginners / consumers (→ Sample 1)
   - [ ] Business owners / pros (→ Sample 2)
   - [ ] Mix of both (→ Sample 1 + upgrades)

2. **Scale**: How many parties will users have?
   - [ ] < 50 entries (any sample works)
   - [ ] 50-500 entries (→ Sample 2 features)
   - [ ] 500+ entries (→ Sample 2 + caching)

3. **Mobile vs Desktop**: Primary device?
   - [ ] Mobile first (→ Sample 1)
   - [ ] Desktop first (→ Sample 2)
   - [ ] Both equally (→ Sample 1 + responsive)

4. **Onboarding**: First-time user experience?
   - [ ] Not important (→ Sample 1/2)
   - [ ] Very important (→ Sample 3)
   - [ ] Nice to have (→ Sample 1 + optional tooltips)

5. **Translation**: How many languages?
   - [ ] 1-2 languages (any sample)
   - [ ] 3+ languages (→ Simple 1 wording)
   - [ ] Global (→ All samples need i18n)

---

## Next Steps After You Choose

### If You Choose Sample 1:
1. Update localization strings (see PARTIES_SCREEN_DESIGN_SAMPLES.md)
2. Simplify party_health_card.dart (quick stats only)
3. Add filter tabs widget
4. Improve empty state UI
5. Enhance status badges with icons

### If You Choose Sample 2:
1. Redesign list to table layout
2. Add sorting functionality
3. Implement batch selection
4. Add export/import buttons
5. Create verification queue section

### If You Choose Sample 3:
1. Create onboarding overlay/tooltip
2. Build add-party wizard widget
3. Add verification explainer modal
4. Implement progress tracking
5. Create help tooltip system

---

## Localization Strings Template

**For all samples, update these localization strings:**

```dart
// app_en.arb
{
  "registeredParties": "Your People",
  "manageParties": "Manage customers & partners you work with",
  "activeEntities": "Quick Stats", // or remove
  "addParty": "Add New Person",
  "noPartiesSaved": "Nobody Here Yet!",
  
  // New strings
  "peopleTotal": "{count} people saved",
  "peopleVerified": "{count} verified ({percent}%)",
  "peoplePending": "{count} waiting to verify",
  "verificationStatus": "Verification Status",
  "statusVerified": "Verified ✓",
  "statusPending": "Waiting to verify",
  "statusFailed": "Verification failed",
  "joinedDate": "Joined {date}",
  "theirAccount": "Their account",
  "viewHistory": "View History",
  "reviewQueue": "Review Queue",
  "noMatchingParties": "No people match that search",
  "tryDifferentKeyword": "Try a different name or account number"
}
```

---

## Accessibility Checklist

All samples should include:
- [ ] Minimum 44px touch targets for buttons
- [ ] Color not only indicator of status (use icons)
- [ ] Sufficient color contrast (4.5:1)
- [ ] Clear, descriptive labels
- [ ] Keyboard navigation support
- [ ] Screen reader friendly (semantic HTML/Widgets)
- [ ] Error messages in plain language
- [ ] Help text for unclear fields
- [ ] Confirmation before destructive actions

---

## Files to Review Before Starting Implementation

1. `lib/l10n/app_*.arb` - Localization files
2. `lib/core/app_theme.dart` - Color system
3. `lib/features/parties/party_management_screen.dart` - Main screen
4. `lib/features/parties/widgets/` - Current widgets
5. `lib/shared/widgets/architect_card.dart` - Card component
6. `lib/shared/widgets/architect_app_bar.dart` - App bar component

Good luck! 🎯
