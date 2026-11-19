"""Generate android/app/src/main/res/values*/strings.xml from the iOS Localizable.strings.

Usage: python tools/gen_android_strings.py
iOS keys are reused as-is; keys that only make sense on iOS are skipped and Android-specific
texts (permissions, places, voice notes) come from ANDROID below.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS = ROOT / 'ios' / 'LifeSyncAI' / 'Resources'
RES = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'

LANGS = {'en': 'values', 'it': 'values-it', 'es': 'values-es', 'fr': 'values-fr'}

# iOS-only keys (Shortcuts, Apple EULA, iOS settings wording, call detection via CallKit, Watch)
SKIP = {
    'set_auto_title', 'set_auto_body', 'set_auto_open', 'pro_terms', 'pw_terms_link',
    'tl_call_in', 'tl_call_out', 'tl_call_missed', 'backup_complete', 'backup_complete_message',
}

ANDROID = {
    'en': {
        'voice_desc': "Dictate a thought: the phone's speech recognition turns it into text for your journal. No audio is stored.",
        'voice_err_perm': 'Speech recognition was cancelled.',
        'voice_err_unsupported': 'Speech recognition is not available on this phone.',
        'voice_notes_count': 'Voice notes',
        'perm_title': 'Allow the sensors',
        'perm_body': 'LifeSync AI counts your steps with the phone\'s step sensor, records the places you visit only while the app is open, and can send you the evening reminder. Everything stays on your device.',
        'perm_button': 'Continue',
        'places_note': 'Places are recorded when you open the app.',
        'notif_channel': 'Daily summary',
        'pw_f1_s': 'Generate your evening summary whenever you want',
        'act_detected_none': 'Still',
        'pw_purchase_pending': 'Purchase pending: it will be unlocked as soon as the payment is confirmed.',
        'history_back': 'Back',
    },
    'it': {
        'voice_desc': 'Detta un pensiero: il riconoscimento vocale del telefono lo trasforma in testo per il tuo diario. Nessun audio viene salvato.',
        'voice_err_perm': 'Riconoscimento vocale annullato.',
        'voice_err_unsupported': 'Il riconoscimento vocale non è disponibile su questo telefono.',
        'voice_notes_count': 'Note vocali',
        'perm_title': 'Consenti i sensori',
        'perm_body': 'LifeSync AI conta i passi con il sensore del telefono, registra i luoghi visitati solo mentre l\'app è aperta e può inviarti il promemoria serale. Tutto resta sul tuo dispositivo.',
        'perm_button': 'Continua',
        'places_note': 'I luoghi vengono registrati quando apri l\'app.',
        'notif_channel': 'Riepilogo giornaliero',
        'pw_f1_s': 'Genera il riepilogo serale quando vuoi',
        'act_detected_none': 'Fermo',
        'pw_purchase_pending': 'Acquisto in attesa: verrà sbloccato appena il pagamento sarà confermato.',
        'history_back': 'Indietro',
    },
    'es': {
        'voice_desc': 'Dicta una idea: el reconocimiento de voz del teléfono la convierte en texto para tu diario. No se guarda audio.',
        'voice_err_perm': 'Reconocimiento de voz cancelado.',
        'voice_err_unsupported': 'El reconocimiento de voz no está disponible en este teléfono.',
        'voice_notes_count': 'Notas de voz',
        'perm_title': 'Permite los sensores',
        'perm_body': 'LifeSync AI cuenta tus pasos con el sensor del teléfono, registra los lugares visitados solo mientras la app está abierta y puede enviarte el recordatorio nocturno. Todo se queda en tu dispositivo.',
        'perm_button': 'Continuar',
        'places_note': 'Los lugares se registran cuando abres la app.',
        'notif_channel': 'Resumen diario',
        'pw_f1_s': 'Genera tu resumen nocturno cuando quieras',
        'act_detected_none': 'Quieto',
        'pw_purchase_pending': 'Compra pendiente: se desbloqueará cuando se confirme el pago.',
        'history_back': 'Atrás',
    },
    'fr': {
        'voice_desc': 'Dictez une pensée : la reconnaissance vocale du téléphone la transforme en texte pour votre journal. Aucun audio n\'est conservé.',
        'voice_err_perm': 'Reconnaissance vocale annulée.',
        'voice_err_unsupported': 'La reconnaissance vocale n\'est pas disponible sur ce téléphone.',
        'voice_notes_count': 'Notes vocales',
        'perm_title': 'Autorisez les capteurs',
        'perm_body': 'LifeSync AI compte vos pas avec le capteur du téléphone, enregistre les lieux visités uniquement quand l\'app est ouverte et peut vous envoyer le rappel du soir. Tout reste sur votre appareil.',
        'perm_button': 'Continuer',
        'places_note': 'Les lieux sont enregistrés quand vous ouvrez l\'app.',
        'notif_channel': 'Résumé quotidien',
        'pw_f1_s': 'Générez votre résumé du soir quand vous voulez',
        'act_detected_none': 'Immobile',
        'pw_purchase_pending': 'Achat en attente : il sera débloqué dès que le paiement sera confirmé.',
        'history_back': 'Retour',
    },
}

LINE = re.compile(r'^"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)";\s*$')


def parse(path):
    out = {}
    for raw in path.read_text(encoding='utf-8').splitlines():
        m = LINE.match(raw.strip())
        if m:
            out[m.group(1)] = m.group(2).replace('\\"', '"')
    return out


def to_android(value):
    has_args = bool(re.search(r'%(@|d)', value))
    v = value.replace('%@', '%1$s').replace('%d', '%1$d')
    if not has_args:
        v = v.replace('%%', '%')
    v = v.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    v = v.replace('\\', '\\\\').replace("'", "\\'").replace('"', '\\"')
    if v.startswith('@') or v.startswith('?'):
        v = '\\' + v
    return v, has_args


for lang, folder in LANGS.items():
    strings = {k: v for k, v in parse(IOS / f'{lang}.lproj' / 'Localizable.strings').items() if k not in SKIP}
    strings.update(ANDROID[lang])
    lines = ['<?xml version="1.0" encoding="utf-8"?>', '<!-- Generated by tools/gen_android_strings.py: do not edit by hand -->', '<resources>']
    for key in sorted(strings):
        value, has_args = to_android(strings[key])
        attr = '' if has_args else ' formatted="false"'
        lines.append(f'    <string name="{key}"{attr}>{value}</string>')
    lines.append('</resources>')
    target = RES / folder / 'strings.xml'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(target.relative_to(ROOT), len(strings))
