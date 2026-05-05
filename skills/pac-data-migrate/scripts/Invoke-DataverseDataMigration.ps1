<#
.SYNOPSIS
    Migrates data from a Dataverse table between two Power Platform environments.
    The CMT schema is built automatically via pac modelbuilder — no manual field input required.

.PARAMETER SourceEnvUrl
    URL of the source environment, e.g. https://contoso-dev.crm.dynamics.com/

.PARAMETER TargetEnvUrl
    URL of the target environment, e.g. https://contoso-tst.crm.dynamics.com/

.PARAMETER TableName
    Logical name of the Dataverse table, e.g. account, cr123_mytable

.PARAMETER OutputDir
    Directory for temporary files. Default: $env:USERPROFILE\pac-data-export
#>
param(
    [Parameter(Mandatory)] [string] $SourceEnvUrl,
    [Parameter(Mandatory)] [string] $TargetEnvUrl,
    [Parameter(Mandatory)] [string] $TableName,
    [string] $OutputDir = "$env:USERPROFILE\pac-data-export"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Type mapping: AttributeLogicalNameAttribute return type → CMT schema type ─
# See references/cmt-type-mapping.md for background
function Get-CmtType([string]$fieldName, [string]$csContent, [string]$primaryIdField) {
    if ($fieldName -eq $primaryIdField) { return "guid" }

    # CMT-specific types for fixed system fields
    if ($fieldName -eq "ownerid")    { return "owner" }
    if ($fieldName -eq "statecode")  { return "state" }
    if ($fieldName -eq "statuscode") { return "status" }

    # Locate the C# type via the AttributeLogicalNameAttribute
    $attrEsc = [regex]::Escape($fieldName)
    $pattern = '\[Microsoft\.Xrm\.Sdk\.AttributeLogicalNameAttribute\("' + $attrEsc +
               '"\)\]\s+public(\s+virtual|\s+override)?\s+([\w\.\?<>]+)'
    $match = [regex]::Match($csContent, $pattern)
    if (-not $match.Success) { return "string" }

    $modifier = $match.Groups[1].Value.Trim()
    $rawType  = $match.Groups[2].Value.Trim()

    if ($modifier -eq 'virtual')                              { return "optionsetvalue" }
    if ($rawType  -match 'EntityReference')                   { return "lookup" }
    if ($rawType  -match 'Nullable.*Guid|^Guid$')             { return "guid" }
    if ($rawType  -match 'Nullable.*DateTime|^DateTime$')     { return "datetime" }
    if ($rawType  -match 'Nullable.*Int64|^Int64$|^long\?$')  { return "bigint" }
    if ($rawType  -match 'Nullable.*Int|^Int|^int\?$')        { return "number" }
    if ($rawType  -match 'Nullable.*[Dd]ecimal|^decimal\?$')  { return "decimal" }
    if ($rawType  -match 'string')                            { return "string" }
    return "string"
}

# ── Step 1: Modelbuilder — retrieve field metadata ────────────────────────────
$modelDir = "$OutputDir\modelbuilder-$TableName"
New-Item -ItemType Directory -Path $modelDir -Force | Out-Null

Write-Host "`n[1/4] Retrieving field metadata for '$TableName' from $SourceEnvUrl ..."
pac modelbuilder build `
    --outdirectory       $modelDir `
    --entitynamesfilter  $TableName `
    --emitfieldsclasses `
    --language           CS `
    --environment        $SourceEnvUrl | Out-Null

$csFile = Get-ChildItem -Path "$modelDir\Entities" -Filter "${TableName}.cs" -ErrorAction SilentlyContinue |
          Select-Object -First 1
if (-not $csFile) {
    $csFile = Get-ChildItem -Path $modelDir -Filter "*.cs" -Recurse |
              Where-Object { $_.Name -ne "EntityOptionSetEnum.cs" } |
              Select-Object -First 1
}
if (-not $csFile) { throw "No entity .cs file found in $modelDir. Verify the table logical name is correct." }

$csContent = Get-Content $csFile.FullName -Raw

# ── Step 2: Extract field names — scoped to the Fields struct ─────────────────
$fieldsStructMatch = [regex]::Match(
    $csContent,
    'public partial class Fields\s*\{([\s\S]+?)\}',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if (-not $fieldsStructMatch.Success) { throw "No Fields struct found in $($csFile.FullName)" }

$fieldMatches = [regex]::Matches(
    $fieldsStructMatch.Groups[1].Value,
    'public const string \w+ = "(\w+)";'
)
$allFieldNames = $fieldMatches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

# Audit/computed fields that cannot be migrated
$skipFields = @(
    "createdby", "modifiedby", "createdonbehalfby", "modifiedonbehalfby",
    "owningbusinessunit", "owningteam", "owninguser", "versionnumber"
)
$fieldNames = $allFieldNames | Where-Object { $_ -notin $skipFields }

# ── Step 3: Determine primary fields ─────────────────────────────────────────
$primaryIdField   = "${TableName}id"
$publisherPrefix  = ($TableName -split '_')[0]

$primaryNameField = $fieldNames | Where-Object { $_ -eq "${publisherPrefix}_name" } | Select-Object -First 1
if (-not $primaryNameField) {
    $primaryNameField = $fieldNames |
        Where-Object { $_ -match '_name$' -and $_ -ne $primaryIdField } |
        Select-Object -First 1
}
if (-not $primaryNameField) { $primaryNameField = "name" }

Write-Host "    Primary ID    : $primaryIdField"
Write-Host "    Primary name  : $primaryNameField"
Write-Host "    Fields found  : $($fieldNames.Count)"

# ── Step 4: Build schema.xml ──────────────────────────────────────────────────
$fieldLines = foreach ($fn in $fieldNames) {
    $cmtType = Get-CmtType $fn $csContent $primaryIdField
    $pkAttr  = if ($fn -eq $primaryIdField) { ' primaryKey="true"' } else { '' }
    "      <field displayname=""$fn"" name=""$fn"" type=""$cmtType""$pkAttr />"
}

$schemaXml = @"
<?xml version="1.0" encoding="utf-8"?>
<entities>
  <entity name="$TableName" displayname="$TableName" etc="10000" primaryidfield="$primaryIdField" primarynamefield="$primaryNameField" disableplugins="false">
    <fields>
$($fieldLines -join "`n")
    </fields>
    <relationships />
    <m2mrelationships />
  </entity>
</entities>
"@

$schemaFile = "$OutputDir\schema-$TableName.xml"
$dataFile   = "$OutputDir\data-$TableName.zip"

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Set-Content -Path $schemaFile -Value $schemaXml -Encoding UTF8
Write-Host "`n[2/4] Schema written to $schemaFile"

# ── Step 5: Export ────────────────────────────────────────────────────────────
Write-Host "`n[3/4] Exporting from $SourceEnvUrl ..."
Remove-Item $dataFile -Force -ErrorAction SilentlyContinue

$exportResult = pac data export `
    --schemaFile  $schemaFile `
    --dataFile    $dataFile `
    --environment $SourceEnvUrl 2>&1

$exportResult | Write-Host
if ($LASTEXITCODE -ne 0) {
    throw "Export failed. Check the schema at $schemaFile and the error output above."
}

# ── Step 6: Import ────────────────────────────────────────────────────────────
Write-Host "`n[4/4] Importing into $TargetEnvUrl ..."
pac data import `
    --data        $dataFile `
    --environment $TargetEnvUrl

Write-Host "`nDone! Data for '$TableName' successfully migrated from $SourceEnvUrl to $TargetEnvUrl."
