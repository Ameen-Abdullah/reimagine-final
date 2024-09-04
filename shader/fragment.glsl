uniform float scrollVelocity;
uniform float time;
uniform float hover;

uniform sampler2D uTexture;
uniform sampler2D uDisplacement;
uniform sampler2D uDisplacement2;
uniform vec2 uMouseCords;
uniform vec2 uResolution;

varying vec2 vUv;

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

float smoothCircle(vec2 center, float radius, float smoothness) {
    float aspectRatio = .4 / .6;
    vec2 scaledUV = vUv * vec2(1.0, aspectRatio);
    vec2 scaledCenter = center * vec2(1.0, aspectRatio);
    float dist = length(scaledUV - scaledCenter);
    float edge = radius - smoothness;
    float blend = smoothstep(edge, radius, dist);
    return blend;
}

vec2 zoom(vec2 uv, float amount) {
  return 0.5 + ((uv - 0.5) * (1.0 - amount));
}

void main() {
    vec2 copy = vUv;
    // float wave = fbm(copy * 5. + time / 2.) * scrollVelocity;

    // copy -= .5;
    // copy *= 1. + wave * .15;
    // copy += .5;

    // if(copy.x < 0. || copy.x > 1. || copy.y < 0. || copy.y > 1.)
    //     discard;

    vec2 mousePos = vec2(uMouseCords.x, uMouseCords.y); // Assuming normalized mouse position
    vec2 mouseDist = mousePos - vUv;
    float distance = length(mouseDist);
    float maxDist = 0.01;
    float displacementEffect = smoothstep(maxDist + fbm(vUv * 15.0 + time), 0.0, distance) * .3;

    float dispImage = texture2D(uDisplacement, vUv).r;
    displacementEffect *= dispImage * 2.0 * hover;


    vec4 image = texture2D(uTexture, vUv);
    vec4 displacement = texture2D(uDisplacement, vUv);
    vec4 displacement2 = texture2D(uDisplacement2, vUv);


    vec2 displacementOffset = vec2(displacement.r - 0.5, displacement.g - 0.6) * 0.05 * scrollVelocity;
    vec2 displacedUV = zoom(vUv, 0.12 * hover) + displacementOffset;
    displacedUV.x += displacementEffect;

    vec4 displacedImage = texture2D(uTexture, displacedUV);



    float chromaticAberrationAmount = 0.005;
    vec2 redOffset = vec2(chromaticAberrationAmount, 0.0);
    vec2 greenOffset = vec2(0.0, chromaticAberrationAmount);
    vec2 blueOffset = vec2(-chromaticAberrationAmount, 0.0);

    vec4 redChannel = texture2D(uTexture, displacedUV + redOffset);
    vec4 greenChannel = texture2D(uTexture, displacedUV + greenOffset);
    vec4 blueChannel = texture2D(uTexture, displacedUV + blueOffset);

    vec3 rgbImage = vec3(redChannel.r, greenChannel.g, blueChannel.b);
    vec3 grayscaleImage = vec3(dot(rgbImage, vec3(0.299, 0.587, 0.114)));

    vec3 finalImage = mix(grayscaleImage, rgbImage, hover);

    // vec3 rgbImage = vec3(redChannel.r, greenChannel.g, blueChannel.b);

    // vec3 finalImage = mix(grayscaleImage, rgbImage, hover);

    gl_FragColor = image;
    gl_FragColor = displacedImage;
    gl_FragColor = vec4(displacement2.r, displacement2.g, displacement2.b, 1.0);
    gl_FragColor = vec4(hover, 0.0, 0.0, 1.0);
    gl_FragColor = vec4(redChannel.r, greenChannel.g, blueChannel.b, 1.0);
    gl_FragColor = vec4(finalImage, .5 + (hover /2. - .2));

    // gl_FragColor = vec4(circle, 0., 0., 1.0);

}