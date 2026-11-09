import test from "node:test";
import assert from "node:assert/strict";
import { validate, movementDelta, currencyTotals } from "../src/domain/workflow.js";

test("supplier starts as unverified prospect",()=>{const s=validate("suppliers",{name:"North Supply",country:"Suriname"});assert.equal(s.status,"prospect");assert.equal(s.risk_level,"unknown");});
test("supplier requires name and country",()=>{assert.throws(()=>validate("suppliers",{name:"",country:"Suriname"}));assert.throws(()=>validate("suppliers",{name:"Supplier"}));});
test("product requires SKU and name",()=>{assert.equal(validate("catalog",{sku:"P-01",name:"Pump"}).unit,"each");assert.throws(()=>validate("catalog",{sku:"",name:"Pump"}));});
test("purchase order requires positive value and supplier",()=>{assert.equal(validate("orders",{po_number:"PO-1",supplier_id:"s1",currency:"USD",total_amount:5}).status,"draft");assert.throws(()=>validate("orders",{po_number:"PO-1",supplier_id:"s1",currency:"USD",total_amount:0}));});
test("inventory movements retain direction",()=>{assert.equal(movementDelta("receipt",4),4);assert.equal(movementDelta("issue",2),-2);assert.throws(()=>movementDelta("other",1));});
test("currency totals remain separated",()=>{assert.deepEqual(currencyTotals([{currency:"USD",total_amount:4},{currency:"SRD",total_amount:10},{currency:"USD",total_amount:3}]),{USD:7,SRD:10});});
