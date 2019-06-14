<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with class with different functions to gather information and/or perform operations relating Build Definitions in Azure Devops

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
using module ..\Entities\AdoInfo.psm1
using module ..\Entities\GitItemParams.psm1
using module ..\Entities\BuildDefinitions.psm1
using module .\adoGitItems.psm1

class adoBuildDefinitions {
    [AdoInfo]$AdoInfo

    # Cstor
    adoBuildDefinitions([AdoInfo]$adoInfo)
    {
        $this.AdoInfo = $adoInfo
        Write-Debug "[adoBuildDefinitions] Init"
    }

    <#
    .DESCRIPTION
        Function which Export the supplied Build Definition, so it can be used to make a template of it.

    .PARAMETER PROPERTY dropFolder
        Location where to store the build definition

    .PARAMETER PROPERTY idBuildDefinition
        Id of the build definition which must be exported

    .PARAMETER PROPERTY componentName
        Name of the component. So the text in the build defintion can be replaced by a tag so it can be used as template.

    .PARAMETER PROPERTY buildDefinitionPath
        Path which will used to replace in the build definition

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [void]Export([string]$dropFolder, [int]$idBuildDefinition, [string]$componentName, [string]$buildDefinitionPath, [bool]$doStrip) {
        Try {
            $url = $this.AdoInfo.AzureDevopsApiUrls.GetUrlBuildDefinition($idBuildDefinition)

            $buildDefinition = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.AdoInfo.Base64AuthInfo)}
            $propertiesToRemove = @('comment', '_links', 'authoredBy', 'url', 'uri', 'createdDate', 'options')
            if ($doStrip -eq $true) {
                ForEach($prop in $propertiesToRemove) {
                    $buildDefinition.PSObject.Properties.Remove($prop)
                }
            }
            $timeStamp = (Get-Date).ToString("yyyyMMdd_HHmm")
            $file = "$PSScriptRoot\..\$($dropFolder)\template_build_defintition_$($this.AdoInfo.RepositoryNames[0])_$($timeStamp)_id_$($idBuildDefinition).json"

            $buildDefinition.path = $buildDefinitionPath
            $buildDefinition.name = "|BuildDefinitionName|"
            $jsonBody = $buildDefinition | ConvertTo-Json -depth 100
            $jsonBody.Replace($componentName, '|componentName|') | Out-File $file
            Write-Debug "Build Definition '$($buildDefinition.name)' exported to '$($file)'."

            Write-Debug "[Export] Build Definition '$($buildDefinition.name)' exported to '$($file)'."
        }
        Catch {
            Write-Error -Message "[Export] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[Export] Done!"
        }
    }

    <#
    .DESCRIPTION
        Function which Create a build definition based on a template. Template can be made with the Export function

    .PARAMETER PROPERTY templateFile
        Filename of the template which must be used to generate the build definition

    .PARAMETER PROPERTY suffixNameBuildDef
        Which suffix (-PR or -CI or...) must be added to the name of the  build definition

    .PARAMETER PROPERTY componentName
        Name of the component. So the tag in the template can be replaced by the name of the component.

    .PARAMETER PROPERTY buildDefinitionPath
        Path where to store the build definition in Azure DevOps

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [void]Create([string]$jsonBody) {
        Try {

            $url = $this.AdoInfo.AzureDevopsApiUrls.CreateBuildDefinition()
            $buildDefinition = $this.AdoInfo.CallRestMethodPost($url, $jsonBody)
            Write-Debug "[Create] Build Definition: $($buildDefinition.name) is created!"
        }
        Catch {
            Write-Error -Message "[Create] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[Create] Done!"
        }
    }

