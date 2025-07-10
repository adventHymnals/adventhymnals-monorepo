# Update System Architecture

## Current Problem
- **Bundled assets** (assets/data/) cannot be updated after app installation
- **Static JSON files** don't support incremental updates
- **App store approval** required for any bundled data changes

## Proposed Solution: Layered Data Architecture

### 1. Data Storage Layers

```
📱 App Data Architecture
├── 🔒 BUNDLED (Read-only, shipped with app)
│   ├── assets/data/core/
│   │   ├── essential-collections.json    # SDAH, CS1900 metadata
│   │   ├── app-config.json              # App configuration
│   │   └── hymns/essential/             # Top 100 most-used hymns
│   └── Purpose: Immediate offline access, zero download time
│
├── 💾 CACHED (Downloaded, writable)
│   ├── documents/hymnal_data/
│   │   ├── collections/                 # Full collection downloads
│   │   ├── hymns/                      # Individual hymn files
│   │   ├── updates/                    # Incremental updates
│   │   └── index.json                  # Local data index
│   └── Purpose: Full collections, updates, user preferences
│
└── 🔄 RUNTIME (Merged view)
    └── DataManager provides unified access to both layers
```

### 2. Update Mechanism

#### Backend Infrastructure Needed:

**A. Update Server Endpoints**
```
https://api.adventhymnals.org/
├── /version                          # Current data version
├── /updates/{from_version}           # Incremental updates
├── /collections/{id}                 # Full collection download
├── /hymns/{collection}/{hymn_id}     # Individual hymn
└── /manifest                         # Available content manifest
```

**B. Update Server Response Format**
```json
// GET /version
{
  "data_version": "2024.07.15",
  "app_min_version": "1.0.0",
  "critical_update": false,
  "available_updates": [
    {
      "type": "collection_update",
      "collection_id": "SDAH",
      "version": "2024.07.15",
      "size_mb": 2.3,
      "changes": ["new_hymns", "lyrics_corrections"]
    }
  ]
}

// GET /updates/2024.07.01
{
  "from_version": "2024.07.01",
  "to_version": "2024.07.15",
  "updates": [
    {
      "action": "add_hymn",
      "collection": "SDAH",
      "hymn_id": "SDAH-en-696",
      "file_url": "/hymns/SDAH/SDAH-en-696.json"
    },
    {
      "action": "update_lyrics",
      "collection": "CS1900", 
      "hymn_id": "CS1900-en-123",
      "file_url": "/hymns/CS1900/CS1900-en-123.json"
    }
  ]
}
```

#### Mobile App Implementation:

**C. Update Process Flow**
```dart
class UpdateManager {
  // 1. Check for updates (daily)
  Future<UpdateInfo> checkForUpdates()
  
  // 2. Download incremental updates
  Future<void> downloadUpdates(List<Update> updates)
  
  // 3. Apply updates atomically
  Future<void> applyUpdates()
  
  // 4. Fallback to bundled data if needed
  Future<dynamic> getDataWithFallback(String path)
}
```

### 3. Implementation Plan

#### Phase 1: Foundation (Immediate)
- [x] Create layered data architecture
- [ ] Implement UpdateManager class
- [ ] Add version tracking
- [ ] Create data merger logic

#### Phase 2: Backend Setup (Next Sprint)
- [ ] Setup update server endpoints
- [ ] Create versioning system
- [ ] Implement delta generation
- [ ] Add CDN for static files

#### Phase 3: Smart Updates (Future)
- [ ] Background sync
- [ ] Partial collection updates
- [ ] Conflict resolution
- [ ] Rollback capability

### 4. Technical Benefits

✅ **Immediate offline access** (bundled essentials)
✅ **No app store delays** for data updates
✅ **Incremental downloads** (efficient bandwidth)
✅ **Graceful degradation** (bundled fallback)
✅ **Version control** (track all changes)
✅ **Rollback capability** (if updates fail)

### 5. User Experience

```
🚀 First Launch: 
   ├── Bundled data loads instantly
   ├── Essential hymns available offline
   └── Background check for updates

📥 Updates Available:
   ├── Non-intrusive notification
   ├── Download on WiFi only (optional)  
   ├── Progress indicator
   └── Immediate availability after download

🔄 Seamless Experience:
   ├── No app restart required
   ├── New content appears automatically
   └── Old content remains if update fails
```

### 6. Implementation Priority

**High Priority (This Sprint):**
1. Fix collection filtering (completed above)
2. Implement UpdateManager base class
3. Add version checking mechanism
4. Create data layer abstraction

**Medium Priority (Next Sprint):**
1. Setup backend update endpoints
2. Implement incremental download system
3. Add progress indicators and user control

**Low Priority (Future):**
1. Advanced conflict resolution
2. Predictive downloading
3. Analytics and usage tracking