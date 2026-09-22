import re

D = {
 'it': {
  'pw_sub_length': 'LifeSync AI Pro • Abbonamento mensile (1 mese)',
  'pw_privacy_link': 'Informativa sulla privacy',
  'pw_terms_link': 'Termini di utilizzo (EULA)',
 },
 'en': {
  'pw_sub_length': 'LifeSync AI Pro • Monthly subscription (1 month)',
  'pw_privacy_link': 'Privacy Policy',
  'pw_terms_link': 'Terms of Use (EULA)',
 },
 'es': {
  'pw_sub_length': 'LifeSync AI Pro • Suscripción mensual (1 mes)',
  'pw_privacy_link': 'Política de privacidad',
  'pw_terms_link': 'Términos de uso (EULA)',
 },
 'fr': {
  'pw_sub_length': 'LifeSync AI Pro • Abonnement mensuel (1 mois)',
  'pw_privacy_link': 'Politique de confidentialité',
  'pw_terms_link': "Conditions d'utilisation (CLUF)",
 },
}

base = 'ios/LifeSyncAI/Resources/{}.lproj/Localizable.strings'
for lang, kv in D.items():
    path = base.format(lang)
    text = open(path, encoding='utf-8', newline='').read().replace('\r\n', '\n')
    existing = set(re.findall(r'^"([a-z0-9_]+)" =', text, re.M))
    add = ''.join('"%s" = "%s";\n' % (k, v.replace('"', '\\"')) for k, v in kv.items() if k not in existing)
    if not text.endswith('\n'):
        text += '\n'
    open(path, 'w', encoding='utf-8', newline='\n').write(text + '\n' + add)
    print(lang, 'added', len([k for k in kv if k not in existing]))
