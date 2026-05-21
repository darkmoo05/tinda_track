# TindaTracker â€” Inventory Feature Overview

> **Purpose of this document:** A comprehensive reference for AI agents (and human developers) to understand the full business flow, data contracts, sync strategy, and extension points of the Inventory section before making any changes.
>
> **Last updated:** 2026-05-22 â€” Added full-screen image review screen (Hero + InteractiveViewer), Flutter-native gallery crop (`crop_your_image` replaces UCrop), camera flash fixes (torch-only + 300 ms AE delay), image sync reliability (`_imageChanged` flag + clear `image_url` on update), server orphan image cleanup.

---

## 1. Feature Summary

The **Inventory** section lets a sari-sari store owner manage their product catalogue and track stock levels. It is **local-first**: every write goes to SQLite immediately so the app works offline, then syncs to the NestJS + PostgreSQL backend in the background.

Key capabilities:
- Create, read, update, and soft-delete products.
- Adjust stock quantities with a reason/movement type (Restock, Adjustment, Sale, Damage, Theft, Expired, Manual Count).
- View per-product stock movement history.
- Barcode / SKU scanning when adding a product.
- Duplicate-SKU detection with an auto-restock dialog.
- **Product image** â€” pick from gallery or camera; compressed locally to WebP (max 600Ã—600); uploaded to server in background. Gallery uses a Flutter-native crop screen (`crop_your_image` â€” no UCrop/activity issues). After capture or gallery pick, a full-screen **Image Review** screen (pinch-to-zoom, Hero animation) lets the user confirm, retake, or choose a different photo before saving. Stale server images are deleted automatically when a product's image is replaced.
- **Shelf / location tracking** â€” each product is assigned to a store location (Counter, Shelf A, Fridge, etc.).
- Filter by category, **shelf location**, low-stock only, or out-of-stock only.
- Toggle between **grouped-by-shelf list view** and grid view.
- Bulk-select mode for mass archiving.
- Summary header showing totals, low-stock count, out-of-stock count.

---

## 2. Directory Map

```
tinda_track/lib/shared/camera/
â”œâ”€â”€ flutter_crop_screen.dart    # NEW: Shared Flutter-native full-screen crop screen (crop_your_image v2)
â”œâ”€â”€ guided_camera_screen.dart   # Full-screen camera with overlay frame, flash toggle, shutter
â””â”€â”€ guided_camera_service.dart  # Static service: permission â†’ guided camera â†’ crop â†’ WebP compress

tinda_track/lib/tinda_tracker/features/inventory/
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ inventory_constants.dart         # Const lists (categories, units, shelf locations, reasons)
â”‚   â”œâ”€â”€ inventory_repository.dart        # Legacy remote-only repository (kept for reference)
â”‚   â”œâ”€â”€ local_inventory_repository.dart  # PRIMARY: local-first SQLite + fire-and-forget API
â”‚   â”œâ”€â”€ product_image_service.dart       # NEW: image pick + WebP compress + local save
â”‚   â”œâ”€â”€ product_model.dart               # TtProduct (simple server JSON model)
â”‚   â””â”€â”€ models/
â”‚       â”œâ”€â”€ inventory_product.dart       # InventoryProduct (full local model)
â”‚       â””â”€â”€ stock_movement.dart          # StockMovement (server-fetched only)
â”œâ”€â”€ providers/
â”‚   â””â”€â”€ inventory_providers.dart         # All Riverpod providers
â”œâ”€â”€ screens/
â”‚   â”œâ”€â”€ inventory_screen.dart            # Main screen: grouped-shelf list, grid, filters, summary
â”‚   â”œâ”€â”€ add_edit_product_screen.dart     # Create/edit form + image picker + shelf dropdown
â”‚   â”œâ”€â”€ add_product_screen.dart          # (legacy/alternative)
â”‚   â””â”€â”€ stock_history_screen.dart        # Per-product movement history (server-fetched)
â””â”€â”€ widgets/
    â”œâ”€â”€ inventory_filter_sheet.dart      # Bottom sheet: category, location, low/out-of-stock
    â”œâ”€â”€ product_cards.dart               # List tile + grid card (image-first with icon fallback)
    â””â”€â”€ quick_stock_sheet.dart           # DraggableScrollableSheet for rapid stock adjustment

tinda_track_server_nest/src/
â”œâ”€â”€ core/storage/
â”‚   â”œâ”€â”€ storage-provider.interface.ts    # NEW: IStorageProvider abstraction + STORAGE_PROVIDER token
â”‚   â””â”€â”€ local-storage.provider.ts        # NEW: dev local-disk implementation (swap to DO Spaces later)
â””â”€â”€ tinda_tracker/modules/inventory/
    â”œâ”€â”€ dto/
    â”‚   â”œâ”€â”€ adjust-stock.dto.ts
    â”‚   â”œâ”€â”€ create-product.dto.ts         # shelfLocation field added
    â”‚   â”œâ”€â”€ list-products-query.dto.ts
    â”‚   â””â”€â”€ update-product.dto.ts         # shelfLocation field added
    â”œâ”€â”€ inventory.controller.ts           # REST endpoints incl. PATCH :id/image
    â”œâ”€â”€ inventory.module.ts               # Provides LocalStorageProvider via STORAGE_PROVIDER token
    â””â”€â”€ inventory.service.ts              # Business logic + Prisma
```

