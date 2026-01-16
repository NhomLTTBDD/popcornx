# 🏗️ KIẾN TRÚC HỆ THỐNG - Movie App

## 📊 Sơ đồ tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   Firebase   │  │   Cloud      │  │   Firebase    │   │
│  │     Auth     │  │  Firestore   │  │   Storage     │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│       │                  │                  │            │
└───────┼──────────────────┼──────────────────┼────────────┘
        │                  │                  │
        │                  │                  │
┌───────▼──────────┐  ┌───▼──────────┐  ┌───▼──────────┐
│  Flutter Web     │  │  Flutter     │  │  Mobile App  │
│  Admin App       │  │  Mobile App  │  │  (User)      │
│                  │  │  (User)      │  │              │
│  - Login         │  │  - Login     │  │  - View      │
│  - Upload        │  │  - View      │  │    Movies    │
│  - Manage        │  │    Movies    │  │  - Play      │
│    Movies        │  │  - Play      │  │    Videos    │
│                  │  │    Videos    │  │              │
└──────────────────┘  └──────────────┘  └──────────────┘
```

## 🔐 Phân quyền

### Admin (Web App)
- ✅ Login với Firebase Auth
- ✅ Check role = 'admin' trong Firestore
- ✅ Upload ảnh thumbnail lên Storage
- ✅ Upload video MP4 lên Storage
- ✅ Tạo/Update/Delete movies trong Firestore
- ✅ Quản lý users (set role)

### User (Mobile App)
- ✅ Login với Firebase Auth
- ✅ Read movies từ Firestore
- ✅ Read thumbnails và videos từ Storage
- ❌ KHÔNG upload files
- ❌ KHÔNG modify movies

## 📁 Cấu trúc dữ liệu

### Firestore Collection: `users/{uid}`
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "photoUrl": "string",
  "role": "admin" | "user",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Firestore Collection: `movies/{movieId}`
```json
{
  "title": "string",
  "description": "string",
  "thumbnailUrl": "string (Storage URL)",
  "videoUrl": "string (Storage URL)",
  "trending": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Firebase Storage Structure
```
storage/
├── thumbnails/
│   └── {userId}_{timestamp}.jpg
└── videos/
    └── {userId}_{timestamp}.mp4
```

## 🔒 Security Rules

### Firestore Rules
- Users: Read own data, admins can write
- Movies: Everyone can read, only admins can write

### Storage Rules
- Thumbnails: Everyone can read, only admins can upload (max 5MB)
- Videos: Everyone can read, only admins can upload (max 500MB)

## 🚀 Flow hoạt động

### Admin Upload Movie
1. Admin login → Check role = 'admin'
2. Fill form (title, description)
3. Pick thumbnail image → Upload to Storage → Get URL
4. Pick video MP4 → Upload to Storage → Get URL
5. Save metadata to Firestore with URLs

### User View Movie
1. User login (optional)
2. Read movies from Firestore
3. Display thumbnails from Storage URLs
4. Play videos from Storage URLs

## 📦 Tech Stack

### Admin Web App
- Flutter Web
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- File Picker

### Mobile App
- Flutter (Android/iOS)
- Firebase Auth
- Cloud Firestore
- Firebase Storage (read only)
- Video Player

## 🔄 Data Flow

```
Admin Upload:
Admin → Web App → Storage (upload) → Storage URL
                → Firestore (save metadata + URLs)

User View:
Mobile App → Firestore (read metadata) → Storage URLs
          → Storage (read files) → Display/Play
```
