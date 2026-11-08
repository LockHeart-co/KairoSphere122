-- KairoSphere procurement operating model. Additive replacement schema.
create extension if not exists pgcrypto;

create table if not exists public.organizations (
 id uuid primary key default gen_random_uuid(), name text not null check(char_length(btrim(name)) between 2 and 140),
 created_by uuid not null references auth.users(id), created_at timestamptz not null default now()
);
create table if not exists public.organization_members (
 organization_id uuid not null references public.organizations(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null check(role in ('owner','admin','buyer','warehouse','finance','viewer')),
 created_at timestamptz not null default now(), primary key(organization_id,user_id)
);
create schema if not exists private;
revoke all on schema private from public,anon;
grant usage on schema private to authenticated;

create or replace function private.is_org_member(target_org uuid)
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.organization_members m where m.organization_id=target_org and m.user_id=(select auth.uid())); $$;
create or replace function private.can_write_org(target_org uuid)
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.organization_members m where m.organization_id=target_org and m.user_id=(select auth.uid()) and m.role in ('owner','admin','buyer','warehouse','finance')); $$;
create or replace function private.add_org_creator_membership()
returns trigger language plpgsql security definer set search_path=''
as $$
begin
 insert into public.organization_members(organization_id,user_id,role) values(new.id,new.created_by,'owner');
 return new;
end; $$;
revoke all on function private.is_org_member(uuid),private.can_write_org(uuid),private.add_org_creator_membership() from public,anon,authenticated;
grant execute on function private.is_org_member(uuid),private.can_write_org(uuid) to authenticated;
drop trigger if exists organization_creator_membership on public.organizations;
create trigger organization_creator_membership after insert on public.organizations
for each row execute function private.add_org_creator_membership();

