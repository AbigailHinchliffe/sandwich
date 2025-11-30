You are an expert Flutter engineer. I have a small sandwich-shop Flutter app (Dart) with two pages: an Order screen and a Cart screen. The app currently has these models and repositories:

- Sandwich: contains a sandwich type (enum), size flag (six-inch vs footlong), and bread type (enum).
- Cart: a ChangeNotifier-like model with methods addItem, removeOneAt(index), removeItemAt(index), clear; tracks items and calculates total price.
- PricingRepository: calculates prices based on quantity and size only (not on sandwich type or bread).

Goal
Implement a complete, well-tested set of cart-editing features so users can modify items already in the cart. For each feature below, provide a clear specification of UI elements, user interactions, expected data changes, visual feedback, and tests to validate the behavior. Focus on deterministic, simple behavior that integrates with the existing Cart model and PricingRepository.

Features to specify
1. Change quantity (increment/decrement)
- UI:
  - In the Cart screen, each cart row shows item summary, current quantity, and two small buttons: "−" (decrement) and "+" (increment). Buttons must be accessible (have Keys) e.g. `Key('cart_inc_<index>')` and `Key('cart_dec_<index>')`.
  - If the cart is shown as a popup/dialog, ensure rows scroll if there are many items.
- Behavior:
  - Tapping "+" increases that item's quantity by 1 (up to a sensible max, e.g., 10). Tapping "−" decreases by 1. If the quantity becomes 0 after decrement, the item is removed from the cart (or ask the user if they want to remove — choose one behavior and state it).
  - Updating quantity updates the Cart model, notifies listeners, and recalculates the cart total using PricingRepository.
- Visual feedback:
  - Immediately update the displayed quantity and total price.
  - Optionally show a SnackBar: "Updated quantity to N" for 1-2 seconds.
- Edge cases:
  - Hitting the max should disable the "+" button; hitting 0 removes the item.
  - Rapid taps should be debounced at the UI layer to avoid visual jitter (briefly disable buttons while the update is being applied if updates involve async work).
- Tests:
  - Unit tests for Cart: increment and decrement methods update quantities and total price; decrement to 0 removes item.
  - Widget tests: tapping the inc/dec buttons updates the UI and the `Key('cart_summary')` text shows new totals. Include tests for hitting max and removing at 0.

2. Remove item entirely
- UI:
  - Each cart row has a "trash" icon button: `Key('cart_remove_item_<index>')`.
  - Optionally: long-press on a row opens a confirmation dialog before removal.
- Behavior:
  - Tap the trash button immediately removes that item from the cart.
  - If you show a confirmation dialog on long-press, the dialog contains "Remove" and "Cancel". "Remove" deletes; "Cancel" leaves it.
- Visual feedback:
  - Update list and total instantly. Show SnackBar "Removed item" with an "Undo" action that restores the item.
- Edge cases:
  - Undo should only be available for a short window (e.g., 3-5 seconds). If multiple removals occur, either stack undos in LIFO or apply a single undo scope — pick one and document it.
- Tests:
  - Widget test: tap trash button removes the row and updates `cart_summary`. Test that tapping Undo in the SnackBar restores it.

3. Edit item details (size, bread, notes)
- UI:
  - Each cart row has an "edit" icon: `Key('cart_edit_<index>')`.
  - Tapping "edit" opens a modal bottom sheet or dedicated edit screen containing the Order controls: sandwich type (dropdown), size switch, bread dropdown, quantity, and notes text field prefilled with the item data.
  - The edit screen has "Save" and "Cancel" buttons (keys: `Key('edit_save')`, `Key('edit_cancel')`).
- Behavior:
  - "Save" modifies the existing cart item (not a new item) and recalculates price. "Cancel" discards changes.
  - If quantity is changed to zero in the editor, treat as removal or prevent zero and require at least 1. Prefer preventing zero (validation) to avoid accidental deletions.
- Visual feedback:
  - After saving, updated row and totals reflect changes; show SnackBar "Updated item".
- Edge cases:
  - Concurrent edits: if two screens can edit simultaneously, choose a last-writer-wins approach; warn in the UI or disable opening multiple editors for the same item.
  - Validation: ensure quantity >= 1 and <= max, notes length limited (e.g., 200 chars).
- Tests:
  - Widget test: open the editor, change fields, tap Save, assert the row and summary update.
  - Test Cancel: open editor, change fields, tap Cancel, assert no change.

4. Bulk actions (optional / advanced)
- UI:
  - Provide "Clear cart" button with confirmation dialog.
  - Provide "Remove all of type" if applicable.
- Behavior:
  - Clear cart empties items and resets total to 0; show SnackBar with Undo.
- Tests:
  - Widget and unit test for Clear + Undo flow.

Integration and API detail
- Use only the existing Cart ChangeNotifier and PricingRepository. Do not change the PricingRepo API. Integrate by calling Cart methods (e.g., updateQuantityAt(index, newQty) or documented sequence: removeOneAt/ addItem/modify directly and call notifyListeners). If the Cart lacks an update method, provide a minimal, backward-compatible change: add updateItemAt(index, CartItem) and ensure it notifies listeners.
- Ensure each actionable widget has a deterministic Key to make widget tests stable. Use the pattern `Key('cart_<action>_<index>')`.
- All UI updates should be synchronous from the widget side unless network calls are involved (none are). If you add async code, gate buttons with progress indicators and handle cancellation.

Accessibility
- Buttons must have semantic labels and tooltips.
- Provide adequate tappable area and text contrast.
- Support keyboard navigation for desktop/web.

Testing checklist to include in the implementation ticket
- Unit tests:
  - Cart.addItem merges like items.
  - Cart.updateQuantityAt increments/decrements and removes when 0.
  - Cart.totalPrice uses PricingRepository rates after changes.
- Widget tests:
  - Cart screen shows initial items and total.
  - Increment and decrement buttons visibly change quantity and total.
  - Remove icon removes item and updates total; Undo restores item.
  - Edit flow saves changes to the same item; Cancel discards.
  - Clear cart empties and updates totals; Undo restores.
- Integration test (optional):
  - Add an item from Order screen, open Cart, edit item, assert correct final total.

Deliverable format
Return a single, copy-paste friendly implementation prompt for an LLM containing:
- A one-paragraph context about the app and existing models/repo.
- The features list above, each with UI, behavior, feedback, edge-cases, and tests.
- Precise Key names to use for widget tests.
- Minimal API contract if Cart needs one small method added (signature suggestion and behavior).
- Short example of a widget test (4–8 lines) that asserts increment updates total — this is optional but helpful.

Notes and preferences
- Keep behavior deterministic and simple (prevent zero quantity in editor; remove by decrement to zero or explicit remove button).
- Prefer immediate UI feedback and SnackBars for confirmable actions with Undo.
- Make keys explicit and stable to make tests reliable.