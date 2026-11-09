-- New client-created records must enter the workflow in an unapproved state.
-- This prevents clients from bypassing review by supplying a privileged status
-- during INSERT. Later state changes require dedicated transition functions.
drop policy if exists tenant_insert on public.suppliers;
create policy tenant_insert on public.suppliers
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','buyer']::text[]))
    and status = 'prospect'
    and verification_status = 'unverified'
  );

drop policy if exists tenant_insert on public.rfqs;
create policy tenant_insert on public.rfqs
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','buyer']::text[]))
    and status = 'draft'
  );

drop policy if exists tenant_insert on public.supplier_quotes;
create policy tenant_insert on public.supplier_quotes
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','buyer']::text[]))
    and status = 'received'
  );

drop policy if exists tenant_insert on public.requisitions;
create policy tenant_insert on public.requisitions
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','buyer']::text[]))
    and status = 'draft'
  );

drop policy if exists tenant_insert on public.purchase_orders;
create policy tenant_insert on public.purchase_orders
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','buyer']::text[]))
    and status = 'draft'
  );

drop policy if exists tenant_insert on public.goods_receipts;
create policy tenant_insert on public.goods_receipts
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','warehouse']::text[]))
    and status = 'draft'
  );

drop policy if exists tenant_insert on public.invoices;
create policy tenant_insert on public.invoices
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','finance']::text[]))
    and status = 'recorded'
    and match_status = 'unmatched'
  );

drop policy if exists tenant_insert on public.supplier_reviews;
create policy tenant_insert on public.supplier_reviews
  for insert to authenticated
  with check (
    (select private.has_org_role(organization_id, array['owner','admin','buyer']::text[]))
    and reviewed_by = (select auth.uid())
  );
