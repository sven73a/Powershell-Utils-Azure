<#
.SYNOPSIS
<see description>

.DESCRIPTION
    Module file with class to gather information which is used to generate an overview of the remaining branches

.PARAMETER PROPERTY RepoName
    Name of the Azure DevOps Git repo where the report is about

.PARAMETER PROPERTY BranchFullName
    Fullname (including reference information) of the branch which is found (refs/xxx/feature/change-of-blah)

.PARAMETER PROPERTY BranchNameTrimmed
    Name (last part of reference information) of the branch which is found (feature/change-of-blah)

.PARAMETER PROPERTY Creator
    Fullname of the Creator of the branch

.PARAMETER PROPERTY EmailCreator
    UPN of the Creator of the branch, is used for mailing.

.PARAMETER PROPERTY BranchPushSummary
    Information with how many pushed, First and Last Push, Last Pushed By and how may days ago from current date

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
class Branch
{
    [string]$RepoName
    [string]$BranchFullName
    [string]$BranchNameTrimmed
    [string]$Creator
    [string]$EmailCreator
    [BranchPushSummary]$BranchPushSummary

    Branch([string]$repoName, [string]$branchFullName, [string]$creator, [string]$emailCreator)
    {
        $this.RepoName = $repoName
        $this.BranchFullName = $branchFullName
        $this.Creator = $creator
        $this.EmailCreator = $emailCreator
        $this.BranchNameTrimmed = $branchFullName.replace('refs/heads/','')
    }
}

<# see above #>
class BranchPushSummary {
    [PSObject]$Measure
    [string]$LastPushBy
    [int]$LastPushDaysAgo

    BranchPushSummary([PSObject]$measure, [string]$lastPushBy) {
        $this.LastPushBy = $lastPushBy
        $this.Measure = $measure
        $this.LastPushDaysAgo = (New-TimeSpan -End (Get-Date) -Start ([datetime]$measure.Maximum)).Days
    }
}

<#
Collection of Branches
with a function to generatie HTML output
#>
class BranchCollection {
    [Branch[]]$Branches

    PullRequestCollection() {
        $this.Branches = @()
    }

    [void]AddBranch([Branch] $branch) {
        $this.Branches += $branch
    }

    [string[]]GetUniqueEmailAdresses() {
        $EmailAddresses = $this.Branches.EmailCreator | Sort-Object | Get-Unique
        Write-Debug "[Unique Emailaddresses] $($EmailAddresses)"
        return $EmailAddresses
    }

    [string]GetOverviewHtml([int]$daysAgoLastActivity) {
        Import-Module $PSScriptRoot\..\..\Generic\Html-Text-Helpers.ps1 -Force

        $headStyle = GetHtmlHeadStyle(90)
        $signature = GetSignature

        $overView += $this.Branches | ConvertTo-Html -Property `
            @{l='Repo'; e={$_.RepoName}}, `
            @{l='Branch'; e={$_.BranchNameTrimmed}}, Creator, `
            @{l='# Pushes'; e={$_.BranchPushSummary.Measure.Count}}, `
            @{l='First Push'; e={([datetime]$_.BranchPushSummary.Measure.Minimum).ToString("dd-MMM-yyyy")}},  `
            @{l='Last Push'; e={([datetime]$_.BranchPushSummary.Measure.Maximum).ToString("dd-MMM-yyyy")}},  `
            @{l='Last Push By'; e={$_.BranchPushSummary.LastPushBy}}, `
            @{l='Days ago'; e={$_.BranchPushSummary.LastPushDaysAgo}} -Title "Branches" `
        -PreContent "<h3>Overview Branches of which the last activity was more than <u>$($daysAgoLastActivity)</u> days ago.</h3>" `
        -PostContent "<p><b>Please take a look at these branches and if you don't use it anymore please delete it.</b></p>$($signature)" `
        -Head $headStyle
        return $overView
    }
}