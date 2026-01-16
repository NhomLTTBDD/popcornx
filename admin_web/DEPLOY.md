# 🚀 Hướng dẫn Deploy Flutter Web Admin lên Firebase Hosting

## 📋 Yêu cầu

1. Firebase CLI đã cài đặt
2. Đã login Firebase
3. Đã có Firebase project

## 🔧 Bước 1: Cài đặt Firebase CLI (nếu chưa có)

```bash
npm install -g firebase-tools
```

## 🔐 Bước 2: Login Firebase

```bash
firebase login
```

## 🏗️ Bước 3: Build Flutter Web

```bash
cd admin_web
flutter build web --release
```

## 🔥 Bước 4: Initialize Firebase Hosting (lần đầu)

```bash
firebase init hosting
```

Chọn:
- ✅ Use an existing project → Chọn project của bạn
- Public directory: `build/web`
- ✅ Configure as a single-page app
- ✅ Set up automatic builds and deploys with GitHub? → No (hoặc Yes nếu muốn)

## 📝 Bước 5: Cấu hình firebase.json

File `firebase.json` sẽ được tạo, đảm bảo có nội dung:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

## 🚀 Bước 6: Deploy

```bash
firebase deploy --only hosting
```

## ✅ Bước 7: Kiểm tra

Sau khi deploy thành công, bạn sẽ nhận được URL:
```
https://your-project-id.web.app
```

Hoặc:
```
https://your-project-id.firebaseapp.com
```

## 🔄 Deploy lại sau khi update

```bash
# Build lại
flutter build web --release

# Deploy
firebase deploy --only hosting
```

## 🔒 Bước 8: Setup Firestore & Storage Rules

### Firestore Rules

1. Vào Firebase Console → Firestore Database → Rules
2. Copy nội dung từ `firestore.rules`
3. Paste vào và click "Publish"

### Storage Rules

1. Vào Firebase Console → Storage → Rules
2. Copy nội dung từ `storage.rules`
3. Paste vào và click "Publish"

## 🎯 Setup Admin User

1. Đăng ký user mới qua Admin Web App
2. Vào Firestore Console → `users/{uid}`
3. Sửa field `role` = `"admin"`
4. Đăng nhập lại với user đó

## 📱 Custom Domain (Optional)

1. Vào Firebase Console → Hosting → Add custom domain
2. Follow instructions để verify domain
3. Update DNS records

## 🐛 Troubleshooting

### Lỗi: "Firebase not initialized"
```bash
firebase init hosting
```

### Lỗi: "Build failed"
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Lỗi: "Permission denied"
```bash
firebase login
```

## 📚 Tài liệu tham khảo

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
