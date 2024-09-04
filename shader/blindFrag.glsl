uniform vec2 uResolution; // in pixel
uniform float uTime; // in s
uniform vec2 uCursor; // 0 (left) 0 (top) / 1 (right) 1 (bottom)
uniform float uScrollVelocity; // - (scroll up) / + (scroll down)
uniform sampler2D uTexture; // texture
uniform sampler2D uVideo;
uniform sampler2D uDisplacement;
uniform vec2 uTextureSize; // size of texture
uniform vec2 uQuadSize; // size of texture element
uniform float uBorderRadius; // pixel value
uniform float uMouseEnter; // 0 - 1 (enter) / 1 - 0 (leave)
uniform vec2 uMouseOverPos; // 0 (left) 0 (top) / 1 (right) 1 (bottom)
uniform float uProgress;
uniform float uEnter;
uniform float uEnter2;

uniform vec4 uCorners;

varying vec2 vUv; // 0 (left) 0 (bottom) - 1 (right) 1 (top)
varying vec2 vUvCover;
varying vec2 correctedUv;
varying float distanceFromCenterFrag;

varying float area;
varying vec2 vSize;

#define PI 3.14159265359

#define NUM_OCTAVES 8

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

vec4 smoothDistortionEffect(sampler2D tex, sampler2D dispMap, vec2 uv, int numBlinds, float distortionAmount, bool vertical, float time, float blurAmount) {
    float blindSize = vertical ? (1.0 / float(numBlinds)) : (1.0 / float(numBlinds));
    float coord = vertical ? uv.x : uv.y;
    float blindIndex = floor(coord / blindSize) ;

    vec2 mousePos = vec2(uMouseOverPos.x, 1.0 - uMouseOverPos.y); // Assuming normalized mouse position
    vec2 mouseDist = mousePos - uv;
    float distance = length(mouseDist);
    float maxDist = 0.01;
    float displacement = smoothstep(maxDist + fbm(uv * 15.0 + uTime) * uEnter, 0.0, distance) * 0.3;

    float dispImage = texture2D(dispMap, uv).r * .8;
    
    displacement *= dispImage * 5.0;

    // Calculate the proximity to the edge of the blind
    float edgeProximity = mod(coord, blindSize) / blindSize;
    float edgeDistortion = smoothstep(0.0, 0.1, edgeProximity) * smoothstep(1.0, 0.9, edgeProximity);

    // Apply increased distortion near the edges
    float distortion = (sin(blindIndex + time + displacement * 15.0) + edgeDistortion * .5) * distortionAmount;

    vec2 distortedUV = uv;
    if (vertical) {
        distortedUV.x += distortion ;
    } else {
        distortedUV.y += distortion;
    }

    vec4 color = vec4(0.0);
    float totalWeight = 0.0;
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = vec2(float(i), float(j)) * blurAmount;
            vec2 sampleUV = distortedUV + offset / uResolution.xy;
            float weight = exp(-dot(offset, offset) / (2.0 * blurAmount * blurAmount));
            color += texture2D(tex, sampleUV) * weight;
            totalWeight += weight;
        }
    }
    color /= totalWeight;

    // Optionally, add a color emphasis on the edges
    // vec3 edgeColor = vec3(0.24); // Red color emphasis
    // color.rgb = mix(color.rgb, edgeColor, edgeDistortion * 0.2);

    return color;
}

vec2 roundedCorners(vec2 uv, float radius) {
    vec2 center = vec2(0.5);
    vec2 delta = uv - center;
    float dist = length(delta);
    float alpha = smoothstep(radius - 0.01, radius + 0.01, dist);
    return mix(uv, center, alpha);
}

void main() {

  int numBlinds = 15;
  float distortionAmount = 0.04 * uEnter2;
  bool vertical = true;
  float blurAmount = 0.1 + 2. * uEnter;



  vec4 finalColor = smoothDistortionEffect(uTexture, uDisplacement, vUv, numBlinds, distortionAmount, vertical, uTime, blurAmount);


  vec4 color = texture2D(uTexture, vUv);
  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  gl_FragColor = color;
  gl_FragColor = finalColor;

}
