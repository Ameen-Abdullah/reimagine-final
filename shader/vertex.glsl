uniform float scrollVelocity;
uniform float time;
uniform float hover;

uniform vec2 uMouseCords;
uniform vec2 uResolution;
uniform vec4 uCorners;

varying vec2 vUv;

float PI = 3.1415926535897932384626433832795;
vec3 deformationCurve(vec3 position, vec2 uv) {
    position.x = position.x - (sin(uv.y * PI) * min(abs(scrollVelocity * 1.), 5.0) * sign(scrollVelocity * 1.) * 0.01);

    return position;
}



void main() {

    vUv = uv;

    vec3 pos = position;
    vec3 deformed = deformationCurve(pos, vUv);

    deformed.xy *= 1. + .2 * hover;
    float distanceToCenter = distance(vUv, vec2(uMouseCords));

    vec4 normalState = modelMatrix * vec4(pos, 1.0);

    vec4 fulScreenState = vec4(deformed, 1.0);

    fulScreenState.x *= uResolution.x/100.;
    fulScreenState.y *= uResolution.y/100.;
    fulScreenState.z += uCorners.z * 20.;

    float corners = mix(mix(uCorners.x, uCorners.y, vUv.x), mix(uCorners.z, uCorners.w, vUv.x), vUv.y);

    vec4 finalState = mix(normalState, fulScreenState, corners);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(deformed, 1.0);
    gl_Position = projectionMatrix *viewMatrix  * modelMatrix * vec4(deformed, 1.0);


}