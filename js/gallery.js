import * as THREE from 'three';
import gsap from 'gsap';
import vertex from '../shader/vertex.glsl';
import fragment from '../shader/fragment.glsl';
import { OrbitControls } from 'three/examples/jsm/Addons.js';
import Lenis from 'lenis'
// import disp from '/gallery/ice.jpg'
import disp from '../assets/images/normalWave2.jpg'

import disp2 from '../assets/images/swirl.webp'
import { GLTFLoader } from 'three/examples/jsm/Addons.js';


// import VirtualScroll from 'virtual-scroll'



function getRadian(degrees) {
  return degrees * Math.PI / 180;
}

function isEven(num) {
  return num % 2 == 0;
}

function planeCurve(g, z) {

  let p = g.parameters;
  let hw = p.width * 0.5;

  let a = new THREE.Vector2(-hw, 0);
  let b = new THREE.Vector2(0, z);
  let c = new THREE.Vector2(hw, 0);

  let ab = new THREE.Vector2().subVectors(a, b);
  let bc = new THREE.Vector2().subVectors(b, c);
  let ac = new THREE.Vector2().subVectors(a, c);

  let r = (ab.length() * bc.length() * ac.length()) / (2 * Math.abs(ab.cross(ac)));

  let center = new THREE.Vector2(0, z - r);
  let baseV = new THREE.Vector2().subVectors(a, center);
  let baseAngle = baseV.angle() - (Math.PI * 0.5);
  let arc = baseAngle * 2;

  let uv = g.attributes.uv;
  let pos = g.attributes.position;
  let mainV = new THREE.Vector2();
  for (let i = 0; i < uv.count; i++) {
    let uvRatio = 1 - uv.getX(i);
    let y = pos.getY(i);
    mainV.copy(c).rotateAround(center, (arc * uvRatio));
    pos.setXYZ(i, mainV.x, y, -mainV.y);
  }

  pos.needsUpdate = true;

}


let scroll = {
  scrollY: window.scrollY,
  scrollVelocity: 0,
  isScrolling: false
}




const lenis = new Lenis({
  lerp: 0.05,
  passive: true,
  mouseMultiplier: 0.6,
  touchMultiplier: 1.5,
  firefoxMultiplier: 30,
  smooth: true
})
lenis.on('scroll', (e) => {

  scroll.scrollY = window.scrollY
  scroll.scrollVelocity = e.velocity
  // material.uniforms.scroll.value = scroll.scrollY
  // material.uniforms.scrollVelocity.value = scroll.scrollVelocity;
  images.forEach((mesh) => {
    mesh.material.uniforms.scroll.value = scroll.scrollY
    mesh.material.uniforms.scrollVelocity.value = scroll.scrollVelocity
  })


  scroll.isScrolling = e.isScrolling ? true : false;

})


function raf(time) {
  lenis.raf(time)
  requestAnimationFrame(raf)
}

requestAnimationFrame(raf)

// // 1. Initialize Virtual Scroll
// const scroller = new VirtualScroll({
//   mouseMultiplier: 0.6,  // Adjust the scroll speed multiplier
//   touchMultiplier: 1.5,  // Adjust touch scroll speed
//   firefoxMultiplier: 30, // Adjust Firefox scroll speed
//   keyStep: 120,          // Amount of pixels to move on key press
//   passive: true          // Improves performance by not preventing default scroll
// });

// // 2. Create variables to track the scroll position
// let currentScroll = 0;
// let targetScroll = 0;
// const ease = 0.07;


// // 3. Update target scroll position based on scroll events
// scroller.on((event) => {
//   targetScroll += event.deltaY;
// });

// 4. Smooth scrolling function
function smoothScroll() {
  currentScroll += (targetScroll - currentScroll) * ease;

  // console.log(currentScroll)
  scroll.scrollY = currentScroll;
  material.uniforms.scroll.value = scroll.scrollY

  // Calculate scroll velocity
  const deltaTime = 26; // Assuming a constant frame rate of 60fps
  const velocity = (targetScroll - currentScroll) / deltaTime; // Pixels per millisecond
  // console.log('Scroll Velocity:', velocity.toFixed(2));

  material.uniforms.scrollVelocity.value = velocity;


  group.rotation.y = scroll.scrollY * 0.004;




  requestAnimationFrame(smoothScroll);

}

// 5. Start the smooth scrolling loop
// smoothScroll();


let scene, camera, renderer, width, height, controls;

//geometry

let geometry;

//meshes

let mesh;

//materials
let material;

let INTERSECTED;

width = window.innerWidth;
height = window.innerHeight;

// init

camera = new THREE.PerspectiveCamera(70, width / height, .0001, 1000);
camera.position.z = 2;
camera.layers.enable(1);
scene = new THREE.Scene();


document.addEventListener('mousemove', onDocumentMouseMove);

function onDocumentMouseMove(event) {
  const mouseX = (event.clientX / window.innerWidth) * 2 - 1;
  const mouseY = -(event.clientY / window.innerHeight) * 2 + 1;

  camera.position.x += (mouseX - camera.position.x) * 0.01;
  camera.position.y += (mouseY - camera.position.y) * 0.01;
  camera.lookAt(scene.position);
}


