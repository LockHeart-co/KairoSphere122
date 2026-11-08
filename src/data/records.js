export async function listRecords(client,table,orgId,orderBy="created_at"){
 const {data,error}=await client.from(table).select("*").eq("organization_id",orgId).order(orderBy,{ascending:false}).limit(100);
 if(error)throw error;return data||[];
}
export async function createRecord(client,table,organizationId,userId,values){
 const actorColumn=table==="supplier_reviews"?"reviewed_by":"created_by";
 const payload={...values,organization_id:organizationId,[actorColumn]:userId};
 const {data,error}=await client.from(table).insert(payload).select("*").single();
 if(error)throw error;return data;
}
export async function getOrganizations(client){
 const {data,error}=await client.from("organizations").select("id,name,created_at").order("created_at");
 if(error)throw error;return data||[];
}
export async function createOrganization(client,name,userId){
 const {data,error}=await client.from("organizations").insert({name,created_by:userId}).select("id,name").single();
 if(error)throw error;return data;
}
