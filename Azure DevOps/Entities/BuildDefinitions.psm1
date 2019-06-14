class BuildDefinition
{
    [int]$Id
    [string]$Name
    [int]$Revision    

    BuildDefinition([int]$id, [int]$revision, [string]$name)
    {
        $this.Id = $id
        $this.Name = $name
        $this.Revision = $revision
    }
}