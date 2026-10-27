(() => {
  const navToggle = document.querySelector('.nav-toggle');
  const siteNav = document.querySelector('#site-nav');

  if (navToggle && siteNav) {
    navToggle.addEventListener('click', () => {
      const expanded = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', String(!expanded));
      navToggle.setAttribute('aria-label', expanded ? 'Abrir navegación' : 'Cerrar navegación');
      siteNav.classList.toggle('is-open', !expanded);
    });

    siteNav.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => {
        navToggle.setAttribute('aria-expanded', 'false');
        navToggle.setAttribute('aria-label', 'Abrir navegación');
        siteNav.classList.remove('is-open');
      });
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && navToggle.getAttribute('aria-expanded') === 'true') {
        navToggle.setAttribute('aria-expanded', 'false');
        navToggle.setAttribute('aria-label', 'Abrir navegación');
        siteNav.classList.remove('is-open');
        navToggle.focus();
      }
    });
  }

  const copyButton = document.querySelector('[data-copy-loader]');
  const loaderCode = document.querySelector('#loader-code');
  const copyStatus = document.querySelector('#copy-status');
  let statusTimer;

  const fallbackCopy = (text) => {
    const field = document.createElement('textarea');
    field.value = text;
    field.setAttribute('readonly', '');
    field.style.position = 'fixed';
    field.style.left = '-9999px';
    field.style.top = '0';
    document.body.appendChild(field);
    field.select();
    field.setSelectionRange(0, field.value.length);
    let copied = false;
    try {
      copied = document.execCommand('copy');
    } catch {
      copied = false;
    }
    field.remove();
    return copied;
  };

  if (copyButton && loaderCode && copyStatus) {
    copyButton.addEventListener('click', async () => {
      const text = loaderCode.textContent.trim();
      copyButton.disabled = true;
      copyStatus.textContent = '';
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
      } finally {
        copyButton.disabled = false;
      }

      copyButton.classList.toggle('is-copied', copied);
      const label = copyButton.querySelector('span');
      if (label) label.textContent = copied ? '¡Copiado!' : 'Selecciona el código';
      copyStatus.textContent = copied
        ? 'Loader copiado. Pégalo en tu entorno compatible para ejecutarlo.'
        : 'No se pudo copiar automáticamente. Selecciona y copia el código de arriba.';
      window.clearTimeout(statusTimer);
      statusTimer = window.setTimeout(() => {
        copyButton.classList.remove('is-copied');
        if (label) label.textContent = 'Copiar loader';
        copyStatus.textContent = '';
      }, 4500);
    });
  }

  const year = document.querySelector('[data-current-year]');
  if (year) year.textContent = String(new Date().getFullYear());
})();
