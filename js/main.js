import SplitType from 'split-type'
import gsap from 'gsap';

function select(elem) {
    return document.querySelector(elem);
}
function selectAll(elem) {
    return document.querySelectorAll(elem);
}


const text = new SplitType('.content-overlay .row h1')

gsap.set(text.lines, { overflow: 'hidden' })
gsap.set(text.chars, { yPercent: 100, })
gsap.set('.content-overlay .row p', { opacity: 0 })



console.log(Math.random() * 100)

let img = selectAll('[data-webgl-media]')

img.forEach((el, i) => {

    el.addEventListener('click', () => {
        gsap.to(text.chars, { duration: .7, yPercent: 0, stagger: 0.05, delay: .2, ease: "circ" })
        gsap.to('.content-overlay .row p', { opacity: 1 })

    })
    el.addEventListener('mouseleave', () => {
        text.chars.forEach((el, i) => {
            gsap.to(el, { duration: .5, yPercent: 100, ease: "circ", delay: Math.random() * .5 })
            gsap.to('.content-overlay .row p', { opacity: 0 })

        })
    })
});

