-- Migration: Add secure account deletion RPC
-- Description: Allows authenticated users to permanently delete their own
-- account identity and associated app data.

CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  current_uid uuid := auth.uid();
BEGIN
  IF current_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  -- Delete app-owned rows first to avoid FK conflicts.
  IF to_regclass('public.chat_messages') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.chat_messages WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.notification_preferences') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.notification_preferences WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.usage_counters') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.usage_counters WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.subscriptions') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.subscriptions WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.transactions') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.transactions WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.budgets') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.budgets WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.goals') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.goals WHERE user_id = $1'
      USING current_uid;
  END IF;

  IF to_regclass('public.profiles') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.profiles WHERE user_id = $1'
      USING current_uid;
  END IF;

  -- Remove auth identity last.
  DELETE FROM auth.users WHERE id = current_uid;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
