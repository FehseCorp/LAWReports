
# get-lawdatasources.ps1

This script is used to query all log analytics workspaces in a tenant and look for legacy data sources. It will output the workspace name, subscription Id, resource group, and data sources that are not supported in the new log analytics query language.

Usage example:

```./get-datasources -outputfile 'file.csv'```

Dependencies:

- Az module
- Powershell

Using the Azure CLI in Powershell mode is recommended.

Instructions:
Open an Azure CLI session and run the following command:

```(invoke-webrequest -URI https://raw.githubusercontent.com/FehseCorp/LAWReports/main/get-lawdatasources.ps1).content | out-file get-lawdatasources.ps1```

Then run the script with the desired output file name.

```./get-lawdatasources.ps1```

Then run the script with the desired output file name.
