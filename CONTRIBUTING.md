# Contributing to Tubular PC

Thank you for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (OS, versions)
   - Logs/screenshots if applicable

### Suggesting Features

1. Check if the feature has been suggested
2. Create an issue with:
   - Clear description of the feature
   - Use cases
   - Potential implementation approach

### Code Contributions

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages: `git commit -m 'Add amazing feature'`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Open a Pull Request

## Development Guidelines

### Backend (Rust)

- Follow Rust naming conventions
- Use `cargo fmt` before committing
- Run `cargo clippy` to catch common issues
- Add tests for new functionality
- Document public APIs

```bash
cargo fmt
cargo clippy
cargo test
```

### Frontend (Flutter)

- Follow Dart style guide
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues
- Keep widgets small and focused
- Use Riverpod for state management

```bash
flutter format .
flutter analyze
flutter test
```

### Commit Messages

Use clear, descriptive commit messages:

- `feat: Add video quality selection`
- `fix: Resolve stream URL extraction issue`
- `docs: Update installation instructions`
- `refactor: Simplify API service code`
- `test: Add tests for video search`

### Code Style

#### Rust
```rust
// Good
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    // Implementation
}

// Use descriptive names
// Add error handling
// Document complex logic
```

#### Dart
```dart
// Good
class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoCard({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Testing

### Backend Tests

```bash
cd backend
cargo test
```

### Frontend Tests

```bash
cd frontend
flutter test
```

### Integration Testing

1. Start backend: `cd backend && cargo run`
2. Test API endpoints manually or with tools like Postman
3. Run frontend: `cd frontend && flutter run`
4. Test user flows

## Pull Request Process

1. Update README.md if needed
2. Update CHANGELOG.md with your changes
3. Ensure all tests pass
4. Request review from maintainers
5. Address review feedback
6. Squash commits if requested

## Code Review

We review PRs for:

- Code quality and style
- Test coverage
- Documentation
- Performance implications
- Security considerations

## Areas Needing Help

- [ ] SponsorBlock integration
- [ ] Return YouTube Dislike API
- [ ] Playlist support
- [ ] Better error handling
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Documentation
- [ ] Testing

## Questions?

Feel free to:
- Open an issue for discussion
- Join our community chat (if available)
- Email maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🚀
