#!/bin/bash
set -euo pipefail

add_launcher_to_dock() {
  local dock_change
  if ! dock_change=$(/usr/bin/osascript -l JavaScript - "$1" "$2" <<'JXA'
ObjC.import('Foundation');

function run([launcherPath, bundleID]) {
    const key = 'persistent-apps';
    const dock = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.dock');
    const existing = dock.arrayForKey(key);
    const apps = existing.isNil() ? $.NSMutableArray.array : existing.mutableCopy;
    const launcherURL = ObjC.unwrap($.NSURL.fileURLWithPathIsDirectory(launcherPath, true).absoluteString);
    const tile = $({
        'tile-type': 'file-tile',
        'tile-data': {
            'bundle-identifier': bundleID,
            'file-data': { '_CFURLString': launcherURL, '_CFURLStringType': $.NSNumber.numberWithInteger(15) },
            'file-label': 'Codex Osk Launcher',
            'file-type': $.NSNumber.numberWithInteger(41)
        }
    });

    let launcherIndex = -1;
    for (let index = 0; index < apps.count; index++) {
        const data = apps.objectAtIndex(index).objectForKey('tile-data');
        if (data.isNil()) continue;
        const file = data.objectForKey('file-data');
        if (!file.isNil()) {
            const location = ObjC.unwrap(file.objectForKey('_CFURLString'));
            if (location === launcherURL || location === launcherPath) return 'present';
        }
        if (ObjC.unwrap(data.objectForKey('bundle-identifier')) === bundleID) launcherIndex = index;
    }

    if (launcherIndex < 0) apps.addObject(tile);
    else apps.replaceObjectAtIndexWithObject(launcherIndex, tile);
    dock.setObjectForKey(apps, key);
    if (!dock.synchronize) throw new Error('Dock 설정을 저장하지 못했습니다.');
    return 'updated';
}
JXA
  ); then
    printf 'Dock에 추가하지 못했습니다. 실행기 위치: %s\n' "$1" >&2
    return 1
  fi

  if [[ "$dock_change" == updated ]]; then
    /usr/bin/killall -u "$(/usr/bin/id -un)" Dock 2>/dev/null || true
  fi
  printf '%s\n' 'Dock에서 Codex Osk Launcher를 여세요.'
}

install_launcher() (
  applications_dir=$1
  launcher_name='Codex Osk Launcher.app'
  bundle_id='com.oskarbuzzni.osk-codex-launcher'
  launcher="$applications_dir/$launcher_name"

  if [[ $(/usr/bin/uname -s) != Darwin ]]; then
    printf '%s\n' '이 실행기는 macOS에서 설치할 수 있습니다.' >&2
    exit 1
  fi

  if [[ -e "$launcher" || -L "$launcher" ]]; then
    existing_id=$(/usr/bin/plutil -extract CFBundleIdentifier raw -o - "$launcher/Contents/Info.plist" 2>/dev/null || true)
    if [[ "$existing_id" != "$bundle_id" ]]; then
      printf '이름이 같은 앱이 이미 있습니다: %s\n' "$launcher" >&2
      exit 1
    fi
    printf '이미 설치되어 있습니다: %s\n' "$launcher"
    add_launcher_to_dock "$launcher" "$bundle_id"
    exit
  fi

  /bin/mkdir -p "$applications_dir"
  staging_dir=$(/usr/bin/mktemp -d "$applications_dir/.osk-launcher.XXXXXXXX")
  trap '/bin/rm -rf -- "$staging_dir"' EXIT
  staged_launcher="$staging_dir/$launcher_name"

  /usr/bin/osacompile -o "$staged_launcher" <<'APPLESCRIPT'
on run
    try
        set launchScript to POSIX path of (path to resource "launch.sh")
        do shell script "/bin/bash " & quoted form of launchScript
    on error errorMessage
        display alert "Codex Osk Launcher" message errorMessage as warning
    end try
end run
APPLESCRIPT

  launch_script="$staged_launcher/Contents/Resources/launch.sh"
  /bin/cat > "$launch_script" <<'LAUNCH_SCRIPT'
#!/bin/bash
set -euo pipefail

if ! codex_app=$(/usr/bin/osascript -e 'POSIX path of (path to application id "com.openai.codex")'); then
  printf '%s\n' 'Codex 데스크톱 앱을 먼저 설치하세요.' >&2
  exit 1
fi

codex_cli=''
for candidate in \
  "${codex_app%/}/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex" \
  "${codex_app%/}/Contents/Resources/codex" \
  /opt/homebrew/bin/codex /usr/local/bin/codex; do
  if [[ -x "$candidate" ]]; then
    codex_cli=$candidate
    break
  fi
done
if [[ -z "$codex_cli" ]]; then
  codex_cli=$(command -v codex || true)
fi

if [[ ${1:-} == install-plugin ]]; then
  if [[ -z "$codex_cli" ]]; then
    printf '%s\n' 'Codex CLI를 찾을 수 없습니다. 데스크톱 앱을 최신 버전으로 업데이트하세요.' >&2
    exit 1
  fi
  "$codex_cli" plugin marketplace add oskarbuzzni/osk-codex-plugin
  "$codex_cli" plugin add osk@osk-plugins
  exit 0
fi

if [[ -z "$codex_cli" ]] || ! "$codex_cli" plugin marketplace upgrade osk-plugins; then
  /usr/bin/osascript -e 'display notification "Osk 스킬을 갱신하지 못했습니다." with title "Codex Osk Launcher"' || true
fi
/usr/bin/open -a "$codex_app"
LAUNCH_SCRIPT

  /usr/bin/plutil -replace CFBundleIdentifier -string "$bundle_id" "$staged_launcher/Contents/Info.plist"
  /usr/bin/codesign --force --sign - "$staged_launcher"
  /bin/bash "$launch_script" install-plugin
  /bin/mv -n -- "$staged_launcher" "$applications_dir/"
  if [[ -e "$staged_launcher" ]]; then
    printf '실행기를 설치하는 동안 같은 이름의 앱이 생겼습니다: %s\n' "$launcher" >&2
    exit 1
  fi
  printf '설치 완료: %s\n' "$launcher"
  add_launcher_to_dock "$launcher" "$bundle_id"
)

install_launcher "$HOME/Applications"
