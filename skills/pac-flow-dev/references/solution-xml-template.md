# Solution.xml Template

Minimal `Solution.xml` for a mini-solution. Place in `<SolutionFolder>/Other/Solution.xml`.

Replace the placeholders:
- `{{SOLUTION_UNIQUE_NAME}}` — e.g. `MyFlowMiniSolution`
- `{{SOLUTION_DISPLAY_NAME}}` — e.g. `My Flow Mini Solution`
- `{{PUBLISHER_UNIQUE_NAME}}` — must match existing publisher in Dataverse
- `{{PUBLISHER_DISPLAY_NAME}}` — e.g. `Contoso Ltd`
- `{{PUBLISHER_PREFIX}}` — e.g. `contoso`
- `{{PUBLISHER_OPTION_VALUE_PREFIX}}` — numeric, e.g. `10001`

```xml
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2" SolutionPackageVersion="9.2" languagecode="1033" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <SolutionManifest>
    <UniqueName>{{SOLUTION_UNIQUE_NAME}}</UniqueName>
    <LocalizedNames>
      <LocalizedName description="{{SOLUTION_DISPLAY_NAME}}" languagecode="1033" />
    </LocalizedNames>
    <Descriptions />
    <Version>1.0.0.0</Version>
    <Managed>0</Managed>
    <Publisher>
      <UniqueName>{{PUBLISHER_UNIQUE_NAME}}</UniqueName>
      <LocalizedNames>
        <LocalizedName description="{{PUBLISHER_DISPLAY_NAME}}" languagecode="1033" />
      </LocalizedNames>
      <Descriptions />
      <EMailAddress xsi:nil="true"></EMailAddress>
      <SupportingWebsiteUrl xsi:nil="true"></SupportingWebsiteUrl>
      <CustomizationPrefix>{{PUBLISHER_PREFIX}}</CustomizationPrefix>
      <CustomizationOptionValuePrefix>{{PUBLISHER_OPTION_VALUE_PREFIX}}</CustomizationOptionValuePrefix>
      <Addresses>
        <Address>
          <AddressNumber>1</AddressNumber>
          <AddressTypeCode>1</AddressTypeCode>
          <City xsi:nil="true"></City>
          <County xsi:nil="true"></County>
          <Country xsi:nil="true"></Country>
          <Fax xsi:nil="true"></Fax>
          <FreightTermsCode xsi:nil="true"></FreightTermsCode>
          <ShippingMethodCode xsi:nil="true"></ShippingMethodCode>
          <Telephone1 xsi:nil="true"></Telephone1>
          <Telephone2 xsi:nil="true"></Telephone2>
          <Telephone3 xsi:nil="true"></Telephone3>
          <PostalCode xsi:nil="true"></PostalCode>
          <StateOrProvince xsi:nil="true"></StateOrProvince>
          <Street xsi:nil="true"></Street>
        </Address>
      </Addresses>
    </Publisher>
    <RootComponents />
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
```
