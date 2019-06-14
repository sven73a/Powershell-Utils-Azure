<#
.SYNOPSIS
<see description>

.DESCRIPTION
 File with functions which are used to create HTML based reports/email, this helps to make to layout generic.

.NOTES
   AUTHOR: Sven Ansem
   LASTEDIT: Feb 11, 2019

#>

function DecodeHTML([string]$htmlText) {
    Add-Type -AssemblyName System.Web
    return $htmlReturn
}
function GetSignature() {
    [OutputType([string])]
    $signature = "<br/><br/>Kind Regards,<br>Team A."
    return $signature
}
function GetHtmlHeadStyle([int]$tableWidth) {
    [OutputType([string])]

    $htmlHead = "<style>
    body {
        background-color: white;
        font-family:    'Century Gothic';
        font-size:      10pt;
    }

    table {
        border-width:     1px;
        border-style:     solid;
        border-color:     black;
        border-collapse:  collapse;
        width:            $($tableWidth)%;
    }

    th {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: #98C6F3;
        text-align:       left;
    }

    td {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: White;
    }

    tr {
        text-align:       left;
    }
    </style>"
    return $htmlHead
}

