# SharePoint list schemas

Field **internal names** matter: the flows reference them directly, so they are set explicitly at provisioning and never rely on display names.

## Purchase Requests

| Display name | Internal name | Type | Notes |
|---|---|---|---|
| Title | Title | Text | The requested item |
| Requestor | Requestor | Text | Submitter email |
| Amount | Amount | Currency | Parsed to float in the flow |
| Department | Department | Text | |
| Justification | Justification | Note | Free text |
| Approval Notes | ApprovalNotes | Note | Manager comment / auto-approve note |
| Status | Status | Choice | Pending · Approved · Rejected |

## Documents Register

| Display name | Internal name | Type | Notes |
|---|---|---|---|
| Title | Title | Text | Document name |
| Document Owner | DocumentOwner | Person | Reminder recipient |
| Review Date | ReviewDate | DateTime | Drives the reminder window |
| Last Reminder Sent | LastReminderSent | DateTime | Stamped to prevent repeats |
| Review Status | ReviewStatus | Choice | Current · Due · Reminded · Overdue |

## OpsTracker.xlsx (Excel table `PurchaseLog`)

| Column | Type |
|---|---|
| RequestId | Number |
| Item | Text |
| Amount | Currency |
| Status | Text |
| DecidedOn | Date/time |
