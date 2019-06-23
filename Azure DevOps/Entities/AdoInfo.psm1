using module ..\Helpers\ApiUrlsHelpers.psm1
<#
.SYNOPSIS
 see description

.DESCRIPTION
 Module file with class with Azure DevOps information which is used in other PS-functions..

.PARAMETER PROPERTY AccountName
    Name of the Azure DevOps Account

.PARAMETER PROPERTY ProjectName
    Name of the Azure DevOps Project

.PARAMETER PROPERTY RepositoryName
    Array of Repo-names you want to use in your powershell function. If you only want 1 repo, use an 1 array with a single element
    @('single-element')

.PARAMETER PROPERTY User
    Optional for generating the Authorization header to communicate with Azure DevOps

.PARAMETER PROPERTY Token
    Token for generating the Authorization header to communicate with Azure DevOps

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
class AdoInfo {
    [string]$AccountName
    [string]$ProjectName
    [string[]]$RepositoryNames
    [string]$User
    [string]$Token
    [AzureDevopsApiUrls]$UrlAPI

    adoInfo ([string]$accountName, [string]$projectName, [string[]]$repositoryNames, `
        [string]$user, [string]$token){

        $this.AccountName = $accountName
        $this.ProjectName = $projectName
        $this.RepositoryNames = $repositoryNames
        $this.User = $user
        $this.Token = $token
        $this.UrlAPI = [AzureDevopsApiUrls]::new($accountName, $projectName)
    }

    [string]GetBase64AuthInfo() {
        $returnValue = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $this.User, $this.Token)))
        Write-Debug "[GetAuthBase64Info] Base64 Auth Info: $($returnValue)"
        return $returnValue
    }

    [PSObject]CallRestMethodGet([string] $url) {
       return Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.GetBase64AuthInfo())}
    }

    [PSObject]CallRestMethodDelete([string] $url) {
        return Invoke-RestMethod -Uri $url -Method Delete -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.GetBase64AuthInfo())}
     }

    [PSObject]CallRestMethodPut([string] $url, [string]$jsonBody) {
        return Invoke-RestMethod -Uri $url -Method Put -Body $jsonBody -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.GetBase64AuthInfo())}
     }

    [PSObject]CallRestMethodPost([string] $url, [string]$jsonBody) {
        return Invoke-RestMethod -Uri $url -Method Post -Body $jsonBody -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $this.GetBase64AuthInfo())}
     }
}