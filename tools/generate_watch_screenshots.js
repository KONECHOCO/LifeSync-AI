// Generates Apple Watch App Store screenshots (416x496, Series 10) mirroring WatchContentView.
// Usage: node tools/generate_watch_screenshots.js <outDir>
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');
const out = process.argv[2] || path.join(process.cwd(), 'app_store_screenshots', 'watch');
const W = 416, H = 496;
const L = {
  it: { title: 'LifeSync AI', steps: 'Passi', places: 'Luoghi', rest: 'Riposo', sum: 'Riepilogo AI', text: ['Giornata attiva: 8.420 passi', 'e quattro luoghi visitati.', 'Ritmo costante nel pomeriggio.'], refresh: 'Aggiorna' },
  en: { title: 'LifeSync AI', steps: 'Steps', places: 'Places', rest: 'Rest', sum: 'AI Summary', text: ['Active day: 8,420 steps and', 'four places visited. Steady', 'pace in the afternoon.'], refresh: 'Refresh' },
  es: { title: 'LifeSync AI', steps: 'Pasos', places: 'Lugares', rest: 'Reposo', sum: 'Resumen IA', text: ['Día activo: 8.420 pasos y', 'cuatro lugares visitados.', 'Ritmo constante por la tarde.'], refresh: 'Actualizar' },
  fr: { title: 'LifeSync AI', steps: 'Pas', places: 'Lieux', rest: 'Repos', sum: 'Résumé IA', text: ['Journée active : 8 420 pas', 'et quatre lieux visités.', 'Rythme régulier l’après-midi.'], refresh: 'Actualiser' },
};
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
const tile = (x, y, w, h, icon, val, label, col) => `
  <rect x="${x}" y="${y}" width="${w}" height="${h}" rx="22" fill="#ffffff" fill-opacity="0.09"/>
  <circle cx="${x + w / 2}" cy="${y + 34}" r="14" fill="${col}"/>
  <text x="${x + w / 2}" y="${y + 90}" font-family="Arial, Helvetica, sans-serif" font-size="40" font-weight="700" fill="#fff" text-anchor="middle">${esc(val)}</text>
  <text x="${x + w / 2}" y="${y + 118}" font-family="Arial, Helvetica, sans-serif" font-size="22" fill="#9aa4b2" text-anchor="middle">${esc(label)}</text>`;
async function main() {
  for (const [lang, t] of Object.entries(L)) {
    const dir = path.join(out, lang); fs.mkdirSync(dir, { recursive: true });
    const base = (inner) => `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}"><rect width="${W}" height="${H}" fill="#000"/>${inner}</svg>`;
    const shots = {
      '01_overview': `
        <text x="24" y="48" font-family="Arial" font-size="30" font-weight="700" fill="#4de1ee">${esc(t.title)}</text>
        ${tile(24, 70, 172, 140, '', '8420', t.steps, '#4de1ee')}
        ${tile(220, 70, 172, 140, '', '4', t.places, '#a678ff')}
        ${tile(24, 228, 368, 120, '', '7h 12m', t.rest, '#ff9f43')}
        <rect x="24" y="366" width="368" height="100" rx="22" fill="#ffffff" fill-opacity="0.09"/>
        <text x="44" y="400" font-family="Arial" font-size="20" fill="#ffd55f">✦ ${esc(t.sum)}</text>
        <text x="44" y="430" font-family="Arial" font-size="19" fill="#e5eaf0">${esc(t.text[0])}</text>`,
      '02_summary': `
        <text x="24" y="52" font-family="Arial" font-size="26" font-weight="700" fill="#ffd55f">✦ ${esc(t.sum)}</text>
        <rect x="20" y="76" width="376" height="260" rx="24" fill="#ffffff" fill-opacity="0.09"/>
        ${t.text.map((l, i) => `<text x="40" y="${124 + i * 44}" font-family="Arial" font-size="24" fill="#e9eef5">${esc(l)}</text>`).join('')}
        <rect x="88" y="372" width="240" height="64" rx="32" fill="#4de1ee" fill-opacity="0.25"/>
        <text x="208" y="414" font-family="Arial" font-size="24" fill="#4de1ee" text-anchor="middle">↻ ${esc(t.refresh)}</text>`,
    };
    for (const [name, inner] of Object.entries(shots)) {
      await sharp(Buffer.from(base(inner))).png().toFile(path.join(dir, `${name}-${W}x${H}.png`));
    }
  }
  console.log('Watch screenshots in', out);
}
main();
