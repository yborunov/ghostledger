# GhostLedger

Reusable plain-text accounting boilerplate for any company.

This repository is country-agnostic at the bookkeeping layer and supports country-specific tax workflows via dedicated skills.

## Purpose

- Keep books in double-entry plain-text journals.
- Separate raw source files from normalized ledger postings.
- Generate financial reports from one source of truth.
- Keep tax/compliance working papers organized by country and year.

## Repository Structure

- `main.ledger` - root ledger file with `include` statements.
- `imports/<YEAR>/` - normalized `.ledger` files.
- `transaction-imports/<YEAR>/` - raw CSV/XLS exports from banks/providers.
- `expenses/<YEAR>/` - invoices and receipts.
- `reports/<YEAR>/` - generated P&L, balance sheet, and working notes.
- `tax/<YEAR>/` - annual tax/compliance working papers.
- `skills/accounting/SKILL.md` - global bookkeeping workflow.
- `skills/tax-us/SKILL.md` - US tax workflow and form mapping.
- `skills/tax-ca/SKILL.md` - Canada tax workflow and form mapping.

## Quick Start

1. Clone this repository.
2. Replace placeholders in docs (`<COMPANY_NAME>`, `<YEAR>`, `<COUNTRY>`).
3. Add raw bank/provider files to `transaction-imports/<YEAR>/`.
4. Add invoices/receipts to `expenses/<YEAR>/`.
5. Convert source files into normalized entries in `imports/<YEAR>/`.
6. Update `main.ledger` includes.
7. Validate books and generate reports.

## Updating from Boilerplate

To pull the latest boilerplate updates into your working repository:

```bash
curl -sL https://raw.githubusercontent.com/yborunov/GhostLedger/main/update.sh | bash
```

This command downloads and runs the update script which will:
- Create `.bak` backups of any files it modifies
- Update boilerplate core files (skills, docs, templates)
- Auto-replace `<COMPANY_NAME>` and `<YEAR>` placeholders with your detected values
- Add any new files from the latest boilerplate
- **Never touch your transaction data, reports, or actual ledger entries**

After updating, review any `.bak` files if you need to restore previous versions.

## Core Commands

Validate books:

```bash
ledger -f main.ledger bal
ledger -f main.ledger reg
```

Profit and Loss for full year:

```bash
ledger -f main.ledger bal Income Expenses --period "from YYYY-01-01 to YYYY-12-31"
```

Balance Sheet as of year-end:

```bash
ledger -f main.ledger bal Assets Liabilities Equity --period "to <next-year>-01-01"
```

## Tax and Compliance

- Use `tax/<YEAR>/` for annual tax return working papers.
- Use skill files under `skills/` to drive repeatable workflows for specific jurisdictions (US, Canada, etc.).
- Keep all filings and calculations as draft until reviewed by a qualified local professional.

## Notes

- This repository is an operational bookkeeping and working-paper framework.
- It does not replace legal, tax, or accounting advice.
