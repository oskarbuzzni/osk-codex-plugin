---
name: cleancode
description: Use when the user types "cleancode", "클린코드", or requests a branch logic/scenario cross-check and cleanup. Reviews against main with a separate agent, removes unnecessary branch code, verifies changes, and checks UI-affecting work by clicking through the actual app and capturing representative screens.
---

# Clean Code

Use this skill when the user invokes `cleancode`, `클린코드`, or asks for this Korean workflow:

> 이 브런치에서 작업한 내용 로직과 시나리오 이슈 있는지 크로스 체크해주고 불필요한 코드는 제거해줘

For UI-affecting changes, also apply:

> 실제 앱에서 직접 클릭하며 변경된 사용 흐름을 끝까지 확인하고, 빠진 기능·상태·동작이 없는지 점검해줘. 발견한 누락을 수정하고 다시 확인한 뒤, 대표 화면을 캡처해서 보여줘.

## Workflow

1. Confirm the current repository and branch.
   - Use `git status --short --branch`.
   - Determine the comparison base with `origin/main` when available, otherwise `main`.
   - Do not create a new branch unless the user explicitly asks.

2. Inventory branch changes.
   - Use `git diff --stat <base>...HEAD` and `git diff --name-only <base>...HEAD`.
   - Also inspect unstaged changes with `git diff --stat` and `git diff --name-only`.
   - Read only files touched by the branch or files needed to understand those changes.

3. Cross-check behavior and scenarios.
   - Identify affected user flows and state transitions that can regress earlier requirements. For UI changes, use step 7's checks in code review and the actual app.
   - For backend/API changes, verify request/response contracts and mutation feedback expectations.
   - For deployment, preview, sync, or machine changes, check failure and retry paths, not only happy paths.

4. Remove unnecessary code carefully.
   - Remove imports, state, helpers, CSS classes, tests, mocks, and branches made unused by the current branch changes.
   - Keep edits within the branch objective. Preserve user changes and leave pre-existing dead code outside this scope unless explicitly requested.

5. Cross-check with a separate agent.
   - When delegation is available, give a separate agent the repository path, base, branch and uncommitted change scope, requirements, and repository instructions. Ask it to independently inspect the diff and necessary surrounding code for step 3's risks and unnecessary code, without presenting the primary agent's conclusions as the expected answer.
   - Keep review read-only: request severity, file/line references, and a concrete failing scenario. The reviewer must not edit, commit, push, or contact other chats.
   - Wait for findings, verify them against the code, fix confirmed issues within scope, and explain rejected findings. Request recheck of the affected final diff when fixes alter behavior or leave a finding unresolved; the primary agent remains responsible for verification.
   - If delegation is unavailable, check directly and disclose that independent review was not performed.

6. Verify.
   - Run targeted tests for changed areas, typecheck when TypeScript files changed, and `git diff --check`.
   - If verification must be limited, prioritize the highest-signal checks and report omissions and remaining risk.

7. Click through the actual app and capture representative screens when UI is affected.
   - If UI is unaffected, mark this step not applicable. Otherwise follow the repository's UI/UX guide and real-app verification runbook and run the app with current changes; code review or component tests do not substitute for actual clicks.
   - Map requirements and review findings to flows and click from each affected entry point through its final control and observable result. Check missing actions, stale text, hidden-but-active controls, navigation, persistence, cancel/close/reopen behavior, and relevant loading, empty, error, retry, selected, hover, and disabled states. Include light/dark modes when affected.
   - Inspect the whole affected area and neighboring controls for alignment, text, spacing, colors, and interaction consistency. Fix omissions within scope, repeat affected flows after the final change, and report unrelated issues separately.
   - Use an appropriate test profile or disposable fixtures for mutations. Inspect destructive confirmation dialogs without executing real deletion unless that deletion is already authorized; do not expand permissions or change unrelated live data merely to complete a walkthrough.
   - Capture representative final screens and important menu/dialog, interaction, or result states. Directly inspect captures for clipping, overlaps, missing content, and consistency; if a recording is required, record the flow and review its scenes too. Creating evidence alone is not verification.
   - Store evidence in the designated ignored location or a task-specific temporary directory, avoiding secrets and unrelated private content. Do not commit evidence unless requested or required. In the final report, show screenshots using absolute local image paths with their demonstrated flow/state.
   - If app access or capture is unavailable, report the concrete blocker and unverified flows without claiming unperformed clicks or captures.

## Response Format

Keep the final response concise and Korean by default.

Include four compact groups:

- 정리 결과: 발견·수정한 이슈와 제거한 코드(문제가 없으면 명시)
- 검증 결과: 별도 에이전트 지적과 반영 여부·실행한 검증 명령
- UI 변경 시 증거: 실제 클릭한 흐름·누락 수정 결과·대표 화면 캡처
- 남은 문제: 미검증 범위·차단 조건·리스크가 있을 때만 짧게
