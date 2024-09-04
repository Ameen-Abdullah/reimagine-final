float PI = 3.141592653589793;

uniform vec2 uResolution; // in pixel
uniform float uTime; // in s
uniform vec2 uCursor; // 0 (left) 0 (top) / 1 (right) 1 (bottom)
uniform float uScrollVelocity; // - (scroll up) / + (scroll down)
uniform sampler2D uTexture; // texture
uniform sampler2D uVideo;
uniform vec2 uTextureSize; // size of texture
uniform vec2 uQuadSize; // size of texture element
uniform float uBorderRadius; // pixel value
uniform float uMouseEnter; // 0 - 1 (enter) / 1 - 0 (leave)
uniform vec2 uMouseOverPos; // 0 (left) 0 (top) / 1 (right) 1 (bottom)
uniform float uEnter;
uniform float uEnter2;
uniform float uProgress;
uniform vec4 uCorners;

#include './resources/utils.glsl';

varying vec2 vUv;  // 0 (left) 0 (bottom) - 1 (top) 1 (right)
varying vec2 vUvCover;
varying vec2 correctedUv;
varying vec2 vSize;
varying float distanceFromCenterFrag;

varying float area;

void main() {
  vUv = uv;
  vUvCover = getCoverUvVert(uv, uTextureSize, uQuadSize);
  vec3 pos = position;

  gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(pos, 1.0);

}
