import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    if (req.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    const { email, password, name, is_admin, course, department, created_by } = await req.json();
    if (!email || !password || !name) {
      return new Response('email, password, name required', { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SERVICE_ROLE_KEY')!
    );

    // 1) Create auth user
    const { data: userRes, error: authErr } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { name, is_admin: !!is_admin, course, department, created_by },
    });
    if (authErr || !userRes?.user) {
      return new Response(JSON.stringify(authErr ?? { error: 'createUser failed' }), { status: 500, headers: { 'Content-Type': 'application/json' } });
    }

    // 2) Insert profile row
    const { error: profErr } = await supabase.from('profiles').insert({
      id: userRes.user.id,
      name,
      email,
      course,
      department,
      is_admin: !!is_admin,
      created_by: created_by ?? 'admin',
      active: true,
      created_at: new Date().toISOString(),
    });
    if (profErr) {
      return new Response(JSON.stringify(profErr), { status: 500, headers: { 'Content-Type': 'application/json' } });
    }

    return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' } });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
