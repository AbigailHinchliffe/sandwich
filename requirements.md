# Sandwich Shop App - Feature Requirements

## Cart Modification ✅

**Capabilities:** Increment/decrement quantity, remove items, edit details (size, bread, notes), clear cart with undo
**Keys:** `increment_${index}`, `decrement_${index}`, `remove_${index}`, `edit_${index}`, `clear_cart`
**Status:** Complete

---

## Checkout Screen ✅

**Capabilities:** Display order summary, process payment (2s simulation), generate order confirmation, auto-clear cart
**Keys:** `checkout_button` (in CartScreen)
**Behavior:** Shows items, total, payment method. Returns order ID + estimated time, navigates back to Order screen
**Status:** Complete

---

## Profile Screen ✅

**Capabilities:** Edit name, email and phone, save with validation, cancel without saving
**Keys:** `profile_name`, `profile_email`, `profile_phone`, `profile_save`, `profile_cancel`, `open_profile` (navigation)
**Navigation:** Accessible from Order screen bottom link "Open Profile"
**Validation:** Name is required (cannot be empty)
**Status:** Complete

---

## About Screen ✅

**Route:** `/about`
**Content:** Static "Welcome to Sandwich Shop!" message with business description
**Status:** Complete (no navigation trigger in UI yet)

---

## Navigation Flow

```
OrderScreen (/)
├─> CartScreen → CheckoutScreen → (auto) back to OrderScreen
├─> ProfileScreen → Cancel/Save → back to OrderScreen
└─> AboutScreen (/about) → back
```

**Cart workflow:** Order → Cart (shows items) → Checkout → Payment → Confirmation SnackBar → Cart cleared → Return to Order

---

## Detailed Requirements (Cart Modification only)

### User stories

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
- UI operations must be immediate and not cause jank
- Handle rapid repeated taps gracefully

---

## Implementation Notes

All features are complete and tested. Cart model supports `updateItemAt(int index, CartItem newItem)` for in-place edits.

---


## New feature: Profile screen (draft)

AI assistant prompt (for the feature):
"As a product manager, add a simple Profile screen to the Sandwich Shop app where users can view and edit their name, email, and phone number. No authentication or persistence is required for this exercise — saving should simply show a confirmation (SnackBar) and close the screen. The screen must be reachable from the Order screen via a link/button at the bottom. Provide deterministic Keys for every interactive widget to support widget tests, and include widget tests verifying the fields and Save behavior."

Acceptance details (append):
- Add Profile screen UI:
  - Fields: Email (Key: 'profile_email'), Phone (Key: 'profile_phone').
  - Actions: Save (Key: 'profile_save') — validates basic non-empty name and shows SnackBar "Profile saved" and pops; Cancel (Key: 'profile_cancel') — pops without changes.
- Navigation:
  - OrderScreen includes a link/button at the bottom: "Open Profile" (Key: 'open_profile') that pushes ProfileScreen.
- Tests:
  - Widget tests must assert the presence of fields and keys.
  - Test that entering values and pressing Save shows the SnackBar "Profile saved".
- No persistence required for now.

