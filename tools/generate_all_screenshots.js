// Generates App Store screenshots for every device size and app language.
// Usage: node tools/generate_all_screenshots.js  (requires `sharp`)
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const outRoot = path.join(process.cwd(), 'app_store_screenshots', 'final');

const DEVICES = {
  'iphone_6.9': [1320, 2868],
  'iphone_6.7': [1290, 2796],
  'iphone_6.5': [1284, 2778],
  'iphone_5.5': [1242, 2208],
  'ipad_13': [2064, 2752],
  'ipad_12.9': [2048, 2732],
  'ipad_11': [1668, 2388],
};

const L = {
  it: {
    date: 'Martedì, 17 settembre', active: 'ATTIVO', nav: ['Oggi', 'Riepilogo', 'Dati', 'Pro'],
    h1: ['Il diario della tua', 'giornata, in automatico'],
    h2: ['Ogni sera, un riepilogo', 'scritto dall’AI'],
    h3: ['Prova Pro 7 giorni', 'gratis, senza annunci'],
    steps: 'Passi oggi', places: 'Luoghi visitati', activity: 'Attività rilevata', walking: 'Camminata',
    aiTitle: 'Riepilogo giornaliero AI', unlock: 'Guarda video e sblocca',
    aiText: ['Una giornata attiva con 8.420 passi', 'e quattro luoghi visitati.'], adNote: 'Un video Unity Ads sblocca il riepilogo.',
    privTitle: 'Archivio locale privato', privText: 'I tuoi dati restano su questo dispositivo.',
    sumTag: 'RIEPILOGO ASSISTENTE AI', sumHead: 'Una giornata attiva ed equilibrata',
    sumText: ['Oggi hai camminato 8.420 passi e visitato', 'quattro luoghi. Ritmo costante, con più', 'energia nel pomeriggio.'],
    move: 'Movimento', local: 'Generato in locale con i tuoi dati privati.',
    unlocked: 'Sbloccato con video rewarded', proNote: 'Pro elimina gli annunci e automatizza ogni sera.',
    restore: 'Ripristina', trial: '7 GIORNI GRATIS', pwHead: 'Il tuo assistente quotidiano completo',
    feats: ['Riepilogo serale AI illimitato', 'Passi e luoghi con privacy locale', 'Nessuna pubblicità con LifeSync Pro', 'Prova gratuita, annulla quando vuoi'],
    cta: 'INIZIA 7 GIORNI GRATIS', price: 'Poi 4,99 € / mese. Annulla dal tuo Apple ID.',
  },
  en: {
    date: 'Tuesday, September 17', active: 'ACTIVE', nav: ['Today', 'Summary', 'Data', 'Pro'],
    h1: ['Your daily journal,', 'written automatically'],
    h2: ['An AI-written summary', 'every evening'],
    h3: ['Try Pro free for 7 days,', 'no ads'],
    steps: 'Steps today', places: 'Visited places', activity: 'Detected activity', walking: 'Walking',
    aiTitle: 'AI daily summary', unlock: 'Watch video to unlock',
    aiText: ['A focused day with 8,420 steps', 'and four places visited.'], adNote: 'A rewarded Unity Ads video unlocks the summary.',
    privTitle: 'Private local archive', privText: 'Your sensor data stays on this device.',
    sumTag: 'AI ASSISTANT SUMMARY', sumHead: 'An active, balanced day',
    sumText: ['Today you walked 8,420 steps and visited', 'four places. Steady pace, with more', 'energy in the afternoon.'],
    move: 'Movement', local: 'Generated locally from your private data.',
    unlocked: 'Unlocked with a rewarded video', proNote: 'Pro removes ads and automates every evening.',
    restore: 'Restore', trial: '7 DAYS FREE', pwHead: 'Your complete daily assistant',
    feats: ['Unlimited AI evening summaries', 'Steps and places with local privacy', 'No ads with LifeSync Pro', 'Free trial, cancel anytime'],
    cta: 'START 7-DAY FREE TRIAL', price: 'Then €4.99 / month. Cancel anytime in Apple ID.',
  },
  es: {
    date: 'Martes, 17 de septiembre', active: 'ACTIVO', nav: ['Hoy', 'Resumen', 'Datos', 'Pro'],
    h1: ['El diario de tu día,', 'de forma automática'],
    h2: ['Cada noche, un resumen', 'escrito por IA'],
    h3: ['Prueba Pro 7 días gratis,', 'sin anuncios'],
    steps: 'Pasos hoy', places: 'Lugares visitados', activity: 'Actividad detectada', walking: 'Caminando',
    aiTitle: 'Resumen diario IA', unlock: 'Mira un video y desbloquea',
    aiText: ['Un día activo con 8.420 pasos', 'y cuatro lugares visitados.'], adNote: 'Un video de Unity Ads desbloquea el resumen.',
    privTitle: 'Archivo local privado', privText: 'Tus datos se quedan en este dispositivo.',
    sumTag: 'RESUMEN DEL ASISTENTE IA', sumHead: 'Un día activo y equilibrado',
    sumText: ['Hoy caminaste 8.420 pasos y visitaste', 'cuatro lugares. Ritmo constante, con más', 'energía por la tarde.'],
    move: 'Movimiento', local: 'Generado localmente con tus datos privados.',
    unlocked: 'Desbloqueado con video rewarded', proNote: 'Pro elimina los anuncios y automatiza cada noche.',
    restore: 'Restaurar', trial: '7 DÍAS GRATIS', pwHead: 'Tu asistente diario completo',
    feats: ['Resumen nocturno IA ilimitado', 'Pasos y lugares con privacidad local', 'Sin anuncios con LifeSync Pro', 'Prueba gratis, cancela cuando quieras'],
    cta: 'EMPEZAR 7 DÍAS GRATIS', price: 'Luego 4,99 € / mes. Cancela desde tu Apple ID.',
  },
  fr: {
    date: 'Mardi 17 septembre', active: 'ACTIF', nav: ['Aujourd’hui', 'Résumé', 'Données', 'Pro'],
    h1: ['Le journal de votre', 'journée, automatique'],
    h2: ['Chaque soir, un résumé', 'rédigé par l’IA'],
    h3: ['Essayez Pro 7 jours', 'gratuits, sans pub'],
    steps: 'Pas aujourd’hui', places: 'Lieux visités', activity: 'Activité détectée', walking: 'Marche',
    aiTitle: 'Résumé quotidien IA', unlock: 'Regarder une vidéo',
    aiText: ['Une journée active : 8 420 pas', 'et quatre lieux visités.'], adNote: 'Une vidéo Unity Ads débloque le résumé.',
    privTitle: 'Archive locale privée', privText: 'Vos données restent sur cet appareil.',
    sumTag: 'RÉSUMÉ DE L’ASSISTANT IA', sumHead: 'Une journée active et équilibrée',
    sumText: ['Aujourd’hui, vous avez marché 8 420 pas et', 'visité quatre lieux. Rythme stable,', 'avec plus d’énergie l’après-midi.'],
    move: 'Mouvement', local: 'Généré localement avec vos données privées.',
    unlocked: 'Débloqué avec une vidéo rewarded', proNote: 'Pro supprime les pubs et automatise vos soirées.',
    restore: 'Restaurer', trial: '7 JOURS GRATUITS', pwHead: 'Votre assistant quotidien complet',
    feats: ['Résumé du soir IA illimité', 'Pas et lieux, confidentialité locale', 'Aucune pub avec LifeSync Pro', 'Essai gratuit, annulez à tout moment'],
    cta: 'COMMENCER 7 JOURS GRATUITS', price: 'Puis 4,99 € / mois. Annulez depuis votre Apple ID.',
  },
};

