---
name: pac-data-migrate
description: "Migrate data from a Dataverse table between Power Platform environments using PAC CLI. Use when: copying data between environments, migrating a table from dev to tst/acc/prd, synchronizing reference data, running PAC data export/import. Asks interactively for source environment, target environment, and table name. Automatically builds the CMT schema via pac modelbuilder. No manual intervention required."
argument-hint: "Optional: provide the table logical name directly, e.g. 'account'"
---

# PAC Data Migrate

Exports data from a Dataverse table in a source environment and imports it into a target environment. The CMT schema is built fully automatically via `pac modelbuilder` — no need to manually specify field names.

## When to Use

- Copy data between Power Platform environments (dev → tst, dev → acc, etc.)
- Synchronize reference/lookup tables
- One-time or recurring data migration tasks
- When you want to run `pac data export` / `pac data import` without manually crafting a schema.xml

## Prerequisites

- `pac` CLI installed and authenticated (`pac auth list`)
- Access to both source and target environments
- PowerShell 5.1+ or PowerShell Core

## Procedure

### Step 1 — List and select environments

List available auth profiles and environments:

```powershell
pac auth list
pac env list
```

Ask the user for:
1. **Source environment** — which URL or profile?
2. **Target environment** — which URL or profile? (must differ from source)
3. **Table name** — logical name of the Dataverse table (e.g. `account`, `cr123_mytable`)

> Show the available environments from `pac auth list` as options. Use the active profile as the default source unless the user specifies otherwise.

### Step 2 — Auto-build schema and run export/import

Run the migration script with the provided parameters:

```powershell
& "$env:USERPROFILE\.copilot\skills\pac-data-migrate\scripts\Invoke-DataverseDataMigration.ps1" `
    -SourceEnvUrl "<source-url>" `
    -TargetEnvUrl "<target-url>" `
    -TableName    "<table-logical-name>"
```

The script automatically:
1. Runs `pac modelbuilder build` → retrieves all field names and types from the C# proxy
2. Builds a `schema.xml` with correct CMT types (see [type mapping](./references/cmt-type-mapping.md))
3. Runs `pac data export` from the source environment
4. Runs `pac data import` into the target environment

Output files are written to `$env:USERPROFILE\pac-data-export\`.

### Step 3 — Verify

After completion, confirm:
- Script reports `Done! Data for '<table>' successfully migrated.`
- No errors in the import output
- Record count matches between source and target

For errors, see [troubleshooting](./references/troubleshooting.md).

## Limitations and Notes

- **Lookup fields**: referenced records must already exist in the target environment, otherwise those rows will fail silently.
- **Duplicates**: if records already exist in the target (same GUID), they will be updated (upsert behavior).
- **Multiple tables**: run the script multiple times in the correct order — parent tables first, then dependent tables.
- **`--overwrite` bug**: the existing output zip must be removed before re-exporting. The script handles this automatically.
- **Audit fields** (`createdby`, `modifiedby`, etc.) are intentionally excluded from the schema — they are not migratable.
