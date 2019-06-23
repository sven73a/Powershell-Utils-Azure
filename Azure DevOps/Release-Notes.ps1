using module .\Modules\adoPullRequests.psm1
using module .\Entities\AdoInfo.psm1
using module .\Entities\ReleaseNotes.psm1

function Release-Notes {
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
        [string]$senderMail
    )
    Try {
        Write-Debug "[Release-Notes] Init"

        #include file with functions
        Import-Module $PSScriptRoot\..\Generic\Generic-Functions.ps1 -Force
        Set-DebugPreference($displayDebugMessages)
        $global:DebugPrintApiUrls = $true

        $objAdoInfo = [adoInfo]::new($accountName, $projectName, $repositoryNames, $user, $token)

        ForEach ($repo in $objAdoInfo.RepositoryNames)
        {
            $url = $objAdoInfo.UrlAPI.GetUrlPullRequests($repo, $null, $null)

            $pullRequests = $objAdoInfo.CallRestMethodGet($url)
            If ($null -eq $pullRequests.value)
            {
                Throw "[Release-Notes] [Test-Json] Invalid response. Is token valid?"
            }
            $urlCommits = $objAdoInfo.UrlAPI.GetUrlPullRequestCommits($repo, $pullRequests.value[0].pullRequestId)
            $commits = $objAdoInfo.CallRestMethodGet($urlCommits)
            Write-Debug "[Release-Notess] Result.Count: $($pullRequests.Count) for '$($repo)'"

            $releaseNoteCollection = [ReleaseNoteCollection]::new()
            ForEach ($commit in $commits.value) {
                $commit.commitId

                $urlSingleCommit = $objAdoInfo.UrlAPI.GetUrlCommit($repo, $commit.commitId)
                $singleCommit = $objAdoInfo.CallRestMethodGet($urlSingleCommit)
                $releaseNote = [ReleaseNote]::new($singleCommit.comment)

                if($releaseNote.PRComment -eq "`n") {
                    $urlSingleCommitChanges = $objAdoInfo.UrlAPI.GetUrlCommitChanges($repo, $commit.commitId)
                    $singleCommitChanges = $objAdoInfo.CallRestMethodGet($urlSingleCommitChanges)
                    ForEach ($change in $singleCommitChanges.changes | Where-Object { $_.item.gitObjectType -eq 'tree' }) {
                        $componentName = $change.item.path.Split("/")[1]
                        $releaseNote.PRComment = $componentName
                    }
                }

                # ForEach ($readme in $singleCommitChanges.changes | Where-Object { $_.item.gitObjectType -eq 'blob' -and $_.item.path -like '*readme.md'}) {
                #     $componentName = $readme.item.path.Split("/")[1]
                #     Write-Debug "[adoPullRequests] Release-note-changes: $($componentName)"
                #     if ($releaseNoteCollection2.Collection.Count -eq 0 -or $releaseNoteCollection2.Collection.ComponentName.contains($componentName) -eq $false) {
                #         $noteComponent = $releaseNoteCollection.Collection | Where-Object { $_.ComponentName -eq $componentName }
                #         if ($null -ne $noteComponent) {
                #             $noteComponent.Path = $readme.item.path
                #             $noteComponent.Url = $readme.item.url
                #             Write-Debug "[adoPullRequests] $($readme.item.url)"
                #             if ($readme.changeType -ne 'delete') {
                #                 $noteComponent.FullText = Invoke-WebRequest -Uri $readme.item.url -Method Get -Headers @{Authorization=("Basic {0}" -f $objAdoInfo.GetBase64AuthInfo())}
                #             }
                #             else {
                #                 $noteComponent.Text = "Deleted"
                #             }
                #             $releaseNoteCollection2.Add($noteComponent)
                #         }
                #     }
                # }
                $releaseNoteCollection.Add($releaseNote)
            }
            $retValue = "# Release Notes`n`n"
            $retValue += $releaseNoteCollection.Collection.PRComment
            # $retValue = $releaseNoteCollection2.Collection.ComponentName | Sort-Object { $_ } | Select-Object {"[UPDATED] " + $_ + " - 20190204.1" }u
            $retValue | Out-File -FilePath 'C:\temp\release-notes.md'
        }
    }
    Catch {
        Write-Error -Message "[Release-Notes] [ERROR] Exception Message: $($_.Exception.Message)"
    }
    Finally {
        Set-DebugPreference($false)
        $global:DebugPrintApiUrls = $false
        Write-Debug "[Release-Notes] Done!"
    }
}