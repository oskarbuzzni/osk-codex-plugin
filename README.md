# Osk Codex Plugin

Codex에서 브랜치 작업과 PR 검증을 돕는 네 가지 스킬입니다.

## 설치

Codex CLI에서 다음 명령을 실행하세요.

```bash
codex plugin marketplace add oskarbuzzni/osk-codex-plugin
codex plugin add osk@osk-plugins
```

Codex 데스크톱 앱을 사용한다면 앱을 재시작하고 새 채팅에서 스킬을 선택하세요.

| 스킬 | 동작 |
| --- | --- |
| `$osk:cleancode` | 브랜치 변경을 검토하고 불필요한 코드를 정리합니다. |
| `$osk:new` | 최신 기준 커밋에서 새 작업 브랜치를 만듭니다. |
| `$osk:pull` | 현재 변경을 커밋하고 최신 기준 브랜치를 병합합니다. |
| `$osk:pushpr` | 변경을 검증한 뒤 커밋하고 PR을 만들어 리뷰와 CI를 확인합니다. |

스킬은 현재 작업 중인 저장소의 지침과 사용자가 허용한 범위를 따릅니다.
