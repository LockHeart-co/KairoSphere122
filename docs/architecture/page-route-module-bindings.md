# Page, route, module and data bindings

| Page | Route | Module | Primary data |
|---|---|---|---|
| Operations overview | #dashboard | src/modules/dashboard.js | suppliers, rfqs, requisitions, purchase_orders, goods_receipts, invoices |
| Suppliers | #suppliers | src/modules/registry.js | suppliers, supplier_contacts, supplier_products |
| Product catalogue | #catalog | src/modules/registry.js | products, supplier_products |
| Warehouses | #warehouses | src/modules/registry.js | warehouses |
| RFQs | #sourcing | src/modules/registry.js | rfqs, rfq_lines, rfq_invitations |
| Quotations | #quotations | src/modules/registry.js | supplier_quotes, supplier_quote_lines |
| Requisitions | #requisitions | src/modules/registry.js | requisitions, requisition_lines, approvals |
| Purchase orders | #orders | src/modules/registry.js | purchase_orders, purchase_order_lines |
| Receiving | #receiving | src/modules/registry.js | goods_receipts, goods_receipt_lines |
| Inventory ledger | #inventory | src/modules/registry.js | inventory_movements, inventory_balances |
| Invoices | #invoices | src/modules/registry.js | invoices, invoice_lines, invoice_match_exceptions |
| Performance | #performance | src/modules/registry.js | supplier_reviews, audit_events |

The registry supplies shared forms and list behavior. Workflow-specific line-item editors and approval actions remain separate increments; a route shell alone does not complete a workflow.
