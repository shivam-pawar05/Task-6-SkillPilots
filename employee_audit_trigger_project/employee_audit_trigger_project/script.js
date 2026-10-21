// Small progressive-enhancement effects for the project overview page.
document.querySelectorAll('.panel, .stat-card').forEach((item, index) => {
  item.classList.add('reveal');
  item.style.animationDelay = `${Math.min(index * 70, 350)}ms`;
});

document.querySelector('.primary-link')?.addEventListener('click', () => {
  const workflow = document.querySelector('#workflow');
  workflow?.classList.add('highlighted');
  window.setTimeout(() => workflow?.classList.remove('highlighted'), 900);
});
