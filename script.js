// ── Galerie ──
const images = document.querySelectorAll('.gallery-img');
let currentIndex = 0;

setInterval(() => {
    images[currentIndex].classList.remove('active');
    currentIndex = (currentIndex + 1) % images.length;
    images[currentIndex].classList.add('active');
}, 5000);

// ── Menu – přepínání sekcí ──
const menuItems = document.querySelectorAll('.menu-item');
const sections  = document.querySelectorAll('.info-section');

menuItems.forEach(item => {
    item.addEventListener('click', e => {
        e.preventDefault();
        const target = item.getAttribute('href').substring(1); // např. "uvod"

        // Zvýraznění aktivní položky
        menuItems.forEach(i => i.classList.remove('active'));
        item.classList.add('active');

        // Zobrazení příslušné sekce
        sections.forEach(section => {
            section.classList.toggle('hidden', section.id !== target);
        });
    });
});
