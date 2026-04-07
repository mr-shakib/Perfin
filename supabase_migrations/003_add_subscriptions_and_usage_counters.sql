-- Migration: Add subscription and usage counter tables
-- Description: Introduces plan state and metered usage support for feature gating

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL UNIQUE,
  plan TEXT NOT NULL CHECK (plan IN ('free', 'pro', 'family')),
  status TEXT NOT NULL CHECK (status IN ('active', 'trialing', 'canceled', 'past_due', 'expired')),
  period_start TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT date_trunc('month', NOW()),
  period_end TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (date_trunc('month', NOW()) + INTERVAL '1 month - 1 second'),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS usage_counters (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  metric_key TEXT NOT NULL,
  period_key TEXT NOT NULL,
  count INTEGER NOT NULL DEFAULT 0 CHECK (count >= 0),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, metric_key, period_key)
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_counters ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Users can insert own subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Users can update own subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Users can delete own subscriptions" ON subscriptions;

DROP POLICY IF EXISTS "Users can view own usage counters" ON usage_counters;
DROP POLICY IF EXISTS "Users can insert own usage counters" ON usage_counters;
DROP POLICY IF EXISTS "Users can update own usage counters" ON usage_counters;
DROP POLICY IF EXISTS "Users can delete own usage counters" ON usage_counters;

CREATE POLICY "Users can view own subscriptions" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions" ON subscriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions" ON subscriptions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own subscriptions" ON subscriptions
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own usage counters" ON usage_counters
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own usage counters" ON usage_counters
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own usage counters" ON usage_counters
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own usage counters" ON usage_counters
  FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_usage_counters_user_id ON usage_counters(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_counters_period_key ON usage_counters(period_key);

DROP TRIGGER IF EXISTS update_subscriptions_updated_at ON subscriptions;
CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_usage_counters_updated_at ON usage_counters;
CREATE TRIGGER update_usage_counters_updated_at
  BEFORE UPDATE ON usage_counters
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

INSERT INTO subscriptions (user_id, plan, status)
SELECT id, 'free', 'active'
FROM auth.users
ON CONFLICT (user_id) DO NOTHING;
