
# parameters for script
# name of output file
param (
    [string]$outputfile="datasources.csv",
    [switch]$debug
)
$datasourcelist=@(
# 'AzureActivityLog'
# 'ChangeTrackingContentLocation'
# 'ChangeTrackingCustomPath'
# 'ChangeTrackingDataTypeConfiguration'
# 'ChangeTrackingDefaultRegistry'
# 'ChangeTrackingPath'
# 'ChangeTrackingRegistry'
# 'CustomLog'
# 'DnsAnalytics'
'IISLogs'
# 'ImportComputerGroup'
#'LinuxChangeTrackingPath'
'LinuxPerformanceCollection'
'LinuxPerformanceObject'
'LinuxSyslog'
# 'NetworkMonitoring'
'SecurityEventCollectionConfiguration'
'SecurityWindowsBaselineConfiguration'
'WindowsEvent'
'WindowsPerformanceCounter'
'WindowsTelemetry')
$subs=get-azsubscription
$currentsub=(Get-AzContext).Subscription.Id
"Worskpace,Subscription,ResourceGroup,DataSources" | Out-File -FilePath $outputfile
"Current subscription is $currentsub"
foreach ($sub in $subs) {
    # get log analytis workspaces for subscription
    if ($sub.Id -ne $currentsub) {
        Set-AzContext -SubscriptionId $sub.Id | Out-Null
        "Switched to $($sub.Name) subscription."
        $currentsub=$sub.Id
    }
    $workspaces = Get-AzResource -ResourceType "Microsoft.OperationalInsights/workspaces" 
    # get data sources for each workspace
    #add
    $token=(Get-AzAccessToken).Token
    $header=@{
        Authorization = "Bearer $token"
    }
    foreach ($ws in $workspaces) {
        # $URI="https://management.azure.com/subscriptions/$($sub.Id)/resourceGroups/$($ws.ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($ws.Name)/dataSources?%24filter=kind%20eq%20%27windowsPerformanceCounter%27%20or%20kind%20eq%20%27WindowsEvent%27%20or%20kind%20eq%20%27IISLogs%27%20or%20kind%20eq%20%27LinuxPerformanceObject%27%20or%20kind%20eq%20%27LinuxSyslog%27or%20kind%20eq%20%27WindowsTelemetry%27%20%27LinuxSyslogCollection%27%20%27LinuxPerformanceCollection%27&api-version=2020-08-01"
        $dscount=0
        $dsfoundlist=@()
        foreach ($dstype in $datasourcelist) {

            $URI="https://management.azure.com/subscriptions/$($sub.Id)/resourceGroups/$($ws.ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($ws.Name)/dataSources?%24filter=kind%20eq%20%27$dstype%27&api-version=2020-08-01"
            $datasourcesfound=(Invoke-RestMethod -Method GET -Uri $URI -Headers $header)
            $dsfoundcount=$datasourcesfound.value.Count
            if ($dsfoundcount -gt 0) {
                # add found DS kind to a list
                $dsenabled=$true
                if ($datasourcesfound.value.properties.Enabled) {
                    if (($datasourcesfound.value.properties.Enabled | select-object -unique) -eq "false") {
                        if ($debug) {"Datasource $($datasourcesfound.value.name) is disabled."}
                        $dsenabled=$false
                    }
                }
                if ($dsenabled) {
                    if ($debug) {"Datasource $($datasourcesfound.value.name) is enabled."}
                    $dscount++
                    $dsfoundlist+=$datasourcesfound.value.kind | select-object -Unique
                }
            }
        }
        if ($dscount -gt 0) {
            "Found $dscount datasource types in $($ws.Name) workspace."
            # convert list to string
            $dsfoundlist=$dsfoundlist -join ","
            "$($ws.name),$($ws.SubscriptionId),$($ws.ResourceGroupName),""$dsfoundlist""" | Out-File -FilePath $outputfile -Append
            # foreach ($ds in $datasources.value) {
            #     $ds.kind | select-object -Unique
            # }
        }
        else {
            "No datasources found in $($ws.Name) workspace."
            "$($ws.name),$($ws.SubscriptionId),$($ws.ResourceGroupName),""No datasources found""" | Out-File -FilePath $outputfile -Append
        }
    }
    #Invoke-AzRestMethod -SubscriptionId $
    #GET https://management.azure.com/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourcegroups/loganalytics/providers/Microsoft.OperationalInsights/workspaces/mseye/dataSources?%24filter=kind%20eq%20%27windowsPerformanceCounter%27%20or%20kind%20eq%20%27WindowsEvent%27%20or%20kind%20eq%20%27IISLogs%27%20or%20kind%20eq%20%27LinuxPerformanceObject%27%20or%20kind%20eq%20%27LinuxSyslog%27&api-version=2020-08-01
}

<# 
kind eq 'windowsPerformanceCounter' or kind eq 'WindowsEvent' or kind eq 'IISLogs' or kind eq 'LinuxPerformanceObject' or kind eq 'LinuxSyslog'
#>