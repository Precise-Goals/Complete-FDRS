/**
 * contract.js
 * Utility for interacting with the FDRS Donation smart contract
 * Network: Ethereum Sepolia Testnet (chainId: 11155111)
 */

import { ethers } from "ethers";

// ── Config ────────────────────────────────────────────────────
// Replace this with your deployed contract address on Sepolia
export const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDR;

// Ethereum Sepolia public RPC endpoint
const SEPOLIA_RPC = "https://ethereum-sepolia-rpc.publicnode.com";

// Minimal ABI — only the functions we need
const ABI = [
  // donate(): payable, sends ETH to the contract
  "function donate() external payable",

  // getTotalRaised(): returns total ETH donated so far
  "function getTotalRaised() external view returns (uint256)",
];

// ── getReadProvider ───────────────────────────────────────────
// Returns a read-only provider connected to Ethereum Sepolia.
// Used for calling view functions (no wallet needed).
export function getReadProvider() {
  return new ethers.JsonRpcProvider(SEPOLIA_RPC);
}

// ── getContract ───────────────────────────────────────────────
// Returns a contract instance.
// Pass a signer for write calls, or a provider for read-only calls.
export function getContract(signerOrProvider) {
  return new ethers.Contract(CONTRACT_ADDRESS, ABI, signerOrProvider);
}

// ── donate ────────────────────────────────────────────────────
// Sends `amountInEth` ETH to the contract's donate() function.
// Requires the user's MetaMask signer.
// @param {ethers.Signer} signer  - from getSigner() via BrowserProvider
// @param {string}        amount  - amount in ETH, e.g. "0.01"
export async function donate(signer, amount) {
  const contract = getContract(signer);

  // Convert ETH amount (human-readable) to wei
  const value = ethers.parseEther(amount);

  // Send the transaction — MetaMask will prompt the user to confirm
  const tx = await contract.donate({ value });

  // Return immediately with the tx hash — no need to block the UI
  return tx;
}

// ── getTotalRaised ────────────────────────────────────────────
// Fetches the total amount donated (in ETH) from the contract.
// Uses a read-only provider — no wallet needed.
// Returns '0' on failure so the UI never crashes.
// @returns {string} - formatted ETH amount, e.g. "1.25"
export async function getTotalRaised() {
  try {
    const provider = getReadProvider();
    const contract = getContract(provider);

    // Call the view function — returns a BigInt in wei
    const totalWei = await contract.getTotalRaised();

    // Convert wei → ETH (ether units) and return as string
    return ethers.formatEther(totalWei);
  } catch {
    // If blockchain is unreachable, return '0' gracefully
    return "0";
  }
}
