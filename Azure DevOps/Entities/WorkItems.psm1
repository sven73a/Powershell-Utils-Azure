using module .\Base\CollectionBase.psm1
using module .\PullRequests.psm1
<#
.SYNOPSIS
    <see description>

.DESCRIPTION
    Module file with class to gather information which is used to generate an overview Work Items

.PARAMETER PROPERTY Id
    Id of the Workitem

.PARAMETER PROPERTY Url
    Direct API Url to the workItem

.PARAMETER PROPERTY PullRequest
    Pull Request related to the WorkItem

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
class WorkItem {
    [int]$Id
    [string]$ApiUrl
    [string]$WebUrl
    [string]$Title
    [string]$Description
    [string]$Tags
    [string]$Type
    [PullRequest]$PullRequest

    WorkItem([int]$id, [string]$apiUrl) {
        $this.Id = $id
        $this.ApiUrl = $apiUrl
    }
}

<#
Collection of Work Items
#>
class WorkItemCollection : CollectionBase {
    <#
    Report for ChangeManagement dat can be send to Michael Jaeger.
    It outputs a raw version, which has to be manually added

    Manually is needed unit we have the proces in order that every change has the correct Tag.
    #>
    [string]GetChangeMgtReport_Html([int]$lastDays, [string]$branchName, [string]$team) {
        Import-Module $PSScriptRoot\..\..\Generic\Html-Text-Helpers.ps1 -Force

        $headStyle = GetHtmlHeadStyle(90)
        $signature = GetSignature

        $overView += $this.Collection | ConvertTo-Html -Property `
            @{l='Branche Name'; e={$_.PullRequest.RepoName}}, `
            @{l='WorkItem Id'; e={"<a href='$($_.WebUrl)'>$($_.Id)</a>"}}, `
            @{l='Available Since'; e={$_.PullRequest.CompletedOn.ToString("dd MMM yyyy")}}, `
            @{l='WorkItem Title'; e={$_.Title}}, `
            @{l='WorkItem Type'; e={$_.Type}}, `
            @{l='Tags'; e={$_.Tags}} `
        -Title "Changes Azure $($team)" `
        -PreContent "<h3>Overview of the changes of Azure $($team) in the last <u>$($lastDays)</u> days.</h3><p>Based on the branch '<b>$($branchName)</b>.'</p>" `
        -PostContent "<p><b>If you have any questions about this overview, please let me know.</b></p>$($signature)" `
        -Head $headStyle

        return DecodeHTML($overView)
    }
}