# 🔴 MISSING FEATURES - Tubular PC

> **Based on your current project status** | All features NOT yet implemented in Tubular-PC

---

## 📊 IMPLEMENTATION STATUS BREAKDOWN

### ✅ CURRENTLY IMPLEMENTED (MVP Phase)
```
✓ Backend API server (Rust)
✓ Frontend UI (Flutter)
✓ Video search functionality
✓ Video playback (mpv integration)
✓ Download functionality (basic)
✓ Subscriptions management (backend)
✓ Watch history tracking (backend)
✓ SQLite database
✓ REST API endpoints
✓ Video card widget
✓ Player screen (basic)
✓ Home screen with search
```

### 🟡 IN PROGRESS
```
🔄 Download progress tracking UI
🔄 Subscriptions screen UI
🔄 History screen UI
🔄 Settings page
```

---

## 🔴 MISSING FEATURES (PRIORITY ORDER)

---

## TIER 1: CRITICAL FEATURES (UI/UX Screens)

### 1. **Subscriptions Screen** (UI Not Implemented)
- **Status**: Backend exists, **Frontend missing**
- **What's needed**:
  - Display list of subscribed channels
  - Show latest uploads from subscribed channels
  - Subscribe/unsubscribe buttons
  - Manage channel groups
  - Bulk subscription operations
  - Sort/filter subscriptions (by upload date, name, etc.)
  - Notification badges for new uploads
  - Channel info cards (thumbnail, subscriber count, description)
  - Quick access to channel page

---

### 2. **History Screen** (UI Not Implemented)
- **Status**: Backend exists, **Frontend missing**
- **What's needed**:
  - Display watch history timeline
  - Clear history options (all/selected/date range)
  - Continue watching (resume from last timestamp)
  - Search/filter history
  - Group by date
  - Remove individual history entries
  - Hide/show videos in history
  - Export history
  - History statistics (most watched, time spent, etc.)

---

### 3. **Downloads Screen** (Partial - UI missing features)
- **Status**: Basic download exists, **Enhanced UI missing**
- **What's needed**:
  - Download queue management UI
  - **Pause/Resume downloads**
  - **Cancel downloads**
  - Download progress indicators (per file)
  - File size estimates
  - Download location selector
  - Format selection before download (audio/video quality)
  - Batch download operations
  - Downloaded video organization (by date, channel, playlist)
  - Delete downloaded files
  - Search downloaded videos
  - Sort downloads (date added, size, duration)
  - Mark favorites from downloads
  - Move/rename downloaded files

---

### 4. **Settings/Preferences Screen** (MISSING)
- **Status**: Backend may have partial support, **UI completely missing**
- **What's needed**:

  **Playback Settings**:
  - Default video quality (360p, 480p, 720p, 1080p, 4K)
  - Playback speed presets
  - Subtitle preferences (font size, color, language)
  - Caption auto-enable
  - Continue playing after screen off
  - Player controls customization
  - Remember playback position
  - Skip intro/outro automatically

  **Download Settings**:
  - Default download path/location
  - Default download quality
  - Download naming pattern
  - Max concurrent downloads
  - Auto-download new uploads from favorite channels
  - Subtitles download preference

  **Privacy & Content**:
  - Search history on/off
  - Watch history on/off
  - Restricted mode (hide mature content)
  - Regional content preferences
  - Cookie/authentication storage

  **UI Customization**:
  - Theme selection (light/dark/AMOLED black)
  - Accent color selection
  - Font size adjustment
  - Layout options (compact/comfortable)
  - Language selection
  - Sidebar position
  - Always show player controls

  **SponsorBlock Settings** (when implemented):
  - Enable/disable SponsorBlock
  - Skip categories (sponsors, intros, outros, etc.)
  - Auto-skip or notify
  - Show skipped segments counter
  - Report segments permission

  **Return YouTube Dislike Settings**:
  - Enable/disable dislikes display
  - Show as percentage vs. count
  - Hide if below threshold

  **Application**:
  - Notification settings
  - Update checks
  - Debug mode
  - App cache clearing
  - Database export/import
  - About/version info

---

## TIER 2: CORE INTEGRATIONS (Not Implemented)

