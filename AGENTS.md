# AGENTS

This repo is a GhostLedger **boilerplate template**, not a company-specific ledger.

## High-signal facts

- Keep placeholders in template files unless task explicitly asks to instantiate a company repo: `<COMPANY_NAME>`, `<YEAR>`, `<COUNTRY>`.
- GhostLedger depends on Ledger CLI (`ledger`): https://github.com/ledger/ledger.
- `main.ledger` is the execution entrypoint for all checks/reports; it only works through explicit `include` lines.
- Canonical normalized journals expected by the template are `imports/<YEAR>/bank.ledger`, `imports/<YEAR>/card.ledger`, `imports/<YEAR>/invoices.ledger`.
- If you add a new normalized journal file, also update `main.ledger` include statements or Ledger CLI will ignore it.

## Agent execution goals

- Use `main.ledger` as the only execution entrypoint for checks and reports.
- Validate global book integrity before generating any reporting output.
- Review period register activity when reconciling or classifying transactions.
- Produce P&L totals for requested periods and balance sheet totals as of requested dates.
- Report unresolved assumptions, missing evidence, and classification risk items.

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
