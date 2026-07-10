<#
.SYNOPSIS
    Provisions the SharePoint Online lists used by the M365 Operations Automation Suite.

.DESCRIPTION
    Creates and configures the three lists the Power Automate flows depend on:
      - Purchase Requests   (approval workflow source of truth)
      - Documents Register  (document review reminders)
      - Ops Tracker is an Excel table in the document library, provisioned separately.

    Idempotent: re-running skips lists/fields that already exist.

.PREREQUISITES
    Install-Module PnP.PowerShell -Scope CurrentUser
    An app registration or interactive login with Manage Lists permission on the site.

.EXAMPLE
    ./provision-lists.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Operations"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl
)

$ErrorActionPreference = "Stop"

Write-Host "Connecting to $SiteUrl ..." -ForegroundColor Cyan
Connect-PnPOnline -Url $SiteUrl -Interactive

function Ensure-List {
    param([string]$Title, [string]$Template = "GenericList")
    $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if ($null -eq $list) {
        Write-Host "Creating list '$Title'" -ForegroundColor Green
        $list = New-PnPList -Title $Title -Template $Template -EnableVersioning
    } else {
        Write-Host "List '$Title' already exists - skipping" -ForegroundColor DarkGray
    }
    return $list
}

function Ensure-Field {
    param([string]$List, [string]$InternalName, [string]$DisplayName, [string]$Type, [string[]]$Choices)
    $existing = Get-PnPField -List $List -Identity $InternalName -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host "  field '$DisplayName' exists - skipping" -ForegroundColor DarkGray
        return
    }
    if ($Type -eq "Choice") {
        Add-PnPField -List $List -InternalName $InternalName -DisplayName $DisplayName -Type Choice -Choices $Choices -AddToDefaultView | Out-Null
    } else {
        Add-PnPField -List $List -InternalName $InternalName -DisplayName $DisplayName -Type $Type -AddToDefaultView | Out-Null
    }
    Write-Host "  + field '$DisplayName' ($Type)" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 1. Purchase Requests
# ---------------------------------------------------------------------------
Ensure-List -Title "Purchase Requests" | Out-Null
Ensure-Field -List "Purchase Requests" -InternalName "Requestor"     -DisplayName "Requestor"     -Type "Text"
Ensure-Field -List "Purchase Requests" -InternalName "Amount"        -DisplayName "Amount"        -Type "Currency"
Ensure-Field -List "Purchase Requests" -InternalName "Department"    -DisplayName "Department"    -Type "Text"
Ensure-Field -List "Purchase Requests" -InternalName "Justification" -DisplayName "Justification" -Type "Note"
Ensure-Field -List "Purchase Requests" -InternalName "ApprovalNotes" -DisplayName "Approval Notes"-Type "Note"
Ensure-Field -List "Purchase Requests" -InternalName "Status"        -DisplayName "Status"        -Type "Choice" -Choices @("Pending","Approved","Rejected")

# ---------------------------------------------------------------------------
# 2. Documents Register
# ---------------------------------------------------------------------------
Ensure-List -Title "Documents Register" | Out-Null
Ensure-Field -List "Documents Register" -InternalName "DocumentOwner"    -DisplayName "Document Owner"     -Type "User"
Ensure-Field -List "Documents Register" -InternalName "ReviewDate"       -DisplayName "Review Date"        -Type "DateTime"
Ensure-Field -List "Documents Register" -InternalName "LastReminderSent" -DisplayName "Last Reminder Sent" -Type "DateTime"
Ensure-Field -List "Documents Register" -InternalName "ReviewStatus"     -DisplayName "Review Status"      -Type "Choice" -Choices @("Current","Due","Reminded","Overdue")

Write-Host "`nProvisioning complete." -ForegroundColor Cyan
Write-Host "Next: point the three Power Automate flows at this site and import the Excel Ops Tracker into the Shared Documents library." -ForegroundColor Yellow

Disconnect-PnPOnline
