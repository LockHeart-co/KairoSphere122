# Security policy

KairoSphere handles supplier, purchasing, inventory and invoice-control information. Security reports should be sent privately to the repository owner through GitHub's private vulnerability reporting or the contact channel configured by the owner.

Please do not publish exploit details, access tokens, database URLs containing credentials, supplier documents or customer records in public issues.

## Scope
- Authentication and session handling.
- Organization membership and tenant isolation.
- Row-level security and database functions.
- Supplier, procurement, warehouse and invoice records.
- Build, deployment and dependency supply chain.

## Handling rules
- Browser applications use only the Supabase publishable key.
- Never commit service-role keys, database passwords or private credentials.
- Do not use real supplier/client information in tests or public examples.
- Report suspected cross-organization access immediately and include a minimal reproduction without confidential data.
- Do not test against production data or perform destructive actions without explicit authorization.

## Supported version
The supported version is the current `main` branch and the currently deployed application revision.
