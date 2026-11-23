---
name: pushpr
description: Use when the user types "pushpr", "/pushpr", or requests the Korean commit and PR workflow. Cross-checks with a separate agent, verifies UI flows in the actual app with screenshots or valid prior evidence, commits in Korean, integrates the latest base, handles PR CI and reviews, and merges when authorized and ready.
---

# Push PR

Use this skill when the user invokes `pushpr`, `/pushpr`, `PR 만들어줘`, or asks for this Korean workflow:

> 별도 에이전트로 크로스 체크하고 커밋로그를 한글로 해서 커밋해줘. 최신 기준 브런치를 가져와 머지하고 충돌을 해결한 뒤 push하고 PR을 만들어줘. CI와 리뷰 결과를 기다리고 이슈를 해결한 다음, 모두 통과하고 머지 가능한 상태가 되면 머지까지 해줘.

For UI-affecting changes, also apply:

> 실제 앱을 클릭하며 사용 흐름과 누락을 확인하고 대표 화면을 캡처해줘. cleancode에서 이미 검증했고 이후 관련 변경이 없으면 기존 결과와 캡처를 재사용해줘. 병합이나 리뷰 수정으로 영향이 생긴 흐름만 다시 검증하고 캡처해줘.

## Scope

The user's configured `pushpr` / `/pushpr` workflow includes merging the PR after the conditions below are met; do not ask again for the same authorized merge. Honor narrower instructions such as "PR만 생성" or "머지하지 마". A generic "PR 만들어줘" request alone authorizes PR creation, not merging. Preserve applicable approval checkpoints and access restrictions; this skill does not grant unrelated external actions or bypass repository protections.

## Workflow

1. Confirm repository state.
   - Use `git status --short --branch --untracked-files=all`.
   - Identify the current branch and remote.
   - Do not continue if the current branch is the base branch.

2. Determine the base branch.
   - Prefer a base branch named by the user.
   - Otherwise use the repository's default remote branch when discoverable.
   - If not discoverable, use `main` when it exists; otherwise ask which base branch to use.

3. Review and verify changes before committing.
   - Inventory committed branch changes with `git diff <base>...HEAD`, staged changes with `git diff --cached`, unstaged changes with `git diff`, and new files with `git ls-files --others --exclude-standard`. Read relevant new files explicitly; ordinary diffs omit untracked files. Identify which changes belong to this task before staging or reviewing them.
   - Inspect the diff enough to write an accurate Korean commit message.
   - Run an independent, read-only review with a separate agent when delegation tools are available. Provide the repository, comparison base, branch and uncommitted change scope, user requirements, and applicable repository instructions; ask it to inspect the actual diff and surrounding code without treating the primary agent's conclusions as the expected answer.
   - Request concrete logic/scenario regressions, failure/retry issues, unnecessary code, and missing regression coverage with severity, file/line references, and a failing scenario. The review agent must not edit files, commit, push, or contact other chats.
   - Wait for the findings, verify each against the code, fix confirmed issues within scope, and explain rejected findings. Recheck affected changes with the reviewer when fixes alter behavior or leave a finding unresolved.
   - If delegation is unavailable, report the missing independent review and perform the checks directly; do not present self-review as independent review.
   - Run the highest-signal relevant tests or checks for the changed files.
   - Follow the repository's required validation and documentation gates. If a required check is blocked, report the blocker rather than claiming it passed or skipping a mandatory gate.

4. Commit.
   - Stage only task changes and inspect the staged diff. Keep unrelated user changes, including already-staged changes, out of this commit without discarding their content or staging state.
   - Use a concise Korean commit message that describes the behavior or fix.

5. Update from the latest base branch.
   - Fetch or pull the latest base branch from the remote.
   - Merge the latest base branch into the current branch.
   - If conflicts occur, resolve only when the correct resolution is clear.
   - After resolving conflicts, rerun the relevant checks.
   - Inspect the merged result for lost behavior or documentation. Have the separate agent review materially changed conflict resolutions.

