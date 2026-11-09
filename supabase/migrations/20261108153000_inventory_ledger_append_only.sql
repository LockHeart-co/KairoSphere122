-- Inventory movement history is append-only. Posting workflows create rows;
-- authenticated clients cannot mutate or remove historical movements.
drop policy if exists tenant_update on public.inventory_movements;
drop policy if exists tenant_delete on public.inventory_movements;
revoke update, delete on public.inventory_movements from authenticated;
