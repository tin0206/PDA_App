# API Contract (PDA Ingredient Scanning)

## Base URL
- Read from `.env`
- Example:
  - `API_BASE_URL=http://<host>:<port>`

## Common Response Envelope

### Success
```json
{
  "Message": "Success",
  "Data": {}
}
```

### Fail
```json
{
  "Message": "Fail",
  "Error": "Error detail"
}
```

---

## 1) POST `/getTankInfo`
### Function
Resolve tank identity info from scanned tank number.

### Request
```json
{
  "TankNumber": "T05T01"
}
```

### Success Response
```json
{
  "Message": "Success",
  "Data": {
    "ProductionOrder": "PO-20260314-001",
    "BatchNumber": "BATCH-T05T01-01",
    "RecipeName": "IND_SOLVENT_A",
    "RecipeVersion": "2.3",
    "ProductCode": "PRD-ACETONE-A",
    "ProductName": "Industrial Solvent A",
    "Shift": "A",
    "PlannedStart": "2026-03-15T06:00:00Z"
  }
}
```

---

## 2) POST `/getRecipeDetails`
### Function
Get ingredient list by `ProductionOrder` + `BatchNumber`.

### Request
```json
{
  "ProductionOrder": "PO-20260314-001",
  "BatchNumber": "BATCH-T05T01-01"
}
```

### Success Response
```json
{
  "Message": "Success",
  "Data": {
    "ingredients": [
      {
        "IngredientCode": "ING-001",
        "IngredientName": "Acetone",
        "Quantity": 50.0,
        "UnitOfMeasurement": "Kgs"
      },
      {
        "IngredientCode": "ING-002",
        "IngredientName": "Ethanol",
        "Quantity": 12.0,
        "UnitOfMeasurement": "Kgs"
      }
    ]
  }
}
```

---

## 3) POST `/ingredient-scan/complete`
### Function
Called when one ingredient reaches target in tolerance (`target ± 0.1kg`).
Server stores all scan records of that ingredient for this tank.

### Request
```json
{
  "TankNumber": "T05T01",
  "ProductionOrder": "PO-20260314-001",
  "BatchNumber": "BATCH-T05T01-01",
  "IngredientCode": "ING-001",
  "IngredientName": "Acetone",
  "TargetQty": 50.0,
  "ActualQty": 49.95,
  "Scans": [
    {
      "ItemCode": "ING-001",
      "Weight": 20.0,
      "Lot": "LOT-20260315-01",
      "WeightBatch": "CAN001",
      "LabelId": "LBL0001",
      "ScannedAt": "2026-03-15T08:31:15.123Z"
    },
    {
      "ItemCode": "ING-001",
      "Weight": 29.95,
      "Lot": "LOT-20260315-01",
      "WeightBatch": "CAN002",
      "LabelId": "LBL0002",
      "ScannedAt": "2026-03-15T08:34:11.010Z"
    }
  ]
}
```

### Success Response
```json
{
  "Message": "Success",
  "Data": {
    "IngredientCode": "ING-001",
    "SavedScanCount": 2,
    "AcceptedQty": 49.95
  }
}
```

---

## 4) POST `/tank-transfer/complete`
### Function
Called when user confirms full tank transfer completion after all ingredients are done.

### Request
```json
{
  "TankNumber": "T05T01",
  "ProductionOrder": "PO-20260314-001",
  "BatchNumber": "BATCH-T05T01-01",
  "Status": "Completed",
  "CompletedAt": "2026-03-15T09:05:00.000Z"
}
```

### Success Response
```json
{
  "Message": "Success",
  "Data": {
    "TankNumber": "T05T01",
    "Status": "Completed"
  }
}
```

### Fail Response (example)
```json
{
  "Message": "Fail",
  "Error": "Endpoint /tank-transfer/complete not found"
}
```

---

## 5) (Future) POST `/label/check`
### Function
Optional future API to validate whether a `LabelId` was scanned before (cross-tank, cross-shift, etc.).
Current app still blocks duplicate label IDs in local session memory.

### Suggested Request
```json
{
  "LabelId": "LBL0002",
  "TankNumber": "T05T01",
  "ProductionOrder": "PO-20260314-001",
  "BatchNumber": "BATCH-T05T01-01"
}
```

### Suggested Success Response
```json
{
  "Message": "Success",
  "Data": {
    "AlreadyUsed": false,
    "LastUsedAt": null
  }
}
```

---

## Barcode Rules (Implemented in app)

### Tank barcode format
- `AIT10 <TankNumber>`

### Ingredient barcode format
- `AIT01 <itemCode> <weight> <Lot> <weightBatch> <labelId>`

### Ingredient validation flow
1. `itemCode` must exist in ingredient list.
2. App auto-focuses to matched ingredient by `itemCode`.
3. `labelId` must not duplicate in current tank session.
4. If cumulative scanned qty for ingredient is:
   - `< target - 0.1`: keep scanning.
   - `within target ± 0.1`: mark ingredient completed and call `/ingredient-scan/complete`.
   - `> target + 0.1`: show error and clear all local records of that ingredient.

### Tank completion flow
- After all ingredients completed, app opens completion screen.
- On confirm button, app calls `/tank-transfer/complete`.
