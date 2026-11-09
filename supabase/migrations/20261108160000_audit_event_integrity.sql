-- Immutable, database-generated audit history for operational records.
-- Audit payloads are restricted to owner/admin members because they may contain
-- commercial and financial record details.
create or replace function private.capture_audit_event()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row jsonb;
  v_before jsonb;
  v_after jsonb;
  v_org_id uuid;
  v_record_id uuid;
begin
  if tg_op = 'INSERT' then
    v_row := to_jsonb(new);
    v_after := v_row;
  elsif tg_op = 'UPDATE' then
    v_row := to_jsonb(new);
    v_before := to_jsonb(old);
    v_after := v_row;
  else
    v_row := to_jsonb(old);
    v_before := v_row;
  end if;

  v_org_id := (v_row ->> 'organization_id')::uuid;
  v_record_id := (v_row ->> 'id')::uuid;

  insert into public.audit_events (
    organization_id, actor_id, operation, table_name,
    record_id, before_data, after_data
  ) values (
    v_org_id, (select auth.uid()), tg_op, tg_table_name,
    v_record_id, v_before, v_after
  );

  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

revoke all on function private.capture_audit_event() from public, anon, authenticated;

do $$
declare
  t text;
begin
  foreach t in array array[
    'organization_members','suppliers','products','supplier_products',
    'supplier_contacts','warehouses','rfqs','rfq_lines','rfq_invitations',
    'supplier_quotes','supplier_quote_lines','requisitions','requisition_lines',
    'approvals','purchase_orders','purchase_order_lines','goods_receipts',
    'goods_receipt_lines','inventory_movements','invoices','invoice_lines',
    'invoice_match_exceptions','supplier_reviews'
  ]
  loop
    execute format('drop trigger if exists audit_row_change on public.%I', t);
    execute format(
      'create trigger audit_row_change after insert or update or delete on public.%I for each row execute function private.capture_audit_event()',
      t
    );
  end loop;
end $$;

-- Clients may read audit history only as organization owners/admins.
drop policy if exists tenant_read on public.audit_events;
create policy audit_admin_read on public.audit_events
  for select to authenticated
  using ((select private.has_org_role(organization_id, array['owner','admin']::text[])));

-- Audit rows are written only by the trusted SECURITY DEFINER trigger.
revoke insert, update, delete on public.audit_events from authenticated, anon;
