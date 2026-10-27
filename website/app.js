(() => {
  const root = document.documentElement;
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const navToggle = document.querySelector('.nav-toggle');
  const siteNav = document.querySelector('#site-nav');

  if (navToggle && siteNav) {
    const closeMenu = () => {
      navToggle.setAttribute('aria-expanded', 'false');
      navToggle.setAttribute('aria-label', 'Abrir menú');
      siteNav.classList.remove('is-open');
    };

    navToggle.addEventListener('click', () => {
      const open = navToggle.getAttribute('aria-expanded') !== 'true';
      navToggle.setAttribute('aria-expanded', String(open));
      navToggle.setAttribute('aria-label', open ? 'Cerrar menú' : 'Abrir menú');
      siteNav.classList.toggle('is-open', open);
    });

    siteNav.querySelectorAll('a').forEach((link) => link.addEventListener('click', closeMenu));
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && navToggle.getAttribute('aria-expanded') === 'true') {
        closeMenu();
        navToggle.focus();
      }
    });
  }

  const copyStatus = document.querySelector('#copy-status');
  const code = document.querySelector('#loader-code');
  const copyButtons = document.querySelectorAll('[data-copy-loader]');
  let copyTimer;

  const fallbackCopy = (text) => {
    const field = document.createElement('textarea');
    field.value = text;
    field.setAttribute('readonly', '');
    field.style.position = 'fixed';
    field.style.opacity = '0';
    field.style.pointerEvents = 'none';
    document.body.appendChild(field);
    field.select();
    field.setSelectionRange(0, field.value.length);
    let copied = false;
    try { copied = document.execCommand('copy'); } catch { copied = false; }
    field.remove();
    return copied;
  };

  if (code && copyButtons.length) {
    copyButtons.forEach((button) => {
      button.addEventListener('click', async () => {
        const text = code.textContent.trim();
        let copied = false;
        try {
          if (navigator.clipboard && window.isSecureContext) {
            await navigator.clipboard.writeText(text);
            copied = true;
          } else {
            copied = fallbackCopy(text);
          }
        } catch {
          copied = fallbackCopy(text);
        }

        button.classList.toggle('is-copied', copied);
        const label = button.querySelector('[data-copy-label]');
        if (label) label.textContent = copied ? 'Copiado' : 'No se pudo copiar';
        copyButtons.forEach((other) => { other.disabled = copied; });
        if (copyStatus) {
          copyStatus.textContent = copied
            ? 'Listo. Ya puedes pegar el loader.'
            : 'No se copió automáticamente. Selecciona el código para copiarlo.';
        }
        window.clearTimeout(copyTimer);
        copyTimer = window.setTimeout(() => {
          copyButtons.forEach((other) => {
            other.disabled = false;
            other.classList.remove('is-copied');
            const otherLabel = other.querySelector('[data-copy-label]');
            if (otherLabel) otherLabel.textContent = 'Copiar loader';
          });
          if (copyStatus) copyStatus.textContent = '';
        }, 3000);
      });
    });
  }

  if (!reduceMotion && 'IntersectionObserver' in window) {
    root.classList.add('has-reveal');
    const observer = new IntersectionObserver((entries, currentObserver) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          currentObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.14, rootMargin: '0px 0px -36px 0px' });
    document.querySelectorAll('.reveal').forEach((element, index) => {
      element.style.setProperty('--reveal-delay', `${Math.min(index % 4, 3) * 85}ms`);
      observer.observe(element);
    });
  }

  const progress = document.querySelector('.scroll-progress > span');
  const header = document.querySelector('.site-header');
  let scrollFrame = false;
  const updateScroll = () => {
    const scrollable = document.documentElement.scrollHeight - window.innerHeight;
    const amount = scrollable > 0 ? window.scrollY / scrollable : 0;
    if (progress) progress.style.transform = `scaleX(${Math.min(1, Math.max(0, amount))})`;
    if (header) header.classList.toggle('is-scrolled', window.scrollY > 16);
    scrollFrame = false;
  };
  window.addEventListener('scroll', () => {
    if (!scrollFrame) {
      window.requestAnimationFrame(updateScroll);
      scrollFrame = true;
    }
  }, { passive: true });
  updateScroll();

  const hero = document.querySelector('.hero');
  const tilt = document.querySelector('[data-tilt]');
  const pointerMotion = window.matchMedia('(pointer: fine) and (prefers-reduced-motion: no-preference)').matches;
  if (hero && tilt && pointerMotion) {
    let pointerFrame = false;
    hero.addEventListener('pointermove', (event) => {
      if (pointerFrame) return;
      pointerFrame = true;
      window.requestAnimationFrame(() => {
        const bounds = hero.getBoundingClientRect();
        const x = (event.clientX - bounds.left) / bounds.width;
        const y = (event.clientY - bounds.top) / bounds.height;
        hero.style.setProperty('--pointer-x', `${Math.round(x * 100)}%`);
        hero.style.setProperty('--pointer-y', `${Math.round(y * 100)}%`);
        tilt.style.setProperty('--tilt-x', `${(0.5 - y) * 3}deg`);
        tilt.style.setProperty('--tilt-y', `${(x - 0.5) * 4}deg`);
        pointerFrame = false;
      });
    }, { passive: true });
    hero.addEventListener('pointerleave', () => {
      hero.style.setProperty('--pointer-x', '50%');
      hero.style.setProperty('--pointer-y', '42%');
      tilt.style.setProperty('--tilt-x', '0deg');
      tilt.style.setProperty('--tilt-y', '0deg');
    });
  }

  const year = document.querySelector('[data-current-year]');
  if (year) year.textContent = String(new Date().getFullYear());
})();