### 5. **SponsorBlock Integration** (PLANNED)
- **Status**: Rust backend module exists, **NOT integrated with player**
- **What's needed**:
  - API calls to SponsorBlock database
  - Extract video ID from URL
  - Get skip segments for video
  - **Automatic segment skipping in mpv** (critical)
  - **Show skip notifications** ("Sponsor skipped - 2:34 saved")
  - **Cumulative time saved counter**
  - Manual skip controls
  - Report incorrect segments
  - Whitelist channels
  - Choose categories to skip (sponsor, intro, outro, interaction, etc.)
  - Skip timing adjustments
  - Visual indicator of sponsor segments on timeline
  - Cache skip data locally

---

### 6. **ReturnYouTubeDislike Integration** (PLANNED)
- **Status**: Rust backend module exists, **NOT integrated with UI**
- **What's needed**:
  - API calls to RYD database
  - Fetch dislike counts for video
  - **Display on video cards** (before opening video)
  - **Display on player screen** (like/dislike ratio)
  - **Show as bar graph** (visual representation)
  - Show count as text
  - Like/dislike percentage
  - Aggregate rating (thumbs up/down)
  - Cache dislike data locally
  - Update on demand

---

## TIER 3: ADVANCED FEATURES (Not Implemented)

### 7. **Playlists System** (MISSING)
- **Status**: No implementation at all
- **What's needed**:
  - Create custom playlists
  - Add videos to playlists
  - Remove videos from playlists
  - Reorder videos in playlists
  - Delete playlists
  - Rename playlists
  - Playlist UI (dedicated screen)
  - Playlist descriptions
  - Share playlists
  - Import playlists
  - Export playlists (JSON/CSV)
  - YouTube playlist support (fetch/play YouTube playlists)
  - Save channel favorites to playlist
  - Auto-playlist for channels (latest uploads)

---

### 8. **Channel/Creator Pages** (MISSING)
- **Status**: No implementation at all
- **What's needed**:
  - Channel info display (banner, profile pic, subscriber count, description)
  - Channel uploads list
  - Channel playlists
  - Channel featured videos
  - Channel tabs (uploads, playlists, featured, community)
  - Subscribe/unsubscribe button
  - All videos/videos/shorts sorting
  - Search within channel
  - Channel statistics
  - Channel notifications
  - Channel pinned video indicator
  - Channel community posts (if available)

---

### 9. **Comments Section** (PLANNED in UI)
- **Status**: UI widget exists, **NOT functional**
- **What's needed**:
  - Fetch comments from yt-dlp/YouTube
  - Display comment threads
  - Load more comments (pagination)
  - Nested replies support
  - Sort comments (top/newest)
  - Like/unlike comments
  - Timestamp links in comments
  - User avatars in comments
  - Comment author badges
  - Pinned comments
  - Video author replies highlight
  - Reply to comments
  - Delete own comments
  - Report comments
  - Search comments

---

### 10. **Trending/Discovery** (MISSING)
- **Status**: No implementation
- **What's needed**:
  - Trending videos feed
  - Category-based trending (music, gaming, news, etc.)
  - Regional trending support
  - Trending by time period (today/this week/this month)
  - Recommendations based on watch history
  - Similar videos (when viewing video)
  - "Recommended for you" feed
  - Explore/discovery page
  - Random video suggestion
  - Category exploration

---

### 11. **Multi-Language & Localization** (MISSING)
- **Status**: No implementation
- **What's needed**:
  - App UI translation (all screens)
  - Settings for language selection
  - Support for multiple language packs
  - Subtitle language preferences
  - Searchable content in different languages
  - Regional video content support
  - RTL language support (Arabic, Hebrew)
  - Currency support (for regional pricing if applicable)
  - Date/time format localization

---

## TIER 4: PLAYER ENHANCEMENTS (Partial Implementation)

