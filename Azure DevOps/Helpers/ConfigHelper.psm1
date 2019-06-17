<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with class that can get the config easily from config.json.

.NOTES
    AUTHOR: Mart de Graaf
    LASTEDIT: June 18, 2019

    Initial version.
#>


class ConfigHelper {
    [string]$configPath

    [PSCustomObject]$config

    ConfigHelper () {
        $this.ConfigPath = "config.json"
        #Load the config from the config file.
        $this.config = Get-Content -Path  $this.configPath | ConvertFrom-Json 

        Write-Host $this.config
    }

    [string]GetStringFromConfig([string]$key) {
        Write-Host $this.propByPath($this.config, $key)
        return $this.propByPath($this.config, $key)
    }
    
    [String]propByPath([PSCustomObject]$obj, [string]$propertyPath) {
        foreach ($prop in $propertyPath -split '\.') 
        {
            $obj = $obj.$prop
        }
        return $obj
    }
}