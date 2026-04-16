# Skill: tax-us

## Purpose

Prepare a draft US corporate tax package from the books for year `<YEAR>`.

This skill is designed for bookkeeping repositories using `main.ledger` and year-based import folders.

## Scope

- Primary default: US C-corp return workflow (Form 1120).
- If entity type differs, adjust forms and mappings explicitly.

## Required Inputs

1. `year` (example: `2026`)
2. return period start and end
3. entity profile assumptions (entity type, first-year status, accounting method)
4. federal and state scope

If any input is missing, use best-known defaults and document assumptions.

## Standard Workflow

1. Ensure all source transactions are reflected in `imports/<YEAR>/` and included by `main.ledger`.
2. Validate books integrity using `main.ledger` as source of truth.
3. Generate income statement and year-end balance sheet figures.
4. Create/update US working papers under `tax/<YEAR>/`.
5. Keep working paper totals synchronized with the books.

## Validation Objectives

- Confirm global books balance.
- Review register activity for the full filing year.
- Produce requested-period P&L totals.
- Produce year-end balance sheet totals.
- Flag unresolved classification or compliance assumptions.

## Suggested US Working Papers

- `tax/<YEAR>/form-1120-draft.md`
- `tax/<YEAR>/form-1120-lines.json`
- `tax/<YEAR>/supporting-schedules.md`
- `tax/<YEAR>/advisor-handoff-checklist.md`

## Typical Form References

- Form 1120 (U.S. Corporation Income Tax Return)
- Schedule L, M-1, and M-2 support when applicable
- State return support files as required

## Output Contract

Return:

1. files created/updated
2. requested period totals
3. key line mapping values used
4. unresolved assumptions and compliance open items

## Compliance Note

Draft outputs only. Final filing positions must be reviewed by a qualified US tax professional.
