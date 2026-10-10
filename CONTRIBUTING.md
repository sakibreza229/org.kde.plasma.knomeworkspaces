# Contributing to Knome Workspace Switcher

Thanks for your interest in contributing! Bug reports, feature ideas, and pull requests are all welcome.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to contribute

- **Report a bug**: [open an issue](https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces/issues/new?template=bug_report.yml)
- **Request a feature**: [open a feature request](https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces/issues/new?template=feature_request.yml)
- **Ask a question or share an idea**: use [Discussions](https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces/discussions)
- **Send a pull request**: see below

Please search existing issues and discussions before opening a new one.

## Reporting bugs

A good bug report includes:

- Widget version (see `metadata.json` or the release you installed)
- Plasma version and distro
- Panel setup (horizontal or vertical, floating, multi-monitor)
- Steps to reproduce, what you expected, and what happened
- Screenshots or a short screen recording, if relevant

## Development setup

### Requirements

- KDE Plasma 6.0+
- `plasma5support` package
- `kpackagetool6` (included with Plasma)

### Get the code

```bash
git clone https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces.git
cd org.kde.plasma.knomeworkspaces
```

### Install for testing

Install the widget from your local folder:

```bash
kpackagetool6 -t Plasma/Applet -i .
```

After making changes, upgrade the installed copy:

```bash
kpackagetool6 -t Plasma/Applet -u .
```

If changes don't appear, restart the shell:

```bash
systemctl --user restart plasma-plasmashell
```

Then add **Knome Workspace Switcher** to your panel via **Add Widgets**.

### Project structure

```
contents/        QML source, config, and UI files
metadata.json    Plasmoid metadata (name, version, ID)
CHANGELOG.md     Notable changes per version
```

## Submitting a pull request

1. **Fork** the repository and create a branch from `main`:
```bash
   git checkout -b feature/short-description
```
2. Make your changes. Keep each pull request focused on one thing.
3. **Test** on Plasma 6 and confirm the widget loads without errors.
4. Update `CHANGELOG.md` if your change is user-facing.
5. Commit with a clear message:
```
   Fix active dot misalignment on vertical panels
```
6. Push your branch and open a pull request. Describe what changed and why, and link the related issue (for example, `Closes #12`).

### Guidelines

- Keep the design **minimal and clean**. This widget aims to stay lightweight, so changes that add a lot of visual or code complexity may be declined.
- Follow the existing code style and naming in the files you edit.
- Don't bundle unrelated changes or formatting-only rewrites with a fix.
- New settings should have sensible defaults and appear in the configuration dialog.
- Test with both horizontal and vertical panels when your change affects layout.
- For larger features, **open an issue or discussion first** so we can agree on the approach before you spend time on it.

## License

By contributing, you agree that your contributions will be licensed under the project's [GPL-3.0](LICENSE) license.

## Questions?

Start a [discussion](https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces/discussions). Happy to help.
