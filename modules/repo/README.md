# Repo Module

Git workflow module handling pull, push, squash, rebase, and session logging. Used by `tasks/repo.rake` and Copilot prompts.

## Files

| File | Namespace | Purpose |
|------|-----------|---------|
| `pull.rb` | `Repo::Pull` | Pull latest changes from git remote |
| `push.rb` | `Repo::Push` | Run tests, commit, and push to git remote |
| `log.rb` | `Repo::Log` | Save a timestamped session log to `logs/` |
| `squash.rb` | `Repo::Squash` | Anchored squash of all commits to root commit |
| `rebase.rb` | `Repo::Rebase` | Rebase onto remote default branch |

---

## `Repo::Pull` — `/pull`

Pull updates from git remote to local repository.

**Workflow:**
1. Check working directory status
2. Stash uncommitted changes if present (`git stash push --all`)
3. `git pull --rebase origin <branch>` — handles diverged branches cleanly
4. Restore stash if changes were stashed
5. Show git status summary of what changed

**Features:**
- Safe stash/restore around the pull
- Rebase-based pull avoids unnecessary merge commits
- Reports new changes after pull for manual review

**When to Use:**
- Start of a work session — get latest from remote
- After changes were pushed from another device

**Rake task:** `rake repo:pull`
**Prompt:** `/pull`

---

## `Repo::Push` — `/push`

Run linting, tests, commit all changes, and push to git remote.

**Workflow:**
1. `bundle exec rake fix` — RuboCop autocorrect
2. `bundle exec rake test` — RuboCop + yamllint (stops on failure)
3. Confirm push (interactive, skipped when called via rake)
4. Stash local changes → `git pull --rebase origin <branch>` → restore stash
5. `git add .` + `git commit -m "Push repository: Automated commit YYYY-MM-DD HH:MM:SS"`
6. `git push`

**Features:**
- Tests must pass before any git operations run
- Stash/restore ensures a clean pull before committing
- Explicit `origin <branch>` pull avoids ambiguous tracking config

**When to Use:**
- End of a work session — save and push everything
- After completing a feature or fix
- Before switching devices

**Rake task:** `rake repo:push`
**Prompt:** `/push`

---

## `Repo::Squash` — `/squash`

Anchored squash: collapses all commits after the root commit into a single commit, then optionally force pushes.

**Workflow:**
1. Find the root commit (`git rev-list --max-parents=0 HEAD`)
2. Collect all commit subjects after the root (oldest → newest)
3. Build and display the squash commit message:
   ```
   SQUASHED:

   - commit subject one
   - commit subject two
   ```
4. Prompt: *"Proceed with this commit message?"*
5. Prompt: *"Squash all commits locally? This rewrites history."*
6. `git reset --soft <root_sha>` → `git commit --amend -m "SQUASHED: ..."`
7. Prompt: *"Force push to remote?"* → `git push --force-with-lease`

**When to Use:**
- Before opening a pull request — clean up a noisy commit history
- After iterative local work — consolidate into one meaningful commit

**Rake task:** `rake repo:squash`
**Prompt:** `/squash`

---

## `Repo::Rebase` — `/rebase`

Rebase the current branch onto the remote default branch, with an optional pre-squash step.

**Workflow:**
1. Prompt: *"Run squash before rebasing? [y/N]"*
   - If yes → delegates to `Repo::Squash.run` and returns
2. `git fetch --prune`
3. Auto-detect base branch (`origin/main` → `origin/master` → `origin/HEAD`)
4. `git rebase <base>`

**When to Use:**
- To bring a branch up to date with main before merging
- After squashing — rebase to apply cleanly on top of remote

**Rake task:** `rake repo:rebase`
**Prompt:** `/rebase`

---

## `Repo::Log` — session logging

Save a markdown session log to `logs/` with a timestamped filename.

**Workflow:**
1. Prompt for a log title (if not provided)
2. Generate filename: `YYYYMMDDHHMM_slug.md`
3. Write log template to `logs/` (creates directory if needed)

**Log Template:**
```markdown
# <title>

Date: <ISO 8601 timestamp>

## Summary
## Code Changes
## Validation
## Notes
```

**When to Use:**
- End of a coding session — record what was done
- After a significant change — document the work

**Rake task:** `rake repo:log`
