using module .\Base\CollectionBase.psm1

<#
.SYNOPSIS
    <see description>

.DESCRIPTION
    Module file with class to gather information which is used to generate an overview of the pending pull requests

.PARAMETER PROPERTY RepoName
    Name of the Azure DevOps Git repo where the report is about

.PARAMETER PROPERTY TargetBranchName
    Name of the branch which is target by the pull request (most of the time develop or master)

.PARAMETER PROPERTY PullRequestName
    Name of the pull request

.PARAMETER PROPERTY Submitter
    Creator of the pull request

.PARAMETER PROPERTY StatusPR
    Status of the Pull request

.PARAMETER PROPERTY IsDraft
    Flag if the pull request is a draft or not

.PARAMETER PROPERTY UrlPullRequest
    Direct URL link to the Pull request

.PARAMETER PROPERTY PullRequestReviewers
    Overview of the reviewers and their belonging status.

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>

class PullRequest
{
    [string]$RepoName
    [string]$TargetBranchName
    [string]$PullRequestName
    [string]$Submitter
    [string]$StatusPR
    [bool]$IsDraft
    [datetime]$CreatedOn
    [datetime]$CompletedOn
    [string]$UrlPullRequest
    [PullRequestReviewer[]]$PullRequestReviewers

    PullRequest([string]$repoName, [string]$targetRefName, [string]$titlePullrequest, [string]$CreatedBy `
    , [string]$status, [bool]$isDraft, [datetime]$dateCreated, [string]$url)
    {
        #ToString("dd MMM yyyy HH:mm")
        $this.RepoName = $repoName
        $this.TargetBranchName = $targetRefName
        $this.PullRequestName = $titlePullrequest
        $this.Submitter = $CreatedBy
        $this.StatusPR = $status
        $this.IsDraft = $isDraft
        $this.CreatedOn = $dateCreated
        $this.UrlPullRequest = $url
        $this.PullRequestReviewers = @()
    }
}

<#
Collection of Pull Requests
with a function to generatie HTML output
#>
class PullRequestCollection : CollectionBase {

    [string[]]GetUniqueEmailAdresses() {
        $EmailAddresses = $this.Collection.PullRequestReviewers.Reviewer.EmailReviewer | Sort-Object | Get-Unique
        Write-Debug "[Unique Emailaddresses] $($EmailAddresses)"
        $EmailAddresseReturn = $EmailAddresses | Where-Object { $_ -notlike "vstfs*"}
        return $EmailAddresseReturn
     }

    [string]GetOverviewHtml() {
        Import-Module $PSScriptRoot\..\Helpers\ReviewHelpers.ps1 -Force
        Import-Module $PSScriptRoot\..\..\Generic\Html-Text-Helpers.ps1 -Force

        $overView = "<html>"
        $headStyle = GetHtmlHeadStyle(55)
        $overView += "<head>$($headStyle)</head>"
        $overView += "<body>"
        $repoText = ""
        ForEach ($pullReq in $this.Collection) {
            Write-Debug "[GetOverviewHtml] $($pullReq.RepoName)"
            if ($repoText -ne $pullReq.RepoName) {
                $overView += "<h2>Repo: $($pullReq.RepoName)</h2>"
                $repoText = $pullReq.RepoName
                }
            $overView += "<div style=`"margin-left: 20px; margin-bottom: 30px`">"
            #$overView += "<div>"
            $overView += "<b><a href=`"$($pullReq.UrlPullRequest)`">[$($pullReq.TargetBranchName)] $($pullReq.PullRequestName)</a></b><br>"
            $overView += "Submitted by: $($pullReq.Submitter) on $($pullReq.CreatedOn.ToString("dd MMM yyyy HH:mm"))<br>"
            $overView += "Status PR: $($pullReq.StatusPR) $(if ($pullReq.IsDraft -eq 'false') {" ==> DRAFT"})"
            #$overView += "<h3>Reviewer status</h3>`n"
            $overView += "<table><tr><th>Reviewer</th><th>Status review</th></tr>"
            ForEach ($rw in $pullReq.PullRequestReviewers | Sort-Object { $_.StatusReviewer, $_.Reviewer.NameReviewer } ) {
                $overView += "<tr><td>$($rw.Reviewer.NameReviewer)</td><td>$(Get-VoteText($rw.StatusReviewer))</td></tr>"
            }
            $overView += "</table></div>"
        }
        $overView += GetSignature
        $overView += "</body></html>"
        return $overView
    }
}

<#
see above
#>
class PullRequestReviewer
{
    [Reviewer]$Reviewer
    [string]$StatusReviewer

    PullRequestReviewer ([Reviewer]$reviewer, [string]$status)
    {
        $this.Reviewer = $reviewer
        $this.StatusReviewer = $status
    }
}


<#
see above
#>
class Reviewer
{
    [string]$NameReviewer
    [string]$EmailReviewer

    Reviewer([string]$nameReviewer, [string]$mailReviewer)
    {
        $this.NameReviewer = $nameReviewer
        $this.EmailReviewer = $mailReviewer
    }
}