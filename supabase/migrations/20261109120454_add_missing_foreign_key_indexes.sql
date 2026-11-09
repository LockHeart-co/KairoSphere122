-- Add B-tree indexes for public foreign-key columns not already covered
-- by the leading key columns of a valid, non-partial index.
--
-- Index names are deterministic from the table and constraint names.
-- Existing indexes are preserved; no data or constraints are modified.

do $$
declare
  fk record;
begin
  for fk in
    select
      n.nspname as schema_name,
      t.relname as table_name,
      c.conname as constraint_name,
      'idx_' || t.relname || '_' || left(md5(c.conname), 8) as index_name,
      (
        select string_agg(quote_ident(a.attname), ', ' order by k.ord)
        from unnest(c.conkey) with ordinality as k(attnum, ord)
        join pg_attribute a
          on a.attrelid = t.oid
         and a.attnum = k.attnum
      ) as column_list
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where c.contype = 'f'
      and n.nspname = 'public'
      and not exists (
        select 1
        from pg_index i
        where i.indrelid = t.oid
          and i.indisvalid
          and i.indpred is null
          and i.indnkeyatts >= cardinality(c.conkey)
          and (
            select array_agg(i.indkey[s.ord] order by s.ord)
            from generate_series(0, cardinality(c.conkey) - 1) as s(ord)
          ) = c.conkey
      )
    order by t.relname, c.conname
  loop
    execute format(
      'create index if not exists %I on %I.%I (%s)',
      fk.index_name,
      fk.schema_name,
      fk.table_name,
      fk.column_list
    );
  end loop;
end
$$;
