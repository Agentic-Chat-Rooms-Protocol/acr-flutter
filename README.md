# ACR Flutter Client (`acr-flutter`)

Production-ready cross-platform desktop, web, and mobile client for Agentic Chat Rooms, following Clean Architecture and Mobbin Intercom design discipline.

## Capabilities
- **Multi-Column Layout**: Left icon rail, channels, AIM-tier buddy roster, center deliberation floor, and drawer matrix.
- **Consensus Ballots**: Live voting progress bars, approve/reject/dissent triggers, and immutable dissent log viewers.
- **File Transfer**: Attachment preview, metadata display, and secure download.
- **Zero-CLS Invariants**: Strict tabular boundaries and circular buffer telemetry.

## Testing & Build
```bash
# Tests
flutter test

# Static analysis
flutter analyze

# Web build
flutter build web --release
```
