# Troubleshooting

## Export fails: "schema validation failed for missing fields"

**Cause**: A field in `schema.xml` does not exist on the entity, or its type is incorrect.

**Fix**:
1. Inspect the generated `schema-<tablename>.xml` in `$env:USERPROFILE\pac-data-export\`
2. Compare against the Web API metadata:
   ```
   https://<org>/api/data/v9.2/EntityDefinitions(LogicalName='<table>')/Attributes?$select=LogicalName,AttributeTypeName
   ```
3. Remove the offending field from the schema and rerun.

---

## Export fails: "The file already exists"

**Cause**: `--overwrite` does not work correctly in the current PAC CLI version.

**Fix**: Remove the zip manually:
```powershell
Remove-Item "$env:USERPROFILE\pac-data-export\data-<table>.zip" -Force
```
The script does this automatically.

---

## Import: records created but fields are empty

**Cause**: The schema only contained the primary key — fields were not included.

**Fix**: Inspect the generated schema.xml before exporting. Re-run the script after deleting the empty records in the target environment.

---

## Import: some rows fail (lookup fields)

**Cause**: Records referenced via a lookup do not yet exist in the target environment.

**Fix**: Migrate the parent table first, then the dependent table.

---

## "No Fields struct found"

**Cause**: `pac modelbuilder build` did not generate `--emitfieldsclasses` output, or the table name is incorrect.

**Fix**:
1. Verify the table name is the correct logical name (lowercase, with publisher prefix).
2. Run `pac modelbuilder build` manually and inspect the generated `.cs` file.

---

## "Missing Comparison Key" warnings during import

**Cause**: Informational warning — the import tool cannot match an existing record by name for comparison. Not critical if the record count is correct.

**Effect**: None — records are still created or updated based on GUID.
