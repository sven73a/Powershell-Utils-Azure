<#
.SYNOPSIS
    see description

.DESCRIPTION
 Module file with class with different functions to gather information and /or perform operation relating to Build Requests in Azure Devops

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    # Initial version
#>
using module ..\Entities\AdoInfo.psm1
using module ..\Entities\PullRequests.psm1
using module ..\Entities\WorkItems.psm1
using module ..\Helpers\ApiUrlsHelpers.psm1
using module ..\..\Generic\Modules\modMail-Utils.psm1

class adoPullRequests {

    [AdoInfo]$AdoInfo

    adoPullRequests([AdoInfo]$adoInfo)
    {
        $this.AdoInfo = $adoInfo
        Write-Debug "[adoPullRequests] Init"
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

    .NOTES
        AUTHOR: Sven Ansem
        LASTEDIT: Feb 11, 2019

        Initial version.
    #>
    [void]PublishPendingPullRequests([string]$dropFolderMail, [string]$senderMail) {
        Try {

            $ListPullRequests = [PullRequestCollection]::new()
            ForEach ($repo in $this.AdoInfo.RepositoryNames)
            {
                $url = $this.adoInfo.UrlAPI.GetUrlPullRequests($repo, $null, $null)

                $pullRequests = $this.AdoInfo.CallRestMethodGet($url)
                If ($null -eq $pullRequests.value)
                {
                    Throw "[adoPullRequests] [Test-Json] Invalid response. Is token valid?"
                }
                Write-Debug "[adoPullRequests] Result.Count: $($pullRequests.Count) for '$($repo)'"

                ForEach ($pr in $pullRequests.value) {
                    Write-Debug "[adoPullRequests]  $($pr.repository.name)"
                    $objPullRequest = [PullRequest]::new($pr.repository.name, $pr.targetRefName.replace('refs/heads/',''), `
                        $pr.title, $pr.createdBy.displayName, $pr.status, $pr.isDraft, $pr.creationDate, `
                        $this.adoInfo.UrlAPI.GetUrlPullRequest($repo, $pr.pullRequestId))

                    ForEach ($reviewer in $pr.reviewers) {
                        $objReviewer = [Reviewer]::new($reviewer.displayName, $reviewer.uniqueName)
                        $objPullRequestReviewer = [PullRequestReviewer]::new($objReviewer, $reviewer.vote)
                        $objPullRequest.PullRequestReviewers += $objPullRequestReviewer
                    }
                    $ListPullRequests.Add($objPullRequest)
                }
            }

            If ($ListPullRequests.Collection.Count -ne 0) {
                $dtmToday = (Get-Date).ToString("dd MMM yyyy HH:mm")
                $mailSubject = "Review Reminder pending Pull Requests - $($dtmToday)"
                Write-Debug "[adoPullRequests] [MailMessage] Subject: $($mailSubject)"

                $mailBody = $ListPullRequests.GetOverviewHtml()
                $stringTo = $ListPullRequests.GetUniqueEmailAdresses() -join ","
                Write-Debug "[adoPullRequests] [MailMessage] Mail to: $($stringTo)"

                $mailMsgObj = [MailMsg]::new($senderMail, $stringTo, $mailSubject, $mailBody, $true)
                $MailMessage = $mailMsgObj.GetMailMessage()

                $MailSendOrSaveObj = [MailSendOrSave]::new($MailMessage)
                $MailSendOrSaveObj.SaveToDisk($dropFolderMail)
                Write-Debug "[adoPullRequests]  Message saved!"
            }
            Else {
                Write-Warning "[adoPullRequests] [WARNING] No pending Pull requests!"
            }
        }
        Catch {
            Write-Error -Message "[adoPullRequests] [ERROR] Exception Message: $($_.Exception.Message)"
        }
        Finally {
            Write-Debug "[adoPullRequests] Done!"
        }
    }
}