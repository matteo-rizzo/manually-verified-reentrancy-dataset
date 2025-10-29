import { ethers } from "ethers";

export function printBalance(name: string, balanceBefore: bigint, balanceAfter: bigint) {
    console.log(`${name} balance: ${parseEther(balanceBefore)} ETH -> ${parseEther(balanceAfter)} ETH`);
}

export function parseEther(amount: bigint): number {
    return parseFloat(parseFloat(ethers.formatEther(amount)).toFixed(2));
}