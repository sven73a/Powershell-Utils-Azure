class CollectionBase {
    [PSCustomObject[]]$Collection

    CollectionBase() {
        $this.Collection = @()
    }

    [void]Add([PSCustomObject] $singleObject) {
        $this.Collection += $singleObject
    }
}