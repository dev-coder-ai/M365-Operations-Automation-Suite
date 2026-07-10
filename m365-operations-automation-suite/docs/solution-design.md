# Solution design

## Principles

1. **The list is the truth.** State lives in SharePoint, never inside a flow run. Anyone can open the list and see reality.
2. **Policy is a parameter, logic is fixed.** Thresholds, recipients, channels and windows are flow parameters so the team changes behaviour without touching actions.
3. **Fail loud.** Every flow that runs unattended has an explicit failure path that notifies a named owner.
4. **Two front doors, one back end.** Forms and Power Apps both feed the same list, so adoption isn't blocked on one input method.
5. **Familiar surfaces.** Output lands where people already look: Outlook, Teams, and an Excel table.

## Parameters surfaced per flow

| Flow | Parameter | Default | Purpose |
|---|---|---|---|
| Purchase Request Approval | `AutoApproveThreshold` | 250 | Spend at/below this skips manager approval |
| Purchase Request Approval | `OpsManagerEmail` | ops.manager@contoso.com | Failure / timeout notifications |
| Purchase Request Approval | `FinanceTeamWebhookChannel` | Finance Operations | Teams channel for approved-request cards |
| Document Review Reminder | `ReminderWindowDays` | 7 | How far ahead to look for due reviews |
| Weekly Operations Report | `ReportRecipients` | ops.manager; finance.lead | Who receives the weekly summary |

## Naming conventions

- Flows: `<Domain> <Action>` — e.g. *Purchase Request Approval*.
- Actions: verb-first, underscore-spaced, describing intent not connector — `Email_requestor_approved`, not `Send_an_email_(V2)_3`.
- SharePoint internal field names: PascalCase, no spaces, set explicitly at provisioning so flow references never break on a display-name change.

## Error handling pattern

The approval flow wraps its decision in a condition whose **configure-run-after** includes `Failed` and `TimedOut` on the failure action. The reminder and report flows are idempotent: the reminder stamps each record so re-runs are safe, and the report is read-only against the source list.

## Security & governance notes

- Run flows under a **service account / shared connection** so they survive staff changes.
- Grant the connection **least privilege** — only the Operations site and the relevant mailbox.
- Keep an unmanaged solution in a **dev environment**, export to **managed** for production.
- These flows touch only the two lists and one mailbox they need, keeping them inside typical DLP policy.