### 12. **Advanced Player Controls** (Partially missing)
- **Status**: Basic mpv integration exists
- **What's needed**:
  - **Video quality selector UI** (select before/during playback)
  - **Playback speed control UI** (0.25x - 2x)
  - **Subtitle selection & customization**
    - Font size
    - Font color
    - Background opacity
    - Subtitle language selection
  - **Audio track selection** (for multilingual videos)
  - **Aspect ratio controls** (fit/fill/zoom)
  - **Theater mode** (wider player)
  - **Picture-in-Picture mode**
  - **Fullscreen mode** (proper implementation)
  - **Keyboard shortcuts** (documented & customizable)
  - **Mouse wheel volume control**
  - **Click-to-pause/play**
  - **Gesture controls** (swipe for seeking, volume)
  - **Hardware acceleration** settings

---

### 13. **Background Playback** (PLANNED)
- **Status**: No implementation
- **What's needed**:
  - Continue playback when app minimized
  - Audio-only playback (extract audio)
  - Lock screen controls
  - System media controls integration
  - Notification controls
  - Pause when other app plays audio
  - Resume when other audio stops

---

### 14. **Video Timeline/Chapters** (MISSING)
- **Status**: No implementation
- **What's needed**:
  - Display chapter markers on timeline
  - Jump to chapters
  - Show chapter names on hover
  - Auto-generated chapters (if YouTube provides)
  - Custom chapter creation
  - Timeline preview/thumbnails on hover
  - Timestamp links in descriptions
  - Keyframe seeking (faster scrubbing)

---

## TIER 5: BACKEND/CORE SYSTEMS (Missing/Incomplete)

### 15. **Robust Error Handling** (Incomplete)
- **Status**: Minimal implementation
- **What's needed**:
  - Network error recovery
  - Timeout handling
  - Rate limiting handling
  - Graceful degradation
  - User-friendly error messages
  - Error logging system
  - Error reporting (optional)
  - Offline mode support
  - Retry mechanisms with exponential backoff
  - Connection status indicator

---

### 16. **Caching System** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Thumbnail caching
  - Search results caching
  - Video metadata caching
  - Comments caching
  - Channel info caching
  - Cache invalidation strategy
  - Cache size management
  - Clear cache option
  - Cache expiration settings

---

### 17. **Search Enhancements** (Basic only)
- **Status**: Only basic text search implemented
- **What's needed**:
  - Search filters (date, duration, upload date, etc.)
  - Filter by channel
  - Filter by video type (video/music/shorts)
  - Search within results
  - Search history
  - Saved searches
  - Advanced search syntax
  - Autocomplete suggestions
  - Search by URL/video ID
  - Fuzzy search support

---

### 18. **Update System** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Check for app updates
  - Auto-update mechanism
  - yt-dlp auto-update (critical)
  - Update progress indicator
  - Changelog display
  - Rollback option
  - Update notifications

---

## TIER 6: DATA MANAGEMENT (Partial)

### 19. **Database Features** (Incomplete)
- **Status**: Basic SQLite schema, **many features missing**
- **What's needed**:
  - **Database schema migrations**
  - **Data integrity checks**
  - **Backup/restore system**
  - **Database cleanup/optimization**
  - **Statistics dashboard** (total watch time, videos downloaded, etc.)
  - **Data export options** (JSON/CSV for subscriptions, history)
  - **Database encryption** (for privacy)
  - **Sync across devices** (cloud optional)
  - **Data size management**

---

### 20. **Auto-Download/Sync** (PLANNED)
- **Status**: No implementation
- **What's needed**:
  - Auto-download latest uploads from channels
  - Scheduling for auto-downloads
  - Smart download (avoid duplicates)
  - Queue management
  - Bandwidth limiting
  - Storage quota management
  - Smart delete (remove old downloads)

---

## TIER 7: ADVANCED UI/UX (Missing)

### 21. **Notifications** (Missing)
- **Status**: No implementation
- **What's needed**:
  - New upload notifications (subscribed channels)
  - Download complete notifications
  - App update notifications
  - SponsorBlock skip notifications
  - Custom notification preferences
  - Notification history
  - Do not disturb mode
  - Sound/vibration settings

---

### 22. **Search UI Enhancement** (Basic only)
- **Status**: Basic search box only
- **What's needed**:
  - Search suggestions dropdown
  - Recent searches
  - Trending searches
  - Saved searches
  - Search categories sidebar
  - Search results filters UI
  - Search results sorting
  - Search result view options (grid/list)

---

