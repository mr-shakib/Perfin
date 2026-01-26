-- Local SQLite Schema for Offline Support
-- This schema is used for local storage and sync queue management

-- Sync queue table (local only, not synced to Supabase)
CREATE TABLE IF NOT EXISTS sync_queue (
  id TEXT PRIMARY KEY,
  operation_type TEXT NOT NULL CHECK (operation_type IN ('create', 'update', 'delete')),
  entity_type TEXT NOT NULL CHECK (entity_type IN ('transaction', 'budget', 'goal', 'chat_message', 'notification_preferences')),
  entity_id TEXT NOT NULL,
  data TEXT NOT NULL, -- JSON string containing the entity data
  queued_at INTEGER NOT NULL, -- Unix timestamp in milliseconds
  retry_count INTEGER DEFAULT 0,
  status TEXT NOT NULL CHECK (status IN ('pending', 'inProgress', 'completed', 'failed'))
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue(status);
CREATE INDEX IF NOT EXISTS idx_sync_queue_queued_at ON sync_queue(queued_at);
CREATE INDEX IF NOT EXISTS idx_sync_queue_entity_type ON sync_queue(entity_type);

-- Local cache metadata table to track last sync times
CREATE TABLE IF NOT EXISTS cache_metadata (
  entity_type TEXT PRIMARY KEY,
  last_sync_time INTEGER NOT NULL, -- Unix timestamp in milliseconds
  is_stale BOOLEAN DEFAULT FALSE
);

-- Insert default cache metadata for all entity types
INSERT OR IGNORE INTO cache_metadata (entity_type, last_sync_time, is_stale) VALUES
  ('transaction', 0, TRUE),
  ('budget', 0, TRUE),
  ('goal', 0, TRUE),
  ('chat_message', 0, TRUE),
  ('notification_preferences', 0, TRUE);
