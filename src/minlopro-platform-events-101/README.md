# 📡 Platform Events 101 (POC)

A small, self-contained POC for getting hands-on with three Platform Event (PE) mechanics that are
hard to internalize from docs alone:

1. **PE trigger/callback Apex classes** — the handler pattern that reacts to a published event.
2. **Retryable PEs/exceptions** — an _unhandled_ exception thrown out of a PE trigger causes the
   Event Bus to automatically retry that trigger invocation.
3. **Resume checkpoints** — `EventBus.TriggerContext.setResumeCheckpoint()`, letting a trigger mark
   a batch as durably processed up to a point, so a later retry doesn't reprocess it.

**Use case:** a pseudo car dealership. `Car__c` is the inventory; `CarSaleEvent__e` represents a
sale. A playground LWC composes and publishes sale events, and a trigger handler is meant to react
to them by decrementing inventory — that handler logic is the actual point of the exercise.

## 🧱 What's built

**`Car__c`** — inventory object, 7 seed records.

- `Model__c` (Text, required, unique)
- `QuantityAvailable__c` (Number, required) + validation rule `QuantityAvailable_Cannot_Be_Negative`

**`CarSaleEvent__e`** — the Platform Event.

- `Model__c` (Text) — matched against `Car__c.Model__c`
- `QuantitySold__c` (Number, required)
- `SetCheckpoint__c` (Checkbox) — ask the handler to call `setResumeCheckpoint()` after this row
- `ThrowException__c` (Checkbox) — force the handler to throw on this row, to exercise retry on demand

**`platformEvents101Tab`** — the playground LWC (Platform Events 101 tab):

- A datatable to compose a batch of `CarSaleEvent__e` payloads (Model, Quantity Sold, Set
  Checkpoint, Throw Exception), published via `CarSalePlaygroundController.publishCarSaleEvents()`
  (`EventBus.publish()`, batched — needed since checkpoint/retry only make sense across multiple
  events in one `Trigger.new`).
- A Car Inventory grid with a quick-edit modal for manually adjusting `QuantityAvailable__c`.
- An embedded Log Monitor to watch handler output live as events are published.

Two triggers are wired up via the `TriggerDispatcher`/`BasicTriggerHandler` framework
(`CarSaleEventTrigger` → `TH_CarSaleEvent_ProcessSale`, `CarTrigger` →
`TH_Car_LogInventoryChanges`), but both handlers are still placeholders — see below.

## 🎯 Next up

**Build the actual trigger handler logic** — this is the whole point of the exercise:

- `TH_CarSaleEvent_ProcessSale`: match each event's `Model__c` to a `Car__c`, decrement
  `QuantityAvailable__c`, let exceptions escape unhandled (unknown model, oversell validation rule,
  or an explicit `ThrowException__c` row) so the Event Bus retries for real, and call
  `setResumeCheckpoint()` for rows flagged `SetCheckpoint__c`.
- `TH_Car_LogInventoryChanges`: log a meaningful message when `QuantityAvailable__c` actually
  changes.
- Cover both with real Apex tests (seed / oversell / unknown-model / explicit-throw / checkpoint
  scenarios), replacing the current single-method stubs.
- **Once the handler logic is done**, revisit the `description`/`inlineHelpText` on the
  `CarSaleEvent__e` fields so they describe actual behavior instead of forward-looking intent.
