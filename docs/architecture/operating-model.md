# Operating architecture

- Presentation: Vite ES modules and route-driven modules.
- Domain: pure validation in src/domain.
- Data access: Supabase adapters in src/data.
- Identity and tenancy: Supabase Auth, organizations and organization_members.
- Persistence: PostgreSQL constraints, same-organization foreign keys and RLS.
- Inventory: movement ledger with derived balance view.
- Evidence: actor, source, status and timestamps for consequential records.

Bounded contexts: supplier master; product catalogue; sourcing; procurement; warehouse; invoice controls; supplier performance and audit.

Never expose service-role secrets. Never mix currencies without explicit FX provenance. Do not mark invoices paid without independent settlement evidence. Do not silently promote unverified supplier information into approved master data.
