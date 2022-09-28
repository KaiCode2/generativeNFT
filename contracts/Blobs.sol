// SPDX-License-Identifier: UNLICENSED
// Author: Kai Aldag <kaialdag@icloud.com>
// Date: September 28, 2022
// Purpose: Make cool blobs of colour n shit

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Base64.sol";

contract Blobs is ERC721 {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    function mint(uint256 tokenID) external {
        _mint(msg.sender, tokenID);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        
        string memory name = string.concat("Blob #", Strings.toString(tokenId));
        string memory description = "Dank blob";
        string memory image = generateBase64Image(tokenId);

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"', 
                            name,
                            '", "description":"', 
                            description,
                            '", "animation_url": "', 
                            'data:text/html;base64,', 
                            image,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function generateBase64Image(uint256 tokenId) public view returns (string memory) {
        return Base64.encode(bytes(generateImage(tokenId)));
    }

    function generateImage(uint256 tokenId) public view returns (string memory) {
        string memory hue = Strings.toString(uint256(tokenId * 60));

        return string(
            abi.encodePacked(
                '<!DOCTYPE html><html lang="en"><style>svg,main {width: 16rem;height: 24rem;isolation: isolate;}:root {--hue: 140;--hue-alt: calc(var(--hue) - 157);}main {display: grid;grid-template-columns: 1fr;grid-template-rows: 1fr;position: relative;rotate: -1deg;}main::before,main::after {content: "";position: absolute;z-index: -1;inset: -0.75rem;border: 0.75rem solid hsl(var(--hue) 100% 50%);background: hsl(var(--hue) 100% 100% / 0.95);}main::after {border-color: hsl(var(--hue-alt) 100% 50%);mix-blend-mode: multiply;rotate: 2deg;}svg {grid-column: 1;grid-row: 1;}g {filter: url(#fancy-goo);}#back,#front {mix-blend-mode: multiply;}#back circle {fill: hsl(var(--hue-alt), 100%, 60%);}#front circle {fill: hsl(var(--hue), 100%, 45%);}body {height: 100vh;overflow: clip;display: flex;justify-content: center;background: linear-gradient(to bottom, hsl(180 100% 10%), hsl(180 100% 6%));}* {box-sizing: border-box;margin: 0;}form {position: absolute;bottom: 0.5rem;}</style><body><main><svg viewBox="20 0 60 100"><g id="back"><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /></g><g id="front"><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /><circle cx="50" cy="50" r="15" /></g><filter id="goo"><feGaussianBlur in="SourceGraphic" stdDeviation="10" result="blur" /><feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -7" result="goo" /><feBlend in="SourceGraphic" in2="goo" /></filter><filter id="fancy-goo"><feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" /><feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 19 -9" result="goo" /><feComposite in="SourceGraphic" in2="goo" operator="atop" /></filter></svg></main><script>const circles = document.querySelectorAll("circle");const DURATION = 6000;circles.forEach((blob, i) => {const start = Math.random() * 40 - 20;blob.setAttribute("r", Math.random() * 10 + 5);blob.animate({transform: [`translate(${start}px, -75px)`,`translate(${start + (Math.random() * 20 - 10)}px, 75px)`]},{iterations: Infinity,duration: DURATION + Math.random() * DURATION,delay: Math.random() * -8000,fill: "backwards"});});document.documentElement.style.setProperty("--hue", ', hue, ');</script></body></html>'
            )
        );
    }
}
