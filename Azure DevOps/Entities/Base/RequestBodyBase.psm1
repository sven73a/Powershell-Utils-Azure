class RequestBodyBase {
    [string]ToJson() {
        return ConvertTo-Json -InputObject $this.ToArray()
        #don't use the pipe "|" method of conversion as it will flatten arrays of 1 item to a non-array
    }

    [PSObject[]] ToArray() {
        $returnArray = @()
        $returnArray += $this
        return $returnArray
    }
}