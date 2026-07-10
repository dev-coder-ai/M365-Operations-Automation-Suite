# Importing the flows

You have two options.

## Option A — import the solution (recommended)

1. Zip the contents of `../solution-export/` (so `solution.xml` is at the root of the zip).
2. In Power Automate / Power Apps: **Solutions → Import solution → Browse** to the zip.
3. During import, map each connection reference to a connection you own (SharePoint, Forms, Approvals, Teams, Office 365, Excel).
4. Open the imported flow and set the parameters at the top (site URL, form id, threshold, recipients).
5. Turn the flow on.

## Option B — recreate from the definition JSON

Each `*/definition.json` is the flow's Workflow Definition Language. To rebuild a flow:

1. Create a new flow with the matching trigger (Forms / Recurrence).
2. Use **Peek code** on each action to compare against the JSON, or rebuild the actions in order following `../docs/flow-walkthrough.md`.
3. The JSON is the authoritative spec for trigger types, connector operation ids, expressions and run-after settings.

> The `definition.json` files are kept clean (no environment-specific connection ids) so they read well in source control and review. The `solution-export/Workflows/*.json` file is the same definition wrapped in the connection-reference envelope an actual export produces.

## Connector operation reference

| Action in the flows | Connector | operationId |
|---|---|---|
| New response trigger | Forms | `CreateFormWebhook` |
| Get response details | Forms | `GetFormResponseDetails` |
| Create / update list item | SharePoint | `PostItem` / `PatchItem` |
| Get items | SharePoint | `GetItems` |
| Start and wait for approval | Approvals | `StartAndWaitForAnApproval` |
| Post message | Teams | `PostMessageToConversation` |
| Send email | Office 365 Outlook | `SendEmailV2` |
| Add row to table | Excel Online (Business) | `AddRowV2` |
