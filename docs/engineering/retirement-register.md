# Legacy retirement register

The opportunity-only dashboard, opportunity CRUD adapter, opportunity-specific domain module and opportunity-only tests have been removed from the active application runtime. The active interface is now supplier-to-procurement oriented.

The old opportunity SQL migrations remain in migration history; they are not imported into the new runtime. Historical migrations must not be edited or removed because they may have been applied. The new schema is additive. Existing opportunity records, if any, were not read, transformed or deleted and are no longer queried by the new UI. Any later data retirement requires a reviewed migration and explicit approval.

No live Supabase data was migrated or deleted in this code reconfiguration.