**Server static assets:** `uploads/` directory served at `/uploads/` (no `/api` prefix) via `NestExpressApplication.useStaticAssets`.

---

## 3. Data Models

### 3.1 Local SQLite â€” `tt_products` table (DB version 16)

Defined in `lib/core/database/app_database.dart` â†’ `_createTtProductsTable`.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | Local row id (never exposed to UI) |
| `sync_id` | TEXT UNIQUE NOT NULL | UUID generated on device; idempotency key for server |
| `server_id` | TEXT | UUID assigned by server after first push; `NULL` while offline |
| `device_id` | TEXT | Device identifier for multi-device sync |
| `name` | TEXT NOT NULL | Display name |
| `sku` | TEXT NOT NULL | Barcode / SKU (unique per store) |
| `description` | TEXT DEFAULT '' | Optional description |
| `category` | TEXT DEFAULT 'General' | One of `kProductCategories` |
| `unit` | TEXT DEFAULT 'pcs' | One of `kProductUnits` |
| `cost_price` | REAL DEFAULT 0 | Purchase price |
| `selling_price` | REAL NOT NULL | Retail price |
| `stock_quantity` | INTEGER DEFAULT 0 | Current on-hand count |
| `reorder_point` | INTEGER DEFAULT 0 | Alert threshold |
| `is_active` | INTEGER DEFAULT 1 | 0 = hidden from POS |
| `is_deleted` | INTEGER DEFAULT 0 | Soft-delete flag |
| `is_dirty` | INTEGER DEFAULT 1 | 1 = pending sync push |
| `image_path` | TEXT | **NEW** Local file path of compressed WebP image; `NULL` until user picks one |
| `image_url` | TEXT | **NEW** Remote CDN/static URL returned after successful image upload; `NULL` until pushed |
| `shelf_location` | TEXT DEFAULT 'Counter' | **NEW** Physical location in the store; one of `kShelfLocations` |
| `created_at` | TEXT | ISO-8601 UTC string |
| `updated_at` | TEXT | ISO-8601 UTC string |

**Migration:** Version bump 15 â†’ 16. `onUpgrade` block uses `_columnExists()` guards before each `ALTER TABLE ADD COLUMN`.

**Key computed properties** (in `InventoryProduct`):
```dart
bool get isLowStock  => stockQuantity > 0 && stockQuantity <= reorderPoint;
bool get isOutOfStock => stockQuantity == 0;
double get profit    => sellingPrice - costPrice;
```

### 3.2 Server PostgreSQL â€” `products` table (Prisma model)

```prisma
model Product {
  id             String          @id @default(uuid())
  syncId         String?         @unique
  deviceId       String?
  name           String
  sku            String          @unique
  description    String          @default("")
  category       String          @default("General")
  unit           String          @default("pcs")
  costPrice      Float           @default(0)
  sellingPrice   Float
  stockQuantity  Int             @default(0)
  reorderPoint   Int             @default(0)
  isActive       Boolean         @default(true)
  isDeleted      Boolean         @default(false)
  imageUrl       String?                              // NEW â€” path/URL of the uploaded product image
  shelfLocation  String?         @default("Counter") // NEW â€” physical store location
  createdAt      DateTime        @default(now())
  updatedAt      DateTime        @updatedAt
  saleItems      SaleItem[]
  stockMovements StockMovement[]
  @@map("products")
}
```

