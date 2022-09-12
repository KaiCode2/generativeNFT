import { ethers } from "hardhat";
import { exec } from "child_process";

async function main() {
  
  const base64Prefix = 'data:image/svg+xml;base64,';

  const lineColour = 'fa0207';
  const svg = `<?xml version="1.0" encoding="UTF-8"?>
  <svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500">
  <defs>
  <style>
  .cls-1{stroke:#${lineColour};stroke-miterlimit:10;}
  </style>
  </defs>
  <line class="cls-1" x1="0" y1="0" x2="500" y2="500"/>
  </svg>`;



  const url = base64Prefix.concat(btoa(svg))
  exec(`open -a Firefox "${url}"`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
