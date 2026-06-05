# TindaTracker Inventory Feature Overview

Purpose: This document is the source of truth for the Inventory area across Flutter app, local SQLite, sync layer, and Nest/Prisma backend integration.

Last updated: 2026-05-24
Scope: Inventory UI, product lifecycle, stock adjustments, measurement and conversion model, sync behavior, and stabilization fixes.

---

## Change Log

### 2026-06-05
- Evolved Tinda Tracker into a versatile multi-industry platform (Phase 1):
  - Created `BusinessProfile` database model (server Postgres & client Drift SQLite) with user isolation.
  - Updated NestJS registration DTO and AuthService to atomically create the user and their 1-to-1 business profile on signup.
  - Updated Sync Engine (bindings, DTOs, mappers, remote repositories) to support `businessProfiles` push/pull.
  - Created `BusinessProfileWizardScreen` onboarding flow for new registrations and legacy user fallbacks.
  - Updated client sign-up UI (LoginScreen) with business name and type selections.
  - Updated dashboard screen to dynamically display the store name and respect currency configurations.

### 2026-05-24
- Updated inventory architecture to support base-unit stock with multi-unit conversion packages.
- Added conversion-aware behavior to Add or Edit Product, Quick Stock, product cards, repository, and sync mapping.
- Updated local database schema (v19) with conversion table and base-unit fields.
- Updated server schema and DTOs for `baseUnit`, `stockInBaseUnit`, and `unitConversions`.
- Added sync endpoint fallback and candidate probing with automatic reachable URL persistence.
- Fixed add or edit product dropdown assertion when legacy unit value is `pcs`.
- Added local unit normalization on DB open (`pcs`, `piece`, `pieces` -> `pc`).

### 2026-05-23
- Implemented mixed category row design in Manage Categories.
- Added Add-button guard when category name input is empty.
- Improved user-facing notification wording for common category management failures.

### 2026-05-22
- Shipped major inventory UI refresh:
  - monitoring-focused summary,
  - grouped shelf list with sticky headers and natural shelf sorting,
  - contextual empty states,
  - category chip spacing and typography polish,
  - product card consistency and peso formatting fixes.

---

## 1) Inventory Feature Summary

The Inventory area lets store owners:
- Create, edit, archive, and browse products.
- Track stock and stock movements.
- Organize by category and shelf location.
- Use list or grid views with filters.
- Manage categories and shelf locations in-place.
- Define product measurements using a base unit plus alternative packaged units.
- Customize modular features (Recipes/BOM, Serial Tracking, Multi-Location, Bundles) using specialized **Business Profiles** based on business type templates (Sari-Sari, Carinderia, Auto Shop, Hardware, Public Market).

Architecture is local-first:
- Writes are committed to SQLite first.
- Dirty records sync asynchronously in background.
- UI remains usable offline.

---

## 2) Current Data Model (Inventory)

### Canonical stock model
- Stock is stored in base units.
- Product field `stockInBaseUnit` is the canonical quantity.
- Product field `baseUnit` defines the measurement basis (example: `pc`, `g`, `ml`).

### Conversion model
- Each product can have many conversion definitions.
- A conversion entry includes:
  - `unitName` (example: `pack`, `box`, `case`),
  - `conversionFactor` (how many base units per selected unit),
  - optional unit-specific `costPrice` and `sellingPrice`.
- Conversion entries are persisted both locally and in server schema.

### Business Profile & Configuration Model (Phase 1)
- User accounts support a strictly 1-to-1 relationship with `BusinessProfile`.
- A profile defines the business type template (`retail`, `food_service`, `auto_parts`, `hardware`, `marketplace`, `general`).
- Industry templates map to specific feature configuration flags stored in `preferencesJson`:
  - `showRecipes`: true for `food_service` (Carinderia). Hides/shows ingredient lists.
  - `showSerialTracking`: true for `auto_parts` (Auto Shop) and `hardware`.
  - `showMultiLocation`: true for `auto_parts` and `hardware`.
  - `showBundles`: true for `auto_parts` and `hardware`.
- Standardizes default store currency (e.g. PHP or USD) across the dashboard and sales records.

### Backward compatibility notes
- Legacy `unit` values are normalized to current canonical values during local DB open.
- Existing code paths maintain compatibility getters where needed, but base-unit fields are authoritative.
- Fallback onboarding setup wizard launches automatically if a logged-in user has no local business profile.

---

## 3) User Flows and Behavior

### A. Setup Wizard & Sign-Up Flow
- New users configure their store name, currency, and business template directly on the registration form.
- Legacy users logging in with 0 profile records are intercepted by a wizard flow (`BusinessProfileWizardScreen`) before accessing the dashboard.
- The selected template initializes target settings dynamically (e.g. enabling recipes for carinderias or serial number fields for auto shops).

### B. Add or Edit Product
- User sets product identity and pricing details.
- Measurement setup now supports:
  - base unit selection,
  - alternative package units with conversion factors,
  - optional package-level pricing overrides.
