/**
 * wallet.js
 * Utility functions for MetaMask wallet connection via window.ethereum
 * Auto-switches to Sepolia testnet on connect
 */

const SEPOLIA_CHAIN_ID = '0xaa36a7' // 11155111 in hex

export function isMetaMaskInstalled() {
    return typeof window.ethereum !== 'undefined' && window.ethereum.isMetaMask
}

export async function connectWallet() {
    if (!isMetaMaskInstalled()) {
        throw new Error('MetaMask is not installed. Please install it from https://metamask.io')
    }

    // Request accounts
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })

    if (!accounts || accounts.length === 0) {
        throw new Error('No accounts found. Please unlock MetaMask.')
    }

    // Switch to Sepolia testnet
    try {
        await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: SEPOLIA_CHAIN_ID }],
        })
    } catch (switchError) {
        // If Sepolia is not added, add it
        if (switchError.code === 4902) {
            await window.ethereum.request({
                method: 'wallet_addEthereumChain',
                params: [{
                    chainId: SEPOLIA_CHAIN_ID,
                    chainName: 'Sepolia Testnet',
                    nativeCurrency: { name: 'SepoliaETH', symbol: 'ETH', decimals: 18 },
                    rpcUrls: ['https://ethereum-sepolia-rpc.publicnode.com'],
                    blockExplorerUrls: ['https://sepolia.etherscan.io'],
                }],
            })
        }
    }

    return accounts[0]
}

export function shortenAddress(address) {
    if (!address) return ''
    return `${address.slice(0, 6)}...${address.slice(-4)}`
}