> **Schema applied via `prisma db push`** (the migration history had a bootstrap issue; the schema is in sync with the live DB).

### 3.3 Stock Movement â€” `stock_movements` (server only)

Stock movements are **never cached locally**; always fetched from the API.

```prisma
model StockMovement {
  id               String            @id @default(uuid())
  productId        String
  movementType     StockMovementType // RESTOCK | ADJUSTMENT | SALE
  quantity         Int
  previousQuantity Int
  newQuantity      Int
  note             String            @default("")
  reference        String            @default("")
  expirationDate   DateTime?
  createdAt        DateTime          @default(now())
  product          Product           @relation(...)
  @@index([productId, createdAt])
  @@map("stock_movements")
}
```

---

## 4. Business Flow (User Journeys)

### 4.1 Add a New Product

```
User taps FAB "Add Product"
  â†’ AddEditProductScreen (create mode)
      Fields:
        [Image Picker]          â€” tap preview or Gallery/Camera buttons
                                  ProductImageService compresses to WebP 600Ã—600
                                  stored at: <documents>/product_images/<tmp_timestamp>.webp
        name, SKU (or scan)
        category (chips)
        unit (dropdown)
        shelf location (dropdown from kShelfLocations)
        cost price, selling price
        initial stock, reorder point
        is_active toggle
  â†’ Tap "Save"
      LocalInventoryRepository.createProduct(
        ..., shelfLocation: _shelfLocation, imagePath: _localImageFile?.path)
        1. Check for duplicate SKU â†’ DuplicateSkuException if found
        2. Insert SQLite row (is_dirty=1, server_id=null, image_path, shelf_location)
        3. Return InventoryProduct
      ref.invalidate(allProductsProvider)
  â†’ Background sync:
      POST /inventory/products  { ..., shelfLocation }
      On HTTP 2xx:
        Store server_id, set is_dirty=0
        If image_path != null AND image_url == null:
          PATCH /inventory/products/:serverId/image  (multipart, field: "file")
          On success: write image_url back to SQLite
```

### 4.2 Edit an Existing Product

```
User taps product â†’ action sheet â†’ "Edit"
  â†’ AddEditProductScreen (edit mode)
      Pre-filled: all fields including shelfLocation, imagePath/imageUrl
      Image picker shows current local file or remote image
      _imageChanged flag starts as false
  â†’ User taps thumbnail â†’ _ImageReviewScreen (full-screen Hero + InteractiveViewer)
      "Retake" â†’ GuidedCameraService.capture() â†’ _imageChanged = true
      "Change Photo" â†’ GuidedCameraService.pickFromGallery() â†’ FlutterCropScreen â†’ _imageChanged = true
  â†’ Tap "Save"
      LocalInventoryRepository.updateProduct(id, {
        ...,
        shelfLocation: _shelfLocation,
        imagePath: _imageChanged ? _localImageFile?.path : null,   // only write when changed
        // if imagePath != null â†’ also clears image_url so sync re-uploads
      })
      ref.invalidate(allProductsProvider)
  â†’ Background sync: PATCH /inventory/products/:serverId  { ..., shelfLocation }
      If image_url == null and image_path != null: image upload fired after successful PATCH
        On server: updateImage() deletes the OLD image file before writing the new one
```

### 4.3 Adjust Stock (Quick Stock Sheet)

```
User taps product â†’ action sheet â†’ "Adjust Stock"
  â†’ showQuickStockSheet()
      DraggableScrollableSheet (65%â€“92%)
      +1 / +5 / +10 / -1 buttons + manual text input
      Reason dropdown (kStockAdjustmentReasons)
  â†’ Tap "Save"
      LocalInventoryRepository.adjustStock(productId, delta, movementType, note, expiryDate?)
        1. Update SQLite stock_quantity, is_dirty = 1
        2. If server_id != null: fire-and-forget POST /inventory/products/:id/adjust-stock
      ref.invalidate(allProductsProvider)
```

### 4.4 View Stock History

```
User taps product â†’ action sheet â†’ "History"
  â†’ StockHistoryScreen(product: product)
      GET <baseUrl>/inventory/products/:apiId/movements  (always server-fetched)
      Movement tiles: icon, type badge, delta, note, reference, date, expiry badge
```

