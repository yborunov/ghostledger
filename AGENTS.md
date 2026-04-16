# AGENTS

This repo is a GhostLedger **boilerplate template**, not a company-specific ledger.

## High-signal facts

- Keep placeholders in template files unless task explicitly asks to instantiate a company repo: `<COMPANY_NAME>`, `<YEAR>`, `<COUNTRY>`.
- GhostLedger depends on Ledger CLI (`ledger`): https://github.com/ledger/ledger.
- `main.ledger` is the execution entrypoint for all checks/reports; it only works through explicit `include` lines.
- Canonical normalized journals expected by the template are `imports/<YEAR>/bank.ledger`, `imports/<YEAR>/card.ledger`, `imports/<YEAR>/invoices.ledger`.
- If you add a new normalized journal file, also update `main.ledger` include statements or Ledger CLI will ignore it.

## Commands (actual repo source of truth)

- Validate ledger structure: `ledger -f main.ledger bal`
- Inspect postings register: `ledger -f main.ledger reg`
- Verify Ledger CLI is installed: `ledger --version`
- Year register slice: `ledger -f main.ledger reg --period "from <YEAR>-01-01 to <YEAR>-12-31"`
- P&L: `ledger -f main.ledger bal Income Expenses --period "from <start> to <end>"`
- Balance sheet: `ledger -f main.ledger bal Assets Liabilities Equity --period "to <next-year>-01-01"`

## Directory intent (do not mix)

- `transaction-imports/<YEAR>/`: raw provider exports; treat as immutable source evidence.
- `expenses/<YEAR>/`: original invoices/receipts; keep originals unchanged.
- `imports/<YEAR>/`: normalized double-entry postings derived from raw sources.
- `reports/<YEAR>/`: generated outputs and close notes.
- `tax/<YEAR>/`: draft tax/compliance working papers.

## Boilerplate update/install behavior

- `install.sh` creates a new working repo from GitHub and intentionally does **not** copy `.git*`, `install.sh`, `update.sh`, `update-test.sh`.
- `install.sh` checks for `ledger`; if missing, it tries auto-install (`brew install ledger` on macOS with Homebrew, `apt-get install ledger` on Debian/Ubuntu), otherwise exits with manual-install instructions.
- `update.sh` updates only selected boilerplate files plus `main.ledger`, creates `.bak` backups, and writes `.boilerplate-version`.
- `update.sh` is designed to avoid user data paths (`imports/`, `expenses/`, `transaction-imports/`, `reports/`, `tax/*/*`, `*.ledger` in discovery step); do not "simplify" this safety model without explicit request.

## Existing instruction sources

- Bookkeeping workflow: `skills/accounting/SKILL.md`
- Jurisdiction-specific tax workflows: `skills/tax-us/SKILL.md`, `skills/tax-ca/SKILL.md`
