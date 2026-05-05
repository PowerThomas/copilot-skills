# CMT Field Type Mapping

The Configuration Migration Tool (CMT) uses its own type names that differ from the Dataverse Web API and C# SDK types.
This reference describes the mapping applied by the migration script.

## Type Mapping Table

| CMT type        | C# SDK type / pattern                    | Example fields                      |
|-----------------|------------------------------------------|-------------------------------------|
| `guid`          | `Nullable<Guid>`, primary key            | `*id`, lookup id fields             |
| `string`        | `string`                                 | text fields, names                  |
| `number`        | `Nullable<int>`, `Nullable<Int32>`       | whole numbers                       |
| `bigint`        | `Nullable<Int64>`, `long?`               | large whole numbers                 |
| `decimal`       | `Nullable<decimal>`                      | decimal numbers                     |
| `datetime`      | `Nullable<DateTime>`                     | `createdon`, `modifiedon`           |
| `lookup`        | `EntityReference`                        | lookup fields (e.g. `parentid`)     |
| `optionsetvalue`| `virtual` modifier (OptionSet enum)      | choice fields (not state/status)    |
| `owner`         | fixed system field `ownerid`             | `ownerid`                           |
| `state`         | fixed system field `statecode`           | `statecode`                         |
| `status`        | fixed system field `statuscode`          | `statuscode`                        |

## Important Notes

- **`owner`, `state`, `status`** are CMT-specific types. They must **not** be declared as `optionsetvalue` or `lookup` — schema validation will fail.
- **`--overwrite` is broken** in the current PAC CLI version: delete the .zip manually before re-exporting. The script handles this automatically.
- The `etc` attribute in `<entity>` must be a number (`10000` works as a placeholder); an empty string causes a deserialization error.
- Fields that are **not migratable** and are skipped: `createdby`, `modifiedby`, `createdonbehalfby`, `modifiedonbehalfby`, `owningbusinessunit`, `owningteam`, `owninguser`, `versionnumber`.

## Quick schema lookup via browser

Navigate to (while logged in):

```
https://<org>.crm.dynamics.com/api/data/v9.2/EntityDefinitions(LogicalName='<tablename>')/Attributes?$select=LogicalName,DisplayName,AttributeTypeName&$orderby=LogicalName
```

Returns JSON with all field names and types — useful for verification.