function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}


let params = {
  bendDepth: .07
}


//raycaster for mouseenter and leave
const raycaster = new THREE.Raycaster();
let pointer = new THREE.Vector2();
let mouse = new THREE.Vector2();

raycaster.layers.set(0);


function onPointerMove(event) {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = - (event.clientY / window.innerHeight) * 2 + 1;
}
const canvas = document.querySelector('.webgl2');
renderer = new THREE.WebGLRenderer({ antialias: true ,canvas});
renderer.setSize(width, height);
renderer.setAnimationLoop(animate);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));


// controls = new OrbitControls(camera, renderer.domElement);
// controls.enableDamping = true;
// controls.enable = false;

window.addEventListener('resize', () => {
  width = window.innerWidth;
  height = window.innerHeight;
  renderer.setSize(width, height);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
}
)

//obejcts

geometry = new THREE.PlaneGeometry(.6, .4, 10, 10);
planeCurve(geometry, params.bendDepth);

let group = new THREE.Group();
scene.add(group);
group.position.y = -3;



let grp1 = new THREE.Group();
let grp2 = new THREE.Group();


const images = [];
const images_num = 6;

const initImages = function (scene) {
  for (let j = 0; j < 6; j++) {
    for (let i = 0; i < images_num; i++) {
      const rad = (i / images_num) * 2 * Math.PI + j; // radians
      const radius = isEven(j) ? 1.25 : 1.15;
      const x = Math.cos(rad) * radius;
      const z = Math.sin(rad) * radius;
      const y = j * .8;

      const position = new THREE.Vector3(x, y, z);

      material = new THREE.ShaderMaterial({
        vertexShader: vertex,
        fragmentShader: fragment,
        // wireframe: true,
        side: THREE.DoubleSide,
        // opacity: .4,
        transparent: true,
        uniforms: {
          time: { value: 0 },
          scroll: { value: 0 },
          scrollVelocity: { value: 0 },
          hover: { value: 0 },
          uResolution: { value: new THREE.Vector2(width, height) },
          uCorners: { value: new THREE.Vector4(0, 0, 0, 0) },
          uTexture: { value: new THREE.TextureLoader().load(`../assets/images/image0${(i % 6) + 1}.jpg`) },
          uDisplacement: { value: new THREE.TextureLoader().load(disp) },
          uDisplacement2: { value: new THREE.TextureLoader().load(disp2) },
          uMouseCords: { value: new THREE.Vector2() },
        }
      });

      const mesh = new THREE.Mesh(geometry, material);
      mesh.position.copy(position);
      mesh.lookAt(new THREE.Vector3(0, y, 0));

      lenis.on('scroll', () => {
        if (Math.abs(scroll.scrollVelocity) > .3) {
          group.rotation.y = scroll.scrollY * 0.002 * 4;
          // grp2.rotation.y = scroll.scrollY * 0.003 * 2;
      
          group.position.y = -3 + scroll.scrollY * 0.0008;
        }
      })

      if (isEven(j)) {
        grp1.add(mesh);
      } else {
        grp2.add(mesh);
      }

      group.add(grp1, grp2);

      images.push(mesh);
    }
  }
};


initImages(group);

//models 

const loader = new GLTFLoader();
loader.load('../assets/ashfall.glb', function (gltf) {
  gltf.scene.scale.set(0.3, 0.3, 0.3);
  gltf.scene.position.y = 0;

  gltf.scene.children[0].children[0].layers.set(1)
  gltf.scene.children[0].children[1].layers.set(1)
  scene.add(gltf.scene);

  gltf.scene.children[0].children[0].material = new THREE.MeshBasicMaterial({ color: "grey", wireframe: true });
  gltf.scene.children[0].children[1].material = new THREE.MeshBasicMaterial({ color: "grey", wireframe: true });

  let ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
  scene.add(ambientLight);


  lenis.on('scroll', (e) => {
    gltf.scene.rotation.y = scroll.scrollY * 0.002;

  })

})


renderer.setClearColor("#212121")


function animate(time) {


  // controls.update();
  grp1.rotation.y += 0.001 /2;
  grp2.rotation.y -= 0.001 /2;


  images.forEach((mesh) => {
    mesh.material.uniforms.time.value = time / 1000
  })

  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(scene.children);
  if (intersects.length > 0) {

    gsap.to(intersects[0].object.material.uniforms.uMouseCords.value, {
      x: intersects[0].uv.x,
      y: intersects[0].uv.y,
      duration: 1,
      delay: .01,
      ease: "power4",
    })

    if (INTERSECTED != intersects[0].object) {
      if (INTERSECTED) {
        gsap.to(INTERSECTED.material.uniforms.hover, { value: 0, duration: 0.3, ease: "circ" });
      }
      INTERSECTED = intersects[0].object;
      gsap.to(INTERSECTED.material.uniforms.hover, { value: 1, duration: 0.3, ease: "circ" });
    }
  } else {
    if (INTERSECTED) {
      gsap.to(INTERSECTED.material.uniforms.hover, { value: 0, duration: 0.3, ease: "circ" });

      INTERSECTED = null;
    }
  }



  renderer.render(scene, camera);

}

window.addEventListener('pointermove', onPointerMove);