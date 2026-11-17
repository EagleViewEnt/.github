---
mode: agent
description: Complete the current work item through issue, branch, commit, pull request, merge, closure, and safe cleanup.
---

Complete the current repository work item from implementation through merged pull request. Treat this as a request to perform the workflow, not merely describe it. Do not stop for routine confirmations. Stop and report the exact blocker if a required safety condition is not met.

## 1. Inventory all changes and establish safety

- Read and follow organization, repository, and user instructions.
- This prompt authorizes closing **all safe Git changes in the current repository**, including changes made before this invocation. Do not stop or omit work merely because it predates the current request or spans multiple related files.
- Inventory the complete state before editing: `git status --short --branch --untracked-files=all`, staged and unstaged diffs, every untracked path, current branch/upstream, local commits not on the upstream, repository default branch, related issues/PRs, and applicable tests/builds. Inspect every changed and untracked file before staging it. If the worktree is clean and there are no local commits ahead of the upstream, report that there is nothing to close; do not create an empty issue, branch, commit, or PR.
- Preserve every legitimate source, test, and documentation change. Group distinct work items into separate issues/commits/PRs when they can be partitioned safely; otherwise use one clearly described umbrella issue/PR. Do not silently drop changes because they are difficult to categorize.
- Never commit secrets, credentials, generated binaries/databases, caches, or temporary artifacts. Do not delete or overwrite them to make the workflow pass. If any change cannot safely be included or retained, stop and identify the exact path and required owner decision.
- Do not rewrite or amend existing commits unless explicitly requested. Do not use destructive cleanup commands. Audit pre-existing as well as newly created temporary and zero-byte files as specified below; inspect each resolved path and determine whether it is safe to remove before acting.

## 2. Issue and branch linkage

- Find suitable open issue(s) for all inventoried work. Reuse matching issues; create concise issues with context and acceptance criteria only where needed, avoiding duplicates. Link each coherent work item to its issue.
- Never commit work directly to the default branch. If already on an appropriate task branch, keep using it. If the worktree is dirty on the default branch, create the issue-linked branch from the current `HEAD` without stashing, resetting, cleaning, or overwriting files; verify that every staged, unstaged, and untracked change remains intact after switching. Prefer `gh issue develop <number> --name <branch-name>` when it preserves the complete worktree; otherwise create an issue-number-prefixed branch from the current `HEAD` with Git and verify status immediately.
- If the current tree cannot be moved to a task branch without losing or altering changes, stop before any destructive action and report the exact blocker. Never force-push or rewrite existing branch history.

## 3. Finish, validate, and stage all safe work

- Complete the inventoried work, following repository conventions. Keep changes surgical and update directly related documentation; do not introduce unrelated features.
- Run the smallest relevant tests, then the required project build for each affected project. Resolve failures caused by this work before proceeding. Never claim tests, builds, or physical validation that were not performed.
- Before the final commit, audit the repository worktree for temporary files and zero-byte regular files, including untracked and ignored paths (exclude Git's internal `.git` data). Inspect each candidate and its references. Remove temporary artifacts and zero-byte files individually; do not exempt placeholders such as `.gitkeep`. Include tracked-file removals in the PR so the merged branch contains the cleanup. If a candidate cannot safely be removed without damaging required application/tooling behavior, report its exact path and the verification needed rather than silently leaving it.
- Recheck status and review the complete final diff, including staged, unstaged, untracked, and local unpushed commits. Stage every inspected, legitimate change intended for closure, and no secret, generated binary/database, cache, temporary artifact, or unresolved zero-byte file. Do not use `git add -A`; use explicit paths (including verified untracked paths) and inspect the staged diff before committing.
- Confirm that no legitimate repository change remains unstaged or uncommitted. If a change is intentionally excluded for a safety reason, report it and the exact blocker instead of claiming all changes are closed.

## 4. Commit, push, PR, and merge

- Create a descriptive commit for the verified task changes. Include the repository-required Copilot co-author trailer unless repository/user instructions say otherwise.
- Push the issue-linked branch to the repository remote.
- Create or update one PR for this issue. Include `Fixes #<issue-number>` in the PR body so GitHub links the issue and closes it on merge. Describe changes and actual validation results; do not overstate them.
- Wait for required CI/review checks. Merge only when merge requirements pass and the PR is mergeable. Use the repository's configured merge method; do not bypass protections, dismiss reviews, or force-merge failing checks. If blocked, leave the issue/branch/PR intact and report what's required.
- After GitHub confirms the merge, verify the linked issue is closed. If GitHub did not close it automatically, close the issue with a concise completion note referencing the merged PR.
- After the merge is confirmed, remove any remaining temporary files and zero-byte regular files identified in the worktree audit, including untracked/ignored files; exclude only Git's internal `.git` data. Inspect each resolved file before deletion and remove files individually. Do not delete tracked content after merge unless its deletion was included in the merged PR. If a candidate cannot safely be removed without damaging required application/tooling behavior, report its exact path and the verification needed.
- Then delete the merged task branch both locally and remotely, but only after confirming the PR is merged, the issue is closed, and the branch has no unmerged work. Verify the current branch is not the task branch before deleting it. Never delete the default branch or any other branch. If deletion is blocked, report the exact branch and reason.

## 5. Final cleanup and report

- Close only temporary files created/opened by this invocation, and only if an available IDE action can identify them reliably. Never close unrelated user editor tabs. If the editor does not expose a safe close operation, report that rather than guessing.
- Complete the temporary/zero-byte file audit and cleanup described above. Never use broad wildcard deletion; remove only individually inspected paths confirmed safe to remove. Do not scan-delete or truncate application files, databases, logs, or user data. Do not leave confirmed temporary or zero-byte files behind unless a specific required-use safety blocker is reported.
- Verify the PR is merged, linked issues are closed, the local and remote task branches are deleted, and the worktree has no remaining task changes. Report any cleanup or branch deletion that could not be completed, with the exact path/branch and reason.
- Finish with a concise report of issue, branch, commit, PR/merge, validation, removed temporary/zero-byte artifacts, branch cleanup, and any actions blocked by permissions or external policy.

## 6. MCP
- Use github.MCP