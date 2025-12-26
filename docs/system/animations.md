# Animation System

## Overview

The Mini Chat Application uses **flutter_animate** exclusively for all animations. This document covers the animation strategy and implementation patterns.

## Core Principles

1. **No AnimationController**: All animations use flutter_animate
2. **Declarative Syntax**: Chain animations using extensions
3. **Consistent Timing**: Standard durations and curves
4. **Micro-interactions**: Delightful feedback on user actions

## Standard Animation Values

### Durations

| Animation Type  | Duration  |
| --------------- | --------- |
| Fast (feedback) | 150ms     |
| Normal          | 300ms     |
| Slow (emphasis) | 400-500ms |

### Curves

| Use Case         | Curve                 |
| ---------------- | --------------------- |
| Enter animations | `Curves.easeOutCubic` |
| Exit animations  | `Curves.easeInCubic`  |
| Bounce effects   | `Curves.easeOutBack`  |
| Default          | `Curves.easeInOut`    |

## Animation Patterns

### 1. List Item Stagger

Cards animate in with a staggered delay:

```dart
Widget.animate()
  .fadeIn(duration: 300.ms, delay: (50 * index).ms)
  .slideX(begin: 0.1, duration: 300.ms, delay: (50 * index).ms)
```

### 2. Message Bubbles

Sender messages slide from right, receiver from left:

```dart
// Sender
.animate()
  .fadeIn(duration: 300.ms)
  .slideX(begin: 0.2, curve: Curves.easeOutCubic)

// Receiver
.animate()
  .fadeIn(duration: 300.ms)
  .slideX(begin: -0.2, curve: Curves.easeOutCubic)
```

### 3. FAB Animation

Scale and fade when appearing:

```dart
FloatingActionButton(...)
  .animate()
  .scale(duration: 300.ms, curve: Curves.easeOutBack)
  .fadeIn(duration: 200.ms)
```

### 4. Bottom Sheet Entrance

Slide up with fade:

```dart
Container(...)
  .animate()
  .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic)
  .fadeIn(duration: 200.ms)
```

### 5. Empty State Icons

Scale with bounce:

```dart
Icon(...)
  .animate()
  .scale(duration: 400.ms, curve: Curves.easeOutBack)
```

### 6. Tab Switcher

Smooth animated container transitions:

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  // ... styling based on isSelected
)
```

### 7. Loading States

Shimmer effect for loading:

```dart
CircularProgressIndicator()
  .animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 1000.ms)
```

### 8. Audio Button Pulse

Pulsing animation while playing:

```dart
IconButton(...)
  .animate(onPlay: (c) => c.repeat(reverse: true))
  .scaleXY(
    begin: 1.0,
    end: isPlaying ? 1.1 : 1.0,
    duration: 500.ms,
  )
```

## Widget-Specific Animations

### AvatarWidget

Optional scale animation on creation:

```dart
if (animate) {
  avatar = avatar.animate().scale(
    duration: 300.ms,
    curve: Curves.easeOutBack,
  );
}
```

### UserCard / ChatCard

Staggered entrance based on list index:

```dart
.animate()
  .fadeIn(duration: 300.ms, delay: (50 * index).ms)
  .slideX(begin: 0.1, duration: 300.ms, delay: (50 * index).ms, curve: Curves.easeOutCubic)
```

### MessageBubble

Direction-aware slide animation:

```dart
.animate()
  .fadeIn(duration: 300.ms)
  .slideX(
    begin: isSender ? 0.2 : -0.2,
    duration: 300.ms,
    curve: Curves.easeOutCubic,
  )
```

### DictionaryBottomSheet

Content sections fade and slide:

```dart
.animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, duration: 300.ms)
```

## Haptic Feedback

Paired with animations for tactile response:

```dart
HapticFeedback.lightImpact();   // Light tap
HapticFeedback.mediumImpact();  // Button press
HapticFeedback.selectionClick(); // Tab switch
```

## Performance Considerations

1. **Use const constructors**: Minimize rebuilds
2. **Limit simultaneous animations**: Avoid janky scrolling
3. **Test on low-end devices**: Ensure smooth performance
4. **Avoid animating during scroll**: Can cause frame drops
