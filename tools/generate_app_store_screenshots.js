const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const outDir = path.join(process.cwd(), 'app_store_screenshots');
fs.mkdirSync(outDir, { recursive: true });

const esc = (value) => String(value)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

function text(x, y, value, size, color = '#F4F7FB', weight = 400, anchor = 'start') {
  return `<text x="${x}" y="${y}" fill="${color}" font-family="Arial, Helvetica, sans-serif" font-size="${size}" font-weight="${weight}" text-anchor="${anchor}">${esc(value)}</text>`;
}

function rounded(x, y, w, h, r, fill, stroke = 'none', sw = 0) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"/>`;
}

function icon(cx, cy, label, color) {
  return `${rounded(cx - 29, cy - 29, 58, 58, 18, color)}${text(cx, cy + 10, label, 28, '#07111E', 700, 'middle')}`;
}

function phoneFrame(w, h, body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
    <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#07111E"/><stop offset="1" stop-color="#171638"/></linearGradient><linearGradient id="accent" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#39D7E8"/><stop offset="1" stop-color="#9A6BFF"/></linearGradient></defs>
    ${rounded(0, 0, w, h, 0, 'url(#bg)')}${body}
  </svg>`;
}

function header(w, title, subtitle, compact = false) {
  const pad = compact ? 74 : 88;
  return `${text(pad, 104, subtitle, compact ? 28 : 32, '#41D4E5', 700)}${text(pad, 158, title, compact ? 54 : 60, '#F8FBFF', 700)}${rounded(w - pad - 185, 92, 185, 62, 25, '#18334A', '#31D2E3', 2)}${text(w - pad - 92, 131, 'ATTIVO', 23, '#63F2A0', 700, 'middle')}`;
}

function nav(w, h, active = 0) {
  const labels = ['Oggi', 'Riepilogo', 'Dati', 'Pro'];
  const xs = [w * .18, w * .39, w * .61, w * .82];
  return labels.map((label, i) => `${i === active ? rounded(xs[i] - 72, h - 128, 144, 72, 24, '#173E58') : ''}${text(xs[i], h - 82, label, 22, i === active ? '#50E5F0' : '#8793A6', 700, 'middle')}`).join('');
}

function home(w, h, language = 'it') {
  const isEn = language === 'en';
  const title = isEn ? 'LifeSync AI' : 'LifeSync AI';
  const subtitle = isEn ? 'Tuesday, September 17' : 'Martedi, 17 settembre';
  const steps = isEn ? 'Steps today' : 'Passi oggi';
  const places = isEn ? 'Visited places' : 'Luoghi visitati';
  const activity = isEn ? 'Detected activity' : 'Attivita rilevata';
  const walking = isEn ? 'Walking' : 'Camminata';
  const ai = isEn ? 'AI daily summary' : 'Riepilogo giornaliero AI';
  const unlock = isEn ? 'Watch video to unlock' : 'Guarda video e sblocca';
  const backup = isEn ? 'Private local archive' : 'Archivio locale privato';
  const desc = isEn ? 'Your sensor data stays on this device.' : 'I tuoi dati restano su questo dispositivo.';
  return phoneFrame(w, h, `${header(w, title, subtitle)}
    ${rounded(74, 215, w - 148, 210, 26, '#101E32', '#203C56', 2)}
    ${icon(135, 290, 'S', '#54E5F2')}${text(190, 273, steps, 25, '#99A8B8', 600)}${text(190, 335, '8.420', 58, '#F8FBFF', 700)}${text(w - 118, 312, '86%', 24, '#5CE69C', 700, 'end')}
    ${rounded(74, 450, (w - 164) / 2, 214, 26, '#101E32', '#203C56', 2)}${rounded(90 + (w - 164) / 2, 450, (w - 164) / 2, 214, 26, '#101E32', '#203C56', 2)}
    ${icon(130, 515, 'P', '#A06CFF')}${text(101, 593, places, 23, '#99A8B8', 600)}${text(101, 642, '4', 52, '#F8FBFF', 700)}
    ${icon(130 + (w - 164) / 2, 515, 'M', '#F3C75A')}${text(120 + (w - 164) / 2, 593, activity, 23, '#99A8B8', 600)}${text(120 + (w - 164) / 2, 642, walking, 34, '#F8FBFF', 700)}
    ${rounded(74, 694, w - 148, 306, 26, '#14253C', '#E3B84C', 2)}${text(104, 757, ai, 32, '#FFD55F', 700)}${rounded(w - 350, 720, 240, 62, 18, 'url(#accent)')}${text(w - 230, 759, unlock, 20, '#07111E', 700, 'middle')}${text(104, 838, isEn ? 'A focused day with 8,420 steps and four' : 'Una giornata attiva con 8.420 passi e quattro', 26, '#F4F7FB', 500)}${text(104, 878, isEn ? 'places visited. Keep your evening routine.' : 'luoghi visitati. Continua la tua routine serale.', 26, '#F4F7FB', 500)}${text(104, 945, isEn ? 'Rewarded Unity Ads unlocks the summary.' : 'Un video Unity Ads sblocca il riepilogo.', 22, '#8FA1B4', 500)}
    ${rounded(74, 1030, w - 148, 192, 26, '#101E32', '#203C56', 2)}${text(104, 1090, backup, 29, '#63F2A0', 700)}${text(104, 1142, desc, 23, '#AAB5C4', 500)}${rounded(104, 1170, 300, 40, 14, '#1A2D43')}${text(254, 1197, isEn ? 'Export daily log' : 'Esporta log giornaliero', 20, '#DCE7F2', 700, 'middle')}
    ${nav(w, h, 0)}`);
}

function summary(w, h, language = 'es') {
  const es = language === 'es';
  return phoneFrame(w, h, `${header(w, 'LifeSync AI', es ? 'Resumen de hoy' : 'Resume du jour')}
    ${rounded(74, 220, w - 148, 560, 28, '#101E32', '#2D4B62', 2)}${text(108, 284, es ? 'RESUMEN ASISTENTE AI' : 'RESUME ASSISTANT IA', 28, '#FFD55F', 700)}${text(108, 350, es ? 'Un dia activo y equilibrado' : 'Une journee active et equilibree', 38, '#F8FBFF', 700)}${text(108, 421, es ? 'Hoy caminaste 8.420 pasos y visitaste' : 'Vous avez marche 8 420 pas et visite', 25, '#DCE7F2', 500)}${text(108, 461, es ? 'cuatro lugares. Tu ritmo fue constante,' : 'quatre lieux. Votre rythme est reste stable,', 25, '#DCE7F2', 500)}${text(108, 501, es ? 'con mas energia por la tarde.' : 'avec plus d energie dans l apres-midi.', 25, '#DCE7F2', 500)}
    ${rounded(108, 568, w - 216, 3, 2, '#2B4258')}${text(108, 630, es ? 'Movimiento' : 'Mouvement', 24, '#8FA1B4', 600)}${text(w - 108, 630, '86%', 25, '#5CE69C', 700, 'end')}${rounded(108, 653, w - 216, 18, 9, '#1B3448')}${rounded(108, 653, (w - 216) * .86, 18, 9, '#4BE2C4')}${text(108, 742, es ? 'Generado localmente con tus datos privati.' : 'Genere localement avec vos donnees privees.', 21, '#8FA1B4', 500)}
    ${rounded(74, 824, w - 148, 160, 26, '#14253C', '#203C56', 2)}${text(106, 884, es ? 'Desbloqueado con video rewarded' : 'Debloque avec une video rewarded', 25, '#50E5F0', 700)}${text(106, 930, es ? 'Pro elimina anuncios y automatiza cada noche.' : 'Pro supprime les annonces et automatise vos soirees.', 22, '#C6D2DF', 500)}
    ${nav(w, h, 1)}`);
}

function paywall(w, h, language = 'fr') {
  const fr = language === 'fr';
  return phoneFrame(w, h, `${text(90, 102, '×', 50, '#A9B4C1', 400)}${text(w - 90, 102, 'Ripristina', 22, '#50E5F0', 700, 'end')}
    ${rounded(74, 170, w - 148, 190, 28, '#12273C', '#304D66', 2)}${icon(w / 2, 245, 'AI', '#54E5F2')}${text(w / 2, 315, 'LifeSync AI Pro', 42, '#F8FBFF', 700, 'middle')}
    ${rounded(112, 395, w - 224, 64, 24, '#46391A', '#DDBA4B', 2)}${text(w / 2, 437, fr ? '7 JOURS GRATUITS' : '7 GIORNI GRATIS', 25, '#FFD55F', 700, 'middle')}
    ${text(100, 548, fr ? 'Votre assistant quotidien complet' : 'Il tuo assistente quotidiano completo', 30, '#F8FBFF', 700)}
    ${['Riepilogo serale AI illimitato', 'Passi e luoghi con privacy locale', 'Nessuna pubblicita con LifeSync Pro', 'Prova gratuita, annulla quando vuoi'].map((item, i) => `${icon(128, 635 + i * 78, '✓', i === 2 ? '#63F2A0' : '#54E5F2')}${text(184, 645 + i * 78, fr && i === 0 ? 'Resume IA illimite chaque soir' : item, 24, '#DCE7F2', 600)}`).join('')}
    ${rounded(74, h - 350, w - 148, 82, 22, 'url(#accent)')}${text(w / 2, h - 298, fr ? 'COMMENCER 7 JOURS GRATUITS' : 'INIZIA 7 GIORNI GRATIS', 24, '#07111E', 700, 'middle')}${text(w / 2, h - 222, fr ? 'Puis 4,99 € / mois. Annulez depuis votre Apple ID.' : 'Poi 4,99 € / mese. Annulla dal tuo Apple ID.', 21, '#9EADBC', 500, 'middle')}`);
}

function ipadDashboard(w, h) {
  return phoneFrame(w, h, `${header(w, 'LifeSync AI', 'Martedi, 17 settembre', true)}
    ${rounded(74, 225, 760, 410, 30, '#101E32', '#203C56', 2)}${text(112, 290, 'ATTIVITA DI OGGI', 28, '#50E5F0', 700)}${text(112, 376, '8.420', 92, '#F8FBFF', 700)}${text(112, 422, 'passi registrati', 26, '#AAB5C4', 500)}${rounded(112, 486, 610, 24, 12, '#1A3449')}${rounded(112, 486, 530, 24, 12, '#4BE2C4')}${text(112, 566, '4 luoghi visitati', 30, '#DCE7F2', 600)}
    ${rounded(870, 225, w - 944, 410, 30, '#14253C', '#E3B84C', 2)}${text(912, 290, 'RIEPILOGO AI', 28, '#FFD55F', 700)}${text(912, 364, 'Una giornata attiva', 34, '#F8FBFF', 700)}${text(912, 418, 'con ritmo costante e', 27, '#DCE7F2', 500)}${text(912, 458, 'buona energia.', 27, '#DCE7F2', 500)}${rounded(912, 516, 300, 60, 17, 'url(#accent)')}${text(1062, 554, 'Sblocca con video', 20, '#07111E', 700, 'middle')}
    ${rounded(74, 704, w - 148, 290, 30, '#101E32', '#203C56', 2)}${text(112, 770, 'STATO PRIVACY', 28, '#63F2A0', 700)}${text(112, 832, 'I dati restano sul dispositivo.', 32, '#F8FBFF', 700)}${text(112, 890, 'LifeSync usa i sensori iOS con consenso esplicito.', 24, '#AAB5C4', 500)}${text(112, 938, 'Nessun profilo pubblicitario personale.', 24, '#AAB5C4', 500)}
    ${text(74, h - 70, 'Oggi', 24, '#50E5F0', 700)}${text(380, h - 70, 'Riepilogo', 24, '#8793A6', 600)}${text(700, h - 70, 'Dati', 24, '#8793A6', 600)}${text(1000, h - 70, 'Pro', 24, '#8793A6', 600)}`);
}

function ipadSummary(w, h) {
  return phoneFrame(w, h, `${header(w, 'LifeSync AI', 'Daily summary', true)}${rounded(74, 220, w - 148, 560, 30, '#101E32', '#2D4B62', 2)}${text(118, 296, 'AI DAILY SUMMARY', 30, '#FFD55F', 700)}${text(118, 370, 'A focused, active day', 48, '#F8FBFF', 700)}${text(118, 440, '8,420 steps, four places visited, and a', 29, '#DCE7F2', 500)}${text(118, 486, 'steady afternoon rhythm.', 29, '#DCE7F2', 500)}${rounded(118, 560, w - 236, 4, 2, '#2B4258')}${text(118, 640, 'Movement', 26, '#8FA1B4', 600)}${text(w - 118, 640, '86%', 26, '#5CE69C', 700, 'end')}${rounded(118, 670, w - 236, 22, 11, '#1B3448')}${rounded(118, 670, (w - 236) * .86, 22, 11, '#4BE2C4')}${rounded(74, 850, w - 148, 160, 30, '#14253C', '#203C56', 2)}${text(118, 920, 'Generated locally from your private data.', 27, '#DCE7F2', 600)}${text(118, 966, 'Rewarded video unlocks the free tier.', 24, '#8FA1B4', 500)}`);
}

function ipadPro(w, h) {
  return phoneFrame(w, h, `${text(90, 102, '×', 50, '#A9B4C1', 400)}${text(w - 90, 102, 'Restore purchases', 24, '#50E5F0', 700, 'end')}${rounded(74, 180, w - 148, 220, 30, '#12273C', '#304D66', 2)}${icon(160, 290, 'AI', '#54E5F2')}${text(230, 310, 'LifeSync AI Pro', 52, '#F8FBFF', 700)}${text(230, 360, 'Your complete private daily assistant', 27, '#AAB5C4', 500)}${rounded(74, 470, w - 148, 78, 26, '#46391A', '#DDBA4B', 2)}${text(w / 2, 521, '7 DAYS FREE TRIAL', 30, '#FFD55F', 700, 'middle')}${['Unlimited AI evening summaries', 'Steps and places with local privacy', 'No ads with LifeSync Pro', 'Cancel anytime in Apple ID settings'].map((item, i) => `${icon(125, 650 + i * 88, '✓', i === 2 ? '#63F2A0' : '#54E5F2')}${text(184, 660 + i * 88, item, 28, '#DCE7F2', 600)}`).join('')}${rounded(74, h - 260, w - 148, 92, 24, 'url(#accent)')}${text(w / 2, h - 202, 'START 7-DAY FREE TRIAL', 28, '#07111E', 700, 'middle')}${text(w / 2, h - 128, 'Then 4.99 EUR / month. Cancel anytime.', 23, '#9EADBC', 500, 'middle')}`);
}

const jobs = [
  ['01_home_it_6_7_v2.png', 1290, 2796, home(1290, 2796, 'it')],
  ['02_summary_en_6_7_v2.png', 1290, 2796, summary(1290, 2796, 'en')],
  ['03_paywall_it_6_7_v2.png', 1290, 2796, paywall(1290, 2796, 'it')],
  ['04_home_it_ipad_13_v2.png', 2064, 2752, ipadDashboard(2064, 2752)],
  ['05_summary_en_ipad_13_v2.png', 2064, 2752, ipadSummary(2064, 2752)],
  ['06_paywall_en_ipad_13_v2.png', 2064, 2752, ipadPro(2064, 2752)],
];

(async () => {
  for (const [name, width, height, svg] of jobs) {
    await sharp(Buffer.from(svg)).png().toFile(path.join(outDir, name));
  }
  console.log(`Generated ${jobs.length} screenshots in ${outDir}`);
})();
