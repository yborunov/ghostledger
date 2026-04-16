# GhostLedger

Reusable plain-text accounting boilerplate for any company.

This repository is country-agnostic at the bookkeeping layer and supports country-specific tax workflows via dedicated skills.

GhostLedger depends on Ledger CLI (`ledger`): https://github.com/ledger/ledger

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

## Installation

Recommended: let Claude Code, Codex, or another coding agent perform setup for you.

Use a prompt like:

```text
You are in the GhostLedger boilerplate repository.
Set up a new working repo using install.sh.
Use defaults where safe, explain each step briefly, and stop only if a destructive choice is required.
```

The setup flow will:
- Prompt for your company name
- Prompt for target directory path
- Verify Ledger CLI is installed (and try auto-install on supported systems)
- Download and set up the boilerplate with current year
- Replace all placeholders automatically

## Quick Start (AI-first)

1. Open the repository root in your coding agent.
2. Tell it this is a boilerplate template and placeholders must stay unchanged unless you explicitly ask to instantiate.
3. Ask it to process source documents into normalized entries under `imports/<YEAR>/`.
4. Ask it to keep `main.ledger` include statements in sync.
5. Ask it to run ledger validation and generate required reports.

## Updating from Boilerplate

Use your coding agent to run `update.sh` and summarize changed files.

Prompt template:

```text
Run the GhostLedger boilerplate updater in this repo.
Keep user data paths untouched, report what changed, and list any .bak files created.
```

The updater will:
- Create `.bak` backups of any files it modifies
- Update boilerplate core files (skills, docs, templates)
- Auto-replace `<COMPANY_NAME>` and `<YEAR>` placeholders with your detected values
- Add any new files from the latest boilerplate
- **Never touch your transaction data, reports, or actual ledger entries**

After updating, review any `.bak` files if you need to restore previous versions.

## Prompting Guide for Claude Code / Codex

Use prompts that describe goals, constraints, and expected outputs. Keep the agent operating from repo root.

Bookkeeping prompt template:

```text
Use this GhostLedger repo to process bookkeeping for <YEAR>.
Inputs are in transaction-imports/<YEAR>/ and expenses/<YEAR>/.
Create or update normalized journals in imports/<YEAR>/.
Ensure main.ledger includes every normalized journal file.
Validate the books, then produce P&L and balance sheet outputs for <period>.
Return: files changed, totals, and unresolved assumptions.
```

Year-close prompt template:

```text
Perform a year-close pass for <YEAR> in this GhostLedger repo.
Check journal completeness, run ledger validation, and prepare year-end reports in reports/<YEAR>/.
Call out classification risks, missing source docs, and next actions.
```

Tax working-paper prompt template:

```text
Create draft tax working papers for <COUNTRY> for <YEAR> using this GhostLedger repo.
Use books from main.ledger, keep assumptions explicit, and write outputs under tax/<YEAR>/.
Include line mappings, supporting schedules, and advisor handoff notes.
Return open compliance questions clearly.
```

## Tax and Compliance

- Use `tax/<YEAR>/` for annual tax return working papers.
- Use skill files under `skills/` to drive repeatable workflows for specific jurisdictions (US, Canada, etc.).
- Keep all filings and calculations as draft until reviewed by a qualified local professional.

## Notes

- This repository is an operational bookkeeping and working-paper framework.
- It does not replace legal, tax, or accounting advice.
