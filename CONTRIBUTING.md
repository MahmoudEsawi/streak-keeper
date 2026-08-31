# 🤝 Contributing to My Green Graph

Thank you for your interest in contributing to **My Green Graph**! We welcome bug fixes, documentation improvements, new commit message pools, and automation features from the community.

---

## 📜 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 🛠️ How to Contribute

### 1. Reporting Bugs
- Search existing [Issues](https://github.com/MahmoudEsawi/my-green-graph/issues) to ensure the bug hasn't already been reported.
- If not, create a new issue using our **🐛 Bug Report** template, providing clear reproduction steps and error logs.

### 2. Suggesting Enhancements
- Have an idea for new conventional messages, scheduling patterns, or CI/CD automations? Open an issue using our **✨ Feature Request** template.

### 3. Submitting Pull Requests
1. **Fork** the repository and clone your fork locally.
2. **Create a branch** for your work:
   ```bash
   git checkout -b feat/add-new-feature
   # or
   git checkout -b fix/resolve-issue-name
   ```
3. **Make your changes**:
   - Follow clean scripting practices in `scripts/`.
   - Update `config/messages.json` if adding new commit messages.
   - Update relevant documentation in `docs/` and `README.md`.
4. **Test your changes locally**:
   ```bash
   bash scripts/generate_commits.sh --dry-run --count 3
   jq empty config/messages.json
   ```
5. **Commit using Conventional Commits**:
   ```bash
   git commit -m "feat(generator): add support for weekend frequency toggles"
   ```
6. **Push to your fork** and submit a **Pull Request** targeting the `main` branch.

---

## 📋 PR Guidelines

- Ensure your branch is up-to-date with `upstream/main`.
- Fill out the provided [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md).
- Automated CI quality checks will run on your PR; ensure all checks pass.

Thank you for helping make open source awesome! 💚