const esc = (v) => String(v).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const FONT = 'Arial, Helvetica, sans-serif';
const T = (x, y, v, size, color = '#F4F7FB', weight = 400, anchor = 'start') =>
  `<text x="${x.toFixed(1)}" y="${y.toFixed(1)}" fill="${color}" font-family="${FONT}" font-size="${size.toFixed(1)}" font-weight="${weight}" text-anchor="${anchor}">${esc(v)}</text>`;
const R = (x, y, w, h, r, fill, stroke = 'none', sw = 0) =>
  `<rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${w.toFixed(1)}" height="${h.toFixed(1)}" rx="${r.toFixed(1)}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"/>`;

function build(kind, lang, w, h) {
  const t = L[lang];
  const tablet = w > 1500;
  const s = Math.min(w / 1290, h / 2796);   // global scale (fits both width and height)
  const cw = Math.min(w * 0.88, 1180 * s * 1.3); // content column width
  const cx = (w - cw) / 2;                  // content left
  const pad = 40 * s;
  const cardBorder = '#203C56';
  let out = '';

  // marketing headline
  const head = { home: t.h1, summary: t.h2, paywall: t.h3 }[kind];
  const hs = 92 * s;
  const hy = 330 * s;
  out += head.map((line, i) => T(w / 2, hy + i * hs * 1.2, line, hs, i ? '#50E5F0' : '#F8FBFF', 700, 'middle')).join('');

  // content region
  const top = hy + hs * 2.4 + 40 * s;
  const bottom = kind === 'paywall' ? h - 120 * s : h - 300 * s;
  const region = bottom - top;
  const gap = 34 * s;

  // card renderer: returns svg for card at (y, ch)
  const card = (y, ch, fill, stroke, inner) =>
    R(cx, y, cw, ch, 44 * s, fill, stroke, 3 * s) + inner(cx + pad, y, ch);

  const rows = [];
  if (kind === 'home') {
    rows.push({ f: 1.0, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) =>
      R(x0, yy + ch / 2 - 45 * s, 90 * s, 90 * s, 28 * s, '#54E5F2') + T(x0 + 45 * s, yy + ch / 2 + 16 * s, 'S', 46 * s, '#07111E', 700, 'middle') +
      T(x0 + 130 * s, yy + ch / 2 - 30 * s, t.steps, 40 * s, '#99A8B8', 600) + T(x0 + 130 * s, yy + ch / 2 + 70 * s, '8.420', 108 * s, '#F8FBFF', 700) +
      T(cx + cw - pad, yy + ch / 2 + 16 * s, '86%', 48 * s, '#5CE69C', 700, 'end')) });
    rows.push({ f: 1.0, draw: (y, ch) => {
      const half = (cw - gap) / 2;
      const mk = (x, ic, col, label, val, vs) => R(x, y, half, ch, 44 * s, '#101E32', cardBorder, 3 * s) +
        R(x + pad, y + pad, 90 * s, 90 * s, 28 * s, col) + T(x + pad + 45 * s, y + pad + 62 * s, ic, 46 * s, '#07111E', 700, 'middle') +
        T(x + pad, y + ch - 118 * s, label, 36 * s, '#99A8B8', 600) + T(x + pad, y + ch - 40 * s, val, vs, '#F8FBFF', 700);
      return mk(cx, 'P', '#A06CFF', t.places, '4', 96 * s) + mk(cx + half + gap, 'M', '#F3C75A', t.activity, t.walking, 66 * s);
    } });
    rows.push({ f: 1.9, draw: (y, ch) => card(y, ch, '#14253C', '#E3B84C', (x0, yy) =>
      T(x0, yy + 100 * s, t.aiTitle, 54 * s, '#FFD55F', 700) +
      R(x0, yy + 150 * s, 520 * s, 90 * s, 30 * s, 'url(#accent)') + T(x0 + 260 * s, yy + 208 * s, t.unlock, 34 * s, '#07111E', 700, 'middle') +
      t.aiText.map((l, i) => T(x0, yy + 330 * s + i * 62 * s, l, 46 * s, '#F4F7FB', 500)).join('') +
      T(x0, yy + ch - 50 * s, t.adNote, 36 * s, '#8FA1B4', 500)) });
    rows.push({ f: 1.0, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) =>
      T(x0, yy + ch / 2 - 20 * s, t.privTitle, 52 * s, '#63F2A0', 700) + T(x0, yy + ch / 2 + 50 * s, t.privText, 38 * s, '#AAB5C4', 500)) });
  } else if (kind === 'summary') {
    rows.push({ f: 3.2, draw: (y, ch) => card(y, ch, '#101E32', '#2D4B62', (x0, yy) =>
      T(x0, yy + 110 * s, t.sumTag, 44 * s, '#FFD55F', 700) + T(x0, yy + 220 * s, t.sumHead, 62 * s, '#F8FBFF', 700) +
      t.sumText.map((l, i) => T(x0, yy + 330 * s + i * 64 * s, l, 44 * s, '#DCE7F2', 500)).join('') +
      R(x0, yy + 560 * s, cw - 2 * pad, 4 * s, 2, '#2B4258') +
      T(x0, yy + 660 * s, t.move, 40 * s, '#8FA1B4', 600) + T(cx + cw - pad, yy + 660 * s, '86%', 44 * s, '#5CE69C', 700, 'end') +
      R(x0, yy + 700 * s, cw - 2 * pad, 32 * s, 16 * s, '#1B3448') + R(x0, yy + 700 * s, (cw - 2 * pad) * 0.86, 32 * s, 16 * s, '#4BE2C4') +
      T(x0, yy + ch - 50 * s, t.local, 36 * s, '#8FA1B4', 500)) });
    rows.push({ f: 1.1, draw: (y, ch) => card(y, ch, '#14253C', cardBorder, (x0, yy) =>
      T(x0, yy + ch / 2 - 10 * s, t.unlocked, 46 * s, '#50E5F0', 700) + T(x0, yy + ch / 2 + 62 * s, t.proNote, 36 * s, '#C6D2DF', 500)) });
    rows.push({ f: 1.1, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) =>
      T(x0, yy + ch / 2 - 10 * s, t.privTitle, 46 * s, '#63F2A0', 700) + T(x0, yy + ch / 2 + 62 * s, t.privText, 36 * s, '#AAB5C4', 500)) });
  } else {
    rows.push({ f: 1.3, draw: (y, ch) => card(y, ch, '#12273C', '#304D66', () =>
      R(w / 2 - 65 * s, y + ch / 2 - 130 * s, 130 * s, 130 * s, 38 * s, '#54E5F2') + T(w / 2, y + ch / 2 - 40 * s, 'AI', 64 * s, '#07111E', 700, 'middle') +
      T(w / 2, y + ch / 2 + 80 * s, 'LifeSync AI Pro', 78 * s, '#F8FBFF', 700, 'middle')) });
    rows.push({ f: 0.6, draw: (y, ch) => R(cx, y, cw, ch, 36 * s, '#46391A', '#DDBA4B', 3 * s) + T(w / 2, y + ch / 2 + 20 * s, t.trial, 52 * s, '#FFD55F', 700, 'middle') });
    rows.push({ f: 3.0, draw: (y, ch) => {
      const step = ch / 4.2;
      return T(cx, y + 20 * s, t.pwHead, 54 * s, '#F8FBFF', 700) +
        t.feats.map((f, i) => {
          const yy = y + 110 * s + i * step;
          return R(cx, yy, 84 * s, 84 * s, 26 * s, i === 2 ? '#63F2A0' : '#54E5F2') + T(cx + 42 * s, yy + 58 * s, '✓', 46 * s, '#07111E', 700, 'middle') +
            T(cx + 128 * s, yy + 58 * s, f, 44 * s, '#DCE7F2', 600);
        }).join('');
    } });
    rows.push({ f: 0.8, draw: (y, ch) => R(cx, y, cw, ch, 36 * s, 'url(#accent)') + T(w / 2, y + ch / 2 + 18 * s, t.cta, 50 * s, '#07111E', 700, 'middle') });
    rows.push({ f: 0.4, draw: (y, ch) => T(w / 2, y + ch / 2 + 12 * s, t.price, 36 * s, '#9EADBC', 500, 'middle') });
  }

  // vertical distribution
  const totalF = rows.reduce((a, r) => a + r.f, 0);
  const avail = region - gap * (rows.length - 1);
  let y = top;
  for (const r of rows) {
    const ch = (avail * r.f) / totalF;
    out += r.draw(y, ch);
    y += ch + gap;
  }

  // top bar / bottom nav
  if (kind === 'paywall') {
    out += T(cx, 110 * s, '×', 80 * s, '#A9B4C1', 400) + T(cx + cw, 100 * s, t.restore, 40 * s, '#50E5F0', 700, 'end');
  } else {
    out += R(cx + cw - 290 * s, 60 * s, 290 * s, 84 * s, 34 * s, '#18334A', '#31D2E3', 3 * s) + T(cx + cw - 145 * s, 116 * s, t.active, 34 * s, '#63F2A0', 700, 'middle');
    out += T(cx, 116 * s, 'LifeSync AI', 40 * s, '#41D4E5', 700);
    const active = kind === 'home' ? 0 : 1;
    const xs = [0.16, 0.39, 0.61, 0.84];
    out += R(cx, h - 210 * s, cw, 130 * s, 44 * s, '#0E1A2B', cardBorder, 3 * s);
    out += t.nav.map((label, i) => {
      const x = cx + cw * ((i + 0.5) / 4);
      return (i === active ? R(x - 110 * s, h - 195 * s, 220 * s, 100 * s, 34 * s, '#173E58') : '') +
        T(x, h - 132 * s, label, 34 * s, i === active ? '#50E5F0' : '#8793A6', 700, 'middle');
    }).join('');
  }

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
    <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#07111E"/><stop offset="1" stop-color="#171638"/></linearGradient>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#39D7E8"/><stop offset="1" stop-color="#9A6BFF"/></linearGradient></defs>
    <rect width="${w}" height="${h}" fill="url(#bg)"/>${out}</svg>`;
}

(async () => {
  let n = 0;
  for (const [dev, [w, h]] of Object.entries(DEVICES)) {
    for (const lang of Object.keys(L)) {
      const dir = path.join(outRoot, dev, lang);
      fs.mkdirSync(dir, { recursive: true });
      for (const [i, kind] of ['home', 'summary', 'paywall'].entries()) {
        const svg = build(kind, lang, w, h);
        await sharp(Buffer.from(svg)).flatten({ background: '#07111E' }).png().toFile(path.join(dir, `0${i + 1}_${kind}.png`));
        n++;
      }
    }
  }
  console.log(`Generated ${n} screenshots in ${outRoot}`);
})();
