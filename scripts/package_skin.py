#!/usr/bin/env python3
# 皮膚打包工具：把 yuanshu-skin/ 編譯並打包成元書可導入的 .cskin
#
# 用法：
#   python scripts/package_skin.py                 # 用預設名稱打包到 repo 根目錄
#   python scripts/package_skin.py -n "我的皮膚"    # 指定皮膚顯示名稱
#   python scripts/package_skin.py -o dist/         # 指定輸出目錄
#   python scripts/package_skin.py --debug          # 產生易讀（較大）的 YAML
#
# 流程（對照 yuanshu-skin/README.md 的「安裝」說明）：
#   1. 用 jsonnet 編譯 jsonnet/main.jsonnet → config.yaml、light/、dark/
#   2. 把 yuanshu-skin/ 的內容包進「一層以皮膚名稱命名的資料夾」
#      （元書要求檔案不能直接放在壓縮檔根目錄，資料夾名＝皮膚顯示名稱）
#   3. 壓成 zip，副檔名改為 .cskin
#
# 需要 jsonnet（google/go-jsonnet 或 C++ jsonnet 或 jrsonnet 皆可）。
# 找不到時會提示安裝方式；可用 --jsonnet 或環境變數 JSONNET 指定路徑。
import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIN_DIR = os.path.join(REPO, 'yuanshu-skin')
MAIN_JSONNET = os.path.join('jsonnet', 'main.jsonnet')  # 相對於 SKIN_DIR

# 皮膚顯示名稱預設值（壓縮檔內那層資料夾的名稱，元書用它當皮膚名）
DEFAULT_SKIN_NAME = 'T9注音九宮格'

# jsonnet 編譯後的產物（相對於 SKIN_DIR）；這些不進版控（見 .gitignore）
BUILD_ARTIFACTS = ['config.yaml', 'light', 'dark']


def eprint(*a):
    print(*a, file=sys.stderr)


def find_jsonnet(explicit=None):
    """依序嘗試：--jsonnet 參數 → JSONNET 環境變數 → PATH 上的常見名稱。"""
    candidates = []
    if explicit:
        candidates.append(explicit)
    if os.environ.get('JSONNET'):
        candidates.append(os.environ['JSONNET'])
    candidates += ['jsonnet', 'jrsonnet', 'go-jsonnet']

    for c in candidates:
        path = c if os.path.isfile(c) else shutil.which(c)
        if path:
            return path
    return None


def compile_skin(jsonnet_bin, debug, quiet):
    """在 SKIN_DIR 內編譯 main.jsonnet，產生 config.yaml / light/ / dark/。"""
    # go-jsonnet 的 -m 不會自動建立子目錄，先把 light/ dark/ 準備好
    for sub in ('light', 'dark'):
        os.makedirs(os.path.join(SKIN_DIR, sub), exist_ok=True)

    cmd = [
        jsonnet_bin, '-S', '-m', '.',
        '--tla-code', 'debug=%s' % ('true' if debug else 'false'),
        MAIN_JSONNET,
    ]
    if not quiet:
        print('編譯：%s（cwd=%s）' % (' '.join(cmd), SKIN_DIR))
    proc = subprocess.run(cmd, cwd=SKIN_DIR, capture_output=True, text=True)
    if proc.returncode != 0:
        eprint('jsonnet 編譯失敗（exit %d）：' % proc.returncode)
        eprint(proc.stderr.strip() or proc.stdout.strip())
        sys.exit(1)

    config = os.path.join(SKIN_DIR, 'config.yaml')
    if not os.path.isfile(config):
        eprint('編譯完成但找不到 config.yaml，請檢查 main.jsonnet。')
        sys.exit(1)


def iter_skin_files():
    """列出要打包的 yuanshu-skin 檔案（相對路徑），跳過雜項與 VCS。"""
    skip_dirs = {'.git', '__pycache__', '.DS_Store'}
    for root, dirs, files in os.walk(SKIN_DIR):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for f in files:
            if f == '.DS_Store':
                continue
            full = os.path.join(root, f)
            yield full, os.path.relpath(full, SKIN_DIR)


