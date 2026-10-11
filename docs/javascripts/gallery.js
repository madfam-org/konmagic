// Progressive enhancement: screenshots remain visible without JavaScript.
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('img[src*="assets/screenshots/"]').forEach(img => {
    const button = document.createElement('button');
    button.type = 'button'; button.style.cssText = 'border:0;background:transparent;padding:0;display:block;width:100%;cursor:zoom-in';
    button.setAttribute('aria-label', 'Enlarge screenshot: ' + img.alt);
    button.className = 'screenshot-enlarge';
    img.before(button); button.append(img);
    button.addEventListener('click', () => {
      const dialog = document.createElement('dialog'); dialog.className = 'screenshot-dialog';
      const close = document.createElement('button'); close.textContent = 'Close · Esc';
      const copy = img.cloneNode(); dialog.append(close, copy); document.body.append(dialog);
      close.addEventListener('click', () => dialog.close());
      dialog.addEventListener('click', e => { if (e.target === dialog) dialog.close(); });
      dialog.addEventListener('close', () => { dialog.remove(); button.focus(); });
      dialog.showModal(); close.focus();
    });
  });
});
