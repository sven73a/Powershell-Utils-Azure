<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with class with Urls to the different information object.
 It is centralized in this fill, to make changes easier when, the URL changes for instance.


.PARAMETER PROPERTY AccountName
    Name of the Azure DevOps Account. Used for making the correct URL.

.PARAMETER PROPERTY ProjectName
    Name of the Azure DevOps Project. Used for making the correct URL.

.PARAMETER PROPERTY ApiVersion
    Which version of the api version you want to use. Default is the last STABLE (not-preview) version

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
using module ..\Entities\GitItemParams.psm1
using module .\ConfigHelper.psm1

class AzureDevopsApiUrls {
    [string]$AccountName
    [string]$ProjectUrl
    [string]$ProjectName
    [string]$ApiVersion

    AzureDevopsApiUrls ([string]$accountName, [string]$projectName) {
        $this.AccountName = $accountName
        $this.ProjectName = $projectName
        $this.ApiVersion = "5.0"

        $config = [ConfigHelper]::new()

        $this.ProjectUrl = $config.GetStringFromConfig("baseUrl")
    }

    [void]WriteUrl([string]$message) {
        if ($global:DebugPrintApiUrls -eq $true) {
            Write-Host $message
        }
    }

    [string]GetAuthBase64Info([string]$userName, [string]$adoPATToken) {
        $returnValue = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName, $adoPATToken)))
        $this.WriteUrl("[Azure DevOps Urls] Base64 Auth Info: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlBase (){
        return "$($this.ProjectUrl)/$($this.AccountName)/$($this.ProjectName)"
    }
    #region Build Definitions
    [string]GetUrlBuildDefinitions ([string] $path, [string]$filterName){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/build/definitions?"
        if (-not ([string]::IsNullOrEmpty($path))) {
            $returnValue += "path=$($path)&"
        }
        if (-not ([string]::IsNullOrEmpty($filterName))) {
            $returnValue += "name=$($filterName)&"
        }
        $returnValue += "api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Build Definitions: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlBuildDefinition ([int] $buildDefintionId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/build/definitions/$($buildDefintionId)?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Build Definition for $($buildDefintionId): $($returnValue)")
        return $returnValue
    }

    [string]CreateBuildDefinition (){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/build/definitions?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Create Build Definition: $($returnValue)")
        return $returnValue
    }

    [string]UpdateBuildDefinition ([int] $buildDefintionId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/build/definitions/$($buildDefintionId)?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Update Build Definition for $($buildDefintionId): $($returnValue)")
        return $returnValue
    }
    [string]DeleteBuildDefinition ([int] $buildDefintionId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/build/definitions/$($buildDefintionId)?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Delete Build Definitionfor $($buildDefintionId): $($returnValue)")
        return $returnValue
    }
    #endregion

    #region Pull Requests
    [string]GetUrlPullRequests ([string] $repo, [string] $status, [string]$targetBranch){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/pullrequests?searchCriteria.includeLinks=true"
        if (-not ([string]::IsNullOrEmpty($status))) {
            $returnValue += "&searchCriteria.status=$($status)"
        }
        if (-not ([string]::IsNullOrEmpty($targetBranch))) {
            $returnValue += "&searchCriteria.targetRefName=$($targetBranch)"
        }
        $returnValue += "&api-version=$($this.ApiVersion)"
        $this.WriteUrl("[Azure DevOps Urls] Pull Requests: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlPullRequest ([string] $repo, [string] $pullRequestId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_git/$($repo)/pullrequest/$($pullRequestId)?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Pull Request: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlPullRequestCommits ([string] $repo, [int]$PullRequestId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/pullrequests/$($pullRequestId)/commits?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Pull Request Commits: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlPullRequestIterations ([string] $repo, [int]$PullRequestId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/pullrequests/$($pullRequestId)/iterations?includeCommits=true&api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Pull Request Interations: $($returnValue)")
        return $returnValue
    }


    [string]GetUrlPullRequestWorkItems ([string] $repo, [int]$PullRequestId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/pullrequests/$($pullRequestId)/workitems?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Pull Request Work Items: $($returnValue)")
        return $returnValue
    }
    #endregion

    #region Branches
    [string]GetUrlBranches ([string] $repo){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/refs?filter=heads/&api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Branches: $($returnValue)")
        return $returnValue
    }
    #endregion

    #region Commits
    [string]GetUrlCommits ([string] $repo){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/commits?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Commits: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlCommit ([string] $repo, [string]$commitId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/commits/$($commitId)?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Commits: $($returnValue)")
        return $returnValue
    }

    [string]GetUrlCommitChanges ([string] $repo, [string]$commitId){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/commits/$($commitId)/changes?api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Commit Changes: $($returnValue)")
        return $returnValue
    }
    #endregion

    #region Git Items
    [string]GetUrlGitItems ([string] $repo, [GitItemParams]$gitItemParams){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/items?scopePath=$($gitItemParams.GitFilePath)&recursionLevel=Full"

        if (-not ([string]::IsNullOrEmpty($gitItemParams.BranchName))) {
            $returnValue += "&versionDescriptor.version=$($gitItemParams.BranchName)&versionDescriptor.versionType=branch"
        }
        $returnValue += "&api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Git Items: $($returnValue)")
        return $returnValue
    }
    #endregion

    #region Pushes
    [string]GetUrlPushes ([string] $repo, [string]$branch){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/pushes?"

        if (-not ([string]::IsNullOrEmpty($branch))) {
            $returnValue += "&searchCriteria.includeRefUpdates&searchCriteria.refName=$($branch)"
        }
        $returnValue += "&api-version=$($this.ApiVersion)"

        $this.WriteUrl("[Azure DevOps Urls] Pushes: $($returnValue)")
        return $returnValue
    }
    #endregion

    #region itemcontent
    [string]GetUrlItemContent ([string] $repo, [string]$branch, [string]$filePath){
        $baseUrl = $this.GetUrlBase()
        $returnValue = "$($baseUrl)/_apis/git/repositories/$($repo)/items?path=$($filePath)"
        $returnValue += "&versionDescriptor.versionType=branch&api-version=$($this.ApiVersion)"
        $returnValue += "&format=json&includeContent=true&versionDescriptor.version=$($branch)"

        $this.WriteUrl("[Azure DevOps Urls] Item Content: $($returnValue)")
        return $returnValue
    }
    #endregion
}