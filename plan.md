
Alright Pragadeesh 😎🔥
You’re not just building an app… you’re basically building a **desktop-level NewPipe/Tubular clone** — that’s elite tier stuff.

I’ll give you a **FULL PROJECT GUIDE (production-level)** for:

# 🚀 Project: **Tubular-PC**

> Goal: Exact Tubular UI/UX + Desktop power 💻⚡
> Platforms: Linux + Windows + macOS
> Stack: Flutter + Rust + yt-dlp

---

# 🧠 0. Reality check (VERY IMPORTANT)

Tubular (NewPipe fork) works by:

* ❌ No official YouTube API
* ✅ Direct extraction/scraping
* ✅ Local data storage
* ✅ No login required

➡️ This gives:

* Ad-free
* Background play
* Downloads
* Privacy

But also:

* Breaks often when YouTube updates ([OSTechNix][1])

👉 So your architecture must be **modular + replaceable**

---

# 🏗️ 1. FINAL ARCHITECTURE (BEST FOR YOU)

```
Tubular-PC/
│
├── frontend/        (Flutter Desktop)
├── backend/         (Rust core)
├── extractor/       (yt-dlp wrapper)
├── player/          (mpv / libmpv)
└── api/             (SponsorBlock, Dislike API)
```

---

# ⚙️ 2. TECH STACK (LOCK THIS IN 🔒)

### 🎨 Frontend

* Flutter (desktop)
* Riverpod / Bloc (state)
* Custom UI (no Material look — replicate Tubular)

---

### ⚡ Backend

* Rust
* Tokio (async)
* Expose API via:

  * IPC (preferred)
  * or HTTP localhost

---

### 🎥 Extractor

* yt-dlp (core engine)
  👉 Supports 1000+ sites including YouTube ([StreamFab][2])

---

### 🎬 Player

* libmpv (BEST)
* fallback: Flutter video player

---

### 🌐 APIs

* SponsorBlock → skip segments
* Return YouTube Dislike

---

# 🎨 3. EXACT UI/UX (Tubular Clone)

You want **exact UI = not copy… replicate behavior**

---

## 📱 Main Screens

### 1. Home Feed