### 23. **Keyboard Shortcuts** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Spacebar to play/pause
  - Arrow keys for seeking
  - Volume control (+ / -)
  - Fullscreen (F)
  - Mute (M)
  - Numbers for seeking (0-9)
  - > / < for playback speed
  - L for like/dislike
  - S for settings
  - Customizable shortcuts
  - Shortcut help dialog (?)

---

### 24. **Accessibility Features** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Screen reader support
  - High contrast mode
  - Font size adjustment
  - Keyboard-only navigation
  - Focus indicators
  - Alt text for images
  - Audio descriptions
  - Captions/subtitles support
  - Color blind modes
  - Dyslexia-friendly font option

---

## TIER 8: CROSS-PLATFORM (Incomplete)

### 25. **Multi-Platform Support** (Partial)
- **Status**: Linux support mostly done, **Windows/macOS need work**
- **What's needed**:
  - **Windows native packaging** (.exe installer)
  - **macOS support** (build & package)
  - **macOS .dmg distribution**
  - **Linux AppImage** packaging
  - **Linux Flatpak** support
  - **Linux Snap** support
  - **Auto-update mechanism** per platform
  - **System tray icon** (minimize to tray)
  - **Launch on startup** option
  - Platform-specific shortcuts
  - Native file dialogs per OS
  - Drag & drop file support

---

### 26. **Platform-Specific Features** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Windows:
    - System media controls (multimedia keys)
    - Windows Notification API
    - Registry integration
  - Linux:
    - D-Bus integration
    - MPRIS protocol (media control)
    - Desktop file integration
  - macOS:
    - TouchBar support
    - Spotlight search integration
    - Handoff support (if cloud sync)

---

## TIER 9: TESTING & QA (Missing)

### 27. **Testing Coverage** (Minimal)
- **Status**: Basic widget test only
- **What's needed**:
  - Unit tests (backend & frontend)
  - Integration tests
  - API endpoint tests
  - Database tests
  - Player integration tests
  - Download tests
  - Search functionality tests
  - Performance tests
  - Stress tests
  - End-to-end UI tests

---

### 28. **Documentation** (Incomplete)
- **Status**: Basic READMEs exist, **detailed docs missing**
- **What's needed**:
  - API documentation (OpenAPI/Swagger)
  - Installation guides per OS
  - Configuration guide
  - Troubleshooting guide
  - Developer setup guide
  - Architecture documentation
  - Code comments/doc strings
  - User manual
  - Video tutorial
  - Keyboard shortcuts documentation
  - FAQ page
  - Contributing guidelines (exists but incomplete)

---

## TIER 10: PERFORMANCE & OPTIMIZATION (Missing)

### 29. **Performance Optimization** (Not done)
- **Status**: No optimization phase yet
- **What's needed**:
  - Lazy loading for lists
  - Virtual scrolling for large lists
  - Image optimization (compression, resizing)
  - Streaming optimization
  - Database query optimization
  - Memory profiling & leaks fixes
  - Startup time optimization
  - UI render optimization
  - Network request batching
  - Connection pooling

---

### 30. **Resource Management** (Missing)
- **Status**: Basic implementation only
- **What's needed**:
  - Memory usage limits
  - CPU usage optimization
  - Bandwidth limiting
  - Storage quota management
  - Download pause on low battery
  - Download pause on mobile data (desktop not applicable but conceptually)
  - Cleanup old cache automatically

---

## TIER 11: SECURITY & PRIVACY (Missing)

### 31. **Security Features** (Missing)
- **Status**: No security implementation
- **What's needed**:
  - HTTPS enforcement
  - Certificate pinning
  - Input validation/sanitization
  - XSS/CSRF protection
  - Rate limiting
  - DDoS protection
  - Secure credential storage
  - API key management
  - OAuth support (future)
  - Security audit

---

### 32. **Privacy Features** (Partial)
- **Status**: Basic, needs enhancement
- **What's needed**:
  - No telemetry/tracking
  - Data privacy policy
  - Cookie management
  - Do-not-track header
  - Anonymous search support
  - Encrypted local storage (optional)
  - Clear all data option
  - Data deletion on uninstall
  - GDPR compliance
  - Privacy audit

---