def make_cskin(name, out_path, quiet):
    """把 SKIN_DIR 內容包進 <name>/ 一層資料夾，壓成 .cskin。"""
    tmp = out_path + '.tmp'
    if os.path.exists(tmp):
        os.remove(tmp)

    count = 0
    with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as z:
        for full, rel in iter_skin_files():
            # 壓縮檔內固定用「/」分隔，並包在一層 <name>/ 資料夾裡
            arc = name + '/' + rel.replace(os.sep, '/')
            z.write(full, arc)
            count += 1

    os.replace(tmp, out_path)
    return count


def main():
    parser = argparse.ArgumentParser(
        description='把 yuanshu-skin 編譯並打包成元書 .cskin 皮膚檔')
    parser.add_argument('-n', '--name', default=DEFAULT_SKIN_NAME,
                        help='皮膚顯示名稱（壓縮檔內那層資料夾名，預設：%s）'
                             % DEFAULT_SKIN_NAME)
    parser.add_argument('-o', '--output', default=REPO,
                        help='輸出目錄或 .cskin 檔完整路徑（預設：repo 根目錄）')
    parser.add_argument('--jsonnet', help='jsonnet 執行檔路徑')
    parser.add_argument('--debug', action='store_true',
                        help='產生易讀但較大的 YAML（預設用精簡格式）')
    parser.add_argument('--no-build', action='store_true',
                        help='跳過編譯，直接用現有的 config.yaml/light/dark 打包')
    parser.add_argument('--keep-build', action='store_true',
                        help='打包後保留編譯產物（預設保留；此旗標為相容用途）')
    parser.add_argument('-q', '--quiet', action='store_true', help='減少輸出')
    args = parser.parse_args()

    if not os.path.isdir(SKIN_DIR):
        eprint('找不到皮膚資料夾：%s' % SKIN_DIR)
        sys.exit(1)

    # 決定輸出檔路徑
    if args.output.endswith('.cskin'):
        out_path = os.path.abspath(args.output)
        os.makedirs(os.path.dirname(out_path) or '.', exist_ok=True)
    else:
        os.makedirs(args.output, exist_ok=True)
        out_path = os.path.abspath(os.path.join(args.output, args.name + '.cskin'))

    # 1. 編譯
    if args.no_build:
        if not os.path.isfile(os.path.join(SKIN_DIR, 'config.yaml')):
            eprint('--no-build 需要先有編譯產物，但找不到 config.yaml。')
            sys.exit(1)
        if not args.quiet:
            print('跳過編譯（--no-build），使用現有產物。')
    else:
        jsonnet_bin = find_jsonnet(args.jsonnet)
        if not jsonnet_bin:
            eprint('找不到 jsonnet。請安裝其中之一並確認在 PATH 上：')
            eprint('  • go-jsonnet： go install github.com/google/go-jsonnet/cmd/jsonnet@latest')
            eprint('  • Homebrew：   brew install jsonnet')
            eprint('  • 或用 --jsonnet /path/to/jsonnet 指定，或設環境變數 JSONNET')
            sys.exit(1)
        if not args.quiet:
            print('使用 jsonnet：%s' % jsonnet_bin)
        compile_skin(jsonnet_bin, args.debug, args.quiet)

    # 2 + 3. 打包成 .cskin
    count = make_cskin(args.name, out_path, args.quiet)

    size = os.path.getsize(out_path)
    print('✅ 已打包：%s' % out_path)
    print('   皮膚名稱：%s   檔案數：%d   大小：%.1f KB'
          % (args.name, count, size / 1024))
    if not args.quiet:
        print('   傳到手機後點該檔即可導入元書；RIME 方案檔（bopomofo_t9/）需另外安裝。')


if __name__ == '__main__':
    main()
