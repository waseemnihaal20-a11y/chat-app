# UI Components System

## Overview

The Mini Chat Application follows Material Design 3 principles with custom reusable widgets. This document covers the UI component architecture.

## Design System

### Theme Configuration

The app uses Material 3 with a purple seed color:

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4),
  brightness: Brightness.light, // or .dark
)
```

### Component Styling

| Component            | Border Radius |
| -------------------- | ------------- |
| Cards                | 16px          |
| Buttons              | 16px          |
| Bottom Sheets        | 28px (top)    |
| Message Bubbles      | 20px          |
| Navigation Indicator | 12px          |

## Core Widgets

### AvatarWidget

Circular avatar displaying user initial with consistent colors.

**Props**:

- `name`: User's full name
- `size`: Diameter (default: 48)
- `fontSize`: Optional override
- `animate`: Enable scale animation

**Features**:

- Generates initial from first character
- Consistent color based on name hash
- Automatic text color contrast
- Optional entrance animation

### UserCard

Card displaying user information in the users list.

**Props**:

- `user`: UserModel instance
- `onTap`: Tap callback
- `index`: Position for stagger animation

**Features**:

- Avatar with user initial
- Full name and username
- Chevron indicator
- Haptic feedback on tap
- Staggered entrance animation

### ChatCard

Card displaying chat session preview.

**Props**:

- `session`: ChatSessionModel
- `onTap`: Navigate to chat
- `onWordTap`: Dictionary lookup callback
- `index`: Animation stagger index

**Features**:

- User avatar and name
- Last message preview (truncated)
- Relative timestamp
- Tappable words for dictionary
- Staggered entrance animation

### MessageBubble

Chat message display with sender/receiver styling.

**Props**:

- `message`: MessageModel
- `userName`: For receiver avatar
- `onWordLongPress`: Dictionary callback
- `index`: Animation index

**Features**:

- Direction-aware styling (left/right)
- Avatar on appropriate side
- Timestamp display
- Delivery checkmarks (sender)
- Tappable words
- Slide-in animation

### TappableText

Rich text with word-level tap detection.

**Props**:

- `text`: Content string
- `onWordTap`: Word tap callback
- `style`: Text style
- `maxLines`: Truncation limit

**Features**:

- Splits text into tappable spans
- Haptic feedback on tap
- Cleans punctuation from words
- Preserves whitespace

### DictionaryBottomSheet

Modal sheet displaying word definitions.

**Props**:

- `word`: Word to look up

**Features**:

- Drag handle
- Word and phonetic display
- Audio playback button
- Meanings by part of speech
- Definitions with examples
- Loading and error states
- Smooth animations

### CustomAppBarSwitcher

Segmented control for home screen tabs.

**Features**:

- Two-option pill design
- Animated selection indicator
- Haptic feedback
- Provider-driven state

### AddUserBottomSheet

Form for adding new users.

**Features**:

- Text input with validation
- Keyboard-aware padding
- Submit on enter
- Success snackbar

## Screen Components

### MainScreen

Root screen with bottom navigation.

**Structure**:

- NavigationBar with 3 destinations
- IndexedStack for tab content
- Provider-driven tab selection

### HomeScreen

Home tab with nested content.

**Structure**:

- NestedScrollView with SliverAppBar
- CustomAppBarSwitcher in app bar
- IndexedStack for sub-tabs
- Conditional FAB

### UsersListScreen

Scrollable user list.

**Features**:

- PageStorageKey for scroll preservation
- AutomaticKeepAliveClientMixin
- Empty state handling
- Navigation to chat

### ChatHistoryScreen

Scrollable chat session list.

**Features**:

- PageStorageKey for scroll preservation
- AutomaticKeepAliveClientMixin
- Empty state handling
- Word tap for dictionary

### ChatScreen

Individual chat conversation.

**Structure**:

- AppBar with user info
- Message list (reversed)
- Input area with send button

**Features**:

- Auto-scroll to new messages
- Keyboard-aware input
- Disabled send when empty
- Word tap for dictionary

## Responsive Design

### Layout Strategies

1. **Message Bubbles**: Max 80% screen width
2. **Cards**: Full width with horizontal margins
3. **Bottom Sheets**: Max 75% screen height
4. **Input Area**: Keyboard-aware padding

### Breakpoints

The app adapts naturally to screen sizes using:

- `MediaQuery.of(context).size`
- `LayoutBuilder` where needed
- Flexible/Expanded widgets
