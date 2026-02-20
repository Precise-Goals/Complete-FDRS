import { useState, useEffect } from "react";
import { ethers } from "ethers";
import {
  connectWallet,
  isMetaMaskInstalled,
  shortenAddress,
} from "./utils/wallet.js";
import { donate } from "./utils/contract.js";
import {
  subscribeCampaigns,
  createCampaign,
  recordDonation,
} from "./utils/firebase.js";

/* ─── Format INR ─────────────────────────────────────────── */
function formatINR(num) {
  if (num >= 10000000) return `₹${(num / 10000000).toFixed(1)} Cr`;
  if (num >= 100000) return `₹${(num / 100000).toFixed(1)} L`;
  if (num >= 1000) return `₹${(num / 1000).toFixed(1)}K`;
  return `₹${Math.round(num)}`;
}

/* ─── Create Campaign Modal ──────────────────────────────── */
function CreateCampaignModal({ onClose, account }) {
  const [form, setForm] = useState({
    title: "",
    tag: "",
    desc: "",
    goal: "",
  });
  const [status, setStatus] = useState("idle"); // idle | loading | success | error
  const [errMsg, setErrMsg] = useState("");

  function handleChange(e) {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.title || !form.tag || !form.desc || !form.goal) {
      setErrMsg("Please fill all fields.");
      return;
    }
    setStatus("loading");
    setErrMsg("");
    try {
      await createCampaign({
        title: form.title,
        tag: form.tag,
        desc: form.desc,
        goal: parseFloat(form.goal),
        creatorAddress: account || "anonymous",
      });
      setStatus("success");
    } catch (err) {
      setErrMsg(err?.message || "Failed to create campaign.");
      setStatus("error");
    }
  }

  function handleBackdrop(e) {
    if (e.target === e.currentTarget) onClose();
  }

  const tagOptions = [
    "Flood Relief",
    "Earthquake",
    "Cyclone",
    "Drought",
    "Fire",
    "Pandemic",
    "Other",
  ];

  return (
    <div className="modal-backdrop" onClick={handleBackdrop}>
      <div className="modal create-modal">
        <div className="modal-header">
          <div>
            <p className="modal-campaign-tag">New Campaign</p>
            <h2 className="modal-title">Start a Campaign</h2>
          </div>
          <button className="modal-close" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <div className="modal-body">
          {status !== "success" ? (
            <form onSubmit={handleSubmit} className="create-form">
              <div className="form-group">
                <label className="modal-label" htmlFor="c-title">
                  Campaign Title
                </label>
                <input
                  id="c-title"
                  className="modal-input"
                  name="title"
                  value={form.title}
                  onChange={handleChange}
                  placeholder="e.g. Kerala Flood Relief 2026"
                  disabled={status === "loading"}
                />
              </div>

              <div className="form-group">
                <label className="modal-label" htmlFor="c-tag">
                  Category
                </label>
                <select
                  id="c-tag"
                  className="modal-input modal-select"
                  name="tag"
                  value={form.tag}
                  onChange={handleChange}
                  disabled={status === "loading"}
                >
                  <option value="">Select a category</option>
                  {tagOptions.map((t) => (
                    <option key={t} value={t}>
                      {t}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="modal-label" htmlFor="c-desc">
                  Description
                </label>
                <textarea
                  id="c-desc"
                  className="modal-input modal-textarea"
                  name="desc"
                  value={form.desc}
                  onChange={handleChange}
                  placeholder="Describe the cause, who it helps, and how funds will be used..."
                  rows={4}
                  disabled={status === "loading"}
                />
              </div>

              <div className="form-group">
                <label className="modal-label" htmlFor="c-goal">
                  Fundraising Goal (₹)
                </label>
                <input
                  id="c-goal"
                  className="modal-input"
                  name="goal"
                  type="number"
                  min="1000"
                  step="1000"
                  value={form.goal}
                  onChange={handleChange}
                  placeholder="e.g. 500000"
                  disabled={status === "loading"}
                />
              </div>

              {errMsg && <p className="modal-error">{errMsg}</p>}

              <button
                type="submit"
                className="modal-donate-btn"
                disabled={status === "loading"}
              >
                {status === "loading" ? (
                  <>
                    <span className="spinner" /> Creating…
                  </>
                ) : (
                  "Create Campaign"
                )}
              </button>
            </form>
          ) : (
            <div className="modal-success">
              <span className="success-icon">🎉</span>
              <h3>Campaign Created!</h3>
              <p>
                Your campaign <strong>{form.title}</strong> is now live. Share
                it with your network to start receiving donations.
              </p>
              <button className="modal-close-btn" onClick={onClose}>
                Close
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/* ─── Donation Modal ─────────────────────────────────────── */
function DonationModal({ campaign, onClose, onDonate, account, onConnect }) {
  const [amount, setAmount] = useState("0.01");
  const [status, setStatus] = useState("idle"); // idle | loading | success | error
  const [txHash, setTxHash] = useState("");
  const [errMsg, setErrMsg] = useState("");

  async function handleDonate() {
    if (!amount || parseFloat(amount) <= 0) return;
    if (!account) {
      setErrMsg("Please connect your wallet first.");
      return;
    }
    setStatus("loading");
    setErrMsg("");
    try {
      const tx = await onDonate(amount, campaign.id);
      setTxHash(tx.hash);
      setStatus("success");
    } catch (err) {
      setErrMsg(err?.reason || err?.message || "Transaction failed.");
      setStatus("error");
    }
  }

  function handleBackdrop(e) {
    if (e.target === e.currentTarget) onClose();
  }

  return (
    <div className="modal-backdrop" onClick={handleBackdrop}>
      <div className="modal">
        {/* Header */}
        <div className="modal-header">
          <div>
            <p className="modal-campaign-tag">{campaign.tag}</p>
            <h2 className="modal-title">{campaign.title}</h2>
          </div>
          <button className="modal-close" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        {/* Body */}
        <div className="modal-body">
          {status !== "success" ? (
            <>
              {!account && (
                <div className="modal-wallet-prompt">
                  <p>Connect your wallet to donate</p>
                  <button className="btn-connect-modal" onClick={onConnect}>
                    Connect Wallet
                  </button>
                </div>
              )}
              <label className="modal-label" htmlFor="donate-amount">
                Donation Amount (ETH)
              </label>
              <input
                id="donate-amount"
                className="modal-input"
                type="number"
                min="0.001"
                step="0.001"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                disabled={status === "loading"}
                placeholder="e.g. 0.01"
              />

              {/* Quick-pick buttons */}
              <div className="modal-quick-picks">
                {["0.01", "0.05", "0.1", "0.5"].map((v) => (
                  <button
                    key={v}
                    className={`quick-pick ${amount === v ? "active" : ""}`}
                    onClick={() => setAmount(v)}
                    disabled={status === "loading"}
                  >
                    {v} ETH
                  </button>
                ))}
              </div>

              {errMsg && <p className="modal-error">{errMsg}</p>}

              <button
                className="modal-donate-btn"
                onClick={handleDonate}
                disabled={status === "loading" || !amount}
              >
                {status === "loading" ? (
                  <>
                    <span className="spinner" /> Confirming…
                  </>
                ) : (
                  "Donate Now"
                )}
              </button>
            </>
          ) : (
            /* Success state */
            <div className="modal-success">
              <span className="success-icon">✅</span>
              <h3>Donation Confirmed!</h3>
              <p>
                Thank you for contributing <strong>{amount} ETH</strong> to{" "}
                {campaign.title}.
              </p>
              <div className="tx-hash-box">
                <span className="tx-hash-label">Transaction Hash</span>
                <a
                  className="tx-hash-link"
                  href={`https://sepolia.etherscan.io/tx/${txHash}`}
                  target="_blank"
                  rel="noreferrer"
                >
                  {txHash.slice(0, 20)}…{txHash.slice(-8)}
                </a>
              </div>
              <button className="modal-close-btn" onClick={onClose}>
                Close
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/* ─── Navbar ─────────────────────────────────────────────── */
function Navbar({ account, onConnect }) {
  const [open, setOpen] = useState(false);
  return (
    <nav className="navbar">
      <div className="navbar-logo">
        <svg
          className="logo-heart"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          width="22"
          height="22"
        >
          <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
        </svg>
        <span className="logo-text">FDRS</span>
      </div>

      {/* Desktop nav links */}
      <ul className={`navbar-links${open ? " nav-open" : ""}`}>
        <li>
          <a href="#campaigns" onClick={() => setOpen(false)}>
            Campaigns
          </a>
        </li>
        <li>
          <a href="https://fdrs.vercel.app">
            FDRS Main Site
          </a>
        </li>
        <li>
          <a href="#how" onClick={() => setOpen(false)}>
            How it Works
          </a>
        </li>
        <li>
          <a href="#about" onClick={() => setOpen(false)}>
            About
          </a>
        </li>
        <li className="nav-wallet-mobile">
          {account ? (
            <span className="wallet-address">✅ {shortenAddress(account)}</span>
          ) : (
            <>
              {isMetaMaskInstalled() ? (
                <button className="btn-connect" onClick={onConnect}>
                  <svg
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                  >
                    <rect x="2" y="6" width="20" height="14" rx="2" />
                    <path d="M22 10H18a2 2 0 0 0 0 4h4" />
                  </svg>
                  Connect Wallet
                </button>
              ) : (
                <a
                  className="btn-connect"
                  href="https://metamask.io/download/"
                  target="_blank"
                  rel="noreferrer"
                >
                  Install MetaMask
                </a>
              )}
            </>
          )}
        </li>
        <li>
          <div className="navbar-right">
            <div className="navbar-wallet">
              {account ? (
                <span className="wallet-address">
                  ✅ {shortenAddress(account)}
                </span>
              ) : (
                <>
                  {isMetaMaskInstalled() ? (
                    <button className="btn-connect" onClick={onConnect}>
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <rect x="2" y="6" width="20" height="14" rx="2" />
                        <path d="M22 10H18a2 2 0 0 0 0 4h4" />
                      </svg>
                      Connect Wallet
                    </button>
                  ) : (
                    <a
                      className="btn-connect"
                      href="https://metamask.io/download/"
                      target="_blank"
                      rel="noreferrer"
                    >
                      Install MetaMask
                    </a>
                  )}
                </>
              )}
            </div>
            <button
              className={`hamburger${open ? " ham-open" : ""}`}
              onClick={() => setOpen((o) => !o)}
              aria-label="Toggle menu"
            >
              <span />
              <span />
              <span />
            </button>
          </div>
        </li>
      </ul>

      {/* Right side */}
    </nav>
  );
}

/* ─── Hero ───────────────────────────────────────────────── */
function Hero({ onCreateCampaign }) {
  return (
    <section className="hero">
      <div className="hero-inner">
        <svg
          className="hero-heart-icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
          width="48"
          height="48"
        >
          <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
        </svg>
        <h1 className="hero-title">
          Empowering Change
          <br />
          Across The Globe
        </h1>
        <p className="hero-desc">
          Join us in making a difference through secure and transparent
          donations
        </p>
        <div className="hero-btns">
          <a href="#campaigns" className="btn-primary">
            Donate Now
          </a>
          <button className="btn-outline" onClick={onCreateCampaign}>
            Start a Campaign
          </button>
        </div>
      </div>
    </section>
  );
}

/* ─── Campaign visual banners (inline SVG by type) ────────── */
const TAG_COLORS = {
  "Flood Relief": "#1c4f8a",
  Earthquake: "#8B4513",
  Cyclone: "#1a2238",
  Drought: "#b8860b",
  Fire: "#cc3300",
  Pandemic: "#2d572c",
  Other: "#444",
};

function CampaignBanner({ tag, title }) {
  const bgColor = TAG_COLORS[tag] || "#444";
  const tagIcons = {
    "Flood Relief": "🌊",
    Earthquake: "🏔️",
    Cyclone: "🌀",
    Drought: "☀️",
    Fire: "🔥",
    Pandemic: "🏥",
    Other: "📢",
  };
  return (
    <div
      className="card-banner-dynamic"
      style={{ background: `linear-gradient(135deg, ${bgColor}, #111)` }}
    >
      <span className="banner-emoji">{tagIcons[tag] || "📢"}</span>
      <span className="banner-title">{title}</span>
    </div>
  );
}

/* ─── Know More Modal ────────────────────────────────────── */
function KnowMoreModal({ campaign, onClose }) {
  function handleBackdrop(e) {
    if (e.target === e.currentTarget) onClose();
  }
  return (
    <div className="modal-backdrop" onClick={handleBackdrop}>
      <div className="modal km-modal">
        <div className="modal-header">
          <div>
            <p className="modal-campaign-tag">{campaign.tag}</p>
            <h2 className="modal-title">{campaign.title}</h2>
          </div>
          <button className="modal-close" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <div className="km-body">
          <CampaignBanner tag={campaign.tag} title={campaign.title} />

          <div className="km-meta">
            <span className="km-pill">📂 {campaign.tag}</span>
            <span className="km-pill">🟢 {campaign.status || "Active"}</span>
            {campaign.creatorAddress &&
              campaign.creatorAddress !== "anonymous" && (
                <span className="km-pill">
                  👤{" "}
                  {campaign.creatorAddress.length > 10
                    ? shortenAddress(campaign.creatorAddress)
                    : campaign.creatorAddress}
                </span>
              )}
          </div>

          <div className="km-section">
            <h4 className="km-section-title">About This Campaign</h4>
            <p className="km-text">{campaign.desc}</p>
          </div>

          <div className="km-section">
            <div className="km-progress-label">
              <span>{formatINR(campaign.raised || 0)} raised</span>
              <span>
                {campaign.percent || 0}% of {formatINR(campaign.goal)}
              </span>
            </div>
            <div className="progress-bar">
              <div
                className="progress-fill"
                style={{ width: `${campaign.percent || 0}%` }}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function CampaignCard({ campaign, onOpenModal, onKnowMore }) {
  const isClosing = campaign.status === "Closing Soon";
  const isCompleted = campaign.status === "Completed";
  return (
    <div className="card">
      <div className="card-img">
        <CampaignBanner tag={campaign.tag} title={campaign.title} />
      </div>
      <div className="card-body">
        <div className="card-header">
          <span className="card-tag">{campaign.tag}</span>
          <span
            className={`card-status ${
              isCompleted
                ? "status-blue"
                : isClosing
                  ? "status-red"
                  : "status-green"
            }`}
          >
            {campaign.status}
          </span>
        </div>
        <h3 className="card-title">{campaign.title}</h3>
        <p className="card-desc">{campaign.desc}</p>
        <div className="card-progress">
          <div className="progress-bar">
            <div
              className="progress-fill"
              style={{ width: `${campaign.percent || 0}%` }}
            />
          </div>
          <div className="progress-meta">
            <span className="raised">
              {formatINR(campaign.raised || 0)} raised
            </span>
            <span className="percent">{campaign.percent || 0}%</span>
          </div>
          <span className="goal">Goal: {formatINR(campaign.goal)}</span>
        </div>
        <div className="card-actions">
          <button
            className="btn-know-more"
            onClick={() => onKnowMore(campaign)}
          >
            Know More
          </button>
          <button
            className="btn-donate"
            onClick={() => onOpenModal(campaign)}
            disabled={isCompleted}
          >
            {isCompleted ? "Funded" : "Donate"}
          </button>
        </div>
      </div>
    </div>
  );
}

function Campaigns({
  campaigns,
  loading,
  onOpenModal,
  onKnowMore,
  onCreateCampaign,
}) {
  return (
    <section id="campaigns" className="campaigns">
      <div className="section-header">
        <h2>Active Relief Campaigns</h2>
        <p>
          All campaigns are community-driven and donations are tracked on-chain.
        </p>
      </div>

      {loading ? (
        <div className="campaigns-loading">
          <span className="spinner" /> Loading campaigns...
        </div>
      ) : campaigns.length === 0 ? (
        <div className="campaigns-empty">
          <p>No campaigns yet. Be the first to create one!</p>
          <button className="btn-primary" onClick={onCreateCampaign}>
            Start a Campaign
          </button>
        </div>
      ) : (
        <div className="cards-grid">
          {campaigns.map((c) => (
            <CampaignCard
              key={c.id}
              campaign={c}
              onOpenModal={onOpenModal}
              onKnowMore={onKnowMore}
            />
          ))}
        </div>
      )}
    </section>
  );
}

/* ─── How It Works ────────────────────────────────────── */
const howSteps = [
  {
    num: "1",
    title: "Create Campaign",
    desc: "Start your fundraising journey by creating a campaign with a compelling story",
  },
  {
    num: "2",
    title: "Share & Connect",
    desc: "Share your campaign with your network and connect with donors",
  },
  {
    num: "3",
    title: "Track Impact",
    desc: "Monitor donations and see your impact grow in real time",
  },
];

function HowItWorks() {
  return (
    <section id="how" className="how-section">
      <h2 className="how-heading">How It Works</h2>
      <div className="how-grid">
        {howSteps.map((s) => (
          <div key={s.num} className="how-step">
            <div className="how-circle">{s.num}</div>
            <h3 className="how-title">{s.title}</h3>
            <p className="how-desc">{s.desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

/* ─── About Us ───────────────────────────────────────────── */
function AboutUs() {
  return (
    <section id="about" className="about-section">
      <div className="about-inner">
        <h2 className="about-title">About Us</h2>
        <p className="about-text">
          FDRS Donation Platform is dedicated to fostering positive change
          across India. We combine blockchain technology with traditional
          payment methods to create a transparent, secure, and accessible
          donation platform.
        </p>
        <p className="about-text">
          Our mission is to connect compassionate donors with meaningful causes,
          ensuring that every contribution makes a real difference in the lives
          of those who need it most.
        </p>
      </div>
    </section>
  );
}

/* ─── Footer ─────────────────────────────────────────────── */
function Footer() {
  function handleSubscribe(e) {
    e.preventDefault();
    e.target.reset();
  }

  return (
    <footer className="footer">
      <div className="footer-inner">
        <div className="footer-col footer-brand-col">
          <div className="footer-logo">
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              width="18"
              height="18"
            >
              <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
            </svg>
            <span className="footer-logo-text">FDRS Donation</span>
          </div>
          <p className="footer-tagline">
            Empowering change through transparent and secure blockchain-powered
            donations across the World
          </p>
        </div>

        <div className="footer-col">
          <h4 className="footer-heading">Quick Links</h4>
          <ul className="footer-list">
            <li>
              <a href="#campaigns">Browse Campaigns</a>
            </li>
            <li>
              <a href="#how">How It Works</a>
            </li>
            <li>
              <a href="#about">About Us</a>
            </li>
          </ul>
        </div>

        <div className="footer-col">
          <h4 className="footer-heading">Resources</h4>
          <ul className="footer-list">
            <li>
              <a href="#faq">FAQ</a>
            </li>
            <li>
              <a href="#terms">Terms of Service</a>
            </li>
            <li>
              <a href="#privacy">Privacy Policy</a>
            </li>
          </ul>
        </div>

        <div className="footer-col">
          <h4 className="footer-heading">Connect With Us</h4>
          <div className="footer-socials">
            <a href="#" className="social-icon" aria-label="Twitter">
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.402 6.231H2.746l7.73-8.835L2.25 2.25h6.945l4.26 5.631 5.79-5.631zm-1.161 17.52h1.833L7.084 4.126H5.117L17.083 19.77z" />
              </svg>
            </a>
            <a href="#" className="social-icon" aria-label="GitHub">
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M12 2C6.477 2 2 6.484 2 12.021c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.009-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0 1 12 6.844a9.59 9.59 0 0 1 2.504.337c1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.02 10.02 0 0 0 22 12.021C22 6.484 17.522 2 12 2z" />
              </svg>
            </a>
            <a href="#" className="social-icon" aria-label="LinkedIn">
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
              </svg>
            </a>
          </div>
          <p className="footer-newsletter-label">Subscribe to our newsletter</p>
          <form className="footer-newsletter" onSubmit={handleSubscribe}>
            <input
              type="email"
              className="newsletter-input"
              placeholder="Enter your email"
              required
            />
            <button type="submit" className="newsletter-btn">
              Subscribe
            </button>
          </form>
        </div>
      </div>

      <div className="footer-bottom">
        <p>© 2026 FDRS Donations. All rights reserved.</p>
      </div>
    </footer>
  );
}

/* ─── App ────────────────────────────────────────────────── */
function App() {
  const [account, setAccount] = useState(null);
  const [walletError, setWalletError] = useState("");
  const [campaigns, setCampaigns] = useState([]);
  const [campaignsLoading, setCampaignsLoading] = useState(true);
  const [modalCampaign, setModalCampaign] = useState(null);
  const [infoCampaign, setInfoCampaign] = useState(null);
  const [showCreateModal, setShowCreateModal] = useState(false);

  // Subscribe to campaigns from Firebase (real-time)
  useEffect(() => {
    const unsubscribe = subscribeCampaigns((list) => {
      setCampaigns(list);
      setCampaignsLoading(false);
    });
    return unsubscribe;
  }, []);

  async function handleConnect() {
    setWalletError("");
    try {
      const addr = await connectWallet();
      setAccount(addr);
    } catch (err) {
      setWalletError(err.message);
    }
  }

  async function handleDonate(amountInEth, campaignId) {
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const tx = await donate(signer, amountInEth);

      // Record donation in Firebase (updates raised amount in real-time)
      await recordDonation(campaignId, amountInEth);

      return tx;
    } catch (err) {
      throw err;
    }
  }

  return (
    <>
      <Navbar account={account} onConnect={handleConnect} error={walletError} />
      <Hero onCreateCampaign={() => setShowCreateModal(true)} />
      <HowItWorks />
      <Campaigns
        campaigns={campaigns}
        loading={campaignsLoading}
        onOpenModal={setModalCampaign}
        onKnowMore={setInfoCampaign}
        onCreateCampaign={() => setShowCreateModal(true)}
      />
      <AboutUs />
      <Footer />

      {/* Create Campaign modal */}
      {showCreateModal && (
        <CreateCampaignModal
          onClose={() => setShowCreateModal(false)}
          account={account}
        />
      )}

      {/* Donation modal */}
      {modalCampaign && (
        <DonationModal
          campaign={modalCampaign}
          onClose={() => setModalCampaign(null)}
          onDonate={handleDonate}
          account={account}
          onConnect={handleConnect}
        />
      )}

      {/* Know More modal */}
      {infoCampaign && (
        <KnowMoreModal
          campaign={infoCampaign}
          onClose={() => setInfoCampaign(null)}
        />
      )}
    </>
  );
}

export default App;
