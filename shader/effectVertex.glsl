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

float circle(vec2 center, float radius, vec2 point) {
  float distance = length(point - center);
  return smoothstep(radius - 0.01, radius + 0.01, distance);
}

vec3 deformationCurve(vec3 position, vec2 uv) {
  position.y = position.y - (sin(uv.x * PI) * min(abs(uScrollVelocity), 5.0) * sign(uScrollVelocity) * -0.01);

  return position;
}

#define NUM_OCTAVES 5

float rand(vec2 n) {
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 ip = floor(p);
  vec2 u = fract(p);
  u = u * u * (3.0 - 2.0 * u);

  float res = mix(mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x), mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
  return res * res;
}

float fbm(vec2 x) {
  float v = 0.0;
  float a = 0.5;
  vec2 shift = vec2(100);
	// Rotate to reduce axial bias
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
  for(int i = 0; i < NUM_OCTAVES; ++i) {
    v += a * noise(x);
    x = rot * x * 2.0 + shift;
    a *= 0.5;
  }
  return v;
}

void main() {
  vUv = uv;
  vUvCover = getCoverUvVert(uv, uTextureSize, uQuadSize);
  correctedUv = getCoverUvFrag(uv, uTextureSize, uQuadSize);
  vec3 pos = position;

  float aspectRatio = uQuadSize.y / uQuadSize.x;

  float corners = mix(mix(uCorners.x, uCorners.y, vUvCover.x), mix(uCorners.z, uCorners.w, vUvCover.x), vUvCover.y);

  // float distanceToCenter = distance(vUvCover, vec2(uMouseOverPos.x, 1.0 - uMouseOverPos.y));

  //decay wave  
  // float waveFrequency = 20.0 * aspectRatio;
  // float amplitude = 25. * aspectRatio;
  // float decayRate = 3.0;

  // float decayFactor = exp(-distanceToCenter * decayRate);
  // float decayingWave = sin(distanceToCenter * waveFrequency - uTime * 3.) * amplitude * decayFactor;

  // pos.z += decayingWave * 1.1 * uEnter;

  // distanceFromCenterFrag = decayingWave;

  //decay 2 

  vec2 aspectCorrectedMouse = vec2(uMouseOverPos.x * uTextureSize.x / uTextureSize.y, 1. - uMouseOverPos.y);
  vec2 aspectCorrectedUv = vec2(vUvCover.x * uTextureSize.x / uTextureSize.y, vUvCover.y);

  float distanceFromMouse = length(aspectCorrectedUv - aspectCorrectedMouse);

    // Calculate the decaying wave using a combination of sine wave and exponential decay\
  float waveFrequency = 20.0 ;
  float waveAmplitude = 20.0  ;
  float decayFactor = 6.0;

  float wave2 = sin(distanceFromMouse * waveFrequency - uTime * 2.) * exp(-distanceFromMouse * decayFactor) * waveAmplitude;

  pos.z += wave2 * uEnter;

  distanceFromCenterFrag = wave2;

//combination of waves 

  // float waveFrequencyX = 20.0 * aspectRatio;
  // float waveFrequencyY = 20.0 * aspectRatio;
  // float waveFrequencyZ = 20.0 * aspectRatio;
  // float amplitudeX = 25. * aspectRatio;
  // float amplitudeY = 25. * aspectRatio;

  // float complexWave = (sin(pos.x * waveFrequencyX + uTime) + cos(pos.y * waveFrequencyY + uTime)) * amplitudeX + sin(distanceToCenter * waveFrequencyZ + uTime) * amplitudeY;

  // pos.z -= complexWave * 1.1 * uEnter;

  // distanceFromCenterFrag = decayingWave;

  float circle = circle(vec2(uMouseOverPos.x, 1.0 - uMouseOverPos.y), 0.1, vUvCover);
  area = circle;

  // pos.z = sin((distanceToCenter * 10. + uTime * 3.)) * 8. * uEnter;



  vec4 normalState = modelMatrix * vec4(pos, 1.0);

  vec4 fulScreenState = vec4(position, 1.0);

  fulScreenState.x *= uResolution.x;
  fulScreenState.y *= uResolution.y;
  fulScreenState.z += uCorners.z * 20.;

  float sine = sin(PI * uProgress);
  // float fbmWave = fbm(vUvCover * .5 + uTime )  ;
  float wave = sine * .1 * sin(5. * fbm(vUvCover * 1. + uTime) * PI);
  // float wave = sine * .1 * sin(5. * fbmWave * PI);


//fbm vers 

  // vec4 finalState = mix(normalState, fulScreenState, corners + fbm(vUvCover * 100. + uTime) * wave);

  //perlin 

  // vec4 finalState = mix(normalState, fulScreenState, corners + cnoise(vUvCover * 6. + uTime) * wave);
  vec4 finalState = mix(normalState, fulScreenState, corners + wave);

  vSize = mix(uQuadSize, uResolution, uProgress);

  gl_Position = projectionMatrix * viewMatrix * finalState;

}
