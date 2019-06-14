<#
.SYNOPSIS  
    <see description> 
  
.DESCRIPTION  
    Module file with class to gather information for generating release notes

.PARAMETER PROPERTY ComponentName
    Name of the component which the release note is about

.PARAMETER PROPERTY Path
    ??

.PARAMETER PROPERTY Url
    ??

.PARAMETER PROPERTY Text
    Trimmed text of the commit description of the pull request

.PARAMETER PROPERTY FullText
    Full text of the commit description of the pull request

.NOTES
    AUTHOR: Sven Ansem
    LASTEDIT: Feb 11, 2019
    
    Initial version.
#>

class ReleaseNote
{
    [string]$ComponentName
    [string]$PRComment
    [string]$Path    
    [string]$Url
    [string]$Text    
    [string]$FullText
    
    # ReleaseNote([string]$componentName)
    # {
    #     $this.ComponentName = $componentName
    # }

    ReleaseNote([string]$comment)
    {
        $this.PRComment = $this.StripComment($comment)
    }

    [string]StripComment([string]$comment) {
        $pattern = "## Release Note\n\n(.*)\n\nRelated"
        $result = [regex]::match($comment, $pattern,[System.Text.RegularExpressions.RegexOptions]::Singleline).Groups[1].Value
        return "$($result)`n`n"
    }
}

<#
Collection of Release Notes
#>
class ReleaseNoteCollection {
    [ReleaseNote[]]$ReleaseNotes

    ReleaseNoteCollection() {
        $this.ReleaseNotes = @()
    }

    [void]Add([ReleaseNote] $releaseNote) {
        $this.ReleaseNotes += $releaseNote
    }

}