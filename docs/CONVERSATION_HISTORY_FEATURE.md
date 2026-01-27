# Conversation History Feature

## Overview
Implemented a comprehensive conversation management system for the Perfin AI Copilot, allowing users to create, manage, and switch between multiple conversation threads. Each conversation is persisted locally and can be renamed, deleted, or cleared independently.

## Features Implemented

### 1. Multiple Conversations
- **Create new conversations**: Users can start fresh conversations at any time
- **Switch between conversations**: Easy navigation between different conversation threads
- **Automatic conversation creation**: First message automatically creates a new conversation if none exists
- **Conversation sorting**: Most recently updated conversations appear first

### 2. Conversation Management
- **Auto-generated titles**: Conversation titles are automatically generated from the first user message
- **Rename conversations**: Users can customize conversation titles
- **Delete conversations**: Remove unwanted conversations with confirmation
- **Clear conversation**: Clear messages from current conversation while keeping the thread

### 3. Conversation History Screen
- **List view**: Clean, card-based list of all conversations
- **Visual indicators**: Active conversation is highlighted with dark background
- **Message count**: Shows number of messages in each conversation
- **Timestamp**: Displays when conversation was last updated (e.g., "2:30 PM", "Yesterday", "Monday", "Jan 27")
- **Quick actions**: Rename and delete options via popup menu
- **Empty state**: Friendly message when no conversations exist

### 4. Persistent Storage
- **Local storage**: All conversations saved to device using Hive
- **User-specific**: Each user has their own set of conversations
- **Automatic save**: Conversations saved after every message
- **Automatic load**: Conversations loaded on app start and user login

## User Interface

### Copilot Screen Header
- **New conversation button** (➕): Creates a new conversation thread
- **History button** (🕐): Opens conversation history screen
- **Clear button** (🗑️): Clears current conversation messages

### Conversation History Screen
- **Back button**: Returns to chat
- **Conversation cards**: Show title, message count, and last updated time
- **Active indicator**: Dark background for currently active conversation
- **Popup menu**: Rename and delete options for each conversation

## Technical Implementation

### New Files Created

1. **`lib/models/conversation.dart`**
   - Conversation model with id, userId, title, timestamps, and messages
   - JSON serialization/deserialization
   - Auto-title generation from first message
   - copyWith method for immutable updates

2. **`lib/screens/copilot/conversation_history_screen.dart`**
   - Full conversation list view
   - Rename dialog with text input
   - Delete confirmation dialog
   - Empty state UI
   - Date formatting utilities

### Modified Files

1. **`lib/providers/ai_provider.dart`**
   - Replaced single chat history with list of conversations
   - Added conversation management methods:
     - `createNewConversation()`
     - `switchConversation(conversationId)`
     - `renameConversation(conversationId, newTitle)`
     - `deleteConversation(conversationId)`
   - Updated storage to save/load conversations instead of single chat history
   - Modified `sendCopilotQuery()` to work with conversations
   - Updated `clearChatHistory()` to clear current conversation only

2. **`lib/screens/copilot/copilot_screen.dart`**
   - Added three header buttons (new, history, clear)
   - Updated clear dialog text
   - Added navigation to conversation history screen
   - Integrated conversation creation

## Data Structure

### Conversation Model
```dart
{
  "id": "1738012345678",
  "userId": "user123",
  "title": "How much did I spend this month?",
  "createdAt": "2026-01-27T10:00:00.000Z",
  "updatedAt": "2026-01-27T10:30:00.000Z",
  "messages": [
    {
      "id": "1738012345679",
      "userId": "user123",
      "content": "How much did I spend this month?",
      "role": "user",
      "timestamp": "2026-01-27T10:00:00.000Z",
      "metadata": null
    },
    {
      "id": "1738012345680",
      "userId": "user123",
      "content": "You spent $1,234.56 this month...",
      "role": "assistant",
      "timestamp": "2026-01-27T10:00:05.000Z",
      "metadata": {
        "confidenceScore": 0.95,
        "dataReferences": [...],
        "calculations": [...]
      }
    }
  ]
}
```

### Storage Format
```dart
Key: 'conversations_{userId}'
Value: [
  { /* conversation 1 */ },
  { /* conversation 2 */ },
  { /* conversation 3 */ },
  // ... more conversations
]
```

## User Workflows

### Starting a New Conversation
1. User taps the ➕ button in header
2. New conversation is created and set as active
3. Empty state with suggested questions is shown
4. User can start chatting immediately

### Viewing Conversation History
1. User taps the 🕐 button in header
2. Conversation history screen opens
3. User sees list of all conversations sorted by recent activity
4. Active conversation is highlighted

### Switching Conversations
1. User opens conversation history
2. User taps on a conversation card
3. Conversation becomes active
4. User is returned to chat screen
5. Messages from selected conversation are displayed

### Renaming a Conversation
1. User opens conversation history
2. User taps ⋮ menu on a conversation
3. User selects "Rename"
4. Dialog appears with current title
5. User enters new title and confirms
6. Conversation title is updated

### Deleting a Conversation
1. User opens conversation history
2. User taps ⋮ menu on a conversation
3. User selects "Delete"
4. Confirmation dialog appears
5. User confirms deletion
6. Conversation is removed
7. If deleted conversation was active, switches to most recent conversation

### Clearing Current Conversation
1. User taps 🗑️ button in header
2. Confirmation dialog appears
3. User confirms
4. All messages in current conversation are cleared
5. Title resets to "New Conversation"
6. Conversation thread is preserved (not deleted)

## Design Principles

### Colors
- **Active conversation**: #1A1A1A (dark background), white text
- **Inactive conversation**: #FAFAFA (light background), dark text
- **Borders**: #E5E5E5
- **Icons**: #666666
- **Destructive actions**: #FF3B30

### Typography
- **Conversation title**: 16px, w600
- **Message count**: 14px, regular
- **Timestamp**: 14px, regular
- **Screen title**: 32px, w700, -1 letter spacing

### Spacing
- **Card padding**: 16px
- **Card margin**: 12px bottom
- **Border radius**: 16px for cards, 12px for dialogs
- **Icon size**: 24px

## Benefits

1. **Organization**: Users can organize different financial topics into separate conversations
2. **Context preservation**: Each conversation maintains its own context and history
3. **Easy navigation**: Quick access to past conversations
4. **Clean interface**: Clutter-free chat experience with organized history
5. **Flexibility**: Users can manage conversations as needed (rename, delete, clear)

## Future Enhancements

- Search within conversations
- Filter conversations by date or topic
- Export individual conversations
- Archive old conversations
- Conversation tags/categories
- Pin important conversations
- Conversation statistics (total messages, date range, etc.)

## Testing

All files compiled successfully with no errors. The feature integrates seamlessly with the existing clean minimal design aesthetic.