### 4.5 Archive (Soft-Delete) a Product

```
Single: product action sheet â†’ "Archive" â†’ confirm dialog
  â†’ LocalInventoryRepository.deleteProduct(id)
      Sets is_deleted=1, is_dirty=1
      Background: DELETE /inventory/products/:serverId

Bulk: enter bulk-select â†’ tap checkboxes â†’ bulk delete icon â†’ confirm
  â†’ Loop deleteProduct() for each selected id, then exit bulk-select mode
```

### 4.6 Filtering and Searching

```
Search bar:
  Tap ðŸ” in AppBar â†’ animated search bar
  Filters by name + SKU (client-side, real-time)

Filter Sheet (bottom sheet â€” 3 sections):
  1. Category â€” chips from kProductCategories
  2. Location  â€” chips from kShelfLocations (NEW)
  3. Stock Alerts â€” "Low Stock Only" / "Out of Stock Only" toggles

Category quick-filter chips:
  Inline horizontal scroll row in InventoryScreen (derived from loaded products)

View Toggle (AppBar icon):
  List mode  â†’ _GroupedShelfView (products grouped and collapsed by shelf location)
  Grid mode  â†’ ProductGridCard 2-column grid
```

---

## 5. State Management (Riverpod)

```
inventoryRefreshProvider     StateProvider<int>
  Increment to force allProductsProvider re-fetch

inventoryFilterProvider      StateNotifierProvider<InventoryFilterNotifier, InventoryFilterState>
  Fields:
    search          String
    category        String?
    shelfLocation   String?   â† NEW: active shelf location filter
    lowStockOnly    bool
    outOfStockOnly  bool
    isGridView      bool
    bulkSelectMode  bool
    selectedIds     Set<String>
  Methods:
    setSearch(), setCategory(), setShelfLocation()  â† NEW
    toggleLowStockOnly(), toggleOutOfStockOnly()
    toggleGridView(), toggleBulkSelectMode()
    toggleSelect(), selectAll(), clearSelection()
    clearFilters()   â€” now also clears shelfLocation
  Getter:
    hasActiveFilters â€” true if category OR shelfLocation OR low/out-of-stock is set

allProductsProvider          FutureProvider.autoDispose<List<InventoryProduct>>
  Watches inventoryRefreshProvider
  Source: LocalInventoryRepository.listProducts()

filteredProductsProvider     Provider.autoDispose<AsyncValue<List<InventoryProduct>>>
  Derives from allProductsProvider + inventoryFilterProvider
  Applies: search â†’ category â†’ shelfLocation â†’ lowStockOnly â†’ outOfStockOnly

inventorySummaryProvider     Provider.autoDispose<AsyncValue<InventorySummary>>
  Source: LocalInventoryRepository.getSummary()

stockMovementsProvider(id)   FutureProvider.autoDispose.family
  Source: LocalInventoryRepository.getMovementsForProduct(id)
  Always fetches from server (no local cache)
```

---

## 6. API Endpoints (NestJS)

Base path: `/inventory/products`

| Method | Path | Description |
|---|---|---|
| `POST` | `/inventory/products` | Create product; returns `{ success, data: Product }` |
| `GET` | `/inventory/products` | List; supports `?search=&includeDeleted=&limit=` |
| `PATCH` | `/inventory/products/:id` | Partial update; returns updated Product |
| `PATCH` | `/inventory/products/:id/image` | **NEW** Upload product image (multipart/form-data, field: `file`); returns updated Product |
| `POST` | `/inventory/products/:id/adjust-stock` | Adjust quantity + create movement record |
| `GET` | `/inventory/products/:id/movements` | List stock movements (max 200, desc) |
| `DELETE` | `/inventory/products/:id` | Soft-delete |

**Static file serving:** Images are stored in `./uploads/products/` on the server and served at `/uploads/products/<filename>` (no `/api` prefix). The `imageUrl` stored in the DB is the full path `/uploads/products/<serverId>-<timestamp>.<ext>`.

### Request Bodies

**CreateProductDto**
```ts
{
  name: string;           // required
  sku: string;            // required, unique
  syncId?: string;
  deviceId?: string;
  description?: string;
  category?: string;      // default: 'General'
  unit?: string;          // default: 'pcs'
  costPrice?: number;     // default: 0
  sellingPrice: number;   // required
  stockQuantity?: number; // default: 0
  reorderPoint?: number;  // default: 0
  isActive?: boolean;     // default: true
  shelfLocation?: string; // NEW â€” default: 'Counter'
}
```

