# GhostLedger

Reusable plain-text accounting boilerplate for any company.

This repository is country-agnostic at the bookkeeping layer and supports country-specific tax workflows via dedicated skills.

GhostLedger depends on Ledger CLI (`ledger`): https://github.com/ledger/ledger

## Purpose

- Keep books in double-entry plain-text journals.
- Separate raw source files from normalized ledger postings.
- Generate financial reports from one source of truth.
- Keep tax/compliance working papers organized by country and year.

## Installation

Recommended: let Claude Code, Codex, or another coding agent perform setup for you.

Use a prompt like:

```text
Install this GhostLedger https://github.com/yborunov/ghostledger into a new repo for my company.
```

Alternatively, execute this command in a terminal:
```
curl -sL https://raw.githubusercontent.com/yborunov/ghostledger/main/install.sh | bash
```


The setup flow will:
- Prompt for your company name
- Prompt for target directory path
- Verify Ledger CLI is installed (and try auto-install on supported systems)
- Download and set up the boilerplate with current year
- Replace all placeholders automatically

## Quick Start

1. Upload receipts / invoices to `transaction-imports/`
2. Open the repository root in your coding agent (Claude Code, Codex, Pi).
2. Ask you agent:
```
import transactions into the ledger and generate balance sheet and P&L statement for the year
```

## Prompting Guide for Claude Code / Codex

Keep prompts minimal. Agents should read repository docs and skill files for the full workflow.

Day-to-day prompt examples:

```text
Generate a balance sheet for <period>.
```

```text
Generate the reports I need for <period> from this ledger.
```

```
Add these new transactions to the books and update reports.
```

## Updating GhostLedger

Use your coding agent to run `update.sh` and summarize changed files.

Prompt template:

```text
Update this repo from the latest GhostLedger boilerplate and summarize changes.
```

Alternatively, run this command from your working directory in terminal:
```
curl -sL https://raw.githubusercontent.com/yborunov/ghostledger/main/update.sh | bash
```

The updater will:
- Create `.bak` backups of any files it modifies
- Update boilerplate core files (skills, docs, templates)
- Auto-replace `<COMPANY_NAME>` and `<YEAR>` placeholders with your detected values
- Add any new files from the latest boilerplate
- **Never touch your transaction data, reports, or actual ledger entries**

After updating, review any `.bak` files if you need to restore previous versions.

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

## Notes

- This repository is an operational bookkeeping and working-paper framework.
- It does not replace legal, tax, or accounting advice.