create table if not exists public.suppliers (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 name text not null, legal_name text, country text not null, registration_no text, email text, phone text, website text,
 payment_terms text, currency text not null default 'USD', status text not null default 'prospect'
 check(status in ('prospect','under_review','approved','suspended')),
 risk_level text not null default 'unknown' check(risk_level in ('unknown','low','medium','high')),
 verification_status text not null default 'unverified' check(verification_status in ('unverified','pending','verified','rejected')),
 created_by uuid references auth.users(id), created_at timestamptz not null default now(), unique(organization_id,id)
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 sku text not null, name text not null, category text, unit text not null default 'each', description text,
 active boolean not null default true, created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,sku)
);
create table if not exists public.supplier_products (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, supplier_id uuid not null, product_id uuid not null,
 supplier_sku text, supplier_description text, last_quoted_price numeric(14,2), currency text, lead_time_days integer,
 verified boolean not null default false, created_at timestamptz not null default now(),
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id) on delete cascade,
 foreign key(organization_id,product_id) references public.products(organization_id,id) on delete cascade
);
create table if not exists public.supplier_contacts (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, supplier_id uuid not null,
 name text not null, role_title text, email text, phone text, is_primary boolean not null default false,
 created_at timestamptz not null default now(),
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id) on delete cascade
);
create table if not exists public.warehouses (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 code text not null, name text not null, location text not null, active boolean not null default true,
 created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,code)
);
create table if not exists public.rfqs (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 reference text not null, title text not null, status text not null default 'draft'
 check(status in ('draft','issued','evaluating','awarded','cancelled')), response_due_at date, notes text,
 created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,reference)
);
create table if not exists public.rfq_lines (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, rfq_id uuid not null, product_id uuid,
 description text not null, quantity numeric(16,3) not null check(quantity>0), unit text not null, required_by date,
 unique(organization_id,id),
 foreign key(organization_id,rfq_id) references public.rfqs(organization_id,id) on delete cascade,
 foreign key(organization_id,product_id) references public.products(organization_id,id)
);
create table if not exists public.rfq_invitations (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, rfq_id uuid not null, supplier_id uuid not null,
 invited_at timestamptz not null default now(), response_status text not null default 'pending'
 check(response_status in ('pending','responded','declined','expired')),
 foreign key(organization_id,rfq_id) references public.rfqs(organization_id,id) on delete cascade,
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id) on delete cascade,
 unique(organization_id,rfq_id,supplier_id)
);
create table if not exists public.supplier_quotes (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, rfq_id uuid not null, supplier_id uuid not null,
 quote_reference text not null, currency text not null, total_amount numeric(14,2) not null check(total_amount>=0),
 valid_until date, lead_time_days integer, status text not null default 'received'
 check(status in ('received','under_review','shortlisted','selected','rejected')), notes text,
 created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,quote_reference),
 foreign key(organization_id,rfq_id) references public.rfqs(organization_id,id) on delete cascade,
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id)
);
create table if not exists public.supplier_quote_lines (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, quote_id uuid not null, rfq_line_id uuid not null,
 quantity numeric(16,3) not null check(quantity>0), unit_price numeric(14,4) not null check(unit_price>=0),
 currency text not null, lead_time_days integer, notes text,
 foreign key(organization_id,quote_id) references public.supplier_quotes(organization_id,id) on delete cascade,
 foreign key(organization_id,rfq_line_id) references public.rfq_lines(organization_id,id)
);
create table if not exists public.requisitions (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 reference text not null, requester text not null, department text, justification text not null, required_by date,
 currency text not null default 'USD', estimated_total numeric(14,2) not null default 0 check(estimated_total>=0),
 status text not null default 'draft' check(status in ('draft','submitted','approved','rejected','converted')),
 created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,reference)
);
create table if not exists public.requisition_lines (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, requisition_id uuid not null, product_id uuid,
 description text not null, quantity numeric(16,3) not null check(quantity>0), unit text not null, estimated_unit_price numeric(14,4),
 foreign key(organization_id,requisition_id) references public.requisitions(organization_id,id) on delete cascade,
 foreign key(organization_id,product_id) references public.products(organization_id,id)
);
create table if not exists public.approvals (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade, record_type text not null, record_id uuid not null,
 decision text not null check(decision in ('approved','rejected','returned')), decided_by uuid not null references auth.users(id),
 comments text, decided_at timestamptz not null default now()
);
create table if not exists public.purchase_orders (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 po_number text not null, supplier_id uuid not null, requisition_id uuid, quote_id uuid,
 status text not null default 'draft' check(status in ('draft','pending_approval','approved','sent','partially_received','received','closed','cancelled')),
 currency text not null, total_amount numeric(14,2) not null check(total_amount>0), ordered_at date, expected_at date,
 created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,po_number),
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id),
 foreign key(organization_id,requisition_id) references public.requisitions(organization_id,id),
 foreign key(organization_id,quote_id) references public.supplier_quotes(organization_id,id)
);
create table if not exists public.purchase_order_lines (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, purchase_order_id uuid not null, product_id uuid,
 description text not null, quantity_ordered numeric(16,3) not null check(quantity_ordered>0),
 unit text not null, unit_price numeric(14,4) not null check(unit_price>=0), currency text not null,
 unique(organization_id,id),
 foreign key(organization_id,purchase_order_id) references public.purchase_orders(organization_id,id) on delete cascade,
 foreign key(organization_id,product_id) references public.products(organization_id,id)
);
create table if not exists public.goods_receipts (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, receipt_number text not null,
 purchase_order_id uuid not null, warehouse_id uuid not null, status text not null default 'draft'
 check(status in ('draft','received','inspected','accepted','rejected')), received_at date, inspection_notes text,
 created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,receipt_number),
 foreign key(organization_id,purchase_order_id) references public.purchase_orders(organization_id,id),
 foreign key(organization_id,warehouse_id) references public.warehouses(organization_id,id)
);
create table if not exists public.goods_receipt_lines (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, receipt_id uuid not null,
 purchase_order_line_id uuid not null, product_id uuid, quantity_received numeric(16,3) not null check(quantity_received>0),
 quantity_accepted numeric(16,3) not null default 0 check(quantity_accepted>=0),
 quantity_rejected numeric(16,3) not null default 0 check(quantity_rejected>=0), condition_notes text,
 foreign key(organization_id,receipt_id) references public.goods_receipts(organization_id,id) on delete cascade,
 foreign key(organization_id,purchase_order_line_id) references public.purchase_order_lines(organization_id,id),
 foreign key(organization_id,product_id) references public.products(organization_id,id),
 check(quantity_accepted+quantity_rejected<=quantity_received)
);
create table if not exists public.inventory_movements (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, warehouse_id uuid not null, product_id uuid not null,
 movement_type text not null check(movement_type in ('receipt','issue','adjustment_in','adjustment_out','transfer_in','transfer_out')),
 quantity numeric(16,3) not null check(quantity>0), reference_type text, reference_id uuid, reference text,
 occurred_at timestamptz not null default now(), created_by uuid references auth.users(id),
 foreign key(organization_id,warehouse_id) references public.warehouses(organization_id,id),
 foreign key(organization_id,product_id) references public.products(organization_id,id)
);
create table if not exists public.invoices (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, supplier_id uuid not null, purchase_order_id uuid not null,
 invoice_number text not null, currency text not null, total_amount numeric(14,2) not null check(total_amount>=0),
 invoice_date date, due_date date, match_status text not null default 'unmatched' check(match_status in ('unmatched','matched','exception')),
 status text not null default 'recorded' check(status in ('recorded','approved','on_hold','paid')),
 settlement_reference text, settlement_date date, settlement_evidence text, created_by uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(organization_id,id), unique(organization_id,supplier_id,invoice_number),
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id),
 foreign key(organization_id,purchase_order_id) references public.purchase_orders(organization_id,id),
 check(status<>'paid' or (settlement_reference is not null and settlement_date is not null and settlement_evidence is not null))
);
create table if not exists public.invoice_lines (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, invoice_id uuid not null, purchase_order_line_id uuid,
 description text not null, quantity numeric(16,3) not null check(quantity>=0), unit_price numeric(14,4) not null check(unit_price>=0), currency text not null,
 foreign key(organization_id,invoice_id) references public.invoices(organization_id,id) on delete cascade,
 foreign key(organization_id,purchase_order_line_id) references public.purchase_order_lines(organization_id,id)
);
create table if not exists public.invoice_match_exceptions (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, invoice_id uuid not null,
 exception_type text not null check(exception_type in ('supplier','price','quantity','receipt','currency','tax','other')),
 description text not null, resolution_status text not null default 'open' check(resolution_status in ('open','resolved','waived')),
 resolved_by uuid references auth.users(id), resolved_at timestamptz,
 foreign key(organization_id,invoice_id) references public.invoices(organization_id,id) on delete cascade
);
create table if not exists public.supplier_reviews (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null, supplier_id uuid not null, period text not null,
 delivery_score numeric(5,2) check(delivery_score between 0 and 100), quality_score numeric(5,2) check(quality_score between 0 and 100),
 notes text, reviewed_at timestamptz not null default now(), reviewed_by uuid references auth.users(id),
 foreign key(organization_id,supplier_id) references public.suppliers(organization_id,id)
);
create table if not exists public.audit_events (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade, actor_id uuid references auth.users(id),
 operation text not null, table_name text not null, record_id uuid, before_data jsonb, after_data jsonb, occurred_at timestamptz not null default now()
);
create or replace view public.inventory_balances with (security_invoker=true) as
select organization_id,warehouse_id,product_id,
 sum(case when movement_type in ('receipt','adjustment_in','transfer_in') then quantity else -quantity end) quantity_on_hand