<#
    .DESCRIPTION
        Function which UPDATES a build definition based on a template. Template can be made with the Export function

    .PARAMETER PROPERTY templateFile
        Filename of the template which must be used to generate the build definition

    .PARAMETER PROPERTY suffixNameBuildDef
        Which suffix (-PR or -CI or...) must be added to the name of the  build definition

    .PARAMETER PROPERTY componentName
        Name of the component. So the tag in the template can be replaced by the name of the component.

    .PARAMETER PROPERTY buildDefinitionPath
        Path where to store the build definition in Azure DevOps

    .PARAMETER PROPERTY idBuildDefinition
        Id of the Build Definition which has to be updated.

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 27, 2019

        Initial version.
    #>
    [void]Update([string]$jsonBody, [int]$idBuildDef) {
        Try {
            $url = $this.AdoInfo.AzureDevopsApiUrls.UpdateBuildDefinition($idBuildDef)
            $buildDefinition = $this.AdoInfo.CallRestMethodPut($url, $jsonBody)
            Write-Debug "[Update] Build Definition: $($buildDefinition.name) is updated!"
        }
        Catch {
            Write-Error -Message "[Update] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[Update] Done!"
        }
    }

    <#
    .DESCRIPTION
        Function which can be used to verify if a build definition already exists.

    .PARAMETER PROPERTY buildName
        Name of the build definition you want to verify

    .PARAMETER PROPERTY buildDefinitionPath
        Path where to verify the build definition in Azure DevOps

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [int]Exists([string]$buildName, [string]$buildDefinitionPath) {
        Try {
            $url = $this.AdoInfo.AzureDevopsApiUrls.GetUrlBuildDefinitions($buildDefinitionPath, $buildName)
            $buildDefinitions = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.AdoInfo.Base64AuthInfo)}
            Write-Debug "[Exists] Build Definitions: $($buildDefinitions.value.name)"
            return $buildDefinitions.value.name.Contains($buildName)
        }
        Catch {
            Write-Error -Message "[Exists] [ERROR] Exception Message: $($_.Exception.Message)"
            return $false
        }
        Finally {
            Write-Debug "[Exists] Done!"
        }
    }

    [BuildDefinition]GetBuildDef([string]$uniqueBuildName, [string]$buildDefinitionPath) {
        Try {
            $url = $this.AdoInfo.AzureDevopsApiUrls.GetUrlBuildDefinitions($buildDefinitionPath, $uniqueBuildName)
            $buildDefinitions = $this.AdoInfo.CallRestMethodGet($url)
            Write-Debug "[GetBuildDefId] Build Definitions: $($buildDefinitions.value.name)"
            if ($buildDefinitions.Count -eq 0) {
                Write-Debug "[GetBuildDefId] Found no build definition for searchname: '$($uniqueBuildName)'"
                $buildDef = [BuildDefinition]::new(0, 0, "Dummy")
                return $buildDef
            }
            if ($buildDefinitions.Count -gt 1) {
                Throw "[GetBuildDefId] Found more than 1 build definition for searchname: '$($uniqueBuildName)'"
            }
            $temp = $buildDefinitions.value[0]
            $buildDef = [BuildDefinition]::new($temp.Id, $temp.Revision, $temp.Name)
            return $buildDef
        }
        Catch {
            Write-Error -Message "[GetBuildDefId] [ERROR] Exception Message: $($_.Exception.Message)"
            return $false
        }
        Finally {
            Write-Debug "[GetBuildDefId] Done!"
        }
    }
    <# Combine Create and exists function #>
    [void]CreateMissingOrUpdate([string]$buildDefinitionPath, [string]$templateFile, [string]$suffixNameBuildDef, [GitItemParams]$gitItemParams) {
        Try {
            $adoGitItems = [adoGitItems]::new($this.AdoInfo)
            $listComponents = $adoGitItems.ListComponents($gitItemParams)

            ForEach ($component in $listComponents) {
                Write-Debug "[CreateMissingOrUpdate] component: $($component)"
                $buildDef = $this.GetBuildDef("$($component)$($suffixNameBuildDef)", $buildDefinitionPath)
                $json = Get-Content $PSScriptRoot\..\$templateFile | Out-String
                $jsonBody = $json.Replace('|componentName|', $component).Replace("|BuildDefinitionName|", "$($component)$($suffixNameBuildDef)")
                $template = $jsonBody | ConvertFrom-Json
                if (-not ([string]::IsNullOrEmpty($buildDefinitionPath))) {
                    $template.path = $buildDefinitionPath
                }
                if ($buildDef.Id -eq 0) {
                    $propertiesToRemove = @('id', 'revision')
                    ForEach($prop in $propertiesToRemove) {
                        $template.PSObject.Properties.Remove($prop)
                    }
                    $jsonBody = $template | ConvertTo-Json -depth 100
                    $this.Create($jsonBody)
                }
                else {
                    $template.Id = $buildDef.Id
                    $template.Revision = $buildDef.Revision
                    $jsonBody = $template | ConvertTo-Json -depth 100
                    $this.Update($jsonBody, $buildDef.Id)
                }
            }
        }
        Catch {
            Write-Error -Message "[CreateMissingOrUpdate] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[CreateMissingOrUpdate] Done!"
        }
    }

    <#
    .DESCRIPTION
        Function which can be used to delete all build definition at the given path

    .PARAMETER PROPERTY buildDefinitionPath
        Path where to delete all the build definitions in Azure DevOps

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [void]DeleteAll([string]$buildDefinitionPath) {
        Try {
            $url = $this.AdoInfo.AzureDevopsApiUrls.GetUrlBuildDefinitions($buildDefinitionPath)
            $buildDefinitions = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.AdoInfo.Base64AuthInfo)}

            ForEach ($buildDefinition in $buildDefinitions.value) {
                $urlDelete = $this.AdoInfo.AzureDevopsApiUrls.DeleteBuildDefinition($buildDefinition.id)
                Invoke-RestMethod -Uri $urlDelete -Method Delete -Headers @{Authorization=("Basic {0}" -f $this.AdoInfo.Base64AuthInfo)}
                Write-Debug "[DeleteAll] Deleted build defintion '$($buildDefinition.name)'"
            }
        }
        Catch {
            Write-Error -Message "[DeleteAll] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[DeleteAll] Done!"
        }
    }
}