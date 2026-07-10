# Flow walkthrough

A plain-language, action-by-action tour of each flow. This is the document you read to understand *why* each step is there — useful for handover, and the exact level of explanation an operations person needs to maintain the flows themselves.

---

## 1. Purchase Request Approval

**Trigger — `When_a_new_purchase_request_is_submitted`**
A Microsoft Forms webhook. The flow starts the instant a request is submitted; nothing polls or waits. Every flow has exactly one trigger.

**`Get_response_details`**
The trigger only hands over a response id. This action pulls the actual answers (item, amount, department, justification, manager email). Those become *dynamic content* for every step below.

**`Initialise_Amount`**
Form answers arrive as text. We parse the amount into a float variable once, so the threshold comparison and the Excel log both use a clean number. `coalesce(..., '0')` guards against an empty answer.

**`Create_request_record_in_SharePoint`**
Writes the request to the `Purchase Requests` list with status `Pending`. From this point the request exists as a tracked, auditable record independent of the flow run.

**`Check_if_auto_approve` (condition)**
If the amount is at or below `AutoApproveThreshold`, set the record to `Approved` and stop — small spends don't need a manager. Otherwise, go to the approval branch. Keeping the threshold a *parameter* means the team changes policy without editing logic.

**`Start_and_wait_for_manager_approval`**
The Approvals connector emails the manager an Approve/Reject card and pauses the run until they respond. The connector handles the email, the buttons, and capturing the result.

**`Condition_Approved`**
Branches on `outcome == 'Approve'`.
- *Approved:* update the record, post an approved card to Teams, email the requestor, append a row to the Excel tracker.
- *Rejected:* update the record to `Rejected` and email the requestor the manager's comment.

**`Notify_owner_on_failure`**
Runs only if the main condition `Failed` or `TimedOut` (configure-run-after). The process owner gets an email instead of the failure going unnoticed. This is the habit that separates a hobby flow from one a business relies on.

---

## 2. Document Review Reminder

**Trigger — `Every_weekday_at_8am`**
A recurrence trigger. Scheduled flows are how you turn "someone has to remember to check" into "the system checks for you."

**`Get_documents_due_for_review`**
An OData `$filter` on the list pulls only documents whose `ReviewDate` falls inside the reminder window *and* haven't already been reminded. Filtering on the server (not with a later `Condition`) keeps the run fast and cheap.

**`For_each_document`**
Loops the matched items, with concurrency set to 8 so a large batch still finishes quickly.
- **`Determine_if_overdue`** — compares `ReviewDate` to now and sends either an *overdue* (high-importance) or *due-soon* email to the document owner.
- **`Mark_as_reminded`** — stamps the record so the next run skips it. Without this, owners would be emailed every single day.

---

## 3. Weekly Operations Report

**Trigger — `Every_Monday_at_7am`** — recurrence.

**`Get_requests_from_last_7_days`** — `$filter` on `Created` for the trailing week.

**`Select_report_columns`** — reshapes the raw list items into just the columns the report needs. A `Select` is cheaper and cleaner than building a string by hand in a loop.

**`Build_HTML_table`** — the `Create HTML table` action turns that array into an email-ready table in one step.

**`Compose_total_value`** — a small expression to total the amounts for the summary line.

**`Send_weekly_summary_email`** then **`Post_summary_to_Teams`** — deliver the same summary to both inbox and channel, so nobody has to go looking for it.

---

## Concepts these flows teach

- Triggers vs. actions; one trigger per flow
- Dynamic content and variables
- Conditions and branching on a single value
- OData `$filter` / `$orderby` to do work server-side
- Date math with `addDays`, `utcNow`, `formatDateTime`
- `Select` + `Create HTML table` for reporting
- Configure-run-after for error handling
- Parameterising policy (thresholds, recipients, windows) instead of hard-coding it
