# 🌍 FDRS – Falcons Disaster Response System

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Made with React](https://img.shields.io/badge/Made%20with-React-61DAFB?logo=react&logoColor=white)](https://reactjs.org/)
[![Android App](https://img.shields.io/badge/Built%20for-Android-green?logo=android)](https://developer.android.com/)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)](https://firebase.google.com/)
[![Blockchain Powered](https://img.shields.io/badge/Secured%20By-Blockchain-6c4ad4?logo=ethereum)](https://ethereum.org/)
[![AI/ML Powered](https://img.shields.io/badge/AI%2FML-LLaMA%203.3-blue?logo=meta)](https://ai.meta.com/llama/)
[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen?logo=vercel)](https://fdrs.vercel.app)
[![MIT License](https://img.shields.io/github/license/Precise-Goals/Complete-FDRS)](LICENSE)

---

## Abstract

FDRS (Falcons Disaster Response System) is a comprehensive, multi-platform disaster management ecosystem designed to bridge the critical communication gap between disaster-affected civilians and government emergency response agencies. The system implements a layered architecture comprising four principal modules: (1) a **Flutter-based cross-platform mobile application** for real-time SOS signal transmission with a three-tier delivery fallback chain, (2) a **React.js administrative web portal** for centralized multi-agency coordination and real-time geospatial signal monitoring, (3) an **Ethereum blockchain-powered donation platform** ensuring transparent, tamper-proof relief fund management, and (4) a **native Android application** for legacy device support.

The platform leverages Firebase Realtime Database for sub-second data synchronization, Google Maps API for geospatial intelligence, an AI-powered chatbot driven by Meta's LLaMA 3.3 (70B) model for multilingual crisis assistance, and Solidity-based smart contracts on the Ethereum Sepolia testnet for immutable financial audit trails. FDRS was engineered to address real-world challenges in disaster relief coordination—latency in SOS delivery under degraded network conditions, lack of transparency in donation management, and fragmented inter-agency communication.

![Banner](image.png)

---

## Table of Contents

1. [Introduction](#-introduction)
2. [System Architecture](#-system-architecture)
3. [Module I — Flutter Mobile Application](#-module-i--flutter-mobile-application-fdrs-flutter)
4. [Module II — Administrative Web Portal](#-module-ii--administrative-web-portal-fdrs-webpage)
5. [Module III — Blockchain Donation Platform](#-module-iii--blockchain-donation-platform-fdrs-donation)
6. [Module IV — Native Android Application](#-module-iv--native-android-application-fdrs-android)
7. [AI-Powered Disaster Assistance](#-ai-powered-disaster-assistance)
8. [Environmental Impact & Relief Analysis](#-environmental-impact--relief-analysis)
9. [Technology Stack](#-technology-stack)
10. [Live Demo & Credentials](#-live-demo--credentials)
11. [Installation & Setup](#-installation--setup)
12. [Contributing](#-contributing)
13. [Disclaimer](#-disclaimer)
14. [Authors & Contributors](#-authors--contributors)
15. [Contact](#-contact)

---

## 📖 Introduction

Natural and man-made disasters pose an existential threat to human life, infrastructure, and economic stability. According to the United Nations Office for Disaster Risk Reduction (UNDRR), disasters displaced over 32 million people in 2023 alone. The primary bottleneck in disaster response is not the absence of relief resources but the **coordination latency** between distressed civilians and emergency responders.

FDRS was conceived to mitigate this latency through a multi-pronged technological approach:

- **Instant SOS Signal Delivery**: A three-tier fallback mechanism ensures that distress signals reach authorities even under complete network failure—first via Firebase Realtime Database, then via radio mesh links, and finally through local offline caching with auto-retry on connectivity restoration.
- **Centralized Multi-Agency Dashboard**: Government departments (NDRF, CRPF, Police, Fire Brigades, Hospitals) operate from a unified real-time dashboard that displays SOS signals as geolocated markers on an interactive map, enabling intelligent resource routing.
- **Transparent Blockchain Donations**: Every relief donation is processed through an Ethereum smart contract, creating an immutable, publicly auditable financial trail that eliminates corruption and fund misuse.
- **AI-Powered Crisis Intelligence**: A large language model (LLaMA 3.3 70B Instruct Turbo) provides multilingual, context-aware disaster guidance to both civilians and responders.

---

## 🏗 System Architecture

FDRS follows a modular, service-oriented architecture where each sub-system operates independently while sharing a common Firebase Realtime Database as the central data bus.

![Architecture](image-5.png)

---

## 📱 Module I — Flutter Mobile Application (`FDRS-Flutter`)

The Flutter module serves as the **primary civilian-facing interface**, enabling disaster-affected individuals to send SOS distress signals, access emergency knowledge resources, and manage their user profiles. Built with Flutter for true cross-platform deployment (Android, iOS, Web, Desktop), the application follows the MVVM (Model-View-ViewModel) architectural pattern with Provider-based state management.

### 🆘 SOS Alert System

The SOS screen is the centerpiece of the mobile application. It implements a **long-press activation mechanism** with a visually immersive water-fill animation to prevent accidental triggers while maintaining accessibility during high-stress scenarios.

**Activation Flow:**

1. The user presses and holds the SOS button for 2 seconds.
2. A reddish-orange water-like fill animation progressively covers the button using a custom `WaterClipper` (bezier-curve based `CustomClipper`).
3. Haptic feedback (vibration) is triggered upon successful activation.
4. The distress signal—containing the user's **live GPS coordinates**, **device build number**, and **UTC timestamp**—is dispatched through the three-tier delivery chain.

**Three-Tier Distress Signal Delivery Chain:**

| Tier  | Mechanism       | Timeout              | Description                                                                                                                                                                                                                             |
| ----- | --------------- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1** | Firebase RTDB   | 5 seconds            | Primary channel. Signal is written to `/signals/{userId}_{buildNumber}` in Firebase Realtime Database for instant propagation to the admin dashboard.                                                                                   |
| **2** | Radio Mesh Link | 1 second (simulated) | Fallback for RTDB failure. Placeholder for LoRa/mesh radio SDK integration—designed for areas with zero internet connectivity.                                                                                                          |
| **3** | Offline Queue   | Persistent           | Last-resort safety net. Signals are serialized to a local JSON file (`pending_distress_signals.json`) on the device's file system and **automatically flushed** to RTDB when connectivity is restored via `connectivity_plus` listener. |

This architecture ensures **zero signal loss**—even in the most adverse network conditions, the distress signal is persisted locally and will eventually reach authorities.

![SOS](image-1.png)

**Key Implementation Details:**

- **Status Indicators**: Real-time cards display the status of Location Services (GPS accuracy), Network Connection (Firestore reachability), and Signal Readiness (authentication state).
- **Authentication Modes**: Supports authenticated SOS (linked to user profile) and anonymous SOS (for unregistered users), ensuring no one is excluded from sending emergency alerts.
- **Device Fingerprinting**: Each signal includes the Android `display` build number (via `device_info_plus`), enabling device-level signal deduplication and tracking.

### 📚 Knowledge Base

The Knowledge Base screen provides a curated repository of **disaster preparedness protocols, emergency guidelines, and reference documents**. It functions as a self-contained educational resource that civilians can access even in offline scenarios.

**Content Categories:**

- **Emergency Protocols**: Quick-reference cards for Earthquake Response, Flood Safety, and Fire Evacuation procedures, each linking to authoritative external resources (NDMA, Red Cross, NFPA).
- **Official Documents**: Downloadable PDF guides including the NDMA Disaster Management Guidelines, accessible via `url_launcher` for web resources or `open_filex` for locally bundled assets.
- **Search Functionality**: A top-of-page search bar enables rapid lookup within the knowledge base content.

### 👤 User Profile Management

The Profile screen enables authenticated users to manage their personal information, which is persisted to Firebase Realtime Database under `/users/{uid}`.

**Profile Fields:**

- Personal Information: Name, Mobile Number (with custom `MobileNumberFormatter` for regional formats), Age
- Medical Information: Blood Group, Medical Conditions (multi-line textarea)
- Location Data: Address details for pre-positioning relief resources

All profile data is read from and written to RTDB via the `DatabaseService`, with reactive UI updates through `ProfileViewModel` (ChangeNotifier pattern).

### 🔐 Authentication System

The `AuthService` (extending `ChangeNotifier`) provides a flexible, multi-method authentication layer:

| Method             | Implementation                                                                         | Use Case                              |
| ------------------ | -------------------------------------------------------------------------------------- | ------------------------------------- |
| **Email/Password** | `FirebaseAuth.signInWithEmailAndPassword`                                              | Standard registration and login       |
| **Google Sign-In** | `GoogleSignIn` → `GoogleAuthProvider.credential` → `FirebaseAuth.signInWithCredential` | One-tap social login                  |
| **Anonymous**      | `FirebaseAuth.signInAnonymously`                                                       | Guest access for emergency-only users |

Upon successful authentication (any method), user metadata (UID, email, last login timestamp) is automatically persisted to RTDB. Error codes from Firebase are mapped to human-readable messages via `_mapAuthError()` for clear user feedback.

### 🧭 Navigation & Theming

The `MainScreen` implements a **glassmorphism-styled bottom navigation bar** using `BackdropFilter` with `ImageFilter.blur`, providing three primary tabs:

- **Home** (SOS Screen): Default landing tab for emergency actions
- **Info** (Knowledge Base): Disaster preparedness resources with amber accent highlighting
- **Profile** (Profile/Login): Conditional rendering—authenticated users see their profile, guests see the login screen

Screen transitions are animated using `AnimatedSwitcher` with a 500ms `FadeTransition` for smooth, polished navigation.

---

## 🖥 Module II — Administrative Web Portal (`FDRS-Webpage`)

The web portal is a **React.js single-page application** (SPA) built with Vite, designed for government department administrators to monitor, analyze, and respond to incoming distress signals in real time.

### 🗺 Real-Time Signal Monitoring Dashboard

The `Dashboard` component is the operational nerve center, providing:

- **Live Signal Stream**: All SOS signals stored under `/users` in Firebase RTDB are streamed in real time via `onValue` listeners. Each signal's raw GPS coordinates are reverse-geocoded into human-readable addresses using the **OpenStreetMap Nominatim API** (`nominatim.openstreetmap.org/reverse`).
- **Interactive Google Maps Visualization**: The `MapComponent` embeds a fully interactive Google Maps instance (via the Maps JavaScript API) that dynamically plots markers for every active distress signal. The map is centered on coordinates `[18.5316, 73.8670]` (Pune, India) by default and supports zoom/pan.
- **Hotspot Detection Engine**: The dashboard algorithmically clusters SOS signals by rounding latitude/longitude to the nearest integer degree. Areas with **≥ 10 signals** within the same grid cell are flagged as **Critical Hotspots** (⚠️), enabling authorities to prioritize high-density disaster zones.
- **Department Context Panel**: Displays the logged-in administrator's department details (name, camp type, address) fetched from `/admins/{uid}` in RTDB.
- **Signal-to-Maps Deep Linking**: Each signal card in the Recent Signals list is a clickable link that opens Google Maps with a search query for the signal's reverse-geocoded address, facilitating rapid navigation for field responders.

### 🏢 Multi-Agency Coordination

The platform supports concurrent operation by multiple government agencies, each authenticated into their own admin account:

- **NDRF** (National Disaster Response Force)
- **CRPF** (Central Reserve Police Force)
- **Local Police Stations**
- **Fire Brigades**
- **Hospitals & Medical Centers**

Each department's admin dashboard provides identical real-time signal visibility, enabling synchronized, non-duplicative response coordination across agencies.

### 🔒 Authentication & Access Control

The web portal implements a full authentication flow with:

- **Signup** (`Signup.jsx`): New department registration with Firebase Auth `createUserWithEmailAndPassword`, storing admin details (department name, type, address) under `/admins/{uid}`.
- **Login** (`Login.jsx`): Department authentication with `signInWithEmailAndPassword`.
- **Protected Routes** (`PrivateRoute.jsx`): Dashboard access is gated behind authentication state, redirecting unauthenticated users to the login page.
- **Landing Page** (`LandingPage.jsx`): Public-facing entry point with navigation to login/signup flows.

---

## 💰 Module III — Blockchain Donation Platform (`FDRS-Donation`)

The donation module is a standalone **React.js + Ethers.js** web application that combines the transparency of blockchain technology with the usability of modern web interfaces. It enables donors to contribute relief funds via Ethereum cryptocurrency, with every transaction recorded immutably on-chain.

### 🪙 Smart Contract Architecture

The platform interacts with a custom **Solidity smart contract** deployed on the **Ethereum Sepolia Testnet** (Chain ID: `11155111`).

**Contract Interface (ABI):**

```solidity
function donate() external payable           // Accepts ETH donations
function getTotalRaised() external view returns (uint256)  // Returns cumulative donations
```

**Key Contract Interactions:**

- **`donate(signer, amount)`**: Converts a human-readable ETH amount (e.g., `"0.01"`) to wei using `ethers.parseEther()`, then invokes the contract's `donate()` function. MetaMask prompts the user for transaction confirmation. The transaction hash is returned immediately for non-blocking UI feedback.
- **`getTotalRaised()`**: Calls the contract's view function via a read-only `JsonRpcProvider` (no wallet required), converts the returned BigInt from wei to ETH, and returns a formatted string.

### 🦊 MetaMask Wallet Integration

The `wallet.js` module provides seamless MetaMask connectivity:

1. **Detection**: Checks for `window.ethereum.isMetaMask` to verify MetaMask installation.
2. **Account Access**: Requests account access via `eth_requestAccounts`.
3. **Network Auto-Switch**: Automatically switches the user's wallet to the Sepolia testnet. If Sepolia is not configured, it programmatically adds the network with the correct RPC URL (`ethereum-sepolia-rpc.publicnode.com`) and block explorer (`sepolia.etherscan.io`).

### 📊 Campaign Management System

Campaigns serve as the organizational unit for relief fundraising. The system is backed by Firebase Realtime Database under `/campaigns`.

**Campaign Lifecycle:**

| Phase                      | Action                                     | Implementation                                                                                                                             |
| -------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Creation**               | Admin or donor creates a new campaign      | `createCampaign()` pushes to Firebase with title, tag, description, goal (INR), creator wallet address, and timestamp                      |
| **Real-Time Subscription** | All clients receive live updates           | `subscribeCampaigns()` uses `onValue` listener with deduplication by title and newest-first sorting                                        |
| **Donation Recording**     | Donation amount is converted and tracked   | `recordDonation()` converts ETH to INR (at ≈₹2,50,000/ETH), increments `raised`, recalculates `percent`, and auto-closes campaigns at 100% |
| **Seeding**                | Default campaigns populate empty databases | `seedDefaultCampaigns()` provisions three example campaigns (Assam Floods, Uttarakhand Earthquake, Cyclone Reena) on first load            |

**Campaign Tags & Visual System:**
Each campaign is categorized with a disaster type tag—Flood Relief, Earthquake, Cyclone, Drought, Fire, Pandemic, or Other—each rendered with a distinctive color-coded banner via `CampaignBanner` inline SVG components.

**UI Components:**

- **`CreateCampaignModal`**: Form for creating new campaigns with title, tag (dropdown), description, and goal amount.
- **`DonationModal`**: Wallet-connected donation interface with ETH amount input, connected wallet display, and transaction state management.
- **`KnowMoreModal`**: Expanded campaign details including description, raised/goal breakdown, and status badge.
- **`CampaignCard`**: Grid-rendered card with progress bar, raised amount (INR formatted), and action buttons (Donate, Know More).
- **`HowItWorks`**: Three-step explainer section (Create Campaign → Share & Connect → Track Impact).
- **`AboutUs`**: Mission statement and organizational information.

![Donation](image-2.png)

---

## 📱 Module IV — Native Android Application (`FDRS-Android`)

The `FDRS-Android` module is a standalone native Android application built with **Kotlin/Java** and **Gradle (KTS)**. It serves as a legacy-compatible alternative to the Flutter mobile app, providing core SOS signal generation functionality for devices that may not support the Flutter runtime.

**Core Capabilities:**

- SOS distress signal generation with GPS coordinate extraction
- Firebase Realtime Database integration for signal transmission
- Device-level location tracking and metadata collection
- Compatible with Android API levels specified in the Gradle configuration

---

## 🤖 AI-Powered Disaster Assistance

The FDRS web portal integrates an AI chatbot (`Bot.jsx`) powered by **Meta's LLaMA 3.3 70B Instruct Turbo** model, accessed via the **Together AI** inference API (`api.together.xyz/v1/chat/completions`).

**Chatbot Capabilities:**

- **Contextual Disaster Guidance**: Users can ask about evacuation procedures, first-aid protocols, shelter locations, and resource availability. The model processes conversational history for multi-turn contextual responses.
- **Multilingual Support**: Leveraging the LLaMA 3.3 model's training on 100+ languages, the chatbot can assist users in their native language, critical for India's linguistically diverse disaster zones.
- **Markdown-Rich Responses**: Bot responses are rendered via `ReactMarkdown` with custom component overrides for headings, lists, bold text, and paragraphs—ensuring clear, structured, and readable crisis information.

**Technical Configuration:**

- Model: `meta-llama/Llama-3.3-70B-Instruct-Turbo`
- Temperature: `0.7` (balanced creativity/accuracy for crisis scenarios)
- Max Tokens: `1000` (sufficient for detailed procedural guidance)

<div style="display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;flex-direction:column">
  <img src="image-4.png" alt="AI" style="flex: 2; max-width: 60%; height: auto; object-fit: cover; border-radius: 8px;" />
</div>

---

## 📊 Environmental Impact & Relief Analysis

FDRS provides data-driven environmental and relief intelligence through its dashboard analytics:

- **Real-Time Damage Assessment**: The dashboard aggregates SOS signal density, geographic distribution, and temporal patterns to generate live damage assessment reports for incident commanders.
- **Predictive Hotspot Detection**: The algorithmic clustering engine (rounding coordinates to integer degrees and flagging cells with ≥10 signals) identifies emerging disaster hotspots, enabling preemptive resource staging.
- **Reverse Geocoding Intelligence**: Every SOS signal's raw GPS coordinates are resolved to human-readable addresses via OpenStreetMap's Nominatim service, providing street-level situational awareness.
- **Geospatial Resource Allocation**: Admin department addresses (stored in `/admins`) are mapped alongside civilian SOS signals, enabling distance-optimized dispatch of the nearest available response unit.

<div style="width: 100%; max-width: 800px; overflow: hidden; border-radius: 12px; display: flex; justify-content: center; align-items: center; background-color: #f5f5f5; height:300px">
  <img src="image-3.png" alt="AI2" style="width: 100%; height: 300px; object-fit: cover; border-radius: 10px;" />
</div>

---

## 🌐 Live Demo & Credentials

Experience the platform live:

| Platform       | URL                                                |
| -------------- | -------------------------------------------------- |
| **Web Portal** | [https://fdrs.vercel.app](https://fdrs.vercel.app) |

**Test Credentials**  
Email: `test@gmail.com`  
Password: `testadmin`

---

## 🧠 Technology Stack

### 🖥️ Frontend

| Technology         | Module                      | Purpose                                                                                                             |
| ------------------ | --------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Flutter (Dart)** | FDRS-Flutter                | Cross-platform mobile application (Android, iOS, Web, Desktop) with MVVM architecture and Provider state management |
| **React.js 18**    | FDRS-Webpage, FDRS-Donation | Single-page applications for admin dashboard and donation portal                                                    |
| **Vite**           | FDRS-Webpage, FDRS-Donation | Next-generation build tooling with hot module replacement (HMR)                                                     |
| **Kotlin/Java**    | FDRS-Android                | Native Android app with Gradle KTS build system                                                                     |

### ⚙️ Backend & Database

| Technology                     | Purpose                                                                                                                                      |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Firebase Realtime Database** | Sub-second data synchronization for SOS signals (`/signals`), user data (`/users`), admin metadata (`/admins`), and campaigns (`/campaigns`) |
| **Firebase Authentication**    | Multi-method auth: Email/Password, Google Sign-In, Anonymous—shared across Flutter and Web modules                                           |
| **Cloud Functions (Node.js)**  | Serverless backend logic, automation triggers, and real-time event processing                                                                |

### 🔐 Blockchain Layer

| Technology                   | Purpose                                                                                                           |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Solidity**                 | Smart contract for transparent, tamper-proof donation tracking with `donate()` and `getTotalRaised()` functions   |
| **Ethers.js v6**             | JavaScript library for Ethereum contract interaction, transaction signing, and wei/ETH conversion                 |
| **MetaMask**                 | Browser wallet for user authentication, transaction signing, and Sepolia testnet management                       |
| **Ethereum Sepolia Testnet** | Test network for development and demonstration (Chain ID: `11155111`, RPC: `ethereum-sepolia-rpc.publicnode.com`) |

### 🤖 AI/ML Layer

| Technology                            | Purpose                                                                      |
| ------------------------------------- | ---------------------------------------------------------------------------- |
| **Meta LLaMA 3.3 70B Instruct Turbo** | Large language model for multilingual disaster assistance chatbot            |
| **Together AI API**                   | Inference hosting for LLaMA model with low-latency chat completions endpoint |
| **ReactMarkdown**                     | Markdown rendering engine for structured AI response display                 |

### 🗺️ Geospatial Services

| Technology                     | Purpose                                                                                   |
| ------------------------------ | ----------------------------------------------------------------------------------------- |
| **Google Maps JavaScript API** | Interactive map visualization with dynamic marker placement for SOS signals               |
| **OpenStreetMap Nominatim**    | Free reverse geocoding service for converting GPS coordinates to human-readable addresses |
| **Flutter `location` Plugin**  | Native GPS access on mobile devices with runtime permission handling                      |
| **`device_info_plus`**         | Android device fingerprinting (build number extraction) for signal deduplication          |

### 📦 Key Flutter Dependencies

| Package                                               | Purpose                                                          |
| ----------------------------------------------------- | ---------------------------------------------------------------- |
| `firebase_core`, `firebase_auth`, `firebase_database` | Firebase ecosystem integration                                   |
| `google_sign_in`                                      | Google OAuth 2.0 social login                                    |
| `provider`                                            | Reactive state management (ChangeNotifier pattern)               |
| `location`, `permission_handler`                      | GPS access and runtime permission requests                       |
| `connectivity_plus`                                   | Network state monitoring for offline queue auto-flush            |
| `vibration`                                           | Haptic feedback on SOS activation                                |
| `url_launcher`, `open_filex`                          | External URL/document opening in Knowledge Base                  |
| `path_provider`                                       | Local file system access for offline distress signal persistence |

### 🚀 Deployment

| Service                         | Purpose                                                        |
| ------------------------------- | -------------------------------------------------------------- |
| **Vercel**                      | Hosting with CI/CD for web client (auto-deploys on `git push`) |
| **Firebase Hosting**            | Serverless deployment for backend APIs and database rules      |
| **Google Play Store (Planned)** | Upcoming distribution channel for the Flutter and Android apps |

---

## 🛠 Installation & Setup

### Prerequisites

- **Flutter SDK** (≥ 3.0) for the mobile application
- **Node.js** (≥ 18) and **npm/bun** for web modules
- **MetaMask** browser extension for blockchain donation testing
- **Firebase Project** with Realtime Database and Authentication enabled

### FDRS-Flutter (Mobile App)

```bash
cd FDRS-Flutter
flutter pub get
flutter run
```

### FDRS-Webpage (Admin Portal)

```bash
cd FDRS-Webpage
npm install
# Create .env with Firebase and Google Maps API keys
npm run dev
```

### FDRS-Donation (Blockchain Platform)

```bash
cd FDRS-Donation
npm install
# Create .env with Firebase keys, contract address, and Together API key
npm run dev
```

### FDRS-Android (Native App)

```bash
cd FDRS-Android
./gradlew build
# Open in Android Studio and run on device/emulator
```

---

## 🤝 Contributing

We welcome contributions from the open-source community. To contribute:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/your-feature-name`)
3. **Commit** your changes with descriptive messages (`git commit -m 'Add feature: description'`)
4. **Push** to your branch (`git push origin feature/your-feature-name`)
5. **Open** a Pull Request with a detailed description of your changes

Please ensure your code follows the existing project conventions and includes relevant documentation.

---

## ⚠️ Disclaimer

FDRS is a **research prototype** developed for academic demonstration, hackathon presentation, and proof-of-concept validation. For real-world deployment in active disaster scenarios, the following are prerequisite:

- Official partnerships with government disaster management agencies (NDMA, NDRF, State SDMAs)
- Legal compliance with data protection regulations (IT Act 2000, DPDP Act 2023)
- Verified integration with official emergency communication infrastructure
- Security audits and penetration testing for all public-facing modules
- Smart contract audits by certified blockchain security firms

---

## 👨‍💻 Authors & Contributors

- **Sarthak Patil**  
  GitHub: [Precise-Goals](https://github.com/Precise-Goals)

- **Gaurav Chaudhari**  
  GitHub: [Chgauravpc](https://github.com/Chgauravpc)

- **Prathamesh Kolhe**  
  GitHub: [prathamesh-6099](https://github.com/prathamesh-6099)

- **Utkarsh Vidwat**  
  GitHub: [Utkarsh9090](https://github.com/Utkarsh9090)

---

## 📬 Contact

Email: **sarthakpatil.ug@gmail.com**  
Project Repository: [https://github.com/Precise-Goals/Complete-FDRS](https://github.com/Precise-Goals/Complete-FDRS)

---

## ❤️‍🔥 Made with dedication and Collaboration for Techathon :)

![gid](https://i.pinimg.com/originals/cf/2c/a4/cf2ca4f35eff08e2d8724e2e4b5cdf42.gif)
