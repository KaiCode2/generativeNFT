// SPDX-License-Identifier: UNLICENSED
// Author: Kai Aldag <kaialdag@icloud.com>
// Date: September 28, 2022
// Purpose: Make cool lasers n shit

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Base64.sol";

contract Three is ERC721 {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    function mint(uint256 tokenID) external {
        _mint(msg.sender, tokenID);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory name = string.concat("Lasers #", Strings.toString(tokenId));
        string memory description = "CryptoDisco";
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
                            // '", "image": "', 
                            // 'data:image/svg+xml;base64,', 
                            // image,
                            '", "animation_url": "', // TODO: Convert animation URL to pure SVG
                            'data:text/html;base64,', 
                            image,
                            '", "background_color": "',
                            "003d3d"
                            '", "attributes": [',
                                // '{"trait_type": "Blend Mode", "value": "', blendModeString(tokenTraits.blendMode), '"},'
                                // '{"display_type": "number", "trait_type": "Duration", "value": "', Strings.toString(tokenTraits.duration), '"}' // QUESTION: add hue as trait?
                            ']}'
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
        

        return string(
            abi.encodePacked(
                '<!DOCTYPE html><html lang="en">'
                '<style>'
                    'body{'
                        'overflow: hidden;'
                        'margin: 0;}'
                '</style>'
                '<body>'
                '<script>'
'import * as THREE from "https://cdn.skypack.dev/three@0.136.0";'
'import {OrbitControls} from "https://cdn.skypack.dev/three@0.136.0/examples/jsm/controls/OrbitControls";'
''
'console.clear();'
''
'let scene = new THREE.Scene();'
'let camera = new THREE.PerspectiveCamera(60, innerWidth / innerHeight, 0.1, 1000);'
'camera.position.set(0, 2, 5);'
'let renderer = new THREE.WebGLRenderer({antialias: true});'
'renderer.setSize(innerWidth, innerHeight);'
'document.body.appendChild(renderer.domElement);'
'window.addEventListener("resize", event => {'
'  camera.aspect = innerWidth / innerHeight;'
'  camera.updateProjectionMatrix();'
'  renderer.setSize(innerWidth, innerHeight);'
'})'
''
'let controls = new OrbitControls(camera, renderer.domElement);'
''
'let gu = {'
'  time: {value: 0}'
'}'
''
'scene.add(new THREE.GridHelper());'
''
'let r = 0.1, R = 20, halfAngle = THREE.MathUtils.degToRad(45);'
'let g = new THREE.PlaneGeometry(1, 1, 72, 20);'
'let pos = g.attributes.position;'
'let uv = g.attributes.uv;'
'for(let i = 0; i < pos.count; i++){'
'  let y = 1. - uv.getY(i);'
'  let radius = r + (R - r) * y;'
'  let x = pos.getX(i);'
'  pos.setXY(i, Math.cos(x * halfAngle) * radius, Math.sin(x * halfAngle) * radius);'
'}'
'g.rotateX(-Math.PI * 0.5);'
'g.rotateY(-Math.PI * 0.5);'
''
'let m = new THREE.MeshBasicMaterial({'
'  color: new THREE.Color(0, 0.75, 1),'
'  side: THREE.DoubleSide,'
'  transparent: true,'
'  onBeforeCompile: shader => {'
'    shader.uniforms.time = gu.time;'
'    shader.fragmentShader = `'
'      uniform float time;'
'      ${shader.fragmentShader}'
'    `.replace('
'      `#include <color_fragment>`,'
'      `#include <color_fragment>'
'      float t = time;'
'      float mainWave = sin((vUv.x - t * 0.2) * 1.5 * PI2) * 0.5 + 0.5;'
'      mainWave = mainWave * 0.25 + 0.25;'
'      mainWave *= (sin(t * PI2 * 5.) * 0.5 + 0.5) * 0.25 + 0.75;'
'      float sideLines = smoothstep(0.45, 0.5, abs(vUv.x - 0.5));'
'      float scanLineSin = abs(vUv.x - (sin(t * 2.7) * 0.5 + 0.5));'
'      float scanLine = smoothstep(0.01, 0., scanLineSin);'
'      float fadeOut = pow(vUv.y, 2.7);'
'      '
'      '
'      float a = 0.;'
'      a = max(a, mainWave);'
'      a = max(a, sideLines);'
'      a = max(a, scanLine);'
'      '
'      diffuseColor.a = a * fadeOut;'
'      '
'      `'
'    );'
'    console.log(shader.fragmentShader)'
'  }'
'});'
'm.defines = {"USE_UV": ""}'
''
'let laser = new THREE.Mesh(g, m);'
'laser.position.set(0, 1.5, 0);'
'scene.add(laser);'
''
'let clock = new THREE.Clock();'
''
'renderer.setAnimationLoop(() => {'
'  let t = clock.getElapsedTime();'
'  gu.time.value = t;'
'  laser.rotation.x = (Math.sin(t) * 0.5 + 0.5) * THREE.MathUtils.degToRad(10);'
'  renderer.render(scene, camera);'
'});'
                '</script></body></html>'
            )
        );
    }
}
