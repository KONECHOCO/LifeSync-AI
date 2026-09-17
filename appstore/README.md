# App Store Connect — Metadata multi-lingua

Questa cartella contiene i testi per la scheda App Store di **LifeSync AI** in quattro lingue
(`en-US`, `it`, `es-ES`, `fr-FR`), pronti per essere incollati manualmente in App Store Connect
o caricati via API/fastlane una volta che l'app esiste e le credenziali sono disponibili.

Struttura (uno per locale, stile fastlane `deliver`):

```
appstore/metadata/<locale>/
├── name.txt              # Nome app (max 30 caratteri)
├── subtitle.txt           # Sottotitolo (max 30 caratteri)
├── description.txt        # Descrizione completa (max 4000 caratteri)
├── keywords.txt            # Parole chiave separate da virgola, senza spazi (max 100 caratteri)
├── promotional_text.txt    # Testo promozionale, aggiornabile senza nuova review (max 170 caratteri)
├── release_notes.txt       # Note di rilascio ("What's New") per questa versione
├── support_url.txt         # URL di supporto (obbligatorio)
├── marketing_url.txt       # URL marketing (opzionale)
└── privacy_url.txt         # URL informativa privacy (obbligatorio per la submission)
```

## ⚠️ Prima di poter sottomettere davvero l'app, servono ancora 3 cose

Questi contenuti **non sono ancora stati inviati** ad Apple: al momento della stesura di questi
file, nell'ambiente non erano disponibili le credenziali API necessarie, l'app non risultava
ancora creata su App Store Connect e il repository non contiene un progetto Xcode compilabile
(manca `.xcodeproj`/`.xcworkspace`, `Info.plist`, asset catalog, firma). Prima di una submission
reale occorre:

1. **Registrare il Bundle ID e creare l'app su App Store Connect**
   (developer.apple.com → Certificates, Identifiers & Profiles → registra un Bundle ID, es.
   `com.lifesync.ai`; poi App Store Connect → Le mie App → +).
2. **Creare una API Key di App Store Connect** (Users and Access → Integrations → App Store
   Connect API, ruolo *App Manager* o *Admin*) e impostare le variabili d'ambiente:
   ```bash
   export ASC_KEY_ID="..."
   export ASC_ISSUER_ID="..."
   export ASC_PRIVATE_KEY_PATH="/percorso/sicuro/AuthKey_XXXX.p8"
   ```
3. **Completare il progetto iOS** in `ios/LifeSyncAI/` in un vero progetto Xcode buildabile
   (target, `Info.plist`, entitlements per In-App Purchase / Location / DeviceActivity, asset
   catalog con icona), e produrre almeno una build caricata su App Store Connect (via Xcode,
   Transporter, o una pipeline CI come Codemagic) — una versione non può essere sottomessa alla
   review senza un binario associato.

Vanno inoltre sostituiti tutti i placeholder `https://TODO-add-your-*-url` in ciascun locale con
URL reali e funzionanti: **support_url** e **privacy_url** sono obbligatori per la submission.

## Una volta pronti app + credenziali + build

Con le variabili d'ambiente impostate, la skill `appstore-connect-manager` può leggere lo stato
dell'app e caricare questi testi per ogni locale, ad esempio:

```bash
python scripts/asc_client.py get-metadata <VERSION_ID> --locale it
python scripts/asc_client.py update-metadata <VERSION_ID> --locale it \
  --description "$(cat appstore/metadata/it/description.txt)" \
  --keywords "$(cat appstore/metadata/it/keywords.txt)" \
  --promotional-text "$(cat appstore/metadata/it/promotional_text.txt)" \
  --whats-new "$(cat appstore/metadata/it/release_notes.txt)" \
  --support-url "$(cat appstore/metadata/it/support_url.txt)"
# ripetere per en-US, es-ES, fr-FR
python scripts/asc_client.py submit <VERSION_ID>   # solo dopo conferma esplicita
```

La sottomissione (`submit`) resta un passaggio da confermare esplicitamente con l'utente prima di
essere eseguito.
