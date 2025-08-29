# Contributing to Grader

## Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit: `git commit -m 'Add amazing feature'`
6. Push: `git push origin feature/amazing-feature`
7. Create a Pull Request

## Release Process

### Versioning
We use [Semantic Versioning](https://semver.org/): `vX.Y.Z`

- **X** - Major version (breaking changes)
- **Y** - Minor version (new features, backward compatible)
- **Z** - Patch version (bug fixes, backward compatible)

### Creating a Release

1. Update version in:
   - `ios/Runner/Info.plist` (CFBundleShortVersionString)
   - `pubspec.yaml` (version)
   - `appstore/release-notes/`

2. Create and push tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

3. GitHub Actions will automatically:
   - Build iOS app
   - Upload to TestFlight
   - Create artifacts

### Release Notes

Update both language versions:
- `appstore/release-notes/ru-RU.txt`
- `appstore/release-notes/en-US.txt`

## Code Style

- Follow Flutter/Dart conventions
- Use meaningful commit messages
- Test on both iOS and Android
- Update documentation for new features

## Testing

- Run `flutter test` before committing
- Test on physical devices when possible
- Verify iOS build with `./scripts/ios.sh doctor`

## Questions?

Contact: support@grader.ai
