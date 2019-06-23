using module .\Base\RequestBodyBase.psm1

class RequestBodyCreateBranch : RequestBodyBase {
    [string]$Name
    [string]$OldObjectId
    [string]$NewObjectId

    RequestBodyCreateBranch([string]$name, [string]$basedOnCommitSHA) {
        $this.Name = $Name
        $this.OldObjectId = "0000000000000000000000000000000000000000"
        $this.newObjectId =  $basedOnCommitSHA
    }
}