const text=(v,label,max=160)=>{const s=String(v??"").trim();if(!s||s.length>max)throw Error(label+" is required (max "+max+" characters).");return s;};
const optional=v=>String(v??"").trim()||null;
const amount=(v,label="Amount",zero=false,precision=2)=>{const n=Number(v);if(!Number.isFinite(n)||(zero?n<0:n<=0))throw Error(label+" is invalid.");const factor=10**precision;return Math.round((n+Number.EPSILON)*factor)/factor;};
const currency=v=>{const c=String(v||"USD").toUpperCase();if(!["USD","SRD","EUR","TTD","GYD"].includes(c))throw Error("Unsupported currency.");return c;};
const score=(v,label)=>{const n=amount(v??0,label,true);if(n>100)throw Error(label+" must be between 0 and 100.");return n;};
export function validate(key,v){
 if(key==="suppliers")return {name:text(v.name,"Supplier name"),legal_name:optional(v.legal_name),country:text(v.country,"Country",100),registration_no:optional(v.registration_no),email:optional(v.email),phone:optional(v.phone),website:optional(v.website),payment_terms:optional(v.payment_terms),currency:currency(v.currency),status:"prospect",risk_level:v.risk_level||"unknown"};
 if(key==="catalog")return {sku:text(v.sku,"SKU",80),name:text(v.name,"Product name"),category:optional(v.category),unit:text(v.unit||"each","Unit",30),description:optional(v.description),active:true};
 if(key==="warehouses")return {code:text(v.code,"Code",60),name:text(v.name,"Name"),location:text(v.location,"Location"),active:true};
 if(key==="sourcing")return {reference:text(v.reference,"RFQ reference",80),title:text(v.title,"Title"),response_due_at:v.response_due_at||null,status:"draft",notes:optional(v.notes)};
 if(key==="quotations")return {rfq_id:text(v.rfq_id,"RFQ ID"),supplier_id:text(v.supplier_id,"Supplier ID"),quote_reference:text(v.quote_reference,"Quote reference",100),currency:currency(v.currency),total_amount:amount(v.total_amount),valid_until:v.valid_until||null};
 if(key==="requisitions")return {reference:text(v.reference,"Reference",80),requester:text(v.requester,"Requester"),department:optional(v.department),justification:text(v.justification,"Justification",2000),estimated_total:amount(v.estimated_total||0,"Estimate",true),required_by:v.required_by||null,currency:currency(v.currency)};
 if(key==="orders")return {po_number:text(v.po_number,"PO number",80),supplier_id:text(v.supplier_id,"Supplier ID"),currency:currency(v.currency),total_amount:amount(v.total_amount),ordered_at:v.ordered_at||null,expected_at:v.expected_at||null};
 if(key==="receiving")return {receipt_number:text(v.receipt_number,"Receipt number"),purchase_order_id:text(v.purchase_order_id,"Purchase order ID"),warehouse_id:text(v.warehouse_id,"Warehouse ID"),received_at:v.received_at||null,inspection_notes:optional(v.inspection_notes)};
 if(key==="inventory"){movementDelta(v.movement_type,v.quantity);return {warehouse_id:text(v.warehouse_id,"Warehouse ID"),product_id:text(v.product_id,"Product ID"),movement_type:text(v.movement_type,"Movement type",40),quantity:amount(v.quantity,"Quantity",false,3),reference:optional(v.reference),occurred_at:v.occurred_at||new Date().toISOString()};}
 if(key==="invoices")return {supplier_id:text(v.supplier_id,"Supplier ID"),purchase_order_id:text(v.purchase_order_id,"PO ID"),invoice_number:text(v.invoice_number,"Invoice number"),currency:currency(v.currency),total_amount:amount(v.total_amount),invoice_date:v.invoice_date||null,due_date:v.due_date||null};
 if(key==="performance")return {supplier_id:text(v.supplier_id,"Supplier ID"),period:text(v.period,"Period"),delivery_score:score(v.delivery_score,"Delivery score"),quality_score:score(v.quality_score,"Quality score"),notes:optional(v.notes)};
 return v;
}
export function movementDelta(type,quantity){const n=amount(quantity,"Quantity",false,3);const sign={receipt:1,adjustment_in:1,transfer_in:1,issue:-1,adjustment_out:-1,transfer_out:-1}[type];if(sign===undefined)throw Error("Invalid movement type.");return sign*n;}
export function currencyTotals(rows){return rows.reduce((a,r)=>{const n=Number(r.total_amount||0);if(r.currency==="USD")a.USD+=n;if(r.currency==="SRD")a.SRD+=n;return a;},{USD:0,SRD:0});}
