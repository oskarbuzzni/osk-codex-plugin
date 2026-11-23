---
name: pull
description: Use when the user asks to commit the current branch's work with a Korean message, update the base branch, merge it into the current branch, and resolve conflicts in favor of the current branch. Verifies and commits existing work first when present, fetches the latest base branch, merges it, resolves conflicts, verifies the result, and creates the merge commit.
---

# Pull

Use this skill when the user asks for this Korean workflow:

> 현재 브랜치의 작업을 한글 메시지로 커밋하고, 기준 브랜치를 최신화해서 현재 브랜치에 머지하고, 충돌이 생기면 현재 브랜치의 의도를 기준으로 해결한 뒤 커밋해줘

## Objective

Commit the current branch's existing work with a concise Korean message when changes are present, then bring the latest base-branch changes into the current branch and commit the merge. When conflicts occur, preserve the current branch's behavior and intent while retaining compatible updates from the base branch.

## Workflow

1. Confirm the repository state.
   - Run `git status --short --branch` and identify the current branch and remote.
   - Do not continue when the current branch is the base branch or another merge, rebase, or cherry-pick is already in progress.
   - Allow tracked and untracked working-tree changes; commit them separately before the merge in the next step.

2. Commit the current branch's work when changes exist.
   - Inspect staged, unstaged, and untracked changes before staging. Treat them as the current task's work, but do not blindly include credentials, temporary files, generated artifacts, or clearly unrelated changes.
   - Run `git diff --check` and the highest-signal relevant tests or checks for the changed files.
   - Stage only the intentional current-task changes, review the staged diff, and commit them with a concise Korean message that describes the work.
   - If verification fails or the changes cannot safely form one logical commit, stop and report the issue instead of starting the merge.
   - If the worktree is already clean, continue without creating a pre-merge commit.

3. Determine the base branch.
   - Prefer the base branch named by the user.
   - Otherwise use the repository's default remote branch when discoverable.
   - If it is not discoverable, use `main` when it exists; otherwise ask which base branch to use.

4. Fetch the latest base branch.
   - Fetch the matching remote base branch without switching away from the current branch.
   - Prefer merging the refreshed remote-tracking ref such as `origin/<base>`.
   - If no matching remote exists, use the local base branch and clearly report that it could not be refreshed from a remote.
   - Do not rewrite, reset, or force-update branches.

5. Merge into the current branch.
   - Merge with `--no-ff --no-commit` so the result can be reviewed and committed explicitly.
   - If the branch is already up to date, do not create an empty commit; report that no commit was needed.

6. Resolve conflicts in favor of the current branch's intent.
   - List every unmerged path with `git diff --name-only --diff-filter=U` and inspect each conflict in context.
   - Treat the current branch's behavior, requirements, and deliberate edits as authoritative when they conflict with the base branch.
   - Preserve non-conflicting and compatible base-branch changes. Do not resolve the whole tree mechanically with `git checkout --ours .` or an equivalent command.
   - If a binary conflict or ambiguous product decision cannot be resolved safely, stop with the merge in progress and ask the user for the missing decision.
   - Stage only the resolved merge paths and confirm that no unmerged entries remain.

7. Verify and commit.
   - Review the staged merge diff and run `git diff --check`.
   - Run the highest-signal relevant tests or checks for conflicted or materially changed files.
   - Commit with a concise Korean merge message such as `최신 <base> 브랜치 병합`.
   - Do not push or create a pull request unless the user separately asks.

## Response Format

Keep the final response concise and Korean by default.

Include:

- 선행 작업 커밋과 메시지, 또는 작업 트리가 이미 깨끗했던 사실
- 기준 브랜치와 병합한 ref
- 충돌 파일과 해결 기준
- 생성한 커밋과 메시지, 또는 이미 최신이어서 커밋하지 않은 사실
- 실행한 검증 명령
- 남은 리스크나 사용자 결정이 필요한 충돌
