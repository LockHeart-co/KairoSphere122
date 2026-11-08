# Supplier-to-procurement workflow

Supplier discovery → qualification → product catalogue → RFQ preparation → supplier invitations → quotation capture and comparison → requisition → approval → purchase order → delivery → receiving and inspection → inventory ledger → invoice three-way match → settlement evidence → supplier performance.

| Stage | Route | Core records | Required next binding |
|---|---|---|---|
| Supplier onboarding | #suppliers | Supplier, contact, verification, risk | Approved suppliers eligible for RFQ invitation |
| Product catalogue | #catalog | SKU, product, unit, supplier-product mapping | RFQ and PO lines |
| Warehouse setup | #warehouses | Warehouse and location | Goods receipt destination |
| Sourcing | #sourcing | RFQ header, specifications and due date | Supplier invitations and RFQ lines |
| Quotations | #quotations | Supplier quote, line prices, validity and lead time | Comparable quote evaluation and award |
| Requisitions | #requisitions | Requester, justification, need date, estimate | Approval decision |
| Purchase orders | #orders | Approved commitment, supplier, lines, dates | Delivery and receiving |
| Receiving | #receiving | Delivery, PO, warehouse, received and accepted quantities | Accepted receipt creates stock movements |
| Inventory | #inventory | Append-only movement ledger | Derived stock balances |
| Invoice control | #invoices | Supplier invoice, PO, receipt, exceptions | Three-way match and settlement evidence |
| Performance | #performance | Delivery, quality, discrepancies, review | Future sourcing and qualification |

## Controls
- Organization membership is the tenant boundary; all operational tables use organization-scoped RLS and same-tenant foreign keys where a parent relationship exists.
- Write roles are separated: buyers manage sourcing and purchasing, warehouse roles manage receipt/inventory records, finance roles manage invoices, and owner/admin roles administer the workspace. Read-only members cannot write. Operational records have no direct delete policy.
- Client-created suppliers, RFQs, quotations, requisitions, purchase orders, receipts and invoices are forced into initial unapproved states. Direct client updates to qualification, approval, PO, receiving and invoice status are disabled until controlled transition actions exist. Approval rows cannot be client-inserted or edited.
- Database triggers append audit events for operational row changes. Audit history is readable only by organization owners/admins and cannot be inserted, updated or deleted by authenticated clients.
- Inventory is a movement ledger. A receipt is not stock until quantities are accepted; transfers are paired movements. Balances are derived.
- Currency remains explicit; never sum unlike currencies without a sourced FX rate and timestamp.
- Supplier prospect is not verified. RFQ/quote is not a PO. Requisition is not approval.
- Invoice paid status requires settlement reference, date and evidence. No money movement is executed.
- Unknown supplier claims remain unknown; do not fabricate verification, delivery, inspection or payment.

## Implementation boundary
The current application provides authentication, organization creation, module navigation, list/create registers and a dashboard. Detailed RFQ lines, quote scoring, approval actions, receipt-to-ledger posting and invoice three-way matching are planned next increments, not yet implemented.


## Supabase API exposure note
Supabase's 2026 Data API exposure change means SQL grants alone may not expose newly created tables through PostgREST. After reviewing the target project's Data API settings, explicitly expose the required public tables or schema there. Do not expose the private helper schema. The organization membership helper functions live in the non-exposed private schema; only authenticated users receive execute permission for the read-only policy helpers.
