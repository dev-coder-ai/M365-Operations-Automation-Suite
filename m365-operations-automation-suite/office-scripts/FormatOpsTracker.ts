/**
 * Ops Tracker formatter & summariser
 * -----------------------------------
 * Runs against the "OpsTracker.xlsx" workbook used by the Weekly Operations Report flow.
 * Called either on demand or from Power Automate via the "Run script" action.
 *
 * What it does:
 *   1. Normalises the PurchaseLog table (header style, currency format, banded rows).
 *   2. Writes a small Summary sheet: count + total value by status.
 *   3. Returns the summary so a calling flow can use it in an email or Teams card.
 *
 * Office Scripts use the ExcelScript API (TypeScript). No external dependencies.
 */

interface StatusSummary {
  status: string;
  count: number;
  totalAmount: number;
}

function main(workbook: ExcelScript.Workbook): StatusSummary[] {
  const sheet = workbook.getWorksheet("PurchaseLog") ?? workbook.getActiveWorksheet();
  const table = sheet.getTables()[0];
  if (!table) {
    throw new Error("No table found on the PurchaseLog sheet. Expected a table named 'PurchaseLog'.");
  }

  // --- 1. Formatting -------------------------------------------------------
  const headerRange = table.getHeaderRowRange();
  headerRange.getFormat().getFill().setColor("#0E2138");
  headerRange.getFormat().getFont().setColor("#FFFFFF");
  headerRange.getFormat().getFont().setBold(true);
  table.setShowBandedRows(true);
  table.setPredefinedTableStyle("TableStyleMedium2");

  const amountCol = table.getColumnByName("Amount");
  if (amountCol) {
    amountCol.getRangeBetweenHeaderAndTotal().setNumberFormat("£#,##0.00");
  }

  // --- 2. Aggregate by status ---------------------------------------------
  const bodyRange = table.getRangeBetweenHeaderAndTotal();
  const values = bodyRange.getValues();
  const headers = headerRange.getValues()[0].map(String);
  const statusIdx = headers.indexOf("Status");
  const amountIdx = headers.indexOf("Amount");

  const buckets = new Map<string, StatusSummary>();
  for (const row of values) {
    const status = String(row[statusIdx] ?? "Unknown");
    const amount = Number(row[amountIdx] ?? 0);
    const b = buckets.get(status) ?? { status, count: 0, totalAmount: 0 };
    b.count += 1;
    b.totalAmount += amount;
    buckets.set(status, b);
  }
  const summary = Array.from(buckets.values()).sort((a, b) => b.totalAmount - a.totalAmount);

  // --- 3. Write Summary sheet ---------------------------------------------
  let summarySheet = workbook.getWorksheet("Summary");
  if (summarySheet) {
    summarySheet.delete();
  }
  summarySheet = workbook.addWorksheet("Summary");
  summarySheet.getRange("A1:C1").setValues([["Status", "Count", "Total Amount"]]);
  summarySheet.getRange("A1:C1").getFormat().getFont().setBold(true);
  summary.forEach((s, i) => {
    const r = i + 2;
    summarySheet.getRange(`A${r}:C${r}`).setValues([[s.status, s.count, s.totalAmount]]);
    summarySheet.getRange(`C${r}`).setNumberFormat("£#,##0.00");
  });
  summarySheet.getRange("A:C").getFormat().autofitColumns();

  return summary;
}
