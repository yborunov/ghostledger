# Skill: tax-ca

## Purpose

Prepare a draft Canada corporate tax package from the books for year `<YEAR>`.

This skill is designed for bookkeeping repositories using `main.ledger` and year-based import folders.

## Scope

- Primary default: Canadian corporate return workflow (T2).
- If entity type differs, adjust forms and mappings explicitly.

## Required Inputs

1. `year` (example: `2026`)
2. fiscal period start and end
3. entity profile assumptions (corporation type, first-year status, accounting method)
4. province/territory filing scope

If any input is missing, use best-known defaults and document assumptions.

## Standard Workflow

1. Ensure all source transactions are reflected in `imports/<YEAR>/` and included by `main.ledger`.
2. Validate books integrity using `main.ledger` as source of truth.
3. Generate income statement and year-end balance sheet figures.
4. Create/update Canada working papers under `tax/<YEAR>/`.
5. Keep working paper totals synchronized with the books.

## Validation Objectives

- Confirm global books balance.
- Review register activity for the full filing year.
- Produce requested-period P&L totals.
- Produce year-end balance sheet totals.
- Flag unresolved classification or compliance assumptions.

## Suggested Canada Working Papers

- `tax/<YEAR>/t2-draft.md`
- `tax/<YEAR>/t2-lines.json`
- `tax/<YEAR>/supporting-schedules.md`
- `tax/<YEAR>/advisor-handoff-checklist.md`

## Typical Form References

- T2 Corporation Income Tax Return
- GIFI-aligned mapping support where applicable
- Provincial schedules and supporting forms as required

## Output Contract

Return:

1. files created/updated
2. requested period totals
3. key line mapping values used
4. unresolved assumptions and compliance open items

## Compliance Note

Draft outputs only. Final filing positions must be reviewed by a qualified Canadian tax professional.
