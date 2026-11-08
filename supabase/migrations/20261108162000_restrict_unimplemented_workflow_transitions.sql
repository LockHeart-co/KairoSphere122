-- Prevent direct client-side workflow decisions until controlled transition RPCs
-- are implemented. The current UI creates draft records but does not approve,
-- issue, receive, or settle them.
revoke update on public.requisitions from authenticated;
revoke insert, update, delete on public.approvals from authenticated;
revoke update on public.purchase_orders from authenticated;
revoke update on public.goods_receipts from authenticated;
revoke update on public.invoices from authenticated;

-- Approvals remain readable only through the existing tenant-scoped read policy.
-- Future approval/settlement functions must validate actor role, separation of
-- duties, allowed state transitions, and write the resulting audit event.
