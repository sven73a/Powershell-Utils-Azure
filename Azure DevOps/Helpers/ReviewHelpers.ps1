<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with functions specific for Azure DevOps

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019

    Initial version.
#>

<# Function to translate 'meaningless' text from the repsonse into readable to text, so it can be used in reporting #>
function Get-VoteText {
    param([string]$vote)

    $returnValue = "N/A"

    switch ($vote) {
    "0" {$returnValue = "<b>No Vote</b>"; break}
    "5" {$returnValue = "Apporoved with Suggestions"; break}
    "10" {$returnValue = "Approved"; break}
    "-5" {$returnValue = "Waiting for Author"; break}
    "-10" {$returnValue = "Rejected"; break}
    default {$returnValue = "N/A"; break}
    }

    return $returnValue
}