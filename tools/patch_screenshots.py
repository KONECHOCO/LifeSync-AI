p = 'tools/generate_all_screenshots.js'
s = open(p, encoding='utf-8', newline='').read().replace('\r\n', '\n')


def rep(old, new):
    global s
    assert old in s, 'missing: ' + old[:70]
    s = s.replace(old, new, 1)


# ---- extra strings per language (inserted before "const esc") ----
extra = r'''
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
const STEPS = [6200, 8420, 7100, 9800, 5400, 11200, 8420];

'''
rep('const esc = (v)', extra + 'const esc = (v)')

# ---- headlines ----
rep("const head = { home: t.h1, summary: t.h2, paywall: t.h3 }[kind];",
    "const x = X[lang];\n  const head = { home: t.h1, summary: t.h2, paywall: t.h3, timeline: x.h4, stats: x.h5 }[kind];")

# ---- home: three metric cards instead of two ----
old_start = s.index("    rows.push({ f: 1.0, draw: (y, ch) => {\n      const half = (cw - gap) / 2;")
old_end = s.index("    rows.push({ f: 1.9, draw")
new_metrics = r'''    rows.push({ f: 1.0, draw: (y, ch) => {
      const third = (cw - 2 * gap) / 3;
      const mk = (i, ic, col, label, val, vs) => {
        const x0 = cx + i * (third + gap);
        return R(x0, y, third, ch, 44 * s, '#101E32', cardBorder, 3 * s) +
          R(x0 + pad * 0.7, y + pad * 0.7, 80 * s, 80 * s, 26 * s, col) + T(x0 + pad * 0.7 + 40 * s, y + pad * 0.7 + 55 * s, ic, 40 * s, '#07111E', 700, 'middle') +
          T(x0 + pad * 0.7, y + ch - 100 * s, label, 30 * s, '#99A8B8', 600) + T(x0 + pad * 0.7, y + ch - 36 * s, val, vs, '#F8FBFF', 700);
      };
      return mk(0, 'S', '#54E5F2', t.steps, '8.420', 60 * s) + mk(1, 'P', '#A06CFF', t.places, '4', 60 * s) + mk(2, 'R', '#F3A64A', x.rest, x.restVal, 52 * s);
    } });
'''
s = s[:old_start] + new_metrics + s[old_end:]

# ---- new kinds: timeline, stats (insert before "} else if (kind === 'summary')") ----
new_kinds = r'''  } else if (kind === 'timeline') {
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
'''
rep("  } else if (kind === 'summary') {", new_kinds + "  } else if (kind === 'summary') {")

# nav highlight
rep("const active = kind === 'home' ? 0 : 1;", "const active = (kind === 'home' || kind === 'timeline') ? 0 : (kind === 'stats' ? 2 : 1);")

# jobs
rep("for (const [i, kind] of ['home', 'summary', 'paywall'].entries()) {",
    "for (const [i, kind] of ['home', 'timeline', 'summary', 'stats', 'paywall'].entries()) {")
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched')