**UpdateProductDto** â€” all fields optional, same shape as above including `shelfLocation`.

**Image upload (`PATCH :id/image`):**
- Content-Type: `multipart/form-data`
- Field name: `file`
- Constraints: images only (jpeg/png/webp/gif), max 5 MB
- Response: `{ success: true, data: { imageUrl: '/uploads/products/<filename>' } }`

**AdjustStockDto**
```ts
{
  quantityDelta: number;
  movementType?: 'RESTOCK' | 'ADJUSTMENT' | 'SALE';
  note?: string;
  reference?: string;
  expirationDate?: string;
}
```

### Server Business Rules

- **Duplicate SKU** â†’ HTTP 409 `{ code: 'DUPLICATE_SKU', existingProduct }`.
- **Upsert by syncId** â€” idempotent create retries are safe.
- **adjustStock** runs in a Prisma transaction (atomic quantity update + movement creation).
- **Stock cannot go below 0** â€” server throws 400 if `newQuantity < 0`.
- **Soft-delete** â€” `isDeleted = true` + `isActive = false`; record never physically removed.
- **Image upload** â€” Multer diskStorage writes to `./uploads/products/`, filenames are `<fieldname>-<timestamp>.<ext>`. The `imageUrl` column is set to `/uploads/products/<filename>`.

### Storage Provider Abstraction

```ts
// src/core/storage/storage-provider.interface.ts
export const STORAGE_PROVIDER = Symbol('STORAGE_PROVIDER');
export interface IStorageProvider {
  uploadFile(file: Express.Multer.File, bucketPath: string): Promise<string>;
}
```

Current implementation: `LocalStorageProvider` (returns the local path). To migrate to DigitalOcean Spaces, implement `IStorageProvider` and swap the provider in `inventory.module.ts`.

---

## 7. Sync Strategy

### Write Path (client â†’ server)

1. Write to SQLite with `is_dirty = 1`.
2. If stock adjustment and `server_id` exists: fire-and-forget `POST /:id/adjust-stock` immediately.
3. `syncAll()` / `_syncTtProducts()` in `sync_service.dart` processes all `is_dirty = 1` rows:
   - `server_id == null` â†’ `POST /inventory/products` `{ ..., shelfLocation }`
     - On success: store `server_id`, set `is_dirty = 0`
     - If `image_path != null` AND `image_url == null`: fire `_pushProductImage()` (multipart PATCH)
       - On success: write `image_url` back to SQLite
   - `server_id != null`, `is_deleted = 0` â†’ `PATCH /inventory/products/:serverId` `{ ..., shelfLocation }`
   - `server_id != null`, `is_deleted = 1` â†’ `DELETE /inventory/products/:serverId`
   - `is_deleted = 1`, `server_id == null` â†’ mark `is_dirty = 0` (skip; never existed on server)

### Read Path (server â†’ client)

- Pull sync fetches `GET /inventory/products?includeDeleted=true&limit=1000`.
- Client upserts into `tt_products` by `sync_id` / `server_id`, skipping dirty local rows.
- Pull values map now includes:
  - `shelf_location: m['shelfLocation'] ?? 'Counter'`
  - `image_url: m['imageUrl']`  (does **not** overwrite `image_path` â€” that stays device-local)

### Image Sync Details

- `image_path` is **device-local only** â€” never sent to server, never overwritten by pull.
- `image_url` is **server-assigned** â€” written back to SQLite after a successful image upload.
- `GuidedCameraService.pickFromGallery()` / `capture()` save compressed WebP to `<documents>/product_images/<syncId>.webp`.
- Images are uploaded fire-and-forget: if upload fails, `is_dirty` is not set; the next `syncAll()` retry will attempt it again as long as `image_path != null && image_url == null`.
- **Edit flow â€” change detection**: `AddEditProductScreen` tracks `_imageChanged: bool`. `updateProduct()` only receives `imagePath` when `_imageChanged == true`; when it does, the repository also sets `image_url = null` so the sync service detects a new upload is needed.
- **Server orphan cleanup**: `inventory.service.ts â†’ updateImage()` fetches the product before updating, then fire-and-forget `unlink`s the old image file after the DB write succeeds. No disk accumulation from repeated image edits.

