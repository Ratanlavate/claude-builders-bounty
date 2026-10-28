# /generate-changelog Skill

Generate a structured `CHANGELOG.md` from git history since the last tag.

## Usage

Run the command in your project root:

```bash
/generate-changelog
```

Or use the bash script:

```bash
bash changelog.sh
```

## What it does

1. Finds the most recent git tag
2. Gets all commits since that tag
3. Categorizes commits into: Added, Fixed, Changed, Removed
4. Generates a properly formatted `CHANGELOG.md`