- Dropdown logic is hardened to avoid assertion errors from duplicate or missing selected values.

### C. Quick Stock Adjustment
- User can choose adjustment unit (base unit or conversion unit).
- Input quantity is converted to base units before persistence.
- Movement is saved local-first; sync pushes when server is reachable.

### D. Product Cards and Inventory List
- Stock display is conversion-aware and formatted for readable presentation.
- List and grid cards share aligned status behavior.
- Currency symbols are dynamically formatted based on the active business profile.

### E. Manage Categories and Shelf Locations
- Search is available for category and shelf management.
- Category row UI uses mixed concept design:
  - avatar,
  - quick badge,
  - single pin control,
  - expandable inline editor,
  - delete action in expanded body.
- Add action is disabled while required name input is empty.

---

## 4) Sync and Connectivity Behavior

### Local-first sync model
- Inventory and business profile mutations mark records dirty and return immediately to UI.
- Sync service pushes and pulls in background cycles.

### Endpoint resiliency
- Startup now probes candidate API endpoints.
- Reachable endpoint is auto-selected and persisted.
- Fallback list helps recover from stale LAN IP configuration.
- Health probing treats non-5xx responses as reachable transport layer.

### Sync payload updates
- Product sync includes:
  - `baseUnit`,
  - `stockInBaseUnit`,
  - `unitConversions` list.
- Sync engine manages the `businessProfiles` entity registry to synchronize profile configurations between Drift SQLite and Postgres.

---

## 5) Backend and Local Schema Changes

### Server (Nest/Prisma)
- Product fields migrated from legacy unit stock model to base-unit float model.
- `ProductUnitConversion` relation added.
- Added `BusinessProfile` model with `businessType`, `businessName`, `defaultCurrency`, and `preferences` (JSONB).
- Updated auth/register to create user and profile atomically.

### Local SQLite
- DB version bumped to v2.
- `tt_products` includes `base_unit` and `stock_in_base_unit`.
- `tt_product_conversions` table added.
- `business_profiles` table added with `preferences_json` field.
- Migration logic manages table creation when upgrading schema.

---

## 6) UI and UX Updates in Inventory Area

### Inventory screen redesign set
- Improved summary hierarchy and monitoring readability.
- Grouped shelf list with sticky headers and natural numeric sorting.
- Contextual empty states for no-products and no-results scenarios.
- Category quick-chip spacing, typography, and touch-target improvements.

### Messaging and guardrails
- Error text rewritten in plain language for common user actions.
- Quick-access limit message includes direct next step.
- Duplicate category message is clearer and action-oriented.
- Empty required inputs are blocked before action execution.

---

## 7) Key Files in Inventory Scope

Flutter app:
- `lib/tinda_tracker/features/inventory/screens/inventory_screen.dart`
- `lib/tinda_tracker/features/inventory/screens/add_edit_product_screen.dart`
- `lib/tinda_tracker/features/inventory/screens/business_profile_wizard_screen.dart`
- `lib/tinda_tracker/features/inventory/domain/entities/business_profile.dart`
- `lib/core/database/tables/business_profiles_table.dart`
- `lib/core/database/daos/tinda_tracker/business_profiles_dao.dart`
- `lib/tinda_tracker/features/inventory/widgets/quick_stock_sheet.dart`
- `lib/tinda_tracker/features/inventory/widgets/product_cards.dart`
- `lib/tinda_tracker/features/inventory/widgets/manage_lookup_sheet.dart`
- `lib/tinda_tracker/features/inventory/data/local_inventory_repository.dart`
- `lib/core/database/app_database.dart`
- `lib/core/sync/sync_service.dart`
- `lib/core/sync/sync_config.dart`

Backend integration:
- `../tinda_track_server_nest/prisma/schema.prisma`
- `../tinda_track_server_nest/src/modules/auth/auth.service.ts`
- `../tinda_track_server_nest/src/modules/sync/sync.service.ts`

---

## 8) Validation Checklist (Recommended)

1. Create product with base unit only; verify stock save and card display.
2. Create product with conversion units; verify conversion rows persist after reopen.
3. Edit legacy product (`pcs` source data); confirm no dropdown assertion.
4. Adjust stock using conversion unit; verify base-unit stock math.
5. Confirm list and grid stock/status views remain consistent.
6. Validate category Add button remains disabled when name is blank.
7. Verify setup wizard screen displays and blocks dashboard access if local profile records are zero.
8. Complete registration with business name/type and verify profile creation atomically.
9. Verify dashboard renders store name dynamically and formats currency symbol correctly based on profile defaultCurrency.
10. Run sync cycle and confirm profile configuration payload round-trips correctly between Drift and Postgres.

---

Current status: Inventory area supports a multi-industry base-unit + conversions model and dynamic business profile setups with local-first reliability and improved UX controls.
