<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with class with different functions to gather information relating Branches in Azure Devops

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
using module ..\Entities\AdoInfo.psm1
using module ..\Entities\Branches.psm1
using module ..\Helpers\ApiUrlsHelpers.psm1
using module ..\Helpers\ConfigHelper.psm1
using module ..\..\Generic\Modules\modMail-Utils.psm1

class adoBranches {

    [AdoInfo]$AdoInfo
    [ConfigHelper]$config

    adoBranches([AdoInfo]$adoInfo)
    {
        $this.AdoInfo = $adoInfo
        Write-Debug "[adoBranches] Init"

        $this.config = [ConfigHelper]::new()
    }
    <#
    .SYNOPSIS
    <see description>

    .DESCRIPTION
        Function which gathers information from Azure DevOps and combines it, so a report/mail can be generated

    .PARAMETER PROPERTY dropFolderMail
        Location where to store the email message on disk.

    .PARAMETER PROPERTY senderMail
        Which should be the sender of the email

    .PARAMETER PROPERTY daysAgoLastActivity
        Number of  days a branch should not be updated before it will be added to the report/mail.

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [void]PublishListBranches (
        [string]$dropFolderMail, [string]$senderMail, [int]$daysAgoLastActivity) {
        Try {
            $ListBranches = [BranchCollection]::new()
            # List per repo, the branches
            ForEach ($repo in $this.adoInfo.RepositoryNames)
            {
                $url = $this.AdoInfo.AzureDevopsApiUrls.GetUrlBranches($repo)
                $branches = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.AdoInfo.Base64AuthInfo)}
                If ($branches.value.length -eq 0)
                {
                    Throw "[PublishListBranches] [Test-Json] Invalid response. Is token valid?"
                }
                Write-Debug "[PublishListBranches] Number of branches found: $($branches.count) at url: $($url)"

                #For each branch in the repo
                ForEach ($branch in $branches.value | Where-Object { $_.name -match '^refs/heads/*' -and $_.name -notmatch '^refs/heads/master' -and $_.name -notmatch '^refs/heads/develop' -and $_.name -notmatch '^refs/heads/wiki' } ) {
                    $urlPushes = $this.AdoInfo.AzureDevopsApiUrls.GetUrlPushes($repo, $branch.name)
                    $pushes = Invoke-RestMethod -Uri $urlPushes -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.AdoInfo.Base64AuthInfo)}
                    $lastpush = $pushes.value | Sort-Object -Descending { $_.date } | Select-Object -First 1
                    $measurePushes = $pushes.value | Measure-Object -Property date -Minimum -Maximum
                    $objbranchPushSummary = [BranchPushSummary]::new($measurePushes, $lastpush.pushedBy.displayName)
                    $objBranch = [Branch]::new($repo, $branch.name, $branch.creator.displayName, $branch.creator.uniqueName)
                    $objBranch.BranchPushSummary = $objbranchPushSummary
                    if ($objBranch.BranchPushSummary.LastPushDaysAgo -gt $daysAgoLastActivity) {
                        $ListBranches.AddBranch($objBranch)
                    }
                    else {
                        Write-Debug "[PublishListBranches] Skipped '$($branch.name)', because last activity was less or equal than $($daysAgoLastActivity) days ago."
                    }
                }
            }

            If ($ListBranches.Branches.Count -ne 0) {
                $dtmToday = (Get-Date).ToString("dd MMM yyyy HH:mm")
                $mailSubject = "Overview of (feature) branches - $($dtmToday)"
                Write-Debug "[PublishListBranches] [MailMessage] Subject: $($mailSubject)"

                $mailBody = $ListBranches.GetOverviewHtml($daysAgoLastActivity)
                If($this.config.GetStringFromConfig("EmailTo")){
                    $stringTo = $this.config.GetStringFromConfig("EmailTo")
                }Else{
                    $stringTo = $ListBranches.GetUniqueEmailAdresses() -join ","
                }
                Write-Debug "[PublishListBranches] [MailMessage] Mail to: $($stringTo)"

                $mailMsgObj = [MailMsg]::new($senderMail, $stringTo, $mailSubject, $mailBody, $true)
                $MailMessage = $mailMsgObj.GetMailMessage()

                $MailSendOrSaveObj = [MailSendOrSave]::new($MailMessage)
                $MailSendOrSaveObj.SaveToDisk($dropFolderMail)
                Write-Debug "[PublishListBranches] Message saved!"
            }
            Else {
                Write-Warning "[PublishListBranches] [WARNING] No branches, then develop/master!"
            }
        }
        Catch {
            Write-Error -Message "[PublishListBranches] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[PublishListBranches] Done!"
        }
    }
}