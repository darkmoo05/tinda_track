# Charges Management Screen - UI Design Polish Samples

## Current Screen Analysis

### Current State Review
**Screen Name**: `ChargesScreen` & `ChargesEarningsScreen`
**Current Components**:
- Header: "Charges Management" title with subtitle
- Wallet & Service Selector: GCash/Maya wallet toggle + service dropdown
- Add Bracket Card: Form with 3 inputs (lower bound, upper bound, charge amount) + CREATE BRACKET button
- Active Brackets Section: List of charge brackets with edit/delete actions
- Earnings Screen: Shows total earnings, transaction count, withdrawable amounts, fee movements

### Theme & Design System
- **Primary Color**: Blue (#005DAC)
- **Secondary Color**: Growth Green (#106D20)
- **Semantic**: Error Red (#BA1A1A), Surface variations
- **Typography**: Manrope (headings), Inter (body)
- **Spacing**: Material Design 3 with 24px padding, 12-16px gaps
- **Border Radius**: 8-16px for cards and buttons
- **Icons**: Material Design (payments, wallet, tune, add, edit, delete)

### Current Issues to Address
1. **Terminology Clarity**: "Charges Management", "Bracket", "Lower Bound/Upper Bound" are technical terms
2. **User Guidance**: Average users don't understand what "brackets" are or how to configure them
3. **Workflow**: Complex selection process (wallet → service → then form) not intuitive
4. **Visual Hierarchy**: Important information (available brackets, fee rules) not clearly separated
5. **Empty State**: No clear guidance when no brackets exist or amount doesn't match any bracket
6. **Mobile Layout**: Three inputs in one form can be overwhelming on small screens
7. **Translation**: Current terms need localization for Filipino/Cebuano speakers
8. **Context**: Users need examples of how fees work in practice

---

## SAMPLE 1: "Quick & Simple" Design
### Target: First-time users, casual transactions, business owners
### Philosophy: Minimal settings, guided setup, visual clarity

### Key Changes:
- Simplified header: "Fee Setup" instead of "Charges Management"
- Friendly wording: "Fee brackets" → "Price ranges" or "Fee tiers"
- One-step wallet/service selector with icon preview
- Pre-filled templates for common scenarios
- Visual diagram showing how fees work
- Better empty state with examples

### Layout Structure:
```
╔═ HEADER ═══════════════════════════════════════╗
║ Fee Setup                                      ║
║ Set prices for each type of service            ║
╚════════════════════════════════════════════════╝

╔═ QUICK GUIDE ═══════════════════════════════════╗
║ 📊 How Fees Work:                              ║
║                                                ║
║ For GCash Cash-In transactions:                ║
║ • Transactions ₱1,000-₱2,000 → Fee: ₱50      ║
║ • Transactions ₱2,001-₱5,000 → Fee: ₱100     ║
║ • Transactions ₱5,001+ → Fee: ₱200            ║
║                                                ║
║ [Collapse]                                     ║
╚════════════════════════════════════════════════╝

╔═ SELECT SERVICE ════════════════════════════════╗
║ What service do you want to set fees for?      ║
║                                                ║
║ ┌─ Currently: GCash Wallet ──────────────────┐ ║
║ │ [💳 GCash]  [💰 Maya]                      │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ ┌─ Service Type ───────────────────────────── ┐ ║
║ │ ▼ Select Service  [Cash-In ▼]              │ ║
║ │   • Cash-In        [Send money in]         │ ║
║ │   • Cash-Out       [Withdraw money]        │ ║
║ │   • Load           [Buy load/data]         │ ║
║ │   • Pay Bills      [Pay utilities]         │ ║
║ │   • QR Payment     [QR transfers]          │ ║
║ └────────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════╝

╔═ QUICK TEMPLATES ═══════════════════════════════╗
║ Use a template to get started (optional):      ║
║                                                ║
║ [Small Biz]  [Medium]  [Large]  [Custom]      ║
║ Standard fees for: Various transaction sizes  ║
║                                                ║
║ When tapped: Shows preview of that template    ║
╚════════════════════════════════════════════════╝

╔═ ADD FEE RANGE ═════════════════════════════════╗
║                                                ║
║ 📍 Set a price range:                          ║
║                                                ║
║ From Amount    [e.g. 1000]                     ║
║ ₱_____________                                 ║
║ Enter the starting amount for this fee         ║
║                                                ║
║ To Amount      [e.g. 2000]                     ║
║ ₱_____________                                 ║
║ Enter the highest amount for this fee          ║
║                                                ║
║ Fee Amount     [e.g. 50]                       ║
║ ₱_____________                                 ║
║ The fee you'll earn from each transaction      ║
║                                                ║
║ Preview: For ₱1,500 transaction → Fee ₱50    ║
║                                                ║
║         [Save Fee Range]                       ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ ACTIVE FEE RANGES (GCash / Cash-In) ══════════╗
║                                                ║
║ Total: 3 Fee Ranges                            ║
║                                                ║
║ ┌─ RANGE 1 ──────────────────────────────────┐ ║
║ │ ₱1,000 — ₱2,000                   Fee: ₱50 │ ║
║ │ (Shown for: GCash Cash-In)                 │ ║
║ │                                            │ ║
║ │ [✎ Edit]  [🗑 Delete]                     │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ ┌─ RANGE 2 ──────────────────────────────────┐ ║
║ │ ₱2,001 — ₱5,000                  Fee: ₱100 │ ║
║ │ (Shown for: GCash Cash-In)                 │ ║
║ │                                            │ ║
║ │ [✎ Edit]  [🗑 Delete]                     │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ ┌─ RANGE 3 ──────────────────────────────────┐ ║
║ │ ₱5,001 and above                 Fee: ₱200 │ ║
║ │ (Shown for: GCash Cash-In)                 │ ║
║ │                                            │ ║
║ │ [✎ Edit]  [🗑 Delete]                     │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║         [+ Add Another Range]                  ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ EMPTY STATE ═══════════════════════════════════╗
║                                                ║
║              💰                                ║
║                                                ║
║   No Fee Ranges Yet                            ║
║                                                ║
║ Set up your first fee range to start           ║
║ earning from GCash Cash-In transactions.       ║
║                                                ║
║ [How does this work? 💡]  [Add Fee Range]    ║
║                                                ║
╚════════════════════════════════════════════════╝
```

### User-Friendly Wording:
- "Charge Amount" → "Fee Amount" (what they earn)
- "Lower Bound/Upper Bound" → "From Amount/To Amount" (what transactions this applies to)
- "Add New Bracket" → "Add Fee Range"
- "Active Charge Brackets" → "Active Fee Ranges"
- "Charges Management" → "Fee Setup"
- "Set service fee brackets..." → "Set prices for each type of service"

### Key Features:
✓ Quick visual guide showing how fees work
✓ Template suggestions for common scenarios
✓ Clear labeling with examples (e.g., "e.g. 1000")
✓ Live preview when editing
✓ Simpler terminology appropriate for average users
✓ Clear empty state with guidance
✓ Friendly explanations for each field

---

## SAMPLE 2: "Progressive Disclosure" Design
### Target: Mix of experienced and new users
### Philosophy: Show essentials first, detailed options available on demand

### Key Changes:
- Two-mode interface: Simple (default) and Advanced (toggle)
- Wallet/service shown as selected tag (not form)
- Fee ranges displayed as visual tier cards
- Context-sensitive help tooltips
- Collapsible advanced options
- Transaction preview feature

### Layout Structure:
```
╔═ HEADER ═══════════════════════════════════════╗
║ Fee Configuration                              ║
║ Manage pricing for all services                ║
║                                         [? Help]
╚════════════════════════════════════════════════╝

╔═ ACTIVE SERVICE ════════════════════════════════╗
║ Configuring fees for:                          ║
║                                                ║
║ [💳 GCash] [Cash-In ▼] [Switch Service]       ║
║                                                ║
║ Other services: Maya • Load • Bill Pay • QR   ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ TIER OVERVIEW ═════════════════════════════════╗
║ Quick View: 3 Fee Tiers Configured             ║
║                                                ║
║ Lowest: ₱1,000    │  Mid: ₱2,001   │ High: ₱5,001  ║
║  Fee ₱50          │   Fee ₱100     │ Fee ₱200      ║
║                                                ║
║ Last Updated: Today at 2:30 PM                 ║
╚════════════════════════════════════════════════╝

╔═ FEE TIERS ═════════════════════════════════════╗
║                                                ║
║ 📍 Tier 1: Small Transactions                  ║
║ ┌────────────────────────────────────────────┐ ║
║ │ Range: ₱1,000 to ₱2,000                   │ ║
║ │ Fee: ₱50 per transaction                  │ ║
║ │                                            │ ║
║ │ Status: Active ✓ (10 transactions used)   │ ║
║ │ Last fee earned: ₱50 on Mar 15            │ ║
║ │                                            │ ║
║ │ [Edit] [Delete] [More Details ▼]         │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ 📍 Tier 2: Medium Transactions                 ║
║ ┌────────────────────────────────────────────┐ ║
║ │ Range: ₱2,001 to ₱5,000                   │ ║
║ │ Fee: ₱100 per transaction                 │ ║
║ │                                            │ ║
║ │ Status: Active ✓ (15 transactions used)   │ ║
║ │ Last fee earned: ₱100 on Mar 16           │ ║
║ │                                            │ ║
║ │ [Edit] [Delete] [More Details ▼]         │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ 📍 Tier 3: Large Transactions                  ║
║ ┌────────────────────────────────────────────┐ ║
║ │ Range: ₱5,001 and above                   │ ║
║ │ Fee: ₱200 per transaction                 │ ║
║ │                                            │ ║
║ │ Status: Active ✓ (5 transactions used)    │ ║
║ │ Last fee earned: ₱200 on Mar 14           │ ║
║ │                                            │ ║
║ │ [Edit] [Delete] [More Details ▼]         │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║              [+ Add New Tier]                  ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ ADD NEW TIER ══════════════════════════════════╗
║                                                ║
║ [Simple Mode 🔸] [Advanced Mode ◆]            ║
║                                                ║
║ SIMPLE: Quick setup                            ║
║ ┌────────────────────────────────────────────┐ ║
║ │ Starting Amount    ₱[____]                │ ║
║ │ Ending Amount      ₱[____]                │ ║
║ │ Fee Amount         ₱[____]                │ ║
║ │                                            │ ║
║ │ Preview: ₱1,500 → Fee ₱[__]              │ ║
║ │                                            │ ║
║ │ [Save Tier]                               │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ ADVANCED: [Show more options ▼]               ║
║ • Set percentage-based fees                   ║
║ • Apply to specific days/times               ║
║ • Set transaction limits                     ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ HELP & EXAMPLES ═══════════════════════════════╗
║ 🎯 What do these fields mean?                  ║
║                                                ║
║ Starting Amount: The lowest transaction       ║
║   amount that this fee applies to              ║
║                                                ║
║ Ending Amount: The highest transaction        ║
║   amount that this fee applies to              ║
║                                                ║
║ Fee Amount: How much you earn from            ║
║   each transaction in this range              ║
║                                                ║
║ Examples:                                      ║
║ • If ₱1,500 is sent, and your tier is         ║
║   ₱1,000-₱2,000 with fee ₱50,                ║
║   you earn ₱50 from that transaction.        ║
║                                                ║
║ [View Video Tutorial]                         ║
║                                                ║
╚════════════════════════════════════════════════╝
```

### User-Friendly Wording:
- "Bracket" → "Tier"
- "Charge Amount" → "Fee Amount"
- "Lower/Upper Bound" → "Starting/Ending Amount"
- "Active Charge Brackets" → "Fee Tiers"
- Tier names: "Tier 1: Small Transactions" (instead of just range numbers)
- Added: Status indicators, usage statistics, last used date

### Key Features:
✓ Show current selection prominently
✓ Tier preview with usage statistics
✓ Toggle between simple/advanced modes
✓ Contextual help for each field
✓ Visual tier cards with key information
✓ Examples of how fees work
✓ Show when tiers are actually being used

---

## SAMPLE 3: "Data-Driven Dashboard" Design
### Target: Business owners, frequent users, analytics-focused
### Philosophy: Overview + details, historical context, performance insights

### Key Changes:
- Dashboard-style overview with metrics
- Fee tier list with performance data
- Visual indicators (charts, badges) for tier activity
- Search/filter for finding specific tiers
- Bulk actions (enable/disable all)
- Comparison between wallets/services
- Export functionality

### Layout Structure:
```
╔═ HEADER ═══════════════════════════════════════╗
║ Fee Structure & Analytics                      ║
║ Track pricing, usage, and earnings              ║
╚════════════════════════════════════════════════╝

╔═ PERFORMANCE SNAPSHOT ══════════════════════════╗
║                                                ║
║ 💰 Total Earnings (Today)        ₱2,350.00   ║
║ ✅ Active Tiers                  15          ║
║ 📊 Transactions Using Fees       127         ║
║ 🎯 Coverage Rate                 92%         ║
║                                                ║
║ [Detailed Report ▶]                           ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ FILTERS & CONTROLS ════════════════════════════╗
║ Show:  [All ▼] [GCash ▼] [Maya ▼]            ║
║ Service: [All ▼] [Cash-In ▼] [Cash-Out ▼]   ║
║                                                ║
║ Search tiers... [🔍____________________]      ║
║ Status: [Active ✓] [Inactive] [All]          ║
║                                                ║
║ [Bulk Actions ▼]                              ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ FEE STRUCTURE OVERVIEW ════════════════════════╗
║                                                ║
║ Wallet: 💳 GCash  |  Service: Cash-In         ║
║                                                ║
║ ┌─ TIER 1 ───────────────────────────────────┐ ║
║ │ ₱1,000 - ₱2,000   →   ₱50                 │ ║
║ │                                            │ ║
║ │ Status: Active ✓      Last Used: 2h ago   │ ║
║ │ Usage: 45 trans. (35%)  Earned: ₱2,250   │ ║
║ │ Trend: ▲ +12% (this week)                 │ ║
║ │                                            │ ║
║ │ Frequency Chart: [████░░░] High Activity   │ ║
║ │                                            │ ║
║ │ [View Transactions] [✎ Edit] [🗑 Delete]  │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ ┌─ TIER 2 ───────────────────────────────────┐ ║
║ │ ₱2,001 - ₱5,000   →   ₱100                │ ║
║ │                                            │ ║
║ │ Status: Active ✓      Last Used: 1h ago   │ ║
║ │ Usage: 62 trans. (49%)  Earned: ₱6,200   │ ║
║ │ Trend: ▲ +8% (this week)                  │ ║
║ │                                            │ ║
║ │ Frequency Chart: [██████░░] Very Active   │ ║
║ │                                            │ ║
║ │ [View Transactions] [✎ Edit] [🗑 Delete]  │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ ┌─ TIER 3 ───────────────────────────────────┐ ║
║ │ ₱5,001+   →   ₱200                        │ ║
║ │                                            │ ║
║ │ Status: Active ✓      Last Used: 3h ago   │ ║
║ │ Usage: 20 trans. (16%)  Earned: ₱4,000   │ ║
║ │ Trend: ▼ -5% (this week)                  │ ║
║ │                                            │ ║
║ │ Frequency Chart: [████░░░░] Medium        │ ║
║ │                                            │ ║
║ │ [View Transactions] [✎ Edit] [🗑 Delete]  │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║              [+ Add New Tier]                  ║
║                                                ║
║         [📊 Download Report as PDF]           ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ ADD/EDIT TIER ═════════════════════════════════╗
║                                                ║
║ Edit Tier: ₱1,000 - ₱2,000                    ║
║                                                ║
║ Range Configuration:                           ║
║ ┌────────────────────────────────────────────┐ ║
║ │ From: ₱[1000____________]                 │ ║
║ │ To:   ₱[2000____________]                 │ ║
║ │                                            │ ║
║ │ ℹ Applies to this range only             │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ Fee Configuration:                             ║
║ ┌────────────────────────────────────────────┐ ║
║ │ ◉ Fixed Amount: ₱[50____________]         │ ║
║ │ ○ Percentage: [___]% of transaction      │ ║
║ │                                            │ ║
║ │ ℹ You earn this amount per transaction   │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║ Advanced Options:                              ║
║ ┌────────────────────────────────────────────┐ ║
║ │ [≡] Apply to all wallets [toggle]         │ ║
║ │ [≡] Active tier [toggle]                  │ ║
║ │ [≡] Set time-based rules [toggle]         │ ║
║ └────────────────────────────────────────────┘ ║
║                                                ║
║              [Save Changes] [Cancel]           ║
║                                                ║
╚════════════════════════════════════════════════╝

╔═ EMPTY STATE ═══════════════════════════════════╗
║                                                ║
║              📊                                ║
║                                                ║
║   No Fee Tiers Configured Yet                  ║
║                                                ║
║ Start earning immediately by setting up       ║
║ your first fee structure.                      ║
║                                                ║
║ [See Examples] [Create First Tier]            ║
║                                                ║
║ Average earnings with 3 tiers:                ║
║ 20-50 transactions/day × avg. ₱75 fee        ║
║ = Potential ₱1,500 - ₱3,750 per day         ║
║                                                ║
╚════════════════════════════════════════════════╝
```

### User-Friendly Wording:
- "Charge Bracket" → "Fee Tier"
- "Configure Fees For" → "Select Wallet & Service"
- "Active Charge Brackets" → "Fee Structure Overview"
- "Charges Management" → "Fee Structure & Analytics"
- Added performance metrics and business language

### Key Features:
✓ Dashboard with key metrics (total earnings, active tiers, coverage rate)
✓ Performance data for each tier (usage count, trend, earnings)
✓ Visual indicators (activity level, trend direction)
✓ Filter and search capabilities
✓ Bulk actions support
✓ Fixed vs percentage fee options
✓ Advanced rule options
✓ Export/reporting features
✓ Business-focused empty state with earning potential

---

## Recommended Localization Terms

### English → User-Friendly Terms:
| Technical | Friendly | Filipino | Cebuano |
|-----------|----------|----------|---------|
| Charges Management | Fee Setup | Setup ng Bayad | Setup sa Bayad |
| Charge Bracket | Fee Tier / Price Range | Kalakalan na Presyo | Presyo na Kupo |
| Lower Bound | Starting Amount | Simula ng Halaga | Simula sa Halaga |
| Upper Bound | Ending Amount | Katapusan ng Halaga | Katapusan sa Halaga |
| Charge Amount | Fee Amount | Halaga ng Bayad | Halaga sa Bayad |
| Add New Bracket | Add Fee Range | Magdagdag ng Fee | Magdagdag Fee |
| Active Brackets | Active Fee Ranges | Aktibong Presyo | Aktibong Presyo |
| Transaction Type | Service | Serbisyo | Serbisyo |
| Configure | Set Up | Ayusin | Ayusin |

---

## User Testing Recommendations

### Suggested Test Scenarios:
1. **First-time setup**: Can a new user understand what to do without help?
2. **Edit existing**: Can users quickly find and modify existing fee ranges?
3. **Error handling**: How do users respond to validation errors (overlapping ranges)?
4. **Empty state**: Does empty state guidance help users get started?
5. **Mobile usability**: Is the form accessible on small screens?

### Key Metrics to Track:
- Time to create first fee range
- Error rate for invalid inputs
- Number of help interactions needed
- Successful completion rate
- Mobile vs desktop conversion

---

## Implementation Recommendations

### Priority Changes:
1. **High**: Replace technical terms with user-friendly language
2. **High**: Add visual examples/diagrams showing how fees work
3. **High**: Improve empty state with clear CTAs and examples
4. **Medium**: Add input helpers (e.g., suggested values, templates)
5. **Medium**: Show usage statistics and context for existing tiers
6. **Low**: Add advanced options for experienced users (progressive disclosure)

### Localization Priority:
1. First: English (ensure base wording is clear)
2. Second: Filipino (Tagalog) - largest audience
3. Third: Cebuano - regional coverage

### A/B Testing Suggestion:
- Test Sample 1 vs Sample 3 with different user groups
- Simple users → Sample 1
- Business owners → Sample 3
- Mixed → Sample 2
