# 🛠️ Setup & Development Guide

This guide covers everything needed to configure, run, and test **`my-green-graph`** locally or in your GitHub repository.

---

## 💻 Local Testing & Development

### 1. Prerequisites
- `git` (v2.20+)
- `bash` (v3.2+)
- `jq` (optional, for JSON message parsing validation)

### 2. Clone the Repository
```bash
git clone https://github.com/MahmoudEsawi/my-green-graph.git
cd my-green-graph
```

### 3. Run a Dry Run
Simulate commit generation without creating git commits or modifying your repo history:
```bash
bash scripts/generate_commits.sh --dry-run --count 3
```

### 4. Custom Author Simulation
```bash
bash scripts/generate_commits.sh --dry-run --count 5 \
  --author-name "Developer Name" \
  --author-email "dev@example.com"
```

---

## ⚙️ GitHub Repository Configuration

### Step 1: Grant Workflow Write Permissions
1. In your GitHub repository, open **Settings** > **Actions** > **General**.
2. Scroll to **Workflow permissions**.
3. Enable **Read and write permissions**.
4. Check **Allow GitHub Actions to create and approve pull requests** (optional).
5. Click **Save**.

### Step 2: Configure Author Identity *(Recommended)*
To ensure commits are credited to your profile:
1. Go to **Settings** > **Secrets and variables** > **Actions** > **Variables** tab.
2. Click **New repository variable**:
   - `GIT_USER_NAME`: Your GitHub display name (e.g., `Mahmoud Al-Esawi`)
   - `GIT_USER_EMAIL`: Your GitHub account email address (e.g., `esawi@ieee.org`)

### Step 3: Trigger a Manual Test Run
1. Go to the **Actions** tab on GitHub.
2. Select **⚡ Auto Streak Updater** from the left sidebar.
3. Click **Run workflow** > Select branch `main` > Click **Run workflow**.
4. Once completed, inspect the **Job Summary** to view the generated commits.

---

## 🔍 Troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| **`Permission to repo denied to github-actions[bot]`** | Workflow lacks write permissions | Enable **Read and write permissions** under **Settings > Actions > General**. |
| **Commits not showing on profile heatmap** | Email mismatch | Ensure `GIT_USER_EMAIL` matches the email associated with your GitHub account. |
| **Workflow failing with rebase conflict** | Branch out of sync | The workflow runs `git pull --rebase` before pushing. Verify branch protection settings. |
