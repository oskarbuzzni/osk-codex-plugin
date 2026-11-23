# Osk Codex Plugin

Codex에서 브랜치 작업과 PR 검증을 돕는 세 가지 스킬입니다.

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
| `$osk:pushpr` | 변경을 검증한 뒤 커밋하고 PR을 만들어 리뷰와 CI를 확인합니다. |

스킬은 현재 작업 중인 저장소의 지침과 사용자가 허용한 범위를 따릅니다.

## Mac에서 Codex를 열 때 갱신하기

Codex 데스크톱 앱이 설치된 Mac에서 터미널에 다음 한 줄을 실행하세요. Osk 플러그인과 실행기를 설치하고 **Codex Osk Launcher**를 Dock에 추가합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/oskarbuzzni/osk-codex-plugin/main/install-macos-launcher.sh | /bin/bash
```

Dock의 **Codex Osk Launcher**로 Codex를 시작하세요. 실행기는 Osk 갱신을 마친 뒤 Codex를 엽니다. 갱신에 실패하면 알림을 띄우고 Codex를 엽니다. 실행기를 이미 설치했다면 같은 명령으로 Dock에 추가할 수 있습니다.

수동으로 갱신하려면 터미널에서 `codex plugin marketplace upgrade osk-plugins`를 실행한 뒤 Codex 앱을 다시 여세요.
