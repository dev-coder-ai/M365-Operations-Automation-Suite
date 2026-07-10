# M365 Operations Automation Suite

Implementation of internal operations automation built entirely on the Microsoft 365 / Power Platform stack. It packages the three automations an operations team asks for first — **approvals, reminders, and reporting** — as real, importable artifacts, alongside the SharePoint provisioning, a Power Apps front end, an Office Script, and an Azure Logic App equivalent.

---

## What problem it solves

An operations team was spending hours each week on the same manual loops: chasing managers for purchase sign-off over email, remembering which documents were due for review, and hand-assembling a weekly status report. None of it needed a human judgement call — it needed routing, reminders, and aggregation. This suite replaces those loops with three Power Automate flows backed by SharePoint as the system of record.

The design goal was deliberately **maintainability over cleverness**: an in-house operations person should be able to open any flow, understand it, and change it without help. That principle drives the parameterisation, naming, and error handling throughout.

## Tools demonstrated

| Capability | Tool | Where in this repo |
|---|---|---|
| Workflow automation | Power Automate | `power-automate/` |
| Solution packaging | Power Platform solutions | `solution-export/` |
| Data backbone | SharePoint Online lists | `sharepoint/` |
| Low-code front end | Power Apps (canvas) | `power-apps/` |
| Spreadsheet automation | Office Scripts (Excel) | `office-scripts/` |
| Advanced / cloud integration | Azure Logic Apps (ARM) | `logic-apps/` |
| Notifications & approvals | Teams, Outlook, Approvals | inside each flow |
| Data capture | Microsoft Forms | trigger of the approval flow |

## The three automations

1. **Purchase Request Approval** (`power-automate/PurchaseRequestApproval`)
   Form submission → record in SharePoint → auto-approve under a threshold, otherwise route to the manager via the Approvals connector → on the outcome, update the record, notify the requestor (Outlook), post to Teams, and log to Excel. Includes a failure/timeout notification path.

2. **Document Review Reminder** (`power-automate/DocumentReviewReminder`)
   Scheduled weekday run → query the Documents Register for items due within a configurable window → branch on overdue vs. due-soon → email the owner → stamp the record so it isn't reminded twice.

3. **Weekly Operations Report** (`power-automate/WeeklyOperationsReport`)
   Scheduled Monday run → pull the last 7 days of requests → shape the columns → build an HTML table → email the summary and post a short note to Teams.

See `docs/flow-walkthrough.md` for a step-by-step explanation of each action and the reasoning behind it.

## Repository layout

```
m365-operations-automation-suite/
├─ README.md                       ← you are here
├─ docs/
│  ├─ architecture.md              ← how the pieces connect (with diagram)
│  ├─ solution-design.md           ← design decisions & parameters
│  └─ flow-walkthrough.md          ← action-by-action teaching walkthrough
├─ power-automate/                 ← clean flow definitions (WDL JSON)
│  ├─ PurchaseRequestApproval/definition.json
│  ├─ DocumentReviewReminder/definition.json
│  ├─ WeeklyOperationsReport/definition.json
│  └─ README.md                    ← how to import these into a tenant
├─ solution-export/                ← importable unmanaged solution structure
│  ├─ solution.xml
│  ├─ customizations.xml
│  ├─ [Content_Types].xml
│  └─ Workflows/PurchaseRequestApproval-A1F3C2E0.json
├─ sharepoint/
│  ├─ provision-lists.ps1          ← PnP PowerShell to create the lists
│  └─ list-schemas.md              ← column-by-column schema
├─ power-apps/
│  ├─ app-spec.md
│  └─ src/                         ← Power Fx YAML (pac canvas un/pack)
├─ office-scripts/
│  └─ FormatOpsTracker.ts          ← ExcelScript formatter + summariser
└─ logic-apps/
   └─ azuredeploy.json             ← deployable ARM template (live demo)
```

## How to stand it up

A full walkthrough is in `docs/architecture.md`; the short version:

1. **Provision the lists** — run `sharepoint/provision-lists.ps1 -SiteUrl <yoursite>` (needs the PnP.PowerShell module).
2. **Import the flows** — either import `solution-export/` as an unmanaged solution, or paste each `power-automate/*/definition.json` into a new flow. See `power-automate/README.md`.
3. **Point the connectors** — set the SharePoint site URL, Forms id, Teams channel, and recipient parameters at the top of each flow.
4. **(Optional) Front end** — pack `power-apps/src` with `pac canvas pack` and publish the Request Hub app.
5. **(Optional) Cloud demo** — deploy `logic-apps/azuredeploy.json` to a resource group to show the same approval logic running in Azure.

