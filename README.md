# Salawaat

A cross-platform Salawāt reminder app.

- **Creator / author:** Habib Akil
- **Built in collaboration with:** Abadaa Labs
- **Framework:** Flutter (iOS, Android, Web)
- **Development model:** remote-first through GitHub; no local development machine is required.

## Branches

- `main` — approved/live source.
- `staging` — continuous review branch for Habib and the app agent.

The agent should make changes on `staging`, run CI, and surface the staging preview. Production changes only move to `main` after explicit `go live` approval.

## Build

The repository deliberately keeps app source small. CI/bootstrap creates any missing Flutter platform scaffolding before analysis/build.

```bash
flutter create . --project-name salawaat --org org.abadaa --platforms=web,android,ios
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

## Vercel

Vercel can import this GitHub repository directly. `vercel.json` points Vercel at `scripts/vercel_build.sh`, which installs Flutter stable in the ephemeral build environment, creates missing web scaffolding, and produces `build/web`.

Use `main` as the Vercel Production Branch. Any push to `staging` becomes a Preview Deployment; merges to `main` become Production Deployments.
