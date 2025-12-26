# State Management System

## Overview

The Mini Chat Application uses **Provider** for state management, following the principle of unidirectional data flow. This document details the state management architecture.

## Core Principles

1. **No setState()**: All UI updates flow through providers
2. **Single Source of Truth**: Each provider owns its domain state
3. **Immutable Updates**: State changes create new instances
4. **Reactive UI**: Consumer widgets react to notifyListeners()

## Provider Architecture

### Provider Registration

Providers are registered at the app root in `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => DictionaryProvider()),
  ],
  child: MaterialApp(...),
)
```

## Provider Details

### UserProvider

**Purpose**: Manages the list of chat users

**State**:

- `_users`: List of UserModel
- `_isLoading`: Loading indicator
- `_error`: Error message

**Operations**:

- `addUser(String name)`: Add new user
- `removeUser(String id)`: Remove user
- `updateUser(String id, ...)`: Update user details
- `getUserById(String id)`: Retrieve specific user

### NavigationProvider

**Purpose**: Manages navigation state across the app

**State**:

- `_currentBottomNavIndex`: Active bottom tab (0-2)
- `_currentHomeTab`: HomeTab enum (usersList/chatHistory)

**Operations**:

- `setBottomNavIndex(int)`: Switch bottom tab
- `setHomeTab(HomeTab)`: Switch home sub-tab
- `toggleHomeTab()`: Toggle between Users/History
- `reset()`: Reset to initial state

### ChatProvider

**Purpose**: Manages chat sessions and messages

**State**:

- `_chatSessions`: Map of user ID to ChatSessionModel
- `_isLoading`: API loading state
- `_isSendingMessage`: Message sending state
- `_error`: Error message

**Operations**:

- `getOrCreateSession(UserModel)`: Get/create chat session
- `sendMessage(String userId, String content)`: Send message
- `getMessages(String userId)`: Get message history
- `clearChatSession(String userId)`: Clear specific chat

**Auto-Reply Flow**:

1. User sends message
2. Message added to session immediately
3. 2-second timer starts
4. API fetches random comment
5. Receiver message added to session

### DictionaryProvider

**Purpose**: Handles word definition lookups and audio playback

**State**:

- `_currentWord`: Word being looked up
- `_currentDefinition`: DictionaryModel result
- `_error`: DictionaryError if failed
- `_isLoading`: API loading state
- `_isPlayingAudio`: Audio playback state

**Operations**:

- `lookupWord(String word)`: Fetch definition
- `playAudio()`: Play pronunciation
- `stopAudio()`: Stop playback
- `clear()`: Reset state

## Usage Patterns

### Reading State

```dart
// Using Consumer
Consumer<UserProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.users.length,
      itemBuilder: (_, index) => UserCard(user: provider.users[index]),
    );
  },
)

// Using context.read (for actions, not rebuilds)
context.read<ChatProvider>().sendMessage(userId, content);

// Using context.watch (rebuilds on change)
final isLoading = context.watch<ChatProvider>().isLoading;
```

### Modifying State

```dart
// Add user
context.read<UserProvider>().addUser('John Doe');

// Send message
await context.read<ChatProvider>().sendMessage(userId, 'Hello');

// Switch tabs
context.read<NavigationProvider>().setHomeTab(HomeTab.chatHistory);
```

## State Persistence

Currently, state is **not persisted** across app restarts. Future enhancements could add:

- SharedPreferences for settings
- SQLite/Hive for chat history
- Secure storage for sensitive data

## Error Handling

Each provider maintains an `_error` field:

- Set when operations fail
- Cleared with `clearError()`
- UI can display via Consumer
