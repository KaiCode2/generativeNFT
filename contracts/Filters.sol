// SPDX-License-Identifier: UNLICENSED
// Author: Kai Aldag <kaialdag@icloud.com>
// Date: September 28, 2022
// Purpose: Make cool blobs of colour n shit

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Base64.sol";

contract Filters is ERC721Enumerable {
    mapping(uint256 => string) private images;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function mint(string calldata image) external {
        images[totalSupply()] = image;
        _mint(msg.sender, totalSupply());
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory name = string.concat("Filter #", Strings.toString(tokenId));
        string memory description = "Such cool";
        string memory image = generateBase64Image(tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                // '", "animation_url": "',
                                // "data:text/html;base64,",
                                // image,
                                '", "background_color": "',
                                "003d3d"
                                '", "attributes": [',
                                // '{"trait_type": "Blend Mode", "value": "', blendModeString(tokenTraits.blendMode), '"},'
                                // '{"display_type": "number", "trait_type": "Duration", "value": "', Strings.toString(tokenTraits.duration), '"}' // QUESTION: add hue as trait?
                                "]}"
                            )
                        )
                    )
                )
            );
    }

    function generateBase64Image(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        return Base64.encode(bytes(generateImage(tokenId)));
    }

    function generateImage(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        require(_exists(tokenId), "Filters: Token does not exist");
        string storage image = images[tokenId];

        return
            string(
                abi.encodePacked(
                    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" xmlns:xlink= "http://www.w3.org/1999/xlink">'
                    "<style>"
                    "svg{"
                    "position:absolute;"
                    "top:50%;"
                    "left:50%;"
                    "height:100%;"
                    "width:100%;"
                    "transform:translate(-50%,-50%);"
                    "max-height:700px;"
                    "max-width:700px;"
                    "}"
                    "</style>"
                    '<filter id="blur">'
                    '<feMorphology in="SourceGraphic" operator="dilate" radius="0.3">'
                    "</feMorphology>"
                    "</filter>"
                    '<filter id="turbulence">'
                    "<feComponentTransfer>"
                    '<feFuncR type="discrete" tableValues="0 0.5 0 1"/>'
                    '<feFuncG type="discrete" tableValues="0 0.5 0 1"/>'
                    '<feFuncB type="discrete" tableValues="0 0.5 0 1"/>'
                    '<feFuncA type="discrete" tableValues="0 0.5 0 1"/>'
                    "</feComponentTransfer>"
                    "</filter>"
                    '<filter id="convolve">'
                    "<feComponentTransfer>"
                    '<feFuncR type="table" tableValues="0 0.5 0 1" />'
                    '<feFuncG type="table" tableValues="0 0.5 0 1" />'
                    '<feFuncB type="table" tableValues="0 0.5 0 1" />'
                    '<feFuncA type="table" tableValues="0 0.5 0 1" />'
                    "</feComponentTransfer>"
                    "</filter>"
                    '<mask id="mask1">'
                    '<line x1="0" y1="0%" x2="100" y2="200" stroke="white" stroke-width="15">'
                    '<animate attributeName="x1" values="7.5%;92.5%;7.5%" dur="10s" begin="-2s" repeatCount="indefinite" />'
                    '<animate attributeName="x2" values="7.5%;92.5%;7.5%" dur="10s" begin="-2s" repeatCount="indefinite" />'
                    "</line>"
                    "</mask>"
                    '<mask id="mask2">'
                    '<line x1="0" y1="0" x2="200" y2="100" stroke="white" stroke-width="15">'
                    '<animate attributeName="y1" values="7.5%;92.5%;7.5%" dur="10s" begin="-4s" repeatCount="indefinite" />'
                    '<animate attributeName="y2" values="7.5%;92.5%;7.5%" dur="10s" begin="-4s" repeatCount="indefinite" />'
                    "</line>"
                    "</mask>"
                    '<mask id="mask3">'
                    '<line x1="0" y1="0" x2="200" y2="100" stroke="white" stroke-width="15">'
                    '<animate attributeName="y1" values="7.5%;92.5%;7.5%" dur="10s" begin="-6s" repeatCount="indefinite" />'
                    '<animate attributeName="y2" values="7.5%;92.5%;7.5%" dur="10s" begin="-6s" repeatCount="indefinite" />'
                    "</line>"
                    "</mask>"
                    '<mask id="mask4">'
                    '<line x1="0" y1="0" x2="100" y2="200" stroke="white" stroke-width="15">'
                    '<animate attributeName="x1" values="7.5%;92.5%;7.5%" dur="10s" begin="-8s" repeatCount="indefinite" />'
                    '<animate attributeName="x2" values="7.5%;92.5%;7.5%" dur="10s" begin="-8s" repeatCount="indefinite" />'
                    "</line>"
                    "</mask>",
                    generateImageProperties(image),
                    "</svg>"
                )
            );
    }

    function generateImageProperties(string memory image)
        private pure
        returns (string memory)
    {
        return
            string.concat(
                '<image width="100" href="',image,'" />',
                '<image width="100" filter="url(#turbulence)"  mask="url(#mask2)" href="',image,'"/>'
                '<image width="100" filter="url(#blur)"  mask="url(#mask1)" href="',image,'"/>'
                '<image width="100" filter="invert(100%)"  mask="url(#mask4)" href="',image,'"/>'
                '<image width="100" filter="url(#convolve)"  mask="url(#mask3)" href="',image,'"/>'
            );
    }
}
