// ── Galerie ──
const images = document.querySelectorAll('.gallery-img');
let currentIndex = 0;

setInterval(() => {
    images[currentIndex].classList.remove('active');
    currentIndex = (currentIndex + 1) % images.length;
    images[currentIndex].classList.add('active');
}, 5000);

// ── Fotogalerie ──
const fotogalGrid      = document.getElementById('fotogal-grid');
const lightbox         = document.getElementById('lightbox');
const lightboxImgWrap  = lightbox.querySelector('.lightbox-img-wrap');
const lightboxImg      = document.getElementById('lightbox-img');
const lightboxBackdrop = document.getElementById('lightbox-backdrop');
const lightboxPrev     = document.getElementById('lightbox-prev');
const lightboxNext     = document.getElementById('lightbox-next');
const lightboxClose    = document.getElementById('lightbox-close');

let lightboxOpenTimer  = null;
let currentDir         = '';
let currentFiles       = [];
let currentLightboxIdx = 0;

function openLightbox(idx) {
    currentLightboxIdx = idx;
    lightboxImg.src = `${currentDir}/${currentFiles[idx]}`;
    lightbox.classList.add('open');
}

function closeLightbox() {
    lightbox.classList.remove('open');
    clearTimeout(lightboxOpenTimer);
    lightboxOpenTimer = null;
}

function renderGallery(files) {
    currentFiles = files;
    fotogalGrid.innerHTML = '';
    if (!files.length) {
        fotogalGrid.innerHTML = '<p class="fotogal-loading">Žádné fotografie.</p>';
        return;
    }
    files.forEach((file, idx) => {
        const img = document.createElement('img');
        img.src       = `${currentDir}/${file}`;
        img.alt       = file;
        img.className = 'fotogal-thumb';

        img.addEventListener('mouseenter', () => {
            clearTimeout(lightboxOpenTimer);
            lightboxOpenTimer = setTimeout(() => openLightbox(idx), 1000);
        });
        img.addEventListener('mouseleave', () => {
            clearTimeout(lightboxOpenTimer);
            lightboxOpenTimer = null;
        });

        fotogalGrid.appendChild(img);
    });
}

function loadGallery(dir) {
    currentDir = dir;
    fotogalGrid.innerHTML = '<p class="fotogal-loading">Načítám fotografie…</p>';

    // Přes server: dynamické skenování adresáře
    fetch(`/api/list?path=${encodeURIComponent(dir)}`)
        .then(r => { if (!r.ok) throw new Error(); return r.json(); })
        .then(files => renderGallery(files))
        .catch(() => {
            // Záloha pro file:// – statický gallery-data.js
            renderGallery(GALLERY_DATA[dir] || []);
        });
}

// Zavření: opuštění obalu fotky (šipky a křížek jsou uvnitř – nepřerušují)
lightboxImgWrap.addEventListener('mouseleave', () => closeLightbox());

// Šipky
lightboxPrev.addEventListener('click', e => {
    e.stopPropagation();
    openLightbox((currentLightboxIdx - 1 + currentFiles.length) % currentFiles.length);
});
lightboxNext.addEventListener('click', e => {
    e.stopPropagation();
    openLightbox((currentLightboxIdx + 1) % currentFiles.length);
});

// Křížek a klik na backdrop
lightboxClose.addEventListener('click',    e => { e.stopPropagation(); closeLightbox(); });
lightboxBackdrop.addEventListener('click', () => closeLightbox());

// Klávesnice
document.addEventListener('keydown', e => {
    if (!lightbox.classList.contains('open')) return;
    if (e.key === 'ArrowLeft')  lightboxPrev.click();
    if (e.key === 'ArrowRight') lightboxNext.click();
    if (e.key === 'Escape')     closeLightbox();
});

// Klik na položku vertikálního menu galerie
document.addEventListener('click', e => {
    const navItem = e.target.closest('.fotogal-nav-item');
    if (!navItem) return;
    document.querySelectorAll('.fotogal-nav-item').forEach(i => i.classList.remove('active'));
    navItem.classList.add('active');
    loadGallery(navItem.dataset.dir);
});

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

        // Při přepnutí na Fotogalerie načti první kategorii
        if (target === 'fotogalerie') {
            const firstNav = document.querySelector('.fotogal-nav-item');
            if (firstNav) loadGallery(firstNav.dataset.dir);
        }
    });
});
