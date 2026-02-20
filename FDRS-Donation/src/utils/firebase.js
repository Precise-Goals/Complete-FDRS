import { initializeApp } from "firebase/app";
import {
  getDatabase,
  ref,
  push,
  set,
  get,
  update,
  onValue,
  serverTimestamp,
} from "firebase/database";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID,
};

const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

// ── Campaign CRUD ─────────────────────────────────────────

/** Subscribe to all campaigns in real-time. Returns an unsubscribe fn. */
export function subscribeCampaigns(callback) {
  const campaignsRef = ref(db, "campaigns");
  return onValue(campaignsRef, (snapshot) => {
    const data = snapshot.val();
    if (!data) {
      callback([]);
      return;
    }
    const list = Object.entries(data).map(([id, val]) => ({ id, ...val }));

    // Sort newest first
    list.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));

    // Deduplicate by campaign title
    const uniqueList = [];
    const seenTitles = new Set();

    for (const campaign of list) {
      const normalizedTitle = campaign.title?.trim().toLowerCase() || "";
      if (!seenTitles.has(normalizedTitle)) {
        seenTitles.add(normalizedTitle);
        uniqueList.push(campaign);
      }
    }

    callback(uniqueList);
  });
}

/** Create a new campaign */
export async function createCampaign({
  title,
  tag,
  desc,
  goal,
  creatorAddress,
}) {
  const campaignsRef = ref(db, "campaigns");
  const newRef = push(campaignsRef);
  await set(newRef, {
    title,
    tag,
    desc,
    goal: Number(goal),
    raised: 0,
    percent: 0,
    status: "Active",
    creatorAddress: creatorAddress || "anonymous",
    createdAt: Date.now(),
  });
  return newRef.key;
}

/** Record a donation — increments raised amount */
export async function recordDonation(campaignId, amountInEth) {
  const campaignRef = ref(db, `campaigns/${campaignId}`);
  const snapshot = await get(campaignRef);
  if (!snapshot.exists()) return;

  const campaign = snapshot.val();
  const ethToInr = 250000; // Approx 1 ETH ≈ ₹2,50,000
  const addedInr = parseFloat(amountInEth) * ethToInr;
  const newRaised = (campaign.raised || 0) + addedInr;
  const newPercent = Math.min(
    100,
    Math.round((newRaised / campaign.goal) * 100),
  );

  await update(campaignRef, {
    raised: newRaised,
    percent: newPercent,
    status: newPercent >= 100 ? "Completed" : "Active",
  });
}

/** Seed default campaigns if DB is empty */
export async function seedDefaultCampaigns() {
  const campaignsRef = ref(db, "campaigns");
  const snapshot = await get(campaignsRef);
  if (snapshot.exists()) return; // already has data

  const defaults = [
    {
      tag: "Flood Relief",
      title: "Assam Floods 2025",
      desc: "Providing emergency food, shelter, and medical aid to over 40,000 displaced families across Assam's Brahmaputra valley zone.",
      raised: 1840000,
      goal: 3000000,
      percent: 61,
      status: "Active",
      img: "flood",
      creatorAddress: "fdrs-admin",
      createdAt: Date.now() - 86400000 * 3,
    },
    {
      tag: "Earthquake",
      title: "Uttarakhand Quake Response",
      desc: "Emergency rescue operations and structural relief for communities affected by the 6.1 magnitude earthquake near Chamoli district.",
      raised: 980000,
      goal: 2000000,
      percent: 49,
      status: "Active",
      img: "quake",
      creatorAddress: "fdrs-admin",
      createdAt: Date.now() - 86400000 * 2,
    },
    {
      tag: "Cyclone",
      title: "Cyclone Reena – Odisha",
      desc: "Rebuilding homes, restoring power infrastructure, and supplying clean drinking water to coastal villages ravaged by the storm.",
      raised: 2410000,
      goal: 2500000,
      percent: 96,
      status: "Closing Soon",
      img: "cyclone",
      creatorAddress: "fdrs-admin",
      createdAt: Date.now() - 86400000,
    },
  ];

  for (const c of defaults) {
    const newRef = push(campaignsRef);
    await set(newRef, c);
  }
}

export { db };
