# Cart Modification Feature Requirements

## Overview

This document specifies the requirements for adding cart modification capabilities to the Sandwich Shop Flutter app. The app already includes an Order screen (where users select sandwiches) and a Cart screen (where users view items and total price). The Cart model and PricingRepository already exist: the Cart manages items and totals, and PricingRepository computes prices based on quantity and size only.

Purpose: allow users to modify items already in their cart without leaving the Cart screen. Modifications include changing item quantity, removing items, and editing item details (size, bread, notes). The goal is to make cart editing intuitive, accessible, testable, and robust.

---

## Feature description

Name: Cart Item Modification

Primary capabilities:
- Increment/decrement quantity for each cart item.
- Remove an item entirely.
- Edit item details (size, bread, notes — optionally sandwich type if desired).
- Clear the cart (bulk action) with confirmation and undo.
- Provide immediate visual feedback and undoable removal actions.

Constraints and assumptions:
- PricingRepository determines price from quantity and size only; sandwich type and bread do not affect price.
- The Cart is implemented as a ChangeNotifier-like model with add/remove methods. If an `updateItemAt(index, CartItem)` method is missing, the implementation may add one with minimal, backward-compatible behavior.
- UI must expose deterministic Keys for all actionable widgets to support widget tests.
- All UI updates should be synchronous (no network calls). If async is needed later, UI should show progress and remain responsive.

---

## User stories

### 1. As a shopper, I want to change the quantity of an item in my cart so I can buy multiple sandwiches without re-adding them.

- Given I have at least one item in my cart,
- When I tap the "+" button on that item,
- Then the item quantity increments by 1 (up to a max of 10), the Cart model is updated, the total price updates immediately, and a brief SnackBar confirms the change.

- Given I have at least one item in my cart,
- When I tap the "−" button on that item,
- Then the item quantity decrements by 1. If the quantity becomes 0, remove the item from the cart and show a SnackBar with an Undo action.

### 2. As a shopper, I want to remove an item entirely from the cart so I can discard unwanted items quickly.

- Given I have items in my cart,
- When I tap the trash icon on an item,
- Then the item is removed instantly, the total price updates, and a SnackBar with an Undo action appears.

- Alternate behavior (optional): long-press the item to show a confirmation dialog before removal.

### 3. As a shopper, I want to edit details of a cart item (size, bread, notes) so I can correct my order without re-creating it.

- Given I have an item in my cart,
- When I tap the edit icon on the item,
- Then an editor (modal bottom sheet or full screen) opens with controls prefilled from the item: size switch, bread dropdown, notes text field, and quantity control.

- When I tap Save, the item is updated in-place, the total price is recalculated, and a SnackBar confirms the update.
- When I tap Cancel (or close the editor), no changes are applied.

### 4. As a shopper, I want to clear my entire cart when I decide to start over.

- When I tap "Clear cart",
- Then show a confirmation dialog. If confirmed, clear the cart, update totals to zero, and present a SnackBar with Undo.

---

## Acceptance criteria

The feature is considered complete when all the following are satisfied.

### UI & behavior
1. Each cart row displays:
   - Item summary (quantity, bread, sandwich type name)
   - Quantity controls: decrement `Key('cart_dec_<index>')` and increment `Key('cart_inc_<index>')`.
   - Remove button `Key('cart_remove_item_<index>')`.
   - Edit button `Key('cart_edit_<index>')`.

2. Increment/decrement behavior:
   - Increment increases quantity up to a configurable max (default 10). When max is reached, the increment button is disabled.
   - Decrement decreases quantity. If quantity becomes 0, the item is removed and a SnackBar with an Undo action shows; pressing Undo restores the item.
   - The Cart model's item count and `totalPrice()` reflect changes immediately.

3. Remove behavior:
   - Tapping the remove button deletes the item and shows a SnackBar with Undo. Undo restores the exact item state (quantity, notes, size, bread).
   - If an optional confirmation dialog is enabled, the remove button bypasses the dialog (immediate), but long-press shows confirmation.

4. Edit behavior:
   - Editor opens with prefilled fields for the selected item.
   - Save updates the existing item (no new item added), notifies listeners, and recalculates totals.
   - Cancel discards edits.
   - Editor validates quantity >= 1 and <= max.

5. Bulk actions:
   - Clear cart triggers a confirmation dialog. Confirming clears the cart and shows a SnackBar with Undo.

6. Accessibility:
   - All interactive elements have tooltips and semantic labels.
   - Tappable areas meet minimum size guidance and color contrast is sufficient.

### Keys and testability
- All interactive widgets mentioned above have deterministic Keys as specified to support widget tests:
  - `Key('cart_inc_<index>')`, `Key('cart_dec_<index>')`, `Key('cart_remove_item_<index>')`, `Key('cart_edit_<index>')`, `Key('cart_summary')`.

### API contract
- If Cart lacks an update method, add a single method with the signature:

```dart
void updateItemAt(int index, CartItem newItem)
```

- Behavior: replace the item at `index` with `newItem`, call `notifyListeners()`, and ensure `totalPrice()` uses PricingRepository consistently.

### Tests
- Unit tests (Cart model):
  - addItem merges identical items.
  - updateItemAt updates item fields and total price.
  - removeOneAt decrements quantity or removes when zero.
  - removeItemAt removes the full item.
  - clear() empties the cart and totalPrice() becomes 0.

- Widget tests:
  - The Cart screen shows initial items and `Key('cart_summary')` reflecting correct totals.
  - Tapping `Key('cart_inc_<0>')` increments item 0 and updates `cart_summary` total.
  - Tapping `Key('cart_dec_<0>')` decrements item 0; if reaches zero the row disappears and Undo restores it.
  - Tapping `Key('cart_remove_item_<0>')` removes item 0; Undo restores it.
  - Tapping `Key('cart_edit_<0>')` opens editor; changing size or notes and tapping Save updates row and totals; tapping Cancel preserves original.
  - Clearing the cart via Clear button removes all items and shows Undo.

### Performance and robustness
- UI operations must be immediate and not cause jank. Button presses should not cause frame drops.
- Handle rapid repeated taps gracefully (either by debouncing or by relying on the Cart model to handle atomic updates).

---

## Subtasks (implementation plan)

1. Add missing keys and test hooks to `lib/main.dart` (if not already present): `cart_summary`, `cart_inc_<index>`, `cart_dec_<index>`, `cart_remove_item_<index>`, `cart_edit_<index>`.
2. Add `updateItemAt(int index, CartItem newItem)` to `lib/models/cart.dart` if missing.
3. Implement increment/decrement buttons in cart UI and wire to Cart methods.
4. Implement Remove button + SnackBar Undo.
5. Implement Edit flow (modal bottom sheet or screen) and wire Save/Cancel.
6. Add Clear cart UI + confirm dialog + Undo.
7. Add/adjust widget tests and unit tests to cover all acceptance criteria.
8. Manual accessibility pass: add semantic labels, tooltips, and verify tappable areas.

---

## Open decisions / questions
- Should the decrement-to-zero behavior remove the item automatically, or should the decrement button be disabled at 1 and require explicit remove? The acceptance criteria assume decrement-to-zero removes the item but the editor prevents zero. If you prefer to prevent zero everywhere, update the acceptance criteria accordingly.
- Undo semantics: should we allow multiple undo actions to stack, or only one undo at a time? The document assumes a single, short-lived undo per removal.

---

## Sign-off
- The feature is complete when all acceptance criteria and tests pass. After implementation, run the full test suite and perform a manual exploratory UI pass to verify Undo, SnackBars, and editor behavior.
