import { supabase, supabaseAdmin } from '../config/supabase.js';

/**
 * POST /api/v1/auth/register
 * Creates a Supabase auth user (auto-confirmed) + accounts row,
 * then signs in and returns the JWT session to the mobile client.
 */
export async function register(req, res, next) {
  try {
    const { email, password, parentName } = req.body;

    if (!email || !password || !parentName) {
      return res.status(400).json({ error: 'email, password, and parentName are required' });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    const nameParts = parentName.trim().split(' ');
    const firstName = nameParts[0];
    const lastName = nameParts.slice(1).join(' ') || '';

    // 1. Create Supabase auth user (admin — auto-confirms email, no verification needed)
    const { data: authData, error: authError } =
      await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });

    if (authError) {
      if (authError.message?.toLowerCase().includes('already registered') ||
          authError.message?.toLowerCase().includes('already exists')) {
        return res.status(409).json({ error: 'An account with this email already exists' });
      }
      return res.status(400).json({ error: authError.message });
    }

    // 2. Create accounts row (upsert in case a DB trigger already inserted it)
    const { error: accountError } = await supabaseAdmin
      .from('accounts')
      .upsert({
        id: authData.user.id,
        email,
        parent_first_name: firstName,
        parent_last_name: lastName,
      }, { onConflict: 'id' });

    if (accountError) {
      console.error('[register] accounts insert error:', accountError);
      if (accountError.code === '23505') {
        return res.status(409).json({ error: 'An account with this email already exists' });
      }
      await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
      return res.status(500).json({ error: 'Failed to create account profile' });
    }

    // 3. Sign in with the credentials to get a JWT session for the mobile client
    const { data: sessionData, error: signInError } =
      await supabase.auth.signInWithPassword({ email, password });

    if (signInError || !sessionData.session) {
      // Account was created; client should sign in manually
      return res.status(201).json({ success: true, message: 'Account created. Please sign in.' });
    }

    return res.status(201).json({
      access_token: sessionData.session.access_token,
      refresh_token: sessionData.session.refresh_token,
      user_id: sessionData.user.id,
      email: sessionData.user.email,
    });
  } catch (error) {
    next(error);
  }
}
