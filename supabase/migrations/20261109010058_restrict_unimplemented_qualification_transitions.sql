-- Qualification, RFQ issue, and quote award transitions are not yet
-- implemented as controlled actions. Keep direct clients from changing them.
revoke update on public.suppliers from authenticated;
revoke update on public.rfqs from authenticated;
revoke update on public.supplier_quotes from authenticated;
