# 📄 Ví dụ Firestore Document

## Collection: `movies/{movieId}`

### Example Document
```json
{
  "title": "The Matrix",
  "description": "A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.",
  "thumbnailUrl": "https://firebasestorage.googleapis.com/v0/b/baitap-24951.firebasestorage.app/o/thumbnails%2Fadmin123_1234567890.jpg?alt=media&token=...",
  "videoUrl": "https://firebasestorage.googleapis.com/v0/b/baitap-24951.firebasestorage.app/o/videos%2Fadmin123_1234567890.mp4?alt=media&token=...",
  "trending": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|------------|
| `title` | string | ✅ Yes | Tên phim |
| `description` | string | ❌ No | Mô tả phim |
| `thumbnailUrl` | string | ✅ Yes | URL ảnh thumbnail từ Firebase Storage |
| `videoUrl` | string | ✅ Yes | URL video MP4 từ Firebase Storage |
| `trending` | boolean | ❌ No | Phim có đang trending không (default: false) |
| `createdAt` | timestamp | ✅ Yes | Thời gian tạo |
| `updatedAt` | timestamp | ✅ Yes | Thời gian cập nhật |

## Collection: `users/{uid}`

### Example Document (Admin)
```json
{
  "uid": "admin123",
  "name": "Admin User",
  "email": "admin@example.com",
  "photoUrl": "https://example.com/photo.jpg",
  "role": "admin",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Example Document (User)
```json
{
  "uid": "user456",
  "name": "Regular User",
  "email": "user@example.com",
  "photoUrl": "https://example.com/photo.jpg",
  "role": "user",
  "createdAt": "2024-01-10T00:00:00Z",
  "updatedAt": "2024-01-10T00:00:00Z"
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|------------|
| `uid` | string | ✅ Yes | User ID từ Firebase Auth |
| `name` | string | ❌ No | Tên người dùng |
| `email` | string | ❌ No | Email người dùng |
| `photoUrl` | string | ❌ No | URL ảnh đại diện |
| `role` | string | ✅ Yes | Role: "admin" hoặc "user" |
| `createdAt` | timestamp | ✅ Yes | Thời gian tạo |
| `updatedAt` | timestamp | ✅ Yes | Thời gian cập nhật |

## 🔑 Setup Admin Role

Để set một user thành admin, vào Firestore Console và sửa:

```
users/{uid}/role = "admin"
```

Hoặc dùng code:
```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'role': 'admin'});
```