### Stock Movements

- **No local cache**. Always fetched from server.
- Offline adjustments embed expiration date in the note field as `"<reason> (expires: YYYY-MM-DD)"`.

---

## 8. Constants Reference

### Product Categories (`kProductCategories`)
```
Snacks, Drinks, Cigarettes, Toiletries, Condiments, Canned Goods,
Instant Noodles, Coffee & Tea, Candies, Dairy, Bread & Pastries,
Frozen, Medicine, Others
```

### Units (`kProductUnits`)
```
pc, pack, bottle, box, sachet, can, kilo, gram, liter, dozen, bundle, tray
```

### Shelf Locations (`kShelfLocations`)  â† **Now fully surfaced in UI**
```
Counter, Shelf A, Shelf B, Shelf C, Fridge, Cigarette Area, Near Door, Storage
```
Used in: `AddEditProductScreen` dropdown, `InventoryFilterSheet` location chips, `_GroupedShelfView` grouping key, `product_cards.dart` shelf badge.

### Stock Adjustment Reasons (`kStockAdjustmentReasons`)
```
Restock         â†’ movementType = RESTOCK
Sale Adjustment â†’ movementType = SALE
Damage          â†’ movementType = ADJUSTMENT
Theft           â†’ movementType = ADJUSTMENT
Expired         â†’ movementType = ADJUSTMENT
Manual Count    â†’ movementType = ADJUSTMENT
Others          â†’ movementType = ADJUSTMENT
```

---

## 9. UI Component Reference

### InventoryScreen
- **AppBar**: search, filter (with active-filter dot badge), view-toggle (listâ†”grid), bulk-select.
- **_SummaryHeader**: Total Products, Total Stock, Low Stock, Out of Stock.
- **_CategoryChips**: Horizontal quick-filter row.
- **List mode** â†’ `_GroupedShelfView`: products grouped by `shelfLocation`, each group is a collapsible `_ShelfSection` with a location header chip. **This replaced the flat `ListView.separated`.**
- **Grid mode** â†’ `ProductGridCard` 2-column `GridView`.
- **FAB**: "Add Product" (hidden in bulk-select mode).

### AddEditProductScreen
- **Image section** (top of form): `_ImagePickerWidget` â€” 88Ã—88 preview box wrapped in `Hero(tag: 'product_image_hero')`, Gallery and Camera buttons, Remove button when image is set.
  - Tapping the thumbnail when an image exists opens `_ImageReviewScreen` instead of the gallery.
- **`_ImageReviewScreen`** (fullscreenDialog route): black background, transparent AppBar, `Hero` wrapping `InteractiveViewer(maxScale: 5.0)` for pinch-to-zoom, gradient bottom bar with **Change Photo** (OutlinedButton â†’ gallery flow) and **Retake** (FilledButton â†’ camera flow) buttons. Returns a `_ImageReviewAction` enum value.
- **Image change tracking**: `_imageChanged` flag; only passes `imagePath` to `updateProduct()` when the user actually changed the image. Prevents unnecessary re-uploads on every edit save.
- **Shelf Location section**: `_dropdown()` using `kShelfLocations`.
- Barcode scan via `_BarcodeScannerScreen`.
- `DuplicateSkuException` dialog with restock flow.

### ProductListTile / ProductGridCard (`product_cards.dart`)
- **Image display** (`_ProductImage` widget): checks `product.imagePath` (local `File`) â†’ `product.imageUrl` (network) â†’ falls back to `_ProductIcon` (category-based icon).
- **Shelf badge**: `_MiniChip` with `Icons.shelves` showing `product.shelfLocation` (list tile + grid card info section).

### QuickStockSheet
- Unchanged from original implementation.

### StockHistoryScreen
- Unchanged from original implementation.

### InventoryFilterSheet (`showInventoryFilterSheet`)
Three filter sections (top â†’ bottom):
1. **Category** â€” chips from `kProductCategories` (+ "All" chip)
2. **Location** â€” chips from `kShelfLocations` (+ "All" chip) â† **NEW**
3. **Stock Alerts** â€” Low Stock Only / Out of Stock Only toggles

