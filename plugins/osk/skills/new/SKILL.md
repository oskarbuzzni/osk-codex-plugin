---
name: new
description: Use when the user types "new", "/new", or asks to run "기준 브런치에서 새로 브런치 따서 새 작업 시작하자". Starts a new task by creating a new branch from the base branch.
---

# New

Use this skill when the user invokes `new`, `/new`, `새 작업 시작`, or asks for this Korean workflow:

> 기준 브런치에서 새로 브런치 따서 새 작업 시작하자

## Workflow

1. Confirm the current repository and branch.
   - Use `git status --short --branch`.
   - If there are uncommitted changes, stop and explain that a new branch should not be created until those changes are committed, stashed, or explicitly carried forward.

2. Determine the base branch.
   - Prefer the base branch named by the user.
   - If the user does not name one, use the repository's default remote branch when discoverable.
   - If that is not discoverable, use `main` when it exists, otherwise ask which base branch to use.
   - Identify its matching remote from repository configuration rather than assuming `origin`.

3. Resolve the starting commit safely.
   - When the base has a remote counterpart, fetch that branch and resolve the fetched commit as the starting point (for example, `git fetch <remote> <base>` followed by `git rev-parse 'FETCH_HEAD^{commit}'`). Use that resolved commit in step 4, rather than a potentially stale or divergent local base branch.
   - Do not check out the base first; it may already be checked out in another worktree. Leave that checkout and the local base branch unchanged unless their update is requested.
   - If a local base update is requested, allow only a fast-forward through the appropriate checkout. If it has diverged or cannot be updated safely, preserve it and report the condition; do not create an automatic merge, rebase, reset, or forced branch update.
   - If fetching fails, report the blocker instead of silently using stale refs or claiming the base is current. If no matching remote exists, use the local base commit and disclose that no remote freshness check was possible.

4. Create a new work branch.
   - Create and switch directly from the resolved starting commit (for example, `git switch -c <new-branch> <starting-sha>`).
   - Follow applicable user, repository, and environment branch-naming instructions according to their priority. If no prefix is specified, default to `oskar/`.
   - Choose a short, descriptive branch name from the user's task when available.
   - If no task is provided yet, use a timestamped branch name.

5. Continue the work.
   - Tell the user the new branch name.
   - Ask for the feature or task only if the user has not provided it yet.

## Response Format

Keep the final response concise and Korean by default.

Include:

- 기준 브런치·원격과 실제 출발 커밋(원격 최신화 확인 여부 포함)
- 새 브런치
- 수행한 git 명령 요약
- 진행을 막은 미커밋 변경이 있으면 그 사실
