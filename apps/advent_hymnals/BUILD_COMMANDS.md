# Flutter Web App Build Commands

## Prerequisites

1. **Flutter SDK** (3.5.4 or higher)
2. **JSON Code Generation** - Run this first:
   ```bash
   cd apps/advent_hymnals
   flutter packages pub run build_runner build
   ```

## Environment-Specific Builds

### Development Build
```bash
cd apps/advent_hymnals
flutter build web \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=http://localhost:3000/api \
  --dart-define=MEDIA_BASE_URL=http://localhost:3000/media
```

### Staging Build
```bash
cd apps/advent_hymnals
flutter build web \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=API_BASE_URL=https://staging.adventhymnals.org/api \
  --dart-define=MEDIA_BASE_URL=https://staging.adventhymnals.org/media
```

### Production Build
```bash
cd apps/advent_hymnals
flutter build web \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://adventhymnals.org/api \
  --dart-define=MEDIA_BASE_URL=https://adventhymnals.org/media \
  --release
```

## Debug Commands

### Run in Development Mode
```bash
cd apps/advent_hymnals
flutter run -d chrome \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=http://localhost:3000/api
```

### Run with Custom API URL
```bash
cd apps/advent_hymnals
flutter run -d chrome \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=https://your-custom-api.com/api
```

### Hot Reload Development
```bash
cd apps/advent_hymnals
flutter run -d chrome --hot
```

## Code Generation Commands

### Generate JSON Serialization Code
```bash
cd apps/advent_hymnals
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Watch for Changes (Development)
```bash
cd apps/advent_hymnals
flutter packages pub run build_runner watch
```

### Clean Generated Files
```bash
cd apps/advent_hymnals
flutter packages pub run build_runner clean
```

## Testing Commands

### Run All Tests
```bash
cd apps/advent_hymnals
flutter test
```

### Run Widget Tests
```bash
cd apps/advent_hymnals
flutter test test/widget_test.dart
```

### Run Integration Tests
```bash
cd apps/advent_hymnals
flutter test integration_test/
```

## Package Management

### Get Dependencies
```bash
cd apps/advent_hymnals
flutter pub get
```

### Update Dependencies
```bash
cd apps/advent_hymnals
flutter pub upgrade
```

### Check for Outdated Packages
```bash
cd apps/advent_hymnals
flutter pub outdated
```

## Quality Assurance

### Analyze Code
```bash
cd apps/advent_hymnals
flutter analyze
```

### Format Code
```bash
cd apps/advent_hymnals
flutter format .
```

### Check Dependencies
```bash
cd apps/advent_hymnals
flutter pub deps
```

## Build Optimization

### Optimized Production Build
```bash
cd apps/advent_hymnals
flutter build web \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://adventhymnals.org/api \
  --release \
  --web-renderer html \
  --tree-shake-icons \
  --source-maps
```

### Build with Specific Renderer
```bash
# HTML renderer (better compatibility)
flutter build web --web-renderer html

# CanvasKit renderer (better performance)
flutter build web --web-renderer canvaskit
```

## Docker Commands

### Build Docker Image
```bash
cd apps/advent_hymnals
docker build -t advent-hymnals-flutter .
```

### Run Docker Container
```bash
docker run -p 8080:80 \
  -e ENVIRONMENT=production \
  -e API_BASE_URL=https://adventhymnals.org/api \
  advent-hymnals-flutter
```

## Environment Variables

### Available Environment Variables
- `ENVIRONMENT`: `development`, `staging`, `production`
- `API_BASE_URL`: Base URL for API requests
- `MEDIA_BASE_URL`: Base URL for media files
- `ENABLE_ANALYTICS`: Enable Google Analytics (true/false)
- `DEBUG_MODE`: Enable debug logging (true/false)

### Example `.env` File
```bash
# .env (for development)
ENVIRONMENT=development
API_BASE_URL=http://localhost:3000/api
MEDIA_BASE_URL=http://localhost:3000/media
ENABLE_ANALYTICS=false
DEBUG_MODE=true
```

## Deployment Commands

### Deploy to Firebase Hosting
```bash
cd apps/advent_hymnals
flutter build web --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://adventhymnals.org/api

firebase deploy --only hosting
```

### Deploy to Netlify
```bash
cd apps/advent_hymnals
flutter build web --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://adventhymnals.org/api

# Upload build/web directory to Netlify
```

### Deploy to GitHub Pages
```bash
cd apps/advent_hymnals
flutter build web --release \
  --base-href="/advent-hymnals/" \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://adventhymnals.org/api

# Deploy build/web directory to gh-pages branch
```

## Performance Optimization

### Profile Build Performance
```bash
cd apps/advent_hymnals
flutter build web --profile \
  --dart-define=ENVIRONMENT=development \
  --source-maps
```

### Analyze Bundle Size
```bash
cd apps/advent_hymnals
flutter build web --analyze-size
```

### Enable Tree Shaking
```bash
cd apps/advent_hymnals
flutter build web --tree-shake-icons --release
```

## Troubleshooting

### Clear Build Cache
```bash
cd apps/advent_hymnals
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

### Fix Dependency Issues
```bash
cd apps/advent_hymnals
flutter pub deps --no-dev
flutter pub get
```

### Debug Build Issues
```bash
cd apps/advent_hymnals
flutter build web --verbose
```

## Integration with Monorepo

### Build from Root Directory
```bash
# From monorepo root
cd apps/advent_hymnals && flutter build web --release
```

### Use with pnpm/npm Scripts
```json
{
  "scripts": {
    "build:flutter": "cd apps/advent_hymnals && flutter build web --release",
    "dev:flutter": "cd apps/advent_hymnals && flutter run -d chrome --hot",
    "test:flutter": "cd apps/advent_hymnals && flutter test"
  }
}
```

## Media Download System

### Build with Media Support
```bash
cd apps/advent_hymnals
flutter build web \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://adventhymnals.org/api \
  --dart-define=MEDIA_BASE_URL=https://adventhymnals.org/media \
  --dart-define=ENABLE_MEDIA_DOWNLOAD=true \
  --release
```

### Test Media Features
```bash
cd apps/advent_hymnals
flutter run -d chrome \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=http://localhost:3000/api \
  --dart-define=ENABLE_MEDIA_DOWNLOAD=true
```

## Notes

1. **JSON Generation**: Always run `build_runner build` after modifying model files
2. **Environment Variables**: Use `--dart-define` for compile-time configuration
3. **Web Renderer**: Choose HTML for compatibility, CanvasKit for performance
4. **Source Maps**: Include `--source-maps` for debugging production builds
5. **Tree Shaking**: Use `--tree-shake-icons` to reduce bundle size
6. **Media Support**: Ensure API and media URLs are correctly configured for your environment

## Quick Start

For first-time setup:
```bash
cd apps/advent_hymnals
flutter pub get
flutter packages pub run build_runner build
flutter run -d chrome --dart-define=ENVIRONMENT=development
```