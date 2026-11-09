import { createClient } from "@supabase/supabase-js";
const {VITE_SUPABASE_URL,VITE_SUPABASE_PUBLISHABLE_KEY}=import.meta.env;
export const configured=Boolean(VITE_SUPABASE_URL&&VITE_SUPABASE_PUBLISHABLE_KEY);
export const supabase=configured?createClient(VITE_SUPABASE_URL,VITE_SUPABASE_PUBLISHABLE_KEY,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}}):null;