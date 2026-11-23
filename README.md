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

플러그인을 설치한 Mac에서 **단축어 → 설정 → 고급 → 스크립트 실행 허용**을 켜고, 새 단축어에 **셸 스크립트 실행** 동작을 추가하세요. 다음 스크립트를 붙여 넣고 **파일 → Dock에 추가**를 선택하세요. 이 단축어로 열면 Osk를 갱신한 뒤 Codex를 엽니다. 갱신에 실패하면 알림을 띄우고 Codex를 엽니다.

```sh
app_path=$(/usr/bin/osascript -e 'POSIX path of (path to application id "com.openai.codex")') || exit 1
for codex_cli in \
  "${app_path%/}/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex" \
  "${app_path%/}/Contents/Resources/codex" \
  /opt/homebrew/bin/codex /usr/local/bin/codex; do
  [ -x "$codex_cli" ] && break
done

if [ ! -x "$codex_cli" ] || ! "$codex_cli" plugin marketplace upgrade osk-plugins; then
  /usr/bin/osascript -e 'display notification "Osk 스킬을 갱신하지 못했습니다." with title "Codex 시작"' || true
fi

/usr/bin/open -b com.openai.codex
```

수동으로 갱신하려면 터미널에서 `codex plugin marketplace upgrade osk-plugins`를 실행한 뒤 Codex 앱을 다시 여세요.
