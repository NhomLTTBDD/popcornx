# 🎬 Flutter Web Admin - Movie Management System

Flutter Web application để quản lý phim, upload video và ảnh lên Firebase.

## 📋 Tính năng

- ✅ Login với Firebase Auth
- ✅ Phân quyền Admin (check role từ Firestore)
- ✅ Upload ảnh thumbnail (JPG/PNG)
- ✅ Upload video MP4
- ✅ Quản lý danh sách phim
- ✅ Xóa phim
- ✅ Set trending movie

## 🏗️ Cấu trúc Project

```
admin_web/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── firebase_options.dart        # Firebase config
│   ├── screens/
│   │   ├── admin_login_screen.dart  # Login screen
│   │   └── admin_dashboard.dart     # Main dashboard
│   └── services/
│       ├── firestore_service.dart   # Firestore operations
│       └── upload_service.dart      # Storage upload
├── firestore.rules                  # Firestore security rules
├── storage.rules                    # Storage security rules
└── pubspec.yaml                     # Dependencies
```

## 🚀 Cài đặt

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Chạy local

```bash
flutter run -d chrome
```

### 3. Build for production

```bash
flutter build web --release
```

## 🔐 Setup Admin User

1. Đăng ký user mới qua login screen
2. Vào Firebase Console → Firestore → `users/{uid}`
3. Sửa field `role` = `"admin"`
4. Đăng nhập lại

## 🔒 Security Rules

### Firestore Rules
- Copy `firestore.rules` vào Firebase Console → Firestore → Rules
- Publish rules

### Storage Rules
- Copy `storage.rules` vào Firebase Console → Storage → Rules
- Publish rules

## 📦 Dependencies

- `firebase_core: ^3.6.0`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.5.0`
- `firebase_storage: ^12.3.0`
- `file_picker: ^8.1.2`

## 🚀 Deploy

Xem file `DEPLOY.md` để biết cách deploy lên Firebase Hosting.

## 📱 Mobile App Integration

Mobile app (Flutter) sẽ:
- Read movies từ Firestore
- Display thumbnails từ Storage URLs
- Play videos từ Storage URLs

## 🎯 Workflow

1. **Admin login** → Check role = 'admin'
2. **Fill form** → Title, description
3. **Pick thumbnail** → Upload to Storage → Get URL
4. **Pick video** → Upload to Storage → Get URL
5. **Save to Firestore** → Metadata + URLs
6. **Mobile app** → Read from Firestore → Display/Play

## 📄 License

Private project
