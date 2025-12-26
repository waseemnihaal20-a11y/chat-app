# Networking System

## Overview

The Mini Chat Application uses **Dio** for all HTTP communications. This document covers the networking architecture, configuration, and error handling.

## Configuration

### Global Configuration

All network settings are centralized in `lib/config/global.dart`:

```dart
class GlobalConfig {
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String baseUrl = 'https://dummyjson.com';
  static const String dictionaryBaseUrl = 'https://api.dictionaryapi.dev/api/v2';
  static const String commentsEndpoint = '/comments';
  static const String dictionaryEndpoint = '/entries/en';
}
```

### Timeout Configuration

All API calls use a 30-second timeout for:

- Connection timeout
- Send timeout
- Receive timeout

## Services

### ApiService

**Purpose**: Communicates with DummyJSON API for receiver messages

**Endpoints**:

- `GET /comments?limit=10`: Fetch comments for receiver messages

**Initialization**:

```dart
_dio = Dio(BaseOptions(
  baseUrl: GlobalConfig.baseUrl,
  connectTimeout: GlobalConfig.apiTimeout,
  receiveTimeout: GlobalConfig.apiTimeout,
  sendTimeout: GlobalConfig.apiTimeout,
));
```

**Methods**:

- `fetchComments({int limit})`: Get list of comments
- `fetchRandomComment()`: Get single random comment

### DictionaryService

**Purpose**: Fetches word definitions from Free Dictionary API

**Endpoints**:

- `GET /entries/en/{word}`: Get word definition

**Methods**:

- `getDefinition(String word)`: Fetch word definition

**Error Handling**:

- 404: Word not found → DictionaryError
- Network errors → DictionaryError with resolution hint

## API Endpoints

### Comments API (DummyJSON)

**Request**:

```
GET https://dummyjson.com/comments?limit=10
```

**Response**:

```json
{
  "comments": [
    {
      "id": 1,
      "body": "This is some awesome thinking!",
      "user": {
        "id": 105,
        "username": "emmac",
        "fullName": "Emma Wilson"
      }
    }
  ],
  "total": 340,
  "skip": 0,
  "limit": 10
}
```

### Dictionary API

**Request**:

```
GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}
```

**Success Response**:

```json
[
  {
    "word": "hello",
    "phonetic": "/həˈloʊ/",
    "phonetics": [
      {
        "text": "/həˈloʊ/",
        "audio": "https://..."
      }
    ],
    "meanings": [
      {
        "partOfSpeech": "noun",
        "definitions": [
          {
            "definition": "A greeting",
            "example": "Hello, how are you?"
          }
        ]
      }
    ]
  }
]
```

**Error Response** (404):

```json
{
  "title": "No Definitions Found",
  "message": "Sorry pal, we couldn't find definitions...",
  "resolution": "You can try the search again..."
}
```

## Error Handling Strategy

### Network Errors

1. **Timeout**: Show user-friendly timeout message
2. **No Connection**: Prompt to check internet
3. **Server Error**: Generic error with retry option

### API Errors

1. **404 (Dictionary)**: "Word not found" with suggestion
2. **4xx**: Client error message
3. **5xx**: Server error message

### Error Flow

```
API Call → DioException → Catch in Service → Throw Custom Error →
Provider catches → Sets _error → Consumer shows error UI
```

## Interceptors

Dio interceptors are configured for:

- Request logging (debug)
- Response logging (debug)
- Error logging

```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));
```

## Best Practices

1. **Always use GlobalConfig**: Never hardcode URLs or timeouts
2. **Handle all errors**: Wrap API calls in try-catch
3. **Dispose resources**: Call `dio.close()` in dispose
4. **Clean input**: Sanitize user input before API calls
5. **Parse safely**: Handle missing/null fields in JSON
