<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with class with different functions to gather Git Items (files/folders) in Azure Devops

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
using module ..\Entities\AdoInfo.psm1
using module ..\Entities\GitItemParams.psm1

class adoGitItems {
    [AdoInfo]$AdoInfo

    adoGitItems([AdoInfo]$adoInfo)
    {
        $this.AdoInfo = $adoInfo
        Write-Debug "[adoBuildDefinitions] Init"
    }

    <#
    .SYNOPSIS
    <see description>

    .DESCRIPTION
        Function which gathers Git Items based on the given parameters.

    .PARAMETER PROPERTY gitItemParams
        see for information ../Entities/GitItemParams.psm1

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [string[]]ListComponents([GitItemParams]$gitItemParams) {
        Try {
            $url = $this.adoInfo.UrlAPI.GetUrlGitItems($this.adoInfo.RepositoryNames[0], $gitItemParams)

            $gitItems =  $this.AdoInfo.CallRestMethodGet($url)
            $filteredItems = @()
            $filteredItems = $gitItems.value | Where-Object { $_.gitObjectType -eq 'blob' -and $_.path -like $gitItemParams.FilterPath }

            $listComponents = @()
            # $listComponentsIgnore = @()
            # ForEach ($item in $ignoreItems) {
            #     $nameIgnore = $item.path.Split("/")[1]
            #     $listComponentsIgnore += $nameIgnore
            # }

            ForEach ($item in $filteredItems) {
                $array = $item.path.Split("/")
                $name = $array[-2]
                if ($gitItemParams.IgnoreComponents -notcontains $name) {
                    $listComponents += $name
                }
            }
            If ($gitItemParams.TopItems -eq 0){
                return $listComponents | Sort-Object | Get-Unique
            }
            return $listComponents | Sort-Object | Get-Unique | Select-Object -First $gitItemParams.TopItems

        }
        Catch {
            Write-Error -Message "[Git Items] [ERROR] Exception Message: $($_.Exception.Message)"
            return $null
        }
        Finally {
            Write-Debug "[Git Items] Done!"
        }
    }
}