
<#
.SYNOPSIS
<see description>

.DESCRIPTION
    Module file with class Used to pass parameters between the functions, made to prevent long list of input parameters. this improves code maintainability

.PARAMETER PROPERTY GitFilePath
    Path in the git-repo where to start the loop, most of the time the root ("/")

.PARAMETER PROPERTY FilterPath
    Which files of the git-items you want to query ("*.json")

.PARAMETER PROPERTY BranchName
    In which branch do we want to query the items

.PARAMETER PROPERTY TopItems
    Can be used for developing. How many items do you want to proces. Most functions will do all items when top items is set to '0'

.PARAMETER PROPERTY IgnoreComponents
    List of folders/components which can be ignored.

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>
class GitItemParams {
    [string]$GitFilePath
    [string]$FilterPath
    [string]$BranchName
    [int]$TopItems
    [string[]]$IgnoreComponents


    GitItemParams ([string]$gitFilePath, [string]$filterPath, [string]$branchName, [int]$topItems, [string[]]$ignoreComponents) {
        $this.GitFilePath = $gitFilePath
        $this.FilterPath = $filterPath
        $this.BranchName = $branchName
        $this.TopItems = $topItems
        $this.IgnoreComponents = $ignoreComponents
    }
}