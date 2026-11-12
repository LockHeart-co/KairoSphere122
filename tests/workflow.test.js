import test from "node:test";
import assert from "node:assert/strict";
import { validate, movementDelta, currencyTotals } from "../src/domain/workflow.js";

test("supplier starts as unverified prospect",()=>{const s=validate("suppliers",{name:"North Supply",country:"Suriname",status:"verified"});assert.equal(s.status,"prospect");assert.equal(s.risk_level,"unknown");});
test("supplier requires name and country",()=>{assert.throws(()=>validate("suppliers",{name:"",country:"Suriname"}));assert.throws(()=>validate("suppliers",{name:"Supplier"}));});
test("product requires SKU and name",()=>{assert.equal(validate("catalog",{sku:"P-01",name:"Pump"}).unit,"each");assert.throws(()=>validate("catalog",{sku:"",name:"Pump"}));});
test("purchase order requires positive value and does not accept a client status override",()=>{assert.equal(validate("orders",{po_number:"PO-1",supplier_id:"s1",currency:"USD",total_amount:5,status:"approved"}).status,undefined);assert.throws(()=>validate("orders",{po_number:"PO-1",supplier_id:"s1",currency:"USD",total_amount:0}));});
test("inventory movements retain direction and three-decimal precision",()=>{assert.equal(movementDelta("receipt",0.125),0.125);assert.equal(movementDelta("issue",0.125),-0.125);assert.equal(validate("inventory",{warehouse_id:"w1",product_id:"p1",movement_type:"receipt",quantity:0.125}).quantity,0.125);assert.throws(()=>movementDelta("other",1));});
test("inventory validation rejects unsupported movement types",()=>{assert.throws(()=>validate("inventory",{warehouse_id:"w1",product_id:"p1",movement_type:"unknown",quantity:1}));});
test("supplier performance scores are limited to 0–100",()=>{assert.equal(validate("performance",{supplier_id:"s1",period:"2026-Q4",delivery_score:100,quality_score:87.5}).delivery_score,100);assert.throws(()=>validate("performance",{supplier_id:"s1",period:"2026-Q4",delivery_score:100.01,quality_score:90}));});
test("currency totals remain separated",()=>{assert.deepEqual(currencyTotals([{currency:"USD",total_amount:4},{currency:"SRD",total_amount:10},{currency:"USD",total_amount:3}]),{USD:7,SRD:10});});
