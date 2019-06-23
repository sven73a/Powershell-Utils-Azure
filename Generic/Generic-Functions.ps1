function Set-DebugPreference {
param([bool]$displayDebug)

### ErrorActionPreference ####
# Stop: Displays the error message and stops executing.
# Inquire: Displays the error message and asks you whether you want to continue.
# Continue: Displays the error message and continues (Default) executing.
# Suspend: Automatically suspends a workflow job to allow for further investigation. After investigation,
#           the workflow can be resumed.
# SilentlyContinue: No effect. The error message is not displayed and execution continues without interruption.

### DebugPreference ###
# Stop: Displays the debug message and stops executing. Writes an error to the console.
# Inquire: Displays the debug message and asks you whether you want to continue. Note that adding the Debug common parameter to a command--when the command is configured to generate a debugging message--changes the value of the $DebugPreference variable to Inquire.
# Continue: Displays the debug message and continues with execution.
# SilentlyContinue: No effect. The debug message is not (Default) displayed and execution continues without interruption.

### ErrorView ###
# NormalView: A detailed view designed for most users. (default) Consists of a description of the error, the name of the object involved in the error, and arrows (<<<<) that point to the words in the command that caused the error.
# CategoryView: A succinct, structured view designed for production environments. The format is:
# {Category}: ({TargetName}:{TargetType}):[{Activity}], {Reason}

    $global:DebugPreference = "SilentlyContinue"
    # $global:ErrorActionPreference = 'Continue'
    # $global:ErrorView = 'CategoryView'

    $retValue = "SilentlyContinue"

    if ($displayDebug -eq $true) {
        $global:DebugPreference = "Continue"
        # $global:ErrorActionPreference = 'Suspend'
        # $global:ErrorView = 'NormalView'
    }
}

function NewSHA1 {
    param([string]$clearString)

    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha1')
    $hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($clearString))

    $hashString = [System.BitConverter]::ToString($hash)
    return $hashString.Replace('-', '')
}