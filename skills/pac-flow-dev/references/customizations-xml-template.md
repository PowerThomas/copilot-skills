# Customizations.xml Template

Minimal `Customizations.xml` for a mini-solution. Place in `<SolutionFolder>/Other/Customizations.xml`.

```xml
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Entities />
  <Roles />
  <Workflows />
  <FieldSecurityProfiles />
  <Templates />
  <EntityMaps />
  <EntityRelationships />
  <OrganizationSettings />
  <optionsets />
  <CustomControls />
  <EntityDataProviders />
  <Languages>
    <Language>1033</Language>
  </Languages>
</ImportExportXml>
```

Add additional `<Language>` elements if your environment uses multiple languages (e.g. `<Language>1043</Language>` for Dutch).
