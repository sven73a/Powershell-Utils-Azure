using module .\Base\RequestBodyBase.psm1

class RequestBodyPush : RequestBodyBase {
    [Refupdate[]] $refUpdates
    [Commit[]] $commits
}

class Refupdate {
    [string] $name
    [string] $oldObjectId
}

class Commit {
    [string] $comment
    [Change[]] $changes
}

class Change {
    [string] $changeType
    [Item] $item
    [Newcontent] $newContent
}

class Item {
    [string] $path
}

class Newcontent {
    [string] $content
    [string] $contentType
}
