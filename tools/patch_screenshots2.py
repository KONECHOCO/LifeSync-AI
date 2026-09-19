p = 'tools/generate_all_screenshots.js'
s = open(p, encoding='utf-8', newline='').read().replace('\r\n', '\n')


def rep(old, new):
    global s
    assert old in s, 'missing: ' + old[:70]
    s = s.replace(old, new, 1)


# real tab names + summary lines per language
rep("const STEPS = [", '''const NAV = {
  it: ['Oggi', 'Storico', 'Statistiche', 'Abbonamento', 'Impostazioni'],
  en: ['Today', 'History', 'Stats', 'Subscription', 'Settings'],
  es: ['Hoy', 'Historial', 'Estadísticas', 'Suscripción', 'Ajustes'],
  fr: ['Aujourd\\u2019hui', 'Historique', 'Statistiques', 'Abonnement', 'Réglages'],
};
const SUM = {
  it: ['Riepilogo di oggi', 'Passi: 8420', 'Luoghi visitati: 4', 'Movimento attivo: 65 min', 'Note vocali: 1', 'Sei 4% sopra la tua media degli ultimi giorni.', 'Ottima giornata di movimento!'],
  en: ['Today\\u2019s summary', 'Steps: 8420', 'Places visited: 4', 'Active movement: 65 min', 'Voice notes: 1', 'You are 4% above your recent average.', 'Great day of movement!'],
  es: ['Resumen de hoy', 'Pasos: 8420', 'Lugares visitados: 4', 'Movimiento activo: 65 min', 'Notas de voz: 1', 'Estás un 4% por encima de tu media reciente.', '¡Gran día de movimiento!'],
  fr: ['Résumé du jour', 'Pas : 8420', 'Lieux visités : 4', 'Mouvement actif : 65 min', 'Notes vocales : 1', 'Vous êtes 4 % au-dessus de votre moyenne récente.', 'Belle journée de mouvement !'],
};
const STEPS = [''')

# remove the invented 86% on home
rep("      T(cx + cw - pad, yy + ch / 2 + 16 * s, '86%', 48 * s, '#5CE69C', 700, 'end')) });",
    "      '') });")

# summary card: real summary lines instead of tag/bar
a = s.index("    rows.push({ f: 3.2, draw: (y, ch) => card(y, ch, '#101E32', '#2D4B62'")
b = s.index("    rows.push({ f: 1.1, draw: (y, ch) => card(y, ch, '#14253C', cardBorder")
new_card = '''    rows.push({ f: 3.2, draw: (y, ch) => card(y, ch, '#101E32', '#2D4B62', (x0, yy) => {
      const lines = SUM[lang];
      let o = T(x0, yy + 110 * s, t.aiTitle, 50 * s, '#FFD55F', 700) + T(x0, yy + 230 * s, lines[0], 62 * s, '#F8FBFF', 700);
      lines.slice(1).forEach((l, i) => { o += T(x0, yy + 340 * s + i * 78 * s, l, 42 * s, i === lines.length - 2 ? '#63F2A0' : '#DCE7F2', i === lines.length - 2 ? 700 : 500); });
      return o + T(x0, yy + ch - 50 * s, t.local, 34 * s, '#8FA1B4', 500);
    }) });
'''
s = s[:a] + new_card + s[b:]

# 5-tab nav with real names
a = s.index("    const active = ")
b = s.index("  return `<svg")
nav = '''    const active = (kind === 'stats') ? 2 : 0;
    const labels = NAV[lang];
    out += R(cx, h - 210 * s, cw, 130 * s, 44 * s, '#0E1A2B', cardBorder, 3 * s);
    out += labels.map((label, i) => {
      const x = cx + cw * ((i + 0.5) / 5);
      return (i === active ? R(x - 92 * s, h - 195 * s, 184 * s, 100 * s, 30 * s, '#173E58') : '') +
        T(x, h - 132 * s, label, 22 * s, i === active ? '#50E5F0' : '#8793A6', 700, 'middle');
    }).join('');
  }

'''
s = s[:a] + nav + s[b:]
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('ok')
