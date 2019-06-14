using module .\Modules\adoBuildDefinitions.psm1
using module .\Entities\AdoInfo.psm1
using module .\Entities\GitItemParams.psm1

function Update-BuildDefinitions {
    <#
    .EXAMPLE
        see readme.

    .NOTES
        Author: Sven Ansem
        Last Edit: 2019-02-01
        Version 1.0 - initial release
    #>
    [CmdletBinding()]
    Param(
        [Parameter(mandatory=$true, position=0)]
        [string]$accountName,
        [Parameter(mandatory=$true, position=1)]
        [string]$projectName,
        [Parameter(mandatory=$true, position=2)]
        [string[]]$repositoryNames,
        [Parameter(mandatory=$false, position=3)]
        [bool]$displayDebugMessages=$false,
        [Parameter(mandatory=$false, position=4)]
        [string]$user="",
        [Parameter(mandatory=$true, position=5)]
        [string]$token,

        [Parameter(mandatory=$true, position=6)]
        [string]$buildDefinitionPath,
        [Parameter(mandatory=$true, position=7)]
        [string]$templateFile,
        # [Parameter(mandatory=$false, position=8)]
        # [bool]$deleteAllFirst=$false,

        [Parameter(mandatory=$true, position=8)]
        [string]$gitfilesPath,
        [Parameter(mandatory=$false, position=9)]
        [string]$filterPath,
        [Parameter(mandatory=$false, position=10)]
        [string]$branch,
        [Parameter(mandatory=$false, position=11)]
        [int]$topItems=0 #have smaller set for debugging
    )
    Try {
        Write-Debug "[Update-BuildDefinitions] Init"
        $componentsIgnore = @('utils', 'xxx.json', 'yyy.json', '_cicd', '.azuredevops')
        #include file with functions
        Import-Module $PSScriptRoot\..\Generic\Generic-Functions.ps1 -Force
        Set-DebugPreference($displayDebugMessages)
        $global:DebugPrintApiUrls = $false

        $objAdoInfo = [adoInfo]::new($accountName, $projectName, $repositoryNames, $user, $token)
        $objGitItemParams = [GitItemParams]::new($gitfilesPath, $filterPath, $branch, $topItems, $componentsIgnore)
        $objBuildDefinitions = [adoBuildDefinitions]::new($objAdoInfo)

        # if ($deleteAllFirst -eq $true) {
        #     $objBuildDefinitions.DeleteAll($buildDefinitionPath)
        # }
        $objBuildDefinitions.CreateMissingOrUpdate($buildDefinitionPath, $templateFile, "-PR", $objGitItemParams)
    }
    Catch {
        Write-Error -Message "[Update-BuildDefinitions] [ERROR] Exception Message: $($_.Exception.Message)"
    }
    Finally {
        Set-DebugPreference($false)
        $global:DebugPrintApiUrls = $false
        Write-Debug "[Update-BuildDefinitions] Done!"
    }
}

function Export-BuildDefinition {
    <#
    .EXAMPLE
        see readme

    .NOTES
        Author: Sven Ansem
        Last Edit: 2019-02-01
        Version 1.0 - initial release
    #>
    [CmdletBinding()]
    Param(
        [Parameter(mandatory=$true, position=0)]
        [string]$accountName,
        [Parameter(mandatory=$true, position=1)]
        [string]$projectName,
        [Parameter(mandatory=$true, position=2)]
        [string[]]$repositoryNames,
        [Parameter(mandatory=$false, position=3)]
        [bool]$displayDebugMessages=$false,
        [Parameter(mandatory=$false, position=4)]
        [string]$user="",
        [Parameter(mandatory=$true, position=5)]
        [string]$token,

        [Parameter(mandatory=$true, position=6)]
        [string]$buildDefinitionPath,
        [Parameter(mandatory=$true, position=7)]
        [int]$idBuildDefinition,
        [Parameter(mandatory=$true, position=8)]
        [string]$componentName,
        [Parameter(mandatory=$false, position=9)]
        [string]$dropFolder,
        [Parameter(mandatory=$false, position=10)]
        [bool]$doStripProperties=$true
    )
    Try {
        Write-Debug "[Export-BuildDefinition] Init"

        #include file with functions
        Import-Module $PSScriptRoot\..\Generic\Generic-Functions.ps1 -Force
        Set-DebugPreference($displayDebugMessages)
        $global:DebugPrintApiUrls = $true

        $objAdoInfo = [adoInfo]::new($accountName, $projectName, $repositoryNames, $user, $token)
        $objBuildDefinitions = [adoBuildDefinitions]::new($objAdoInfo)
        $objBuildDefinitions.Export($dropFolder, $idBuildDefinition, $componentName, $buildDefinitionPath, $doStripProperties)
    }
    Catch {
        Write-Error -Message "[ReGenerate-BuildDefinition] [ERROR] Exception Message: $($_.Exception.Message)"
    }
    Finally {
        Set-DebugPreference($false)
        $global:DebugPrintApiUrls = $false
        Write-Debug "[ReGenerate-BuildDefinitions] Done!"
    }
}
