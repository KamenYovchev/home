#!/usr/bin/env bash

sp_name=$1
password=$2
tennant=$3
subscription=$4
resource_group=$5
env_name=$6
app_svc="-app-svc-"
app_insights="-app-insights-"
applications=("fe-app")

az login  -u $sp_name  -p $sp_password
az account set --subscription $subscription
az config set extension.use_dynamic_install=yes_without_prompt


linkAppInsights() {
    apps=("$@")
    for app in "${apps[@]}" ; do
        instrumentationKey=$(az monitor app-insights component show --app $app$app_insights$env_name --resource-group $resource_group --query  "instrumentationKey" --output tsv)
        az webapp config appsettings set --name $app$app_svc$env_name --resource-group $resource_group --settings APPINSIGHTS_INSTRUMENTATIONKEY=$instrumentationKey APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$instrumentationKey ApplicationInsightsAgent_EXTENSION_VERSION=~2
        az webapp config appsettings set -n $app$app_svc$env_name -g $resource_group --settings "XDT_MicrosoftApplicationInsights_Mode=recommended" "APPINSIGHTS_PROFILERFEATURE_VERSION=1.0.0" "APPINSIGHTS_SNAPSHOTFEATURE_VERSION=1.0.0" "DiagnosticServices_EXTENSION_VERSION=~3" "InstrumentationEngine_EXTENSION_VERSION=~1" "SnapshotDebugger_EXTENSION_VERSION=~1" "WEBSITE_HTTPLOGGING_RETENTION_DAYS=7" "XDT_MicrosoftApplicationInsights_BaseExtensions=~1"
    done
}
linkAppInsights "${applications[@]}"
