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


const X = {
  it: {
    h4: ['La tua giornata,', 'minuto per minuto'], h5: ['Statistiche chiare', 'degli ultimi 7 giorni'],
    rest: 'Tempo fermo', restVal: '7h 20m',
    tlTitle: 'Timeline movimenti e attività', add: 'Aggiungi',
    ev: [['08:47', 'Nuova visita: Ufficio', 'Via Roma 12', 'pin'], ['09:15', 'Camminata', 'Durata 32 min', 'walk'], ['13:00', 'Pausa pranzo', 'Aggiunto manualmente', 'note'], ['18:30', 'Sessione palestra', 'Aggiunto manualmente', 'note']],
    voiceTitle: 'Nota vocale rapida', voiceDesc: 'Registra un pensiero: viene trascritto sul dispositivo.', rec: 'Registra',
    voiceText: 'Idea riunione e lista della spesa.',
    statsTitle: 'Passi negli ultimi 7 giorni', avg: 'Media passi', bestDay: 'Giorno migliore', places7: 'Luoghi (7 giorni)',
    days: ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'],
  },
  en: {
    h4: ['Your day,', 'minute by minute'], h5: ['Clear statistics', 'for the last 7 days'],
    rest: 'Still time', restVal: '7h 20m',
    tlTitle: 'Movement & activity timeline', add: 'Add',
    ev: [['08:47', 'New visit: Office', '12 Main Street', 'pin'], ['09:15', 'Walking', 'Lasted 32 min', 'walk'], ['13:00', 'Lunch break', 'Added manually', 'note'], ['18:30', 'Gym session', 'Added manually', 'note']],
    voiceTitle: 'Quick voice note', voiceDesc: 'Record a thought: it is transcribed on your device.', rec: 'Record',
    voiceText: 'Meeting idea and shopping list.',
    statsTitle: 'Steps in the last 7 days', avg: 'Average steps', bestDay: 'Best day', places7: 'Places (7 days)',
    days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  },
  es: {
    h4: ['Tu día,', 'minuto a minuto'], h5: ['Estadísticas claras', 'de los últimos 7 días'],
    rest: 'Tiempo quieto', restVal: '7h 20m',
    tlTitle: 'Línea de tiempo de movimientos', add: 'Añadir',
    ev: [['08:47', 'Nueva visita: Oficina', 'Calle Mayor 12', 'pin'], ['09:15', 'Caminando', 'Duración 32 min', 'walk'], ['13:00', 'Pausa para comer', 'Añadido manualmente', 'note'], ['18:30', 'Sesión de gimnasio', 'Añadido manualmente', 'note']],
    voiceTitle: 'Nota de voz rápida', voiceDesc: 'Graba un pensamiento: se transcribe en tu dispositivo.', rec: 'Grabar',
    voiceText: 'Idea de reunión y lista de la compra.',
    statsTitle: 'Pasos en los últimos 7 días', avg: 'Media de pasos', bestDay: 'Mejor día', places7: 'Lugares (7 días)',
    days: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
  },
  fr: {
    h4: ['Votre journée,', 'minute par minute'], h5: ['Des statistiques claires', 'sur 7 jours'],
    rest: 'Temps immobile', restVal: '7h 20m',
    tlTitle: 'Chronologie des déplacements', add: 'Ajouter',
    ev: [['08:47', 'Nouvelle visite : Bureau', '12 rue Centrale', 'pin'], ['09:15', 'Marche', 'Durée 32 min', 'walk'], ['13:00', 'Pause déjeuner', 'Ajouté manuellement', 'note'], ['18:30', 'Séance de sport', 'Ajouté manuellement', 'note']],
    voiceTitle: 'Note vocale rapide', voiceDesc: 'Enregistrez une pensée : elle est transcrite sur votre appareil.', rec: 'Enregistrer',
    voiceText: 'Idée de réunion et liste de courses.',
    statsTitle: 'Pas des 7 derniers jours', avg: 'Moyenne de pas', bestDay: 'Meilleur jour', places7: 'Lieux (7 jours)',
    days: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
  },
};
const NAV = {
  it: ['Oggi', 'Storico', 'Statistiche', 'Abbonamento', 'Impostazioni'],
  en: ['Today', 'History', 'Stats', 'Subscription', 'Settings'],
  es: ['Hoy', 'Historial', 'Estadísticas', 'Suscripción', 'Ajustes'],
  fr: ['Aujourd\u2019hui', 'Historique', 'Statistiques', 'Abonnement', 'Réglages'],
};
const SUM = {
  it: ['Riepilogo di oggi', 'Passi: 8420', 'Luoghi visitati: 4', 'Movimento attivo: 65 min', 'Note vocali: 1', 'Sei 4% sopra la tua media degli ultimi giorni.', 'Ottima giornata di movimento!'],
  en: ['Today\u2019s summary', 'Steps: 8420', 'Places visited: 4', 'Active movement: 65 min', 'Voice notes: 1', 'You are 4% above your recent average.', 'Great day of movement!'],
  es: ['Resumen de hoy', 'Pasos: 8420', 'Lugares visitados: 4', 'Movimiento activo: 65 min', 'Notas de voz: 1', 'Estás un 4% por encima de tu media reciente.', '¡Gran día de movimiento!'],
  fr: ['Résumé du jour', 'Pas : 8420', 'Lieux visités : 4', 'Mouvement actif : 65 min', 'Notes vocales : 1', 'Vous êtes 4 % au-dessus de votre moyenne récente.', 'Belle journée de mouvement !'],
};
const STEPS = [6200, 8420, 7100, 9800, 5400, 11200, 8420];

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
  const x = X[lang];
  const head = { home: t.h1, summary: t.h2, paywall: t.h3, timeline: x.h4, stats: x.h5 }[kind];
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
    rows.push({ f: 1.0, draw: (y, ch) => {
      const third = (cw - 2 * gap) / 3;
      const mk = (i, ic, col, label, val, vs) => {
        const x0 = cx + i * (third + gap);
        return R(x0, y, third, ch, 44 * s, '#101E32', cardBorder, 3 * s) +
          R(x0 + pad * 0.7, y + pad * 0.7, 80 * s, 80 * s, 26 * s, col) + T(x0 + pad * 0.7 + 40 * s, y + pad * 0.7 + 55 * s, ic, 40 * s, '#07111E', 700, 'middle') +
          T(x0 + pad * 0.7, y + ch - 100 * s, label, 30 * s, '#99A8B8', 600) + T(x0 + pad * 0.7, y + ch - 36 * s, val, vs, '#F8FBFF', 700);
      };
      return mk(0, 'S', '#54E5F2', t.steps, '8.420', 60 * s) + mk(1, 'P', '#A06CFF', t.places, '4', 60 * s) + mk(2, 'R', '#F3A64A', x.rest, x.restVal, 52 * s);
    } });
    rows.push({ f: 1.9, draw: (y, ch) => card(y, ch, '#14253C', '#E3B84C', (x0, yy) =>
      T(x0, yy + 100 * s, t.aiTitle, 54 * s, '#FFD55F', 700) +
      R(x0, yy + 150 * s, 520 * s, 90 * s, 30 * s, 'url(#accent)') + T(x0 + 260 * s, yy + 208 * s, t.unlock, 34 * s, '#07111E', 700, 'middle') +
      t.aiText.map((l, i) => T(x0, yy + 330 * s + i * 62 * s, l, 46 * s, '#F4F7FB', 500)).join('') +
      T(x0, yy + ch - 50 * s, t.adNote, 36 * s, '#8FA1B4', 500)) });
    rows.push({ f: 1.0, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) =>
      T(x0, yy + ch / 2 - 20 * s, t.privTitle, 52 * s, '#63F2A0', 700) + T(x0, yy + ch / 2 + 50 * s, t.privText, 38 * s, '#AAB5C4', 500)) });
  } else if (kind === 'timeline') {
    const icons = { pin: ['P', '#A06CFF'], walk: ['W', '#54E5F2'], note: ['+', '#F3A64A'] };
    rows.push({ f: 3.3, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) => {
      let o = T(x0, yy + 90 * s, x.tlTitle, 46 * s, '#F8FBFF', 700) +
        R(cx + cw - pad - 230 * s, yy + 40 * s, 230 * s, 70 * s, 22 * s, '#173E58') + T(cx + cw - pad - 115 * s, yy + 88 * s, '+ ' + x.add, 32 * s, '#50E5F0', 700, 'middle');
      const step = (ch - 150 * s) / 4;
      x.ev.forEach((e, i) => {
        const ey = yy + 150 * s + i * step;
        const [ic, col] = icons[e[3]];
        o += R(x0, ey, cw - 2 * pad, step - 16 * s, 26 * s, '#14253C') +
          T(x0 + 24 * s, ey + (step - 16 * s) / 2 + 12 * s, e[0], 34 * s, '#50E5F0', 700) +
          R(x0 + 170 * s, ey + (step - 16 * s) / 2 - 34 * s, 68 * s, 68 * s, 22 * s, col) + T(x0 + 204 * s, ey + (step - 16 * s) / 2 + 14 * s, ic, 34 * s, '#07111E', 700, 'middle') +
          T(x0 + 270 * s, ey + (step - 16 * s) / 2 - 4 * s, e[1], 38 * s, '#F8FBFF', 700) +
          T(x0 + 270 * s, ey + (step - 16 * s) / 2 + 42 * s, e[2], 30 * s, '#8FA1B4', 500);
      });
      return o;
    }) });
    rows.push({ f: 1.6, draw: (y, ch) => card(y, ch, '#14253C', '#E0567A', (x0, yy) =>
      T(x0, yy + 90 * s, x.voiceTitle, 46 * s, '#F8FBFF', 700) +
      R(cx + cw - pad - 250 * s, yy + 40 * s, 250 * s, 70 * s, 22 * s, '#4A2233') + T(cx + cw - pad - 125 * s, yy + 88 * s, x.rec, 32 * s, '#FF7A9C', 700, 'middle') +
      T(x0, yy + 165 * s, x.voiceDesc, 30 * s, '#8FA1B4', 500) +
      R(x0, yy + 205 * s, cw - 2 * pad, ch - 250 * s, 22 * s, '#0E1A2B') + T(x0 + 28 * s, yy + 205 * s + (ch - 250 * s) / 2 + 14 * s, '“' + x.voiceText + '”', 40 * s, '#DCE7F2', 600)) });
  } else if (kind === 'stats') {
    rows.push({ f: 3.0, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) => {
      let o = T(x0, yy + 90 * s, x.statsTitle, 46 * s, '#F8FBFF', 700);
      const chartTop = yy + 150 * s, chartH = ch - 300 * s, chartW = cw - 2 * pad;
      const barW = chartW / 7 * 0.6, max = 12000;
      STEPS.forEach((v, i) => {
        const bh = chartH * v / max;
        const bx = x0 + i * chartW / 7 + (chartW / 7 - barW) / 2;
        o += R(bx, chartTop + chartH - bh, barW, bh, 14 * s, i === 5 ? '#9A6BFF' : '#39D7E8') +
          T(bx + barW / 2, chartTop + chartH + 55 * s, x.days[i], 30 * s, '#8FA1B4', 600, 'middle');
      });
      return o;
    }) });
    rows.push({ f: 1.0, draw: (y, ch) => {
      const half = (cw - gap) / 2;
      const mk = (i, label, val) => R(cx + i * (half + gap), y, half, ch, 44 * s, '#101E32', cardBorder, 3 * s) +
        T(cx + i * (half + gap) + pad, y + ch / 2 - 10 * s, label, 34 * s, '#99A8B8', 600) + T(cx + i * (half + gap) + pad, y + ch / 2 + 72 * s, val, 72 * s, '#F8FBFF', 700);
      return mk(0, x.avg, '8.077') + mk(1, x.places7, '19');
    } });
    rows.push({ f: 0.8, draw: (y, ch) => card(y, ch, '#14253C', '#E3B84C', (x0, yy) =>
      T(x0, yy + ch / 2 + 14 * s, x.bestDay, 40 * s, '#FFD55F', 700) + T(cx + cw - pad, yy + ch / 2 + 14 * s, '11.200', 56 * s, '#F8FBFF', 700, 'end')) });
  } else if (kind === 'summary') {
    rows.push({ f: 3.2, draw: (y, ch) => card(y, ch, '#101E32', '#2D4B62', (x0, yy) => {
      const lines = SUM[lang];
      let o = T(x0, yy + 110 * s, t.aiTitle, 50 * s, '#FFD55F', 700) + T(x0, yy + 230 * s, lines[0], 62 * s, '#F8FBFF', 700);
      lines.slice(1).forEach((l, i) => { o += T(x0, yy + 340 * s + i * 78 * s, l, 42 * s, i === lines.length - 2 ? '#63F2A0' : '#DCE7F2', i === lines.length - 2 ? 700 : 500); });
      return o + T(x0, yy + ch - 50 * s, t.local, 34 * s, '#8FA1B4', 500);
    }) });
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
    const active = (kind === 'stats') ? 2 : 0;
    const labels = NAV[lang];
    out += R(cx, h - 210 * s, cw, 130 * s, 44 * s, '#0E1A2B', cardBorder, 3 * s);
    out += labels.map((label, i) => {
      const x = cx + cw * ((i + 0.5) / 5);
      return (i === active ? R(x - 92 * s, h - 195 * s, 184 * s, 100 * s, 30 * s, '#173E58') : '') +
        T(x, h - 132 * s, label, 22 * s, i === active ? '#50E5F0' : '#8793A6', 700, 'middle');
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
      for (const [i, kind] of ['home', 'timeline', 'summary', 'stats', 'paywall'].entries()) {
        const svg = build(kind, lang, w, h);
        await sharp(Buffer.from(svg)).flatten({ background: '#07111E' }).png().toFile(path.join(dir, `0${i + 1}_${kind}.png`));
        n++;
      }
    }
  }
  console.log(`Generated ${n} screenshots in ${outRoot}`);
})();