### FlutterCropScreen (`lib/shared/camera/flutter_crop_screen.dart`)
- Shared Flutter-native full-screen crop screen; used by `GuidedCameraService.pickFromGallery()`.
- Built with `crop_your_image ^2.0.0` â€” renders entirely in Flutter's widget tree, so `SafeArea` handles system-bar insets correctly (no UCrop toolbar overlap).
- Features: black background, CloseButton AppBar, pinch-to-zoom (`interactive: true`), locked aspect ratio, loading spinner while bytes decode.
- Bottom row: **Cancel** (OutlinedButton) + **Crop** (FilledButton, white); spinner replaces button label while cropping.
- On `CropSuccess`: writes bytes to a temp `.jpg` file and pops with the `File`. On `CropFailure`: shows a SnackBar and re-enables the Crop button.
- API: `Navigator.push<File?>(context, MaterialPageRoute(builder: (_) => FlutterCropScreen(file: f, aspectRatio: 1.0)))`.

### GuidedCameraService â€” Camera Flash Modes
- Flash cycles: `off â†’ torch â†’ off` (auto mode removed â€” caused white overexposed images on Camera2).
- `torch` keeps the LED on continuously so the sensor AE calibrates before the shot.
- A **300 ms delay** is inserted before `takePicture()` when torch is active to allow AE to settle.
- `setFlashMode()` is NOT called inside `_capture()` (calling it resets the AE pipeline).

### ProductImageService (`product_image_service.dart`)
Thin wrapper around `GuidedCameraService` scoped to inventory.
```dart
ProductImageService.instance.pickAndCompress(
  syncId: '...',
  context: context,  // required for both camera AND gallery (gallery needs context for FlutterCropScreen)
  useCamera: false,  // true â†’ guided camera; false â†’ gallery + FlutterCropScreen
)
// â†’ compressed WebP File saved to <documents>/product_images/<syncId>.webp
// â†’ null if user cancels
```
Uses: `image_picker ^1.1.2`, `flutter_image_compress ^2.3.0`, `crop_your_image ^2.0.0`.
Target format: WebP, max 600Ã—600 px, quality 85.

---

## 10. Extension Points & Change Guidance

### Adding a new product field
1. Add column to `_createTtProductsTable`; add `if (oldVersion < N)` migration block in `onUpgrade`.
2. Add field to `InventoryProduct` (`fromLocalDb`, `fromJson`, `toJson`, `copyWith`).
3. Update `LocalInventoryRepository.createProduct()` and `updateProduct()` maps.
4. Update `CreateProductDto` / `UpdateProductDto` on server.
5. Update `schema.prisma` and run `npx prisma db push` (or `migrate dev`).
6. Update sync push payload and pull values map in `sync_service.dart`.
7. Add UI input in `AddEditProductScreen`.

### Upgrading image storage to DigitalOcean Spaces
1. Create `do-spaces-storage.provider.ts` implementing `IStorageProvider`.
2. Use the DO Spaces SDK to upload `file.buffer` to the configured bucket.
3. In `inventory.module.ts`, replace `LocalStorageProvider` with `DoSpacesStorageProvider`.
4. Update `STORAGE_PROVIDER` registration â€” no changes needed in the controller or service.
5. Update the `image_url` value in `inventory.service.ts` `updateImage()` to use the returned CDN URL.

### Adding a new stock movement type
1. Add to `StockMovementType` enum in `schema.prisma`.
2. Add to `kStockAdjustmentReasons` in `inventory_constants.dart`.
3. Update `_reasonToType()` in `quick_stock_sheet.dart`.
4. Update movement tile icon/color in `stock_history_screen.dart`.

### Adding a new filter type
1. Add field to `InventoryFilterState` + `copyWith`.
2. Add toggle/setter to `InventoryFilterNotifier`.
3. Update `filteredProductsProvider` derivation.
4. Update `hasActiveFilters` getter.
5. Add UI control in `inventory_filter_sheet.dart`.

### Changing sync behavior
- Push logic: `sync_service.dart` â†’ `_syncTtProducts()` push section.
- Pull logic: same function, pull section â€” look for the `values` map.
- Image upload: `_pushProductImage()` private method in `SyncService`.

### Adding offline movement caching
- Currently `getMovementsForProduct` always calls the API.
- To cache: add `tt_stock_movements` SQLite table, write movements during `adjustStock()`, fall back to cache when API call fails.

---

## 11. Key File Paths (Quick Reference)

