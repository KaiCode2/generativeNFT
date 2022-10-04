// SPDX-License-Identifier: UNLICENSED
// Author: Kai Aldag <kaialdag@icloud.com>
// Date: September 28, 2022
// Purpose: Make cool diamonds n shit

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Base64.sol";

contract Diamonds is ERC721 {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    function mint(uint256 tokenID) external {
        _mint(msg.sender, tokenID);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory name = string.concat("Diamond #", Strings.toString(tokenId));
        string memory description = "oooo such shine";
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
                            '", "background_color": "', // TODO: Set to hue!
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

    function generateBase64Image(uint256 tokenId) public pure returns (string memory) {
        return Base64.encode(bytes(generateImage(tokenId)));
    }

    function generateImage(uint256 tokenId) public pure returns (string memory) {

        return string(
            abi.encodePacked(
'<!DOCTYPE html>'
'<html lang="en">'
'  <meta charset="UTF-8" /><style>'
'    * {'
'      box-sizing: border-box;'
'    }'
'    body,'
'    html {'
'      margin: 0;'
'      min-height: 100vh;'
'      overflow: hidden;'
'      background: repeating-radial-gradient('
'        circle at center,'
'        #444 0 10%,'
'        #111 10% 20%'
'      );'
'      touch-action: none;'
'    }'
'    canvas {'
'      width: 100%;'
'      height: auto;'
'      object-fit: contain;'
'    }</style><canvas id="canvas"></canvas>'
'  <script>'
'    const canvas = window.canvas,'
'      gl = canvas.getContext("webgl2"),'
'      dpr = window.devicePixelRatio,'
'      touches = new Map();'
'    const vertexSource =`#version 300 es\n #ifdef GL_FRAGMENT_PRECISION_HIGH\n   precision highp float;\n   #else\n   precision mediump float;\n   #endif\n   \n   in vec2 position;\n   \n   void main(void) {\n       gl_Position = vec4(position, 0., 1.);\n   }`;'
'    const fragmentSource =`#version 300 es\n #ifdef GL_FRAGMENT_PRECISION_HIGH\n   precision highp float;\n   #else\n   precision mediump float;\n   #endif\n   \n   uniform vec2 resolution;\n   uniform int pointerCount;\n   uniform vec2 touch;\n   uniform float time;\n   \n   const float PI = radians(180.);\n   const float TAU = 2.*PI;\n   const float IOR = 1.45;\n   const float DENSE = .7;\n   \n   #define MAX_STEPS 100\n   #define MAX_DIST 20.\n   #define SURF_DIST .001\n   \n   #define S smoothstep\n   #define T 3.5 + time\n   \n   out vec4 fragColor;\n   \n   vec2 MatMin(vec2 lhs, vec2 rhs) {\n     if (lhs.x < rhs.x) return lhs;\n   \n     return rhs;\n   }\n   \n   float cLength(vec2 p, float k) {\n     p = abs(p);\n   \n     return pow(pow(p.x, k)+pow(p.y, k), 1./k);\n   }\n   \n   mat2 Rot(float a) {\n     float s = sin(a),\n     c = cos(a);\n     return mat2(c, -s, s, c);\n   }\n   \n   float Spiral(vec2 p, float t, float k) {\n     float r = cLength(p, k);\n     float a = atan(p.y, p.x) / TAU;\n   \n     return sin(fract(log(r) * t + a));\n   }\n   \n   float Octahedron(vec3 p, float s) {\n     p = abs(p);\n   \n     return (p.x + p.y + p.z - s) * (1. / sqrt(3.));\n   }\n   \n   vec2 GetDist(vec3 p) {\n     vec2 md = MatMin(\n       vec2(\n         Octahedron(p, 1.),\n         1.\n       ),\n       vec2(\n         dot(\n           p,\n           normalize(vec3(.0, 1., .0))\n         ) + 2., 2.\n       )\n     );\n   \n     return md;\n   }\n   \n   vec2 RayMarch(vec3 ro, vec3 rd, float side) {\n     float dO = 0.;\n     vec2 d;\n   \n     for (int i = 0; i < MAX_STEPS; i++) {\n       vec3 p = ro + rd*dO;\n       d = GetDist(p) * side;\n       dO += d.x;\n   \n       if (dO > MAX_DIST || abs(d.x) < SURF_DIST) break;\n     }\n   \n     return vec2(dO, d.y);\n   }\n   \n   vec3 GetNormal(vec3 p) {\n     float d = GetDist(p).x;\n     vec2 e = vec2(.05, 0);\n   \n     vec3 n = d - vec3(\n       GetDist(p-e.xyy).x,\n       GetDist(p-e.yxy).x,\n       GetDist(p-e.yyx).x);\n   \n     return normalize(n);\n   }\n   \n   vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {\n     vec3 f = normalize(l-p),\n     r = normalize(cross(vec3(0, 1, 0), f)),\n     u = cross(f, r),\n     c = f*z,\n     i = c + uv.x*r + uv.y*u,\n     d = normalize(i);\n     return d;\n   }\n   \n   vec3 Refract(vec3 p, vec3 n, inout vec3 ro, inout vec3 rd, inout float od) {\n     vec3 rdIn = refract(rd, n, 1./IOR);\n     vec3 pEnter = p-n*SURF_DIST*3.;\n     vec2 dIn = RayMarch(pEnter, rdIn, -1.);\n     vec3 pExit = pEnter + rdIn * dIn.x;\n     vec3 nExit = -GetNormal(pExit);\n     vec3 rdOut = refract(rdIn, nExit, IOR);\n   \n     if (dot(rdOut, rdOut) == .0) {\n       rdOut = reflect(rdIn, nExit);\n     }\n   \n     ro = pEnter;\n     rd = rdOut;\n     od = exp(-dIn.x * DENSE);\n   \n     return pExit;\n   }\n   \n   vec3 Render(inout vec3 ro, inout vec3 rd, inout float ref) {\n     vec2 d = RayMarch(ro, rd, 1.);\n   \n     vec3 col = vec3(.0);\n   \n     if (d.x < MAX_DIST) {\n       vec3 p = ro + rd * d.x;\n       vec3 l = normalize(ro);\n       vec3 n = GetNormal(p);\n       vec3 r = reflect(rd, n);\n   \n       // material\n       vec3 mat = vec3(.0);\n       float fres = pow(clamp(1.+dot(n, rd), .0, 1.), 5.);\n   \n           vec3 offs = vec3(.25)*length(p.xz);\n       float s = 1.5 * sin(T*.5);\n       float k = .5 + 1. * (.5+.5*cos(T*.5));\n       mat2 rot = Rot(T*.5);\n   \n       // floor\n       if (d.y == 2.) {\n   \n         float spiral = clamp(\n           Spiral(p.xz*rot, s, k),\n           .0,\n           1.\n         );\n   \n         mat = pow(vec3(spiral) - offs, vec3(offs));\n   \n         ro = p + n * SURF_DIST * 3.;\n         rd = r;\n   \n       }\n       // object\n       else if (d.y == 1.) {\n   \n         float od;\n         vec3 st = Refract(p, n, ro, rd, od);\n         float spiral = Spiral(st.xz*rot, s, k);\n         \n         vec3 si = pow(vec3(spiral) - offs, vec3(offs));\n   \n         mat = mix(\n           si,\n           vec3(1.5, 1.75, 2.),\n           od\n         ) - pow(1.-abs(ro.y), 2.);\n         mat *= exp(log(vec3(.5)));\n   \n         ref = mix(.05, .5, fres);\n       }\n   \n       // light\n       float diffuse = dot(n, l) * .5 + .5;\n     \n       float spot = clamp(\n         dot(\n           normalize(r),\n           reflect(r, vec3(0))),\n         .0,\n         1.\n       );\n     \n       col += .8 * diffuse;\n       col += .95 * pow(spot, 16.);\n     \n       col *= mat;\n     }\n   \n     return col;\n   }\n   \n   void main(void) {\n     float mn = min(resolution.x, resolution.y);\n     float mx = max(resolution.x, resolution.y);\n     vec2 uv = (\n       gl_FragCoord.xy - .5 * resolution.xy\n     ) / mx;\n   \n     vec2 m = touch.xy / resolution.xy;\n     m.y = clamp(m.y, .0, .55);\n   \n     vec3 ro = vec3(0., 3., -6.);\n     bool aut = pointerCount == 0;\n   \n     ro.yz *= Rot(aut ? .55+sin(T*.25)*.5: -m.y * PI + 1.);\n     ro.xz *= Rot(aut ? T*.25: -m.x * TAU);\n   \n     vec3 rd = GetRayDir(uv, ro, vec3(0), 1.);\n     vec3 sto = ro;\n   \n     float ref = .0;\n     vec3 col = Render(ro, rd, ref);\n   \n     for (int i = 0; i < 2; i++) {\n       col += ref * Render(ro, rd, ref);\n     }\n   \n     // gamma correction\n     col = pow(col, vec3(.45));\n   \n     // vignette\n     vec2 z = (gl_FragCoord.xy -.5 * resolution) / mn;\n     col *= 1. - dot(z, z);\n   \n     fragColor = vec4(col, 1.);\n   }`;'
'    let time,'
'      buffer,'
'      program,'
'      touch,'
'      resolution,'
'      pointerCount,'
'      vertices = [],'
'      touching = !1;'
'    function resize() {'
'      const { innerWidth: n, innerHeight: e } = window;'
'      (canvas.width = n * dpr),'
'        (canvas.height = e * dpr),'
'        gl.viewport(0, 0, n * dpr, e * dpr);'
'    }'
'    function compile(n, e) {'
'      gl.shaderSource(n, e),'
'        gl.compileShader(n),'
'        gl.getShaderParameter(n, gl.COMPILE_STATUS) ||'
'          console.error(gl.getShaderInfoLog(n));'
'    }'
'    function setup() {'
'      const n = gl.createShader(gl.VERTEX_SHADER),'
'        e = gl.createShader(gl.FRAGMENT_SHADER);'
'      (program = gl.createProgram()),'
'        compile(n, vertexSource),'
'        compile(e, fragmentSource),'
'        gl.attachShader(program, n),'
'        gl.attachShader(program, e),'
'        gl.linkProgram(program),'
'        gl.getProgramParameter(program, gl.LINK_STATUS) ||'
'          console.error(gl.getProgramInfoLog(program)),'
'        (vertices = [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]),'
'        (buffer = gl.createBuffer()),'
'        gl.bindBuffer(gl.ARRAY_BUFFER, buffer),'
'        gl.bufferData('
'          gl.ARRAY_BUFFER,'
'          new Float32Array(vertices),'
'          gl.STATIC_DRAW'
'        );'
'      const o = gl.getAttribLocation(program, "position");'
'      gl.enableVertexAttribArray(o),'
'        gl.vertexAttribPointer(o, 2, gl.FLOAT, !1, 0, 0),'
'        (time = gl.getUniformLocation(program, "time")),'
'        (touch = gl.getUniformLocation(program, "touch")),'
'        (pointerCount = gl.getUniformLocation(program, "pointerCount")),'
'        (resolution = gl.getUniformLocation(program, "resolution"));'
'    }'
'    function draw(n) {'
'      gl.clearColor(0, 0, 0, 1),'
'        gl.clear(gl.COLOR_BUFFER_BIT),'
'        gl.useProgram(program),'
'        gl.bindBuffer(gl.ARRAY_BUFFER, buffer),'
'        gl.uniform1f(time, 0.001 * n),'
'        gl.uniform2f(touch, ...getTouches()),'
'        gl.uniform1i(pointerCount, touches.size),'
'        gl.uniform2f(resolution, canvas.width, canvas.height),'
'        gl.drawArrays(gl.TRIANGLES, 0, 0.5 * vertices.length);'
'    }'
'    function getTouches() {'
'      if (!touches.size) return [0, 0];'
'      for (let [n, e] of touches) {'
'        return [dpr * e.clientX, dpr * (innerHeight - e.clientY)];'
'      }'
'    }'
'    function loop(n) {'
'      draw(n), requestAnimationFrame(loop);'
'    }'
'    function init() {'
'      setup(), resize(), loop(0);'
'    }'
'    (document.body.onload = init),'
'      (window.onresize = resize),'
'      (canvas.onpointerdown = (n) => {'
'        (touching = !0), touches.set(n.pointerId, n);'
'      }),'
'      (canvas.onpointermove = (n) => {'
'        touching && touches.set(n.pointerId, n);'
'      }),'
'      (canvas.onpointerup = (n) => {'
'        (touching = !1), touches.clear();'
'      }),'
'      (canvas.onpointerout = (n) => {'
'        (touching = !1), touches.clear();'
'      });'
'  </script>'
'</html>'
            )
        );
    }
}
