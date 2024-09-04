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
vec2 accel = vec2(0.01);
// https://github.com/transitive-bullshit/react-fluid-gallery/blob/master/src/frag.js    

vec2 mirror(vec2 v) {
    // The progress is added to vector making it 0 to 2
    // Se we mod by 2
  vec2 m = mod(v, 2.0);
    // Not sure about this one
  return mix(m, 2.0 - m, step(1.0, m));
}

float tri(float p) {
  return mix(p, 1.0 - p, step(.5, p)) * 2.0;
}

vec3 zoomBlur(vec2 uv, sampler2D texture3, vec2 center, float strength) {
    vec3 color = vec3(0.0);
    for (float i = 0.0; i < 1.0; i += 0.1) {
        vec2 blurUV = mix(uv, center, i * strength);
        color += texture2D(texture3, blurUV).rgb;
    }
    color /= 10.0;
    return color;
}





void main() {
  vec2 texCoords = correctedUv;
  vec2 vUv1 = correctedUv;




  // aspect ratio needed to create a real circle when quadSize is not 1:1 ratio
  float aspectRatio = uQuadSize.y / uQuadSize.x;

  // create a circle following the mouse with size 15
  float circle = 1.0 - distance(vec2(uMouseOverPos.x, (1.0 - uMouseOverPos.y) * aspectRatio), vec2(vUv.x, vUv.y * aspectRatio)) * 15.0;

  vec4 video1 = texture2D(uVideo, texCoords);

  float p = pow(min(cos(PI * (mod(uEnter  , 2.) - 1.) / 2.), 1. - abs(mod(uEnter , 2.) - 1.)), 1.);

  float delayValue = p * 7. - texCoords.y * 2. + texCoords.x - 2.0;
  delayValue = clamp(delayValue, 0., 1.);

  vec2 acc = vec2(0.5, 2.);

  vec2 translateValue = p + delayValue * acc;
  vec2 translateValue1 = vec2(-0.5, 1.) * translateValue; // Flipped the y direction
  vec2 translateValue2 = vec2(-0.5, 1.) * (translateValue - 1.0 - acc); // Flipped the y direction

  vec2 w = sin(sin(uTime) * vec2(0, 0.3) + texCoords * vec2(0, 4.)) * vec2(0, 0.5);
  vec2 xy = w * (tri(p) * 0.5 + tri(delayValue) * 0.5);

  vec2 uv1 = vUv1 + translateValue1 + xy;
  vec2 uv2 = vUv1 + translateValue2 + xy;
  vec4 t0 = texture(uTexture, mirror(uv1), 0.);
  vec4 t1 = texture(uVideo, mirror(uv2), 0.);
  vec4 blurT0 = vec4(zoomBlur(mirror(uv1), uTexture, vec2(uMouseOverPos.x , 1. - uMouseOverPos.y), .05  ), 1.0);
  vec4 blurT1 = vec4(zoomBlur(mirror(uv2), uVideo, vec2(uMouseOverPos.x , 1. - uMouseOverPos.y), uCorners.x == 1. ? .05 : .0 ), 1.0);

  // output
  // gl_FragColor = color;
  gl_FragColor.rgb += circle / 20.;
  gl_FragColor = video1;
  // gl_FragColor = vec4(area2, 0.0, 0.0, 1.0)  ;
   // gl_FragColor = mix(image, video1, smoothArea);
  gl_FragColor = mix(t0, t1 + (distanceFromCenterFrag * .002), delayValue);
  gl_FragColor = vec4(distanceFromCenterFrag, 0.0, 0.0, 1.0);
  gl_FragColor = mix(blurT0 , t1  , delayValue);


}