6. Verify UI flows in the actual app, reusing valid evidence.
   - Apply this step when UI or user flows are affected; otherwise state that it is not applicable. Follow the repository's UI/UX guide and real-app verification runbook, including recording and direct scene review when required.
   - Reuse existing `cleancode` results and captures when they cover the required flows, remain available, and no subsequent change affects those flows. Compare the verified snapshot (including uncommitted changes) with the current result, accounting for base merges, conflict resolutions, review fixes, shared UI code, and relevant API/runtime behavior. Commit IDs or screenshot filenames alone do not establish validity. Recheck flows whose verified scope or baseline is unclear.
   - For new, affected, or previously unverified flows, run the actual app with the current changes and click from the entry point through the final control and observable result. Check for missing actions, navigation, saving/persistence, cancel/close/reopen behavior, relevant loading/empty/error/retry and interaction states, and consistency with neighboring controls. Check light/dark modes when affected. Code inspection or component tests alone do not count as actual clicks.
   - Fix confirmed omissions within scope and repeat the affected flows. Use a test profile or disposable fixtures for mutations; inspect destructive confirmations without executing real deletion unless already authorized. Do not modify unrelated live data or expand permissions for verification.
   - If the walkthrough produces code or documentation changes, rerun affected tests/checks and UI flows, stage only the task changes, and commit them in Korean before pushing. Update the verification baseline to include those final fixes.
   - Capture and directly inspect representative screens, including important menu/dialog or result states, only for flows without valid evidence under the reuse rule above. Store evidence in the repository's designated ignored location or a task-specific temporary directory, avoid secrets and unrelated private content, and do not commit evidence unless requested or required.
   - Record the verified baseline, flows, results, evidence paths, and which evidence was reused or refreshed in the existing task record or report. If actual-app access or capture is blocked, report the concrete blocker and remaining unverified flows; do not mark required verification complete or merge while a required UI check remains unmet.

7. Push and create the PR.
   - Recheck staged, unstaged, and untracked files before pushing. Confirm all intended task fixes, including changes made during UI verification, are committed; unrelated user changes may remain and must be preserved.
   - Run required pre-push gates after committing (for example, `npm run preflight` when required by the repository).
   - Push the current branch to the remote.
   - Verify the remote branch contains the final verified commit and its fixes. A successful push alone does not prove an uncommitted fix was included; if the remote head differs from the intended local head, inspect the difference before claiming the work was uploaded.
   - Reuse an existing PR for this branch when present; otherwise create one against the base branch and attach it to the current task when the app supports that.
   - Use a Korean PR title and concise Korean summary.
   - Complete required PR URL references in release notes or task documents, and validate and push any resulting updates.

8. Wait for CI and handle reviews.
   - Track checks and review status for the latest pushed head commit. PR creation is an intermediate result; continue through required checks and automated reviews, using bounded waits with progress updates rather than rapid polling.
   - For a failure, inspect its diagnostics and logs, reproduce the relevant failure where possible, and fix confirmed issues within scope. Re-run affected local checks and required gates, commit fixes in Korean, and push. Follow the checks and reviews for the new head; earlier successes do not validate later commits.
   - Read review findings and unresolved threads, verify them against the actual code, and address valid findings. Explain unsupported findings with evidence; do not treat disagreement as permission to bypass a blocking review.
   - Do not push while a review bot that writes fix commits is still processing the current head. Inspect its completed changes or fix PR, integrate applicable fixes into this PR branch under existing authorization, and validate the combined result.
   - Reconcile new base conflicts when needed, preserving both intended changes, and repeat the affected review and validation. Do not weaken tests, disable checks, dismiss required reviews, or expand into unrelated repairs merely to obtain a green status.
   - After each integration or fix, apply step 6's UI verification and evidence reuse rules.
   - If progress requires credentials, a human approval, an out-of-scope decision, or an external repair, report the exact blocker and remaining conditions. Do not claim completion or repeatedly retry unchanged failures.

9. Merge and verify completion.
   - Merge only within the user's authorized scope. Immediately before merging, refresh the PR head, base, mergeability, checks, and review status. Confirm the latest head has passed all required CI and any additional checks used to validate this work, automated reviews have finished, and blocking findings or change requests have been addressed with required approvals in place.
   - If the head changes after verification, repeat the relevant checks and review. Use an expected-head guard when supported (for example, `gh pr merge --match-head-commit <verified-sha>`) to avoid merging unreviewed commits.
   - Confirm step 6's required UI verification is satisfied for the final result.
   - Use the repository's allowed merge method and ordinary protection rules. Never use an admin bypass, force a merge, approve your own PR to satisfy a required review, or delete branches unless separately requested.
   - When a merge queue is required, enqueue through the normal workflow and wait for the actual merge; enqueueing or enabling auto-merge alone is not completion.
   - Verify the PR is actually merged and record its merge commit and final CI/review status. If merging is blocked, preserve the branch and PR and report the remaining condition instead.

## Response Format

Keep the final response concise and Korean by default.

Include four compact groups:

- PR 결과: 링크·기준 브랜치·커밋 요약·충돌 처리·머지 여부와 머지 커밋
- 검증 결과: 별도 에이전트 지적과 반영 여부·실행한 검증 명령·최종 커밋의 CI 및 리뷰 결과
- UI 변경 시 증거: 실제 클릭한 흐름과 누락 수정 결과·대표 화면(절대 로컬 경로로 이미지 표시)·기존 cleancode 결과와 캡처의 재사용 여부
- 남은 문제: 미검증 범위·차단 조건·리스크가 있을 때만 짧게
