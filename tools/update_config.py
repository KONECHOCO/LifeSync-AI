p = 'project.yml'
s = open(p, encoding='utf-8', newline='').read().replace('\r\n', '\n')

# Permessi microfono / riconoscimento vocale + lingue supportate
old = '        NSUserTrackingUsageDescription:'
assert old in s
s = s.replace(
    old,
    '        NSMicrophoneUsageDescription: "LifeSync AI usa il microfono per registrare le tue note vocali. L\'audio viene trascritto sul dispositivo e poi eliminato."\n'
    '        NSSpeechRecognitionUsageDescription: "LifeSync AI usa il riconoscimento vocale sul dispositivo per trascrivere le tue note vocali."\n'
    '        CFBundleLocalizations:\n'
    '          - it\n'
    '          - en\n'
    '          - es\n'
    '          - fr\n'
    '        NSUserTrackingUsageDescription:',
    1,
)

# Framework
old = '      - sdk: AppTrackingTransparency.framework\n'
assert old in s
s = s.replace(old, old + '      - sdk: Speech.framework\n      - sdk: AVFoundation.framework\n', 1)
open(p, 'w', encoding='utf-8', newline='\n').write(s)

# Privacy manifest: UserDefaults (@AppStorage) richiede un motivo dichiarato
p = 'ios/LifeSyncAI/PrivacyInfo.xcprivacy'
s = open(p, encoding='utf-8', newline='').read().replace('\r\n', '\n')
old = '\t<key>NSPrivacyAccessedAPITypes</key>\n\t<array/>\n'
assert old in s
new = '''\t<key>NSPrivacyAccessedAPITypes</key>
\t<array>
\t\t<dict>
\t\t\t<key>NSPrivacyAccessedAPIType</key>
\t\t\t<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
\t\t\t<key>NSPrivacyAccessedAPITypeReasons</key>
\t\t\t<array>
\t\t\t\t<string>CA92.1</string>
\t\t\t</array>
\t\t</dict>
\t</array>
'''
s = s.replace(old, new, 1)
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('config ok')
