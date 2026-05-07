---
name: pac-flow-dev
description: 'Develop and deploy Power Automate cloud flows via PAC CLI and mini-solutions. Use when: modifying cloud flow JSON, creating new cloud flows, importing flows to Dataverse, working with Power Platform solution packaging, editing Power Automate flow definitions locally. Covers the full roundtrip: create mini-solution, add flow, export, edit JSON, pack, import.'
argument-hint: 'Describe the flow change or provide a flow GUID and solution context'
---

# Power Automate Flow Development via PAC CLI

Develop and deploy Power Automate cloud flows by editing their JSON definition locally, using a lightweight mini-solution for fast import/export cycles. This avoids exporting the entire main solution (which can be slow and contain many unrelated components).

## When to Use

- Modifying an existing cloud flow's definition (actions, triggers, connections)
- Creating a new cloud flow from a JSON definition
- Bulk-editing flow expressions or action parameters
- Debugging flow logic by inspecting the raw JSON
- Any scenario where the Power Automate designer is too limited

## Prerequisites

- `pac` CLI installed and authenticated (`pac auth create`)
- An active auth profile pointing to the target environment (`pac auth select`)
- The flow must exist in Dataverse (either already created or to be created via the mini-solution)

Verify with: `pac auth list` and `pac org who`

## Procedure

### Phase 1 — Set Up Mini-Solution

If you already have a mini-solution folder with `Other/Solution.xml` and `Other/Customizations.xml`, skip to Phase 2.

**1a. Create minimal solution folder:**

```
<SolutionName>/
├── Other/
│   ├── Solution.xml
│   └── Customizations.xml
```

The `Solution.xml` must contain:
- `generatedBy="CrmLive"` attribute on root element (required by SolutionPackager)
- A `<Publisher>` block matching the target environment's publisher (same `UniqueName` and `CustomizationPrefix`)
- A unique `<UniqueName>` for the mini-solution

See [Solution.xml template](./references/solution-xml-template.md) for a minimal working template.

The `Customizations.xml` can be empty with just the standard element stubs. See [Customizations.xml template](./references/customizations-xml-template.md).

**1b. Pack and import to create the solution in Dataverse:**

```powershell
pac solution pack --zipfile "<name>.zip" --folder "<folder>" --packagetype Unmanaged
pac solution import --path "<name>.zip"
```

**1c. Add the target flow to the mini-solution:**

```powershell
pac solution add-solution-component --solutionUniqueName "<SolutionName>" --component "<Flow-GUID>" --componentType 29
```

Component type `29` = Workflow (includes cloud flows).

> To find the flow GUID: open the flow in make.powerapps.com → the GUID is in the URL. Alternatively, export and unpack the main solution — the flow JSON filename contains the GUID: `<FlowName>-<GUID>.json`.

### Phase 2 — Export and Unpack

```powershell
pac solution export --name "<SolutionName>" --path "<name>_export.zip"
pac solution unpack --zipfile "<name>_export.zip" --folder "<folder>"
```

This produces:
```
<folder>/
├── Other/
│   ├── Solution.xml
│   └── Customizations.xml
└── Workflows/
    ├── <FlowName>-<GUID>.json           # The flow definition
    └── <FlowName>-<GUID>.json.data.xml  # Flow metadata
```

### Phase 3 — Edit the Flow JSON

The `.json` file contains the full flow definition including:
- `properties.definition` — triggers, actions, expressions
- `properties.connectionReferences` — connector bindings
- `properties.parameters` — parameter definitions

Common edits:
- **Actions**: Add/modify/remove actions in `definition.actions`
- **Expressions**: Change filter expressions, compose values, conditions
- **Connection references**: Update `runtimeSource` (`"embedded"` vs `"invoker"`)
- **Variables**: Add/modify in `Initialize_variable` actions

> **Important**: The JSON uses Power Automate expression syntax with `@{...}` interpolation. Ensure JSON escaping is correct — expressions inside string values must be properly escaped.

### Phase 4 — Pack and Import

```powershell
pac solution pack --zipfile "<name>.zip" --folder "<folder>" --packagetype Unmanaged
pac solution import --path "<name>.zip" --force-overwrite
```

> **Note**: Importing a flow deactivates it. You must manually reactivate it in the environment after import.

### Phase 5 — Iterate or Clean Up

For subsequent edits, repeat Phase 3–4 only. No need to re-export unless you want to pick up changes made in the designer.

When done, optionally delete the mini-solution (this does NOT delete the flow, it only removes the solution container):

```powershell
pac solution delete --solution-name "<SolutionName>"
```

## Flow JSON Structure Reference

```
{
  "properties": {
    "definition": {
      "$schema": "...",
      "contentVersion": "1.0.0.0",
      "triggers": { ... },
      "actions": { ... },
      "outputs": { ... }
    },
    "connectionReferences": {
      "<ConnectionRefName>": {
        "connectionName": "...",
        "source": "Invoker",          // or "Embedded"
        "id": "/providers/Microsoft.PowerApps/apis/<api-name>",
        "tier": "Standard"
      }
    },
    "parameters": { ... }
  },
  "schemaVersion": "1.0.0.0"
}
```

## Key Component Type IDs

| Type | ID | Description |
|------|-----|-------------|
| Workflow | 29 | Cloud flows, classic workflows, business process flows |
| Entity | 1 | Dataverse tables |
| OptionSet | 9 | Global choice columns |
| WebResource | 61 | JavaScript, HTML, CSS, images |
| PluginAssembly | 91 | .NET plugins |
| Role | 20 | Security roles |
| CanvasApp | 300 | Canvas apps |
| EnvironmentVariableDefinition | 380 | Environment variables |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `generatedBy` missing error on pack | Add `generatedBy="CrmLive"` to `<ImportExportXml>` in Solution.xml |
| `does not exist` on add-solution-component | Verify the GUID is correct and the flow exists in the environment |
| `component not declared as root component` on import | The mini-solution doesn't exist in Dataverse yet. First import the empty mini-solution (without Workflows/), then `add-solution-component`, then export+unpack to get the correct structure, then edit and import with `--force-overwrite`. |
| Flow deactivated after import | Expected — manually reactivate in make.powerapps.com or the model-driven app |
| Expression parsing errors | Check JSON escaping — `@` expressions inside strings need proper quoting |
| Publisher mismatch | The mini-solution publisher must match or be compatible with the flow's publisher prefix |

## Quick Command Reference

```powershell
# Full roundtrip (first time)
pac solution pack --zipfile "Mini.zip" --folder "MiniFolderPath" --packagetype Unmanaged
pac solution import --path "Mini.zip"
pac solution add-solution-component --solutionUniqueName "MiniName" --component "<GUID>" --componentType 29
pac solution export --name "MiniName" --path "Mini_export.zip"
pac solution unpack --zipfile "Mini_export.zip" --folder "MiniFolderPath"
# ... edit JSON ...
pac solution pack --zipfile "Mini.zip" --folder "MiniFolderPath" --packagetype Unmanaged
pac solution import --path "Mini.zip" --force-overwrite

# Subsequent edits (just pack + import)
# ... edit JSON ...
pac solution pack --zipfile "Mini.zip" --folder "MiniFolderPath" --packagetype Unmanaged
pac solution import --path "Mini.zip" --force-overwrite

# Clean up mini-solution (flow stays in Dataverse)
pac solution delete --solution-name "MiniName"
```
