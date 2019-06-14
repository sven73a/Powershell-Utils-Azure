<#
.SYNOPSIS
<see description>

.DESCRIPTION
 Module file with class to save am email to disk of send it via SMTP.

.NOTES
   AUTHOR: Sven Ansem
   LASTEDIT: Feb 11, 2019

#>
class MailMsg {
    [System.Net.Mail.MailMessage]$MailMsg

    MailMsg ([string]$mailFrom, [string]$mailTo, [string]$mailSubject, [string]$mailBody, [bool]$isHtmlBody) {
        $this.MailMsg = New-Object System.Net.Mail.MailMessage $mailFrom, $mailTo, $mailSubject, $mailBody
        $this.MailMsg.IsBodyHtml = $isHtmlBody
    }

    [System.Net.Mail.MailMessage]GetMailMessage() {
        return $this.MailMsg
    }

    [void]Dispose() {
        $this.MailMsg.Dispose()
    }
}

class MailSendOrSave {
    [System.Net.Mail.MailMessage]$MailMessage
    [System.Net.Mail.smtpClient]$SmtpClient

    MailSendOrSave ([System.Net.Mail.MailMessage]$mailMessage) {
        $this.MailMessage = $mailMessage
        $this.SmtpClient = New-Object System.Net.Mail.smtpClient
    }

    # MailSendOrSave ([string]$smtpHost, [int]$smtpPort, [MailMsg]$mailMessage) {
    #     MailSmtp($mailMessage)
    #     $this.SmtpClient.host = $smtpHost
    #     $this.SmtpClient.Port = $smtpPort
    # }

    [void]SaveToDisk([string]$dropFolder)
    {
        try {
            $this.SmtpClient.host = "dummy.com" #Empty is not allowed.
            $this.SmtpClient.DeliveryMethod = [System.Net.Mail.SmtpDeliveryMethod]::SpecifiedPickupDirectory
            $this.SmtpClient.PickupDirectoryLocation = $dropFolder
            $this.Send()
        }
        catch {
            Write-Error -Message "[MailSendOrSave][ERROR] Exception Message: $($_.Exception.Message)"
        }
    }

    [void]Send()
    {
        try {
            $this.SmtpClient.Send($this.MailMessage)
        }
        catch {
            Write-Error -Message "[Send][ERROR] Exception Message: $($_.Exception.Message)"
        }
    }

    [void]Dispose() {
        $this.SmtpClient.Dispose()
    }
}
