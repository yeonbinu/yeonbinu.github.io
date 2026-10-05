// 헤더: 스크롤하면 아래 구분선 표시
const header = document.querySelector('.site-header');
const onScroll = () => header?.classList.toggle('is-scrolled', window.scrollY > 8);
window.addEventListener('scroll', onScroll, { passive: true });
onScroll();

// 스크롤하면 요소가 부드럽게 나타남
// 처음 화면에 보이는 요소는 그대로 두고, 아래쪽 요소만 숨겼다가 보여줌
const io = new IntersectionObserver((entries) => {
  entries.forEach((e) => {
    if (e.isIntersecting) {
      e.target.classList.remove('is-pending');
      io.unobserve(e.target);
    }
  });
}, { rootMargin: '0px 0px -8% 0px' });
document.querySelectorAll('.reveal').forEach((el) => {
  if (el.getBoundingClientRect().top > window.innerHeight) {
    el.classList.add('is-pending');
    io.observe(el);
  }
});

// 이메일 복사 버튼
document.querySelectorAll('[data-copy]').forEach((btn) => {
  btn.addEventListener('click', async () => {
    const text = btn.dataset.copy;
    try {
      await navigator.clipboard.writeText(text);
      btn.textContent = '복사됨';
    } catch {
      // 복사가 막힌 환경에서는 주소를 선택해 직접 복사할 수 있게 함
      const target = document.querySelector(btn.dataset.copyTarget);
      if (target) window.getSelection().selectAllChildren(target);
      btn.textContent = '선택됨 — ⌘C로 복사';
    }
    setTimeout(() => { btn.textContent = '이메일 복사'; }, 2000);
  });
});

// 라이트박스: [data-full] 버튼을 누르면 큰 이미지로 보기
// 같은 [data-gallery] 안의 이미지끼리 좌우로 넘길 수 있음
const box = document.createElement('div');
box.className = 'lightbox';
box.setAttribute('role', 'dialog');
box.setAttribute('aria-modal', 'true');
box.innerHTML = `
  <div class="lightbox-ui">
    <span class="count"></span>
    <button type="button" data-act="prev" aria-label="이전">←</button>
    <button type="button" data-act="next" aria-label="다음">→</button>
    <button type="button" data-act="close" aria-label="닫기">✕</button>
  </div>
  <div class="lightbox-inner">
    <img alt="">
    <p class="lightbox-cap"></p>
  </div>`;
document.body.appendChild(box);

const boxImg = box.querySelector('img');
const boxCap = box.querySelector('.lightbox-cap');
const boxCount = box.querySelector('.count');
const boxInner = box.querySelector('.lightbox-inner');
let items = [];
let index = 0;
let opener = null;

function show(i) {
  index = (i + items.length) % items.length;
  const el = items[index];
  boxImg.src = el.dataset.full;
  boxImg.alt = el.dataset.caption || '';
  boxCap.textContent = el.dataset.caption || '';
  boxCount.textContent = items.length > 1 ? `${index + 1} / ${items.length}` : '';
  boxInner.classList.toggle('is-narrow', el.hasAttribute('data-narrow'));
  box.scrollTop = 0;
}

function open(el) {
  const group = el.closest('[data-gallery]');
  items = group ? [...group.querySelectorAll('[data-full]')] : [el];
  opener = el;
  box.querySelectorAll('[data-act="prev"], [data-act="next"]').forEach((b) => { b.hidden = items.length < 2; });
  show(items.indexOf(el));
  box.classList.add('is-open');
  document.body.style.overflow = 'hidden';
  box.querySelector('[data-act="close"]').focus();
}

function close() {
  box.classList.remove('is-open');
  document.body.style.overflow = '';
  boxImg.removeAttribute('src');
  opener?.focus();
}

document.addEventListener('click', (e) => {
  const trigger = e.target.closest('[data-full]');
  if (trigger) { e.preventDefault(); open(trigger); return; }

  const act = e.target.closest('.lightbox [data-act]')?.dataset.act;
  if (act === 'close') close();
  if (act === 'prev') show(index - 1);
  if (act === 'next') show(index + 1);
  // 이미지 바깥 빈 곳을 누르면 닫힘
  if (box.classList.contains('is-open') && (e.target === box || e.target === boxInner)) close();
});

document.addEventListener('keydown', (e) => {
  if (!box.classList.contains('is-open')) return;
  if (e.key === 'Escape') close();
  if (e.key === 'ArrowLeft' && items.length > 1) show(index - 1);
  if (e.key === 'ArrowRight' && items.length > 1) show(index + 1);
});
