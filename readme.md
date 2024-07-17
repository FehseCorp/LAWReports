
# get-datasources.ps1

This script is used to query all log analytics workspaces in a tenant and look for legacy data sources. It will output the workspace name, subscription Id, resource group, and data sources that are not supported in the new log analytics query language.

Usage example:

```powershell ./get-datasources -outputfile 'file.csv'```

Dependencies:
- Az module
- Powershell

Using the Azure CLI in Powershell mode is recommended.
