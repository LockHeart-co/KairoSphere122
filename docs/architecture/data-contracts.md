# Data contracts

All operational data is organization-scoped. IDs are UUIDs. Child records reference parents using organization-aware composite foreign keys.

- Supplier: legal identity, country, registration reference, contacts, payment terms, currency, qualification and risk state.
- Product: organization-unique SKU, name, category, unit and description.
- RFQ: requirements, response date, invited suppliers and requested line items.
- Quote: supplier, RFQ, line prices, currency, validity and lead time.
- Requisition: requester, department, justification, need date, lines and estimated amount.
- Approval: actor, decision, comment and timestamp.
- Purchase order: supplier, originating requisition/quote, line commitments, currency and dates.
- Goods receipt: PO, warehouse, received/accepted/rejected quantities and inspection evidence.
- Inventory movement: warehouse, product, signed movement type, positive quantity, source reference and timestamp.
- Invoice: supplier, PO, invoice lines, match status and exception history.
- Settlement evidence: reference, date and evidence; payment status must not be asserted without these.
- Supplier review: period, delivery and quality scores with supporting notes.

Never infer bank details, certifications, beneficial ownership or registration verification. Keep unknown values null and distinguish unverified from verified.
