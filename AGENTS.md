# KairoSphere engineering operating contract

## Product
Industrial supplier intelligence, sourcing, procurement, warehouse and invoice-control workspace, initially serving Suriname.

## Canonical workflow
Supplier discovery → qualification → catalogue → RFQ → supplier quotations → comparison → requisition → approval → PO → delivery → receiving/inspection → inventory ledger → invoice matching → settlement evidence → supplier performance.

See docs/SUPPLIER_TO_PROCUREMENT_WORKFLOW.md and docs/architecture/page-route-module-bindings.md.

## Architecture
- Vite browser app, vanilla JavaScript modules.
- Supabase Auth and publishable key only in browser.
- Organization and organization_members tenant model.
- PostgreSQL constraints, same-tenant relationships and RLS.
- Inventory is an append-only movement ledger with derived balances.
- Pure validation in src/domain; Supabase access in src/data; route modules in src/modules.

## Invariants
No cross-organization access. No service-role keys in browser. No silent FX conversions. Prospects are not verified suppliers. Quotes and requisitions are not approved purchase orders. Only accepted receipt quantities affect stock. Invoice paid status requires independent settlement evidence. Do not fabricate business facts.

## Current milestone
Milestone A: replace opportunity foundation with organization-scoped procurement shell. Acceptance requires responsive route navigation, organization creation, all operational registers, schema/RLS, tests and successful production build.

Next: RFQ line items and invitations, comparable supplier quote evaluation, approval actions and controlled requisition-to-PO conversion.

## Engineering
Run npm ci, npm test and npm run build on the exact commit. Review security and tenant boundaries. Keep migration files immutable once applied; use new migrations. Do not execute production schema changes, destructive data operations, access changes, financial transactions or external commitments without approval. Clearly distinguish implemented modules from planned workflow actions.
