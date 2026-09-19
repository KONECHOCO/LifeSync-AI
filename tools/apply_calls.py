import re


def read(path):
    with open(path, encoding='utf-8', newline='') as f:
        return f.read().replace('\r\n', '\n')


def write(path, text):
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def rep(text, old, new):
    assert old in text, 'missing: ' + old[:60]
    return text.replace(old, new, 1)


B = 'ios/LifeSyncAI/'

# timeline row icons for calls and messages
s = read(B + 'TimelineSection.swift')
s = rep(s, '''        case "voice": return "mic.fill"
        default: return "square.and.pencil"''', '''        case "voice": return "mic.fill"
        case "call": return "phone.fill"
        case "message": return "message.fill"
        default: return "square.and.pencil"''')
s = rep(s, '''        case "voice": return .pink
        default: return .orange''', '''        case "voice": return .pink
        case "call": return .green
        case "message": return .blue
        default: return .orange''')
write(B + 'TimelineSection.swift', s)

# start observer at launch
s = read(B + 'LifeSyncApp.swift')
s = rep(s, '        LocationManager.shared.resumeIfAuthorized()\n', '        LocationManager.shared.resumeIfAuthorized()\n        CallObserver.shared.start()\n')
write(B + 'LifeSyncApp.swift', s)

# settings: automation section
s = read(B + 'SettingsView.swift')
s = rep(s, '                Section("set_data".localized) {', '''                Section("set_auto_title".localized) {
                    Text("set_auto_body".localized)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    if let shortcutsURL = URL(string: "shortcuts://") {
                        Link("set_auto_open".localized, destination: shortcutsURL)
                    }
                }

                Section("set_data".localized) {''')
write(B + 'SettingsView.swift', s)

# frameworks
s = read('project.yml')
s = rep(s, '      - sdk: Speech.framework\n', '      - sdk: Speech.framework\n      - sdk: CallKit.framework\n      - sdk: AppIntents.framework\n')
write('project.yml', s)

# strings
D = {
 'it': {
  'tl_call_in': 'Chiamata ricevuta', 'tl_call_out': 'Chiamata effettuata', 'tl_call_missed': 'Chiamata senza risposta',
  'set_auto_title': 'Messaggi e automazioni',
  'set_auto_body': 'iOS non permette alle app di leggere o rilevare i messaggi. Puoi però registrarli tu con Comandi: apri Comandi → Automazione → Nuova automazione → Messaggio, poi scegli l\'azione "Registra evento in LifeSync". Le chiamate invece vengono rilevate automaticamente (solo orario e durata, senza numeri né contatti) mentre l\'app è attiva.',
  'set_auto_open': 'Apri Comandi',
 },
 'en': {
  'tl_call_in': 'Incoming call', 'tl_call_out': 'Outgoing call', 'tl_call_missed': 'Missed call',
  'set_auto_title': 'Messages & automations',
  'set_auto_body': 'iOS does not allow apps to read or detect messages. You can log them yourself with Shortcuts: open Shortcuts → Automation → New Automation → Message, then choose the action "Log event in LifeSync". Calls are detected automatically (time and duration only, no numbers or contacts) while the app is active.',
  'set_auto_open': 'Open Shortcuts',
 },
 'es': {
  'tl_call_in': 'Llamada recibida', 'tl_call_out': 'Llamada realizada', 'tl_call_missed': 'Llamada perdida',
  'set_auto_title': 'Mensajes y automatizaciones',
  'set_auto_body': 'iOS no permite que las apps lean ni detecten mensajes. Puedes registrarlos tú con Atajos: abre Atajos → Automatización → Nueva automatización → Mensaje y elige la acción "Registrar evento en LifeSync". Las llamadas se detectan automáticamente (solo hora y duración, sin números ni contactos) mientras la app está activa.',
  'set_auto_open': 'Abrir Atajos',
 },
 'fr': {
  'tl_call_in': 'Appel reçu', 'tl_call_out': 'Appel émis', 'tl_call_missed': 'Appel manqué',
  'set_auto_title': 'Messages et automatisations',
  'set_auto_body': 'iOS ne permet pas aux apps de lire ni de détecter les messages. Vous pouvez les enregistrer vous-même avec Raccourcis : ouvrez Raccourcis → Automatisation → Nouvelle automatisation → Message, puis choisissez l\'action « Enregistrer un événement dans LifeSync ». Les appels sont détectés automatiquement (heure et durée uniquement, sans numéros ni contacts) tant que l\'app est active.',
  'set_auto_open': 'Ouvrir Raccourcis',
 },
}
for lang, kv in D.items():
    path = B + 'Resources/%s.lproj/Localizable.strings' % lang
    text = read(path)
    existing = set(re.findall(r'^"([a-z0-9_]+)" =', text, re.M))
    add = ''.join('"%s" = "%s";\n' % (k, v.replace('"', '\\"')) for k, v in kv.items() if k not in existing)
    if not text.endswith('\n'):
        text += '\n'
    write(path, text + '\n' + add)

# privacy policy
s = read('PRIVACY.md')
s = rep(s, '- Events you add manually and voice notes.', '- Calls: start/end time, direction (incoming, outgoing, missed) and duration, detected through Apple\'s CallKit. Phone numbers and contacts are never accessed.\n- Events you add manually, events added by your own Shortcuts automations, and voice notes.')
s = rep(s, '- Eventi aggiunti manualmente e note vocali.', '- Chiamate: orario di inizio/fine, direzione (ricevuta, effettuata, senza risposta) e durata, rilevati tramite CallKit di Apple. Numeri e contatti non vengono mai letti.\n- Eventi aggiunti manualmente, eventi aggiunti dalle tue automazioni di Comandi e note vocali.')
write('PRIVACY.md', s)
print('done')
