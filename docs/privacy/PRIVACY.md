# Privacy & Child Safety

## Privacy-First Design

This application is designed with privacy and child safety as core principles.

## Data Collection

### What We Collect

- **Progress Data**: XP, levels, badges, stars (metadata only)
- **App Usage**: Basic analytics for app improvement
- **No Handwriting Data**: Stroke data never leaves the device

### What We Don't Collect

- ❌ Handwriting stroke data
- ❌ Images of handwriting
- ❌ Personal information without parent consent
- ❌ Location data
- ❌ Device identifiers (unless for sync)

## Data Storage

### Local Storage

- All handwriting practice data stored locally on device
- SQLite database for progress tracking
- SharedPreferences for app settings

### Cloud Sync (Optional)

- Only progress metadata is synced (XP, levels, badges)
- Requires explicit parent consent
- Encrypted in transit and at rest
- No handwriting data included

## Child Safety

### COPPA Compliance

- No data collection from children under 13 without parent consent
- Parent controls for all data sharing features
- Clear privacy policy accessible to parents

### Content Safety

- No external links without parent gate
- No social features or communication
- No advertisements (if applicable)

## Parent Controls

- Settings screen accessible via parent gate
- Control over cloud sync
- Data export/deletion options
- Progress visibility controls

## ML Model Privacy

- All ML inference happens on-device
- No handwriting data sent to servers
- Pretrained models are static (no learning from user data)
- Model updates via app updates only

## Data Retention

- Local data: Retained until app uninstall or user deletion
- Cloud data: Deletable via parent controls
- No indefinite data retention

## Future Considerations

- GDPR compliance for international users
- Parent dashboard (if implemented) with full data visibility
- Data portability features
