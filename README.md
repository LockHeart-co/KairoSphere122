# KairoSphere

**Industrial supplier intelligence, sourcing, procurement and warehouse operations.**

KairoSphere manages the operating path from supplier discovery to purchasing, receiving, inventory control, invoice matching and supplier performance. Initial operating market: Suriname.

## Application modules
- Organization-based workspace creation and authenticated access.
- Supplier discovery, onboarding, qualification and supplier records.
- Product catalogue and warehouse registers.
- RFQ, supplier quotation, requisition and purchase-order registers.
- Receiving, inventory movement ledger, invoice control and supplier reviews.
- Operational dashboard with sourcing, purchase exposure and control queues.
- Currency separation for USD and SRD.
- PostgreSQL schema with tenant-aware foreign keys, row-level security and derived inventory balances.

## End-to-end workflow
Supplier discovery → qualification → product catalogue → RFQ → quotation comparison → requisition → approval → purchase order → delivery → receiving and inspection → inventory ledger → invoice three-way match → settlement evidence → supplier performance.

See [workflow](docs/SUPPLIER_TO_PROCUREMENT_WORKFLOW.md), [operating architecture](docs/architecture/operating-model.md), [page/route/module bindings](docs/architecture/page-route-module-bindings.md), and [data contracts](docs/architecture/data-contracts.md).

## Run locally
Requirements: Node.js 20.19+.

1. Copy `.env.example` to `.env.local`.
2. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` using the project URL and publishable key. Never place a service-role or secret key in browser code.
3. Review and apply the timestamped SQL migrations to the intended Supabase project in order.
4. Enable Supabase email/password authentication and allow the local and Pages URLs as email redirect destinations.
5. Run `npm ci`, `npm test`, and `npm run dev`.
6. Build with `npm run build`.

## GitHub Pages
Configure Actions variables `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`. Add this URL to the Supabase Auth redirect allowlist:

`https://jakelethard-star.github.io/KairoSphere122-0605e52e/`

## Operating controls
- Every operational record belongs to an organization and is protected by RLS.
- Inventory is a movement ledger; balances are derived, not manually overwritten.
- Currencies are never silently combined or converted.
- A supplier prospect is not a verified supplier.
- An invoice is not marked paid without independent settlement evidence.
- KairoSphere records payment evidence; it does not execute money movement.
- Unknown, estimated and unverified information remains distinguishable.

## Implementation boundary
The current build provides the application shell, organization creation, module navigation, register/list/create screens and dashboard. Detailed RFQ line editing, quote scoring, approval actions, PO conversion, receipt-to-ledger posting and invoice three-way matching remain next implementation increments. A visible register does not imply that its full workflow automation is complete.

See [retirement register](docs/engineering/retirement-register.md) for replaced components and data disposition.