from public.inventory_movements group by organization_id,warehouse_id,product_id;

alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
drop policy if exists org_read on public.organizations;
create policy org_read on public.organizations for select to authenticated using((select private.is_org_member(id)));
drop policy if exists member_read on public.organization_members;
create policy org_create on public.organizations for insert to authenticated with check(created_by=(select auth.uid()));
create policy member_read on public.organization_members for select to authenticated using(user_id=(select auth.uid()) or (select private.is_org_member(organization_id)));

do $$
declare t text;
begin
 foreach t in array array['suppliers','products','supplier_products','supplier_contacts','warehouses','rfqs','rfq_lines','rfq_invitations','supplier_quotes','supplier_quote_lines','requisitions','requisition_lines','approvals','purchase_orders','purchase_order_lines','goods_receipts','goods_receipt_lines','inventory_movements','invoices','invoice_lines','invoice_match_exceptions','supplier_reviews','audit_events']
 loop
  execute format('alter table public.%I enable row level security',t);
  execute format('drop policy if exists tenant_read on public.%I',t);
  execute format('create policy tenant_read on public.%I for select to authenticated using(private.is_org_member(organization_id))',t);
  execute format('drop policy if exists tenant_write on public.%I',t);
  execute format('create policy tenant_write on public.%I for all to authenticated using(private.can_write_org(organization_id)) with check(private.can_write_org(organization_id))',t);
 end loop;
end $$;
grant select,insert on public.organizations to authenticated;
grant select on public.organization_members to authenticated;
grant select,insert,update,delete on public.suppliers,public.products,public.supplier_products,public.supplier_contacts,public.warehouses,public.rfqs,public.rfq_lines,public.rfq_invitations,public.supplier_quotes,public.supplier_quote_lines,public.requisitions,public.requisition_lines,public.approvals,public.purchase_orders,public.purchase_order_lines,public.goods_receipts,public.goods_receipt_lines,public.inventory_movements,public.invoices,public.invoice_lines,public.invoice_match_exceptions,public.supplier_reviews,public.audit_events to authenticated;
grant select on public.inventory_balances to authenticated;
