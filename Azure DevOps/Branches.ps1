using module .\Modules\adoBranches.psm1
using module .\Entities\AdoInfo.psm1

function UpdateARMRepo {
    <#
    .EXAMPLE
        PS C:\>

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
        [string]$token
    )

    Try {
        Write-Debug "[UpdateARMRepo] Init"

        #include file with functions
        Import-Module $PSScriptRoot\..\Generic\Generic-Functions.ps1 -Force
        Set-DebugPreference($displayDebugMessages)
        $global:DebugPrintApiUrls = $true

        $objAdoInfo = [adoInfo]::new($accountName, $projectName, $repositoryNames, $user, $token)
        $objBranches = [adoBranches]::new($objAdoInfo)
        $objBranches.CreateBranch($repositoryNames[0], "refs/heads/generated-updates/update-after-change", "refs/heads/develop", $true)
    }
    Catch {
        Write-Error -Message "[UpdateARMRepo] [ERROR] Exception Message: $($_.Exception.Message)"
    }
    Finally {
        Set-DebugPreference($false)
        $global:DebugPrintApiUrls = $false
        Write-Debug "[UpdateARMRepo] Done!"
    }
}

function Branches {
    <#
    .EXAMPLE
        PS C:\>

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
        [string]$dropFolderMail,
        [Parameter(mandatory=$true, position=7)]
        [string]$senderMail,
        [Parameter(mandatory=$false, position=8)]
        [string]$daysAgoLastActivity=-1
    )
    Try {
        Write-Debug "[Branches] Init"

        #include file with functions
        Import-Module $PSScriptRoot\..\Generic\Generic-Functions.ps1 -Force
        Set-DebugPreference($displayDebugMessages)
        $global:DebugPrintApiUrls = $true

        $objAdoInfo = [adoInfo]::new($accountName, $projectName, $repositoryNames, $user, $token)
        $objBranches = [adoBranches]::new($objAdoInfo)
        $objBranches.PublishListBranches($dropFolderMail, $senderMail, $daysAgoLastActivity)
    }
    Catch {
        Write-Error -Message "[Branches] [ERROR] Exception Message: $($_.Exception.Message)"
    }
    Finally {
        Set-DebugPreference($false)
        $global:DebugPrintApiUrls = $false
        Write-Debug "[Branches] Done!"
    }
}