![Image](https://images.openai.com/static-rsc-4/JrrodGM439iIuk340pyDkGxeNWFGw6sLz1yW8aDj4rTReRVTk20HBLrPRuYDRzL5XKJT1Zw2EZLtV_GXvvTOL8VzE3G0wy2i-Ib7dEuHR9TIwbymktBpT7XjxBLe48gzaR9oyRCa8w9dfEW5eOep608A38-993LEoLhw3GjM3XoQbTutr3dOJOCd_MtY0FAE?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/wbD2cg3B0Oi6JN6snup7UhNJ_CuuKhlDCHB7eTOu_2Rwn0UsyfHjd8jVZMReu7XYtyYCSEw36oMIHvhgrTh_8Hgcz4xiR5kASPW6NVIHoDvxTjk_NGagYlOzJjSr7EODMjdVW5Hhid9ZgmM1M5w3jiDTzoqzQWo0d3lrJGTmK6xRXSIG6O-2QLhNK4O1aumU?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/WH3_ew8HyHcPcljWImFCxFJljf5_ThsiXnW1D3VaN7uvUScAwrjXAzZsfhOcD1AuRJeixRdlAdM4EytV__ICuhzHhGyw1NvpTy5PqBWsZ7PwviFegGJt4EsCj-_MDMrn3x9pLxWgG1pqPtXkLHYQPyxpbQ1PngyOemYunUYEcD0wDJKJtVrFDc4gowSEHENV?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/153-k06EzeqUF5DBMWkapq5MzILqwT5kI8F9kWoaot__jfszRd4uXCj3tnboNgzrOij9rQmsRDjnulvr_-qqIiIaby4P8iQKTUWUPPOrjZPqa3-KzK4o09uwvpTbf9qrLJv0ajzxj5f0EVS14Op-pwjFm-A8YQjZzd9_8OKkNMnOAqlcIX-3g50Z7azxWjEu?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/P_OHHW5awK2pCEhfsDBKPROGZPyGx3DURFacGThY_-z1aIslwMsgXbMI-zrgjf8b_PTPc3h0N6kOUffHjEdTEZgcbG9WjDykT8ROZv_EUSQe5eLxm1ucjaWJHXN9zbilqrveC-fsQkFBpPllncyIrKZ5l7ZFLULn7vrCKE4ofc-VS2ACxaSOnHz1vUxmNw-B?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/1LzK2PtY9MRVhSDqh2OwyrrwjVWoz9JPGnZB5utYbM6o8Pp2fRZRpOcHEGoXmaRIdSmUnYISf-Mm7PHjsmSiCQUoCnVIuzTs4qugReUhK3EMrm6j2yFK7lmDgHhRU_WeIM3aWh5mrU-5wy8Rd7MmWpEETTCZapzPSNto8LP0BoxP3cJN8BK8zkWF4iaKslqN?purpose=fullsize)

* Grid layout
* Infinite scroll
* Thumbnail + duration
* Channel + views

---

### 2. Video Player Screen

![Image](https://images.openai.com/static-rsc-4/ZATUtOLG4ZrIjwk3kb3g3Pi1HaJNLibrZRFWD3Sj7LsmP8sxV3NCGutAIKBcXw1TP7NyRWrnZ-6Co4R7bqCQSEq7MuXk0UxHWxQUkVWRJ_x2HAAQV1ZwuaraVn6gSvQb0TnNu7qq2izspsvxERKZmL3vez5jAo9Fpb8nDFbdmcA3-poyaCdiAsUKVQaosMk6?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/axsWwtRk94no3rqdYEXiH7-MZn_O9nz4gkscqeUx1ujcldSnyHSnND9VYjbkVy5eua3P8-RMwx3H5ufV_48e1_FHhWU43Lt_zYlGh97O5AvBJL1eOqhtqLpgHSVQr_WYN6zx7kanO_VhylQR6lHILCPEL1t2D_AAzWDSY2SIC5cerGpIkLIkLmzAdXGq9f9C?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/F6RbLPOFeiFOLw-1_6JLSyFgBBD2isHPbmByWXRJzOxCEecmGA5sca_84c8H4iRYgHod2AHhfGjuDKc-u3JCR7Z6XpECRF40GPYTWvjROV0FSL979vyhoZz_y2r5bwFvxVrpARborIlDKJ0Uy4FGDR9oLHYdNv4p3uzQj9-BqRvZxW1Qqqm3wUPqPbbFoXu5?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/WEHqCnWnUSvY902VleiW5pQ5omLc5I-a7tDyCFdGdt8LHgAmC5vw0a1Fjxm3GCVCEPy2nNBwqpfL4TP4Y5LggiMdPvgevI7MyngzfV9SzrOTf7-irv2iBHeuEBq3CZW7BtHKTbd_l6N0MEU5c_l6GXQFEkOqpzifoyvxP5de-vOjzuc_fcOYxXNJndVkIcr-?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/GqHw57H63yLcxe6OdAlzE-I4IhWjFjv7gzied5o0lZvWN5E7O04CBlHrniXAS1naMNtsU8GKhO86JgxSAaX2jvFIPwmyrjOyMWuM7-LwTn6t-0zdbTUAheyc2EuqyWUlWwsBNKa7gJ25UMrkWydpuJehUDmXZmL_CK_XnTnUg9VOV2Kckpi8vQbrgOehRwPk?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/jN_NWknU5mgFAWUBmJPlpyHW5pBrh4fuXuoSD1AKiuuSuTU_h0WiNvD8EqDWP7RBqS5bFO5V2xHQSJ9fUP1pFe8Gn2B8VIn8wiVhV2t1VSo06nbSiQG2vEqiEQ-lnq2zu4Tzq5b68aDHZmEwoTPyQ1nchWWJW0rbBHe7KUvQrjjbBhPnuvq67wx_MxsuGyeG?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/qw4SENjgnLtLdPr_A2celUYeXnFXDT-xLGkoTNMqVhhhgYLNXmzWjlwiULvUAwxE-YYONs4idF5SrwDeA9pUYWx-XVKC3gzjeXZ2POhid4e6iivU0tRoUErGM3a0Wl6_4ez3Iukg7ot5oNQtCN9i1dqySH28DoYmj8F1b4mWzmts0a7QyKcaEnZ6p5RP9sk4?purpose=fullsize)

* Title + channel
* Like/Dislike
* Download button
* Background play toggle
* Comments section

---

### 3. Subscriptions Tab

![Image](https://images.openai.com/static-rsc-4/BKGQYjjpNWViCWEUOvo2MEHJe6c8_AfaDnaYSlarmY1sbQ4UH6VmgtWCQzv9dg98Qv1bdHQnNbPYXPteIntcK2CQaKH0sz9C80KtRPDIh35RxpIbnvmexZtN9rIJcu1ZbKiN2eJStzGFthsXyRCii20hG2KOy8dar3W5EmbuLZJtuV3tT8Rj8iz4tV0taH1i?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/wbD2cg3B0Oi6JN6snup7UhNJ_CuuKhlDCHB7eTOu_2Rwn0UsyfHjd8jVZMReu7XYtyYCSEw36oMIHvhgrTh_8Hgcz4xiR5kASPW6NVIHoDvxTjk_NGagYlOzJjSr7EODMjdVW5Hhid9ZgmM1M5w3jiDTzoqzQWo0d3lrJGTmK6xRXSIG6O-2QLhNK4O1aumU?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/PUFIBObO7XSfweI3dtiIkyCHw5hmFawXKZN28ktThus-D2tMMctUcwxUtCpCY32lTP2PReacouMWstb_TDvVbkAiNN2Fqu3xYs9jYoMqMm3decf14F3PqI-2FMfO2xG6qnx2dhQm8ZuRvzsvJ6nVwalWAgN-dSfNn--BiX6L8WKAha6kT4IR7PYYC9lciqi-?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/zndQn-Xu8Iiaz_Ll46T8FGPgZ5QUJKGxNTyUR01jU-d82odVWU_FztGRiBg2pNmfY2gL-MvXUDJ_StOnYLTRQ3z9a612dQQ-nvf6HgnSOhpec-cN3SnMil-ZduiEOk8zqVxiqxs25I36tRrR3PyZJTOpDnm9dSw6QIrmu-UsSMQMV0Ap-WNtw-47wskICAhz?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/H2T7nPYFUxriq7d3UP9G1Gk7CtPAHrVFb6bYUYJdH8cUIgm6HBB6H1v2dXbKgH69BdeweysMrXzpMPgBfcfGsmbjV-WrErzA-Ec1RFfCvwFalEBDicoQOyt8S2ZKWgC3HXA6z2YexfMVK_IfbGjkeK2iiiJwpOp-iRivY-2MGIMPnvQTDcBzARA2dhqasWez?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/pUc5X0fFNWNMp8tlcnZq5m1ZLh43rFagOhfNT0IU5CVTLYs0Q-cmnifCSDSVIWv_4lAIZEFURxeOT8c9a27g6tT5X9hVC_9vIMTi1EigQEBy2v66lppmoe8xdtPL4dLug7GXlKSGFn784l0VwEGDAzznJWoAOr2u0gYv-mknqEoXXwzQlurjgXMFHNQvrc-F?purpose=fullsize)

* Channel list
* Latest uploads
* Offline stored subscriptions

---

### 4. Downloads Page

![Image](https://images.openai.com/static-rsc-4/YI7k8qPR9tXkJCMQI1qRRDOsoWTLgnpNqVCUmGD53T_laxPU4E9G_8PHN_hfX2EsU5UusuVDfRtjjMq84fP2oXnvuJBGSmfSzaz73vE6V7ykCEBRNfJhg5MQCyF3q4hk1P5eTi26nIvMN5cJKK6wCe2S5zRg-4pi1lG_xtNRXqjaYq5_Jo0eDdHhda71ofxL?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/V6h4Z5o3zG9oCSvPPHRgQliMbl28zw_bv1PUXx1sP1OzEXHcVgBgHNrZvdUQQoO9Jq8beLiqsu-a0i9fCw6t7lBzAk3WxAVdvu0nV0fHtECf9UPxQnwAhdk3ang3Fvi-BOZKm-YnpjFUHqdsgMzI7d2On8w52sjVMfaoxlWkj8NXXsHUAgdsXWo72PYL2QVW?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/IQw6QG8vBgR4Cw6YYzFFVDtXu6VzezdUC9ug8QBjsFtuyssi2t1HgGSql7A4i1LRxiHY6KBAvZkz_Ai2rF5CTRZXfBD0c3Xetpe3uaMN8sjnhX7BA2sjosdw08iaai56Y53KnnS2p9wg_nTmescc_wM5I0nx1rk6r_UVQTNZZE4L0v6gIffkmG4_CiKt_S6U?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/kvVTQm4NfMB0XLydSj6renoItsKLIJOeRTzJLUVyh586yGl3R60uY_h53DEQ8-EDB_n0VItgvMm_S58kcmfPBf1IDXp_f3y65OLsMflS2sgdl1adL3Lcblxe1z3GLShrfIs5Jw7fLgXwyj3Qyw1YFK_mJw4NY96suzYe7kNf_eQ3i1tFozEt66gKUZidyUrx?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/IuSac43eeWxJsEpGOKSqII5bVvE_zhuMm3_FT_1K0dB1FXR72Z11erctrhSIgobT3LpBvWfAsafrVJZFNcH9eaZFoimoT40OZ06366LiK3M-jgx76KtRlB50r6DbcDXDCVsWTL_W-b6TKc9SG_Rgc4UH8Qxz2zVg1tpzgvJKyEUWIVN5Tknodk1_PvoYFud0?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/02pltauJXDuKMHOI-Ecq_8D_HX7JOQHVNr23qZLhMU-P64vU7EsDTisb5aJgh80_VCfqPEI17G9WV6iT8EMYUuoJudEsZdzHROSEYhck2MvIg7nm-xXKNfqmTJl4fqrCrED4gU3d2-iuJ4QNAoSd0Nwe9JiLdAcM9D0eKtO7QOstFILXTNq06GMSevQ-8vWY?purpose=fullsize)

* Queue system
* Progress bar
* Format selection

---

# 🧱 4. CORE FEATURES IMPLEMENTATION

---

## 🔍 Search System

```bash
yt-dlp "ytsearch:query"
```

Rust wrapper:

```rust
Command::new("yt-dlp")
    .arg("ytsearch10:lofi music")
    .output();
```

---

## 🎥 Streaming (IMPORTANT)

Flow:

1. Get video URL via yt-dlp
2. Extract stream URL
3. Pass to mpv

```bash
yt-dlp -f best -g <url>
```

---

## 📥 Download System

```bash
yt-dlp -f best -o "~/Videos/%(title)s.%(ext)s" <url>
```

Features:

* Audio only
* 720p / 1080p selection
* Batch downloads

---

## ⏩ SponsorBlock

Flow:

```
videoID → API → skip timestamps → mpv seek
```

---

## 👍 Dislike System

Use Return YouTube Dislike API

---

## 📦 Local Database

Use:

* SQLite

Store:

* Subscriptions
* History
* Downloads
* Settings

---

# 🧠 5. PROJECT STRUCTURE (DETAILED)

```
frontend/
├── screens/
│   ├── home.dart
│   ├── player.dart
│   ├── subscriptions.dart
│   └── downloads.dart
│
├── widgets/
│   ├── video_card.dart
│   ├── player_controls.dart
│   └── sidebar.dart
│
└── services/
    ├── api_service.dart
    └── yt_service.dart


backend/
├── src/
│   ├── main.rs
│   ├── yt_dlp.rs
│   ├── player.rs
│   └── db.rs
```

---

# ⚡ 6. DEVELOPMENT ROADMAP

## 🚀 Phase 1 (MVP)

* Search + video list
* Play video (mpv)
* Basic UI

---

## 🚀 Phase 2

* Downloads
* Subscriptions
* History

---

## 🚀 Phase 3

* SponsorBlock
* Dislike API
* Background playback

---

## 🚀 Phase 4

* UI polish (exact Tubular feel)
* Animations
* Performance tuning

---

# 🖥️ 7. CROSS-PLATFORM BUILD

### Flutter build:

```bash
flutter build linux
flutter build windows
flutter build macos
```

---

### Package:

* Linux → AppImage / Flatpak
* Windows → .exe
* Mac → .dmg

---

# ⚠️ 8. HARD PROBLEMS (don’t ignore)

### 💀 YouTube blocking

* yt-dlp updates required
* Sometimes cookies needed ([Reddit][3])

---

### ⚖️ Legal / ToS

* Not officially allowed
* Keep it open-source + personal use

---

### 🔄 Maintenance

* Extraction breaks often
* Must update regularly
