-- Migration: Add Main App Features Tables
-- Description: Adds goals, chat_messages, and notification_preferences tables
-- Also extends transactions and budgets tables with new fields

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Add new fields to existing transactions table
ALTER TABLE transactions 
  ADD COLUMN IF NOT EXISTS is_synced BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS linked_goal_id UUID REFERENCES goals(id) ON DELETE SET NULL;

-- Add new field to existing budgets table
ALTER TABLE budgets 
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Goals table
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  target_amount DECIMAL(10, 2) NOT NULL CHECK (target_amount > 0),
  current_amount DECIMAL(10, 2) DEFAULT 0 CHECK (current_amount >= 0),
  target_date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_completed BOOLEAN DEFAULT FALSE,
  linked_category_id TEXT,
  is_manual_tracking BOOLEAN DEFAULT FALSE
);

-- Chat messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  content TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB
);

-- Notification preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  budget_alerts BOOLEAN DEFAULT TRUE,
  recurring_expense_reminders BOOLEAN DEFAULT TRUE,
  goal_deadline_alerts BOOLEAN DEFAULT TRUE,
  unusual_spending_alerts BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own goals" ON goals;
DROP POLICY IF EXISTS "Users can insert own goals" ON goals;
DROP POLICY IF EXISTS "Users can update own goals" ON goals;
DROP POLICY IF EXISTS "Users can delete own goals" ON goals;

DROP POLICY IF EXISTS "Users can view own chat messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can insert own chat messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can delete own chat messages" ON chat_messages;

DROP POLICY IF EXISTS "Users can view own notification preferences" ON notification_preferences;
DROP POLICY IF EXISTS "Users can insert own notification preferences" ON notification_preferences;
DROP POLICY IF EXISTS "Users can update own notification preferences" ON notification_preferences;

-- RLS Policies for Goals
CREATE POLICY "Users can view own goals" ON goals 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own goals" ON goals 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own goals" ON goals 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own goals" ON goals 
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for Chat Messages
CREATE POLICY "Users can view own chat messages" ON chat_messages 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages" ON chat_messages 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat messages" ON chat_messages 
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for Notification Preferences
CREATE POLICY "Users can view own notification preferences" ON notification_preferences 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification preferences" ON notification_preferences 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification preferences" ON notification_preferences 
  FOR UPDATE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_target_date ON goals(target_date);
CREATE INDEX IF NOT EXISTS idx_goals_is_completed ON goals(is_completed);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_transactions_linked_goal_id ON transactions(linked_goal_id);
CREATE INDEX IF NOT EXISTS idx_transactions_is_synced ON transactions(is_synced);

-- Triggers to update updated_at
DROP TRIGGER IF EXISTS update_goals_updated_at ON goals;
CREATE TRIGGER update_goals_updated_at 
  BEFORE UPDATE ON goals 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_notification_preferences_updated_at ON notification_preferences;
CREATE TRIGGER update_notification_preferences_updated_at 
  BEFORE UPDATE ON notification_preferences 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create default notification preferences for existing users
INSERT INTO notification_preferences (user_id)
SELECT id FROM auth.users
ON CONFLICT (user_id) DO NOTHING;