| Concern | File |
|---|---|
| Local SQLite schema (v16) | [lib/core/database/app_database.dart](tinda_track/lib/core/database/app_database.dart) |
| Sync push/pull + image upload | [lib/core/sync/sync_service.dart](tinda_track/lib/core/sync/sync_service.dart) |
| Product model (local) | [lib/tinda_tracker/features/inventory/data/models/inventory_product.dart](tinda_track/lib/tinda_tracker/features/inventory/data/models/inventory_product.dart) |
| Stock movement model | [lib/tinda_tracker/features/inventory/data/models/stock_movement.dart](tinda_track/lib/tinda_tracker/features/inventory/data/models/stock_movement.dart) |
| Local repository | [lib/tinda_tracker/features/inventory/data/local_inventory_repository.dart](tinda_track/lib/tinda_tracker/features/inventory/data/local_inventory_repository.dart) |
| Image pick + compress service | [lib/tinda_tracker/features/inventory/data/product_image_service.dart](tinda_track/lib/tinda_tracker/features/inventory/data/product_image_service.dart) |
| Constants (categories, units, shelf locations) | [lib/tinda_tracker/features/inventory/data/inventory_constants.dart](tinda_track/lib/tinda_tracker/features/inventory/data/inventory_constants.dart) |
| Riverpod providers | [lib/tinda_tracker/features/inventory/providers/inventory_providers.dart](tinda_track/lib/tinda_tracker/features/inventory/providers/inventory_providers.dart) |
| Main screen (grouped shelf view) | [lib/tinda_tracker/features/inventory/screens/inventory_screen.dart](tinda_track/lib/tinda_tracker/features/inventory/screens/inventory_screen.dart) |
| Add/edit screen (image + shelf) | [lib/tinda_tracker/features/inventory/screens/add_edit_product_screen.dart](tinda_track/lib/tinda_tracker/features/inventory/screens/add_edit_product_screen.dart) |
| Stock history screen | [lib/tinda_tracker/features/inventory/screens/stock_history_screen.dart](tinda_track/lib/tinda_tracker/features/inventory/screens/stock_history_screen.dart) |
| Product cards (image-first) | [lib/tinda_tracker/features/inventory/widgets/product_cards.dart](tinda_track/lib/tinda_tracker/features/inventory/widgets/product_cards.dart) |
| Quick stock widget | [lib/tinda_tracker/features/inventory/widgets/quick_stock_sheet.dart](tinda_track/lib/tinda_tracker/features/inventory/widgets/quick_stock_sheet.dart) |
| Filter sheet (location section) | [lib/tinda_tracker/features/inventory/widgets/inventory_filter_sheet.dart](tinda_track/lib/tinda_tracker/features/inventory/widgets/inventory_filter_sheet.dart) |
| **Shared Flutter crop screen** | [lib/shared/camera/flutter_crop_screen.dart](tinda_track/lib/shared/camera/flutter_crop_screen.dart) |
| Guided camera screen | [lib/shared/camera/guided_camera_screen.dart](tinda_track/lib/shared/camera/guided_camera_screen.dart) |
| Guided camera service | [lib/shared/camera/guided_camera_service.dart](tinda_track/lib/shared/camera/guided_camera_service.dart) |
| Storage provider interface | [tinda_track_server_nest/src/core/storage/storage-provider.interface.ts](tinda_track_server_nest/src/core/storage/storage-provider.interface.ts) |
| Local storage implementation | [tinda_track_server_nest/src/core/storage/local-storage.provider.ts](tinda_track_server_nest/src/core/storage/local-storage.provider.ts) |
| Server controller (image endpoint) | [tinda_track_server_nest/src/tinda_tracker/modules/inventory/inventory.controller.ts](tinda_track_server_nest/src/tinda_tracker/modules/inventory/inventory.controller.ts) |
| Server service (orphan cleanup) | [tinda_track_server_nest/src/tinda_tracker/modules/inventory/inventory.service.ts](tinda_track_server_nest/src/tinda_tracker/modules/inventory/inventory.service.ts) |
| Prisma schema | [tinda_track_server_nest/prisma/schema.prisma](tinda_track_server_nest/prisma/schema.prisma) |
| Server entry point (static assets) | [tinda_track_server_nest/src/main.ts](tinda_track_server_nest/src/main.ts) |