## TIER 12: NICE-TO-HAVE FEATURES (Bonus)

### 33. **Community/Social** (Not planned)
- **Status**: No implementation
- **What's needed**:
  - Share videos with link
  - Share timestamp links
  - Playlist sharing
  - Social media integration
  - Discord rich presence
  - Watch party (future)
  - Comments/reviews (future)

---

### 34. **Plugins/Extensions** (Not planned)
- **Status**: No implementation
- **What's needed**:
  - Plugin system
  - Custom theme support
  - Custom codec support
  - API for third-party tools

---

### 35. **Analytics/Stats** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Total watch time
  - Most watched channels
  - Most watched videos
  - Watch time by date
  - Download statistics
  - Playback statistics
  - Data visualization (charts)

---

## 📋 SUMMARY TABLE

| Feature | Status | Priority | Difficulty |
|---------|--------|----------|------------|
| Subscriptions UI | 🔴 Missing | P0 | Medium |
| History UI | 🔴 Missing | P0 | Medium |
| Downloads UI (Enhanced) | 🟡 Partial | P0 | Medium |
| Settings Screen | 🔴 Missing | P0 | Hard |
| SponsorBlock Integration | 🟡 Partial | P1 | Medium |
| ReturnYouTubeDislike Integration | 🟡 Partial | P1 | Easy |
| Playlists System | 🔴 Missing | P1 | Hard |
| Channel Pages | 🔴 Missing | P1 | Hard |
| Comments Section | 🟡 Partial | P1 | Medium |
| Trending/Discovery | 🔴 Missing | P2 | Hard |
| Multi-Language | 🔴 Missing | P2 | Medium |
| Background Playback | 🔴 Missing | P1 | Medium |
| Video Quality Selector | 🔴 Missing | P1 | Easy |
| Subtitle Customization | 🔴 Missing | P1 | Medium |
| Search Enhancements | 🟡 Partial | P1 | Medium |
| Database Features | 🟡 Partial | P2 | Hard |
| Auto-Download/Sync | 🔴 Missing | P2 | Hard |
| Notifications | 🔴 Missing | P1 | Medium |
| Keyboard Shortcuts | 🔴 Missing | P2 | Easy |
| Accessibility | 🔴 Missing | P3 | Hard |
| Error Handling | 🟡 Partial | P1 | Medium |
| Caching System | 🔴 Missing | P2 | Hard |
| Update System | 🔴 Missing | P2 | Medium |
| Cross-Platform Packaging | 🟡 Partial | P1 | Hard |
| Testing | 🟡 Minimal | P3 | Hard |
| Documentation | 🟡 Partial | P2 | Medium |
| Performance Optimization | 🔴 Missing | P3 | Hard |

---

## 🎯 RECOMMENDED IMPLEMENTATION ORDER

### **Phase 1 (MVP Completion)** - Next 2-3 weeks
1. **Subscriptions UI Screen**
2. **Settings Screen** (basic)
3. **History UI Screen**
4. **SponsorBlock automatic skipping**
5. **ReturnYouTubeDislike display**
6. **Video quality selector**

### **Phase 2 (Core Features)** - Weeks 4-6
1. **Playlists system**
2. **Channel pages**
3. **Comments section** (functional)
4. **Enhanced downloads UI**
5. **Search enhancements**
6. **Background playback**

### **Phase 3 (Polish)** - Weeks 7-9
1. **Keyboard shortcuts**
2. **Notifications system**
3. **Multi-language support**
4. **Performance optimization**
5. **Error handling improvements**
6. **Caching system**

### **Phase 4 (Advanced)** - Weeks 10+
1. **Trending/Discovery**
2. **Accessibility features**
3. **Cross-platform packaging**
4. **Comprehensive testing**
5. **Documentation**

---

## 🔗 NOTES

- **Total Missing Features**: ~35 major feature areas
- **Estimated Completion Time**: 3-6 months (with dedicated team)
- **Most Critical**: Settings, Subscriptions UI, History UI, SponsorBlock integration
- **Highest Impact**: Playlists, Channel pages, Background playback
- **Quick Wins**: Keyboard shortcuts, Notifications, Quality selector

---

*Generated for Pragadeesh | Tubular PC Project | 2026*
