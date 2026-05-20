# RIME T9 Bopomofo Project

Custom RIME input method schema for T9 (3x4) Bopomofo layout, specifically optimized for mobile devices or numeric keypads.

## Project Overview
- **Type**: RIME Input Method Schema
- **Target Layout**: T9 (3x4) numeric grid for Traditional Chinese (Bopomofo/注音).
- **Core Technology**: RIME engine, deployed via **Hamster (倉輸入法)** on iOS.
- **Dictionary**: Based on `terra_pinyin` (Earth Pinyin) with tone support.

## Key Files
- `bopomofo_t9.schema.yaml`: The main RIME schema definition containing spelling algebra and engine configuration.
- `t9bopomo.yaml`: Keyboard layout definition (for Hamster or similar mobile RIME clients).
- `terra_pinyin.dict.yaml`: The source dictionary providing characters and their pinyin/bopomofo readings.

## Development Conventions

### Tone Filtering
The schema uses four unique, clean, and case-insensitive alphanumeric characters for Bopomofo tone marks. These letters are not used by any Bopomofo symbol in any case (upper or lower):
- **Tone 1 (ˉ)**: Mapped to `q`
- **Tone 2 (ˊ)**: Mapped to `w`
- **Tone 3 (ˇ)**: Mapped to `x`
- **Tone 4 (ˋ)**: Mapped to `y`
- (Tone 5 is disabled)

### Key Mapping Logic
The `speller/algebra` in the schema file maps Bopomofo symbols to numeric keys. This version utilizes case-sensitivity for symbols (e.g., `S` for ㄕ and `s` for ㄙ) to free up the tone letters:
1. `ㄅㄉㄚ` -> `1` (b, d, a)
2. `ㄍㄐㄞ` -> `2` (g, j, I)
3. `ㄓㄗㄢㄦ` -> `3` (Z, z, M, R)
4. `ㄆㄊㄛ` -> `4` (p, t, o)
5. `ㄎㄑㄟ` -> `5` (k, A, J)
6. `ㄔㄘㄣㄧ` -> `6` (C, c, N, i)
7. `ㄇㄋㄜ` -> `7` (m, n, e)
8. `ㄏㄒㄠㄡ` -> `8` (h, B, K, L)
9. `ㄕㄙㄤㄨ` -> `9` (S, s, O, u)
10. `ㄈㄌㄝ` -> `0` (f, l, E)
11. `ㄖㄥㄩ` -> `v` (r, P, v)

### Long-Phrase & Accuracy Optimizations
- **No Predict/Simplifier**: The schema explicitly avoids the `predict_translator` and OpenCC `simplifier` filters to maximize engine performance, as `terra_pinyin.dict.yaml` is already fully Traditional Chinese.
- **Enhanced Translator Memory**: The translator is explicitly configured with `enable_user_dict: true`, `enable_sentence: true`, and `encode_commit_history: true` to leverage the user's typing history and Viterbi decoding for accurate sentence building, while maintaining `derive/^(.).+$/$1/` to support T9 multi-character fuzzy shorthand (e.g. `24` -> `ㄐㄊ` -> `今天`).

## Building and Usage
1. Copy `bopomofo_t9.schema.yaml` and `terra_pinyin.dict.yaml` to your RIME user directory.
2. Add `bopomofo_t9` to your `default.custom.yaml` under `schema_list`.
3. Deploy RIME.
4. For Hamster iOS, upload files via Wi-Fi or iCloud sync, then redeploy.

---

## Hamster (倉輸入法) — iOS Client

- **GitHub**: https://github.com/imfuxiao/Hamster
- **App Store**: 搜尋「倉輸入法」(id6446617683)
- **Engine**: librime (BSD) + KeyboardKit (MIT)
- **Wiki**: https://github.com/imfuxiao/Hamster/wiki
- **Online Layout Builder**: https://lost-melody.github.io/hamster-tools

### File Deployment (上傳方案)

| 方式 | 步驟 |
|---|---|
| Wi-Fi 上傳 | App 內開啟 Wi-Fi 服務 → 瀏覽器輸入 LAN 地址 → 拖入文件 → 重新部署 |
| iCloud 同步 | 開啟 iCloud → 將文件放入 `iCloud/Hamster/RIME/Rime/` → 重新部署 |
| 壓縮包導入 | 打包（根目錄直接放文件，無子目錄）→ 分享給倉 App 開啟 |

> 修改後務必在 App 的 **RIME → 重新部署** 使設定生效。

---

### hamster.yaml 主配置

主配置文件為 `hamster.yaml`（推薦使用 `hamster.custom.yaml` 以 `patch:` 方式覆寫，避免更新覆蓋）。

```yaml
keyboard:
  useKeyboardType: chineseNineGrid  # 預設鍵盤類型
  disableSwipeLabel: false           # 是否隱藏划動標籤
  swipeLabelUpAndDownLayout: false   # 上下滑動標籤規則布局
  upSwipeOnLeft: true                # 上滑標籤顯示在左側
  displayButtonBubbles: true         # 顯示按鍵氣泡
  enableKeySounds: true
  enableHapticFeedback: false
  longPressDelay: 0.3                # 長按觸發延遲（秒）

swipe:
  spaceDragSensitivity: 15     # 空格拖移靈敏度（越小越靈敏）
  distanceThreshold: 40         # 划動觸發距離閾值（px）
  tangentThreshold: 0.577       # 划動角度限制（tan值，≈30度）
  longPressDelay: 0.3

rime:
  maximumNumberOfCandidate: 100
  overrideDictFiles: true       # 重新部署時覆蓋詞庫（自造詞需設 false）
```

**鍵盤類型 (useKeyboardType)**：

| 值 | 說明 |
|---|---|
| `chinese` | 中文 26 鍵 |
| `chineseNineGrid` | 中文九宮格（T9） |
| `alphabetic` | 英文鍵盤 |
| `numericNineGrid` | 數字九宮格 |
| 自定義名稱 | 填入自定義鍵盤的 `name` 值 |

---

### 自定義鍵盤布局 (keyboards)

布局定義在 `hamster.yaml` 的 `keyboards` 區塊，或獨立的 `hamster_keyboards.yaml` 文件。

#### 基本結構

```yaml
keyboards:
  - name: 我的T9鍵盤             # 對應 useKeyboardType 的值
    rows:
      - keys:
          - action: { character: { char: "1" } }
            width:
              portrait: { widthType: percentage, width: 0.333 }
            swipe:
              - direction: up
                action: { symbol: { char: "ㄅ" } }
                label: "ㄅ"
            callout:
              - label: "ㄅ"
                action: { character: { char: "1" } }
              - label: "ㄉ"
                action: { character: { char: "1" } }
```

#### Action 類型

| Action | 格式範例 | 說明 |
|---|---|---|
| 字符輸入（過 RIME） | `{ character: { char: "6" } }` | 送入 RIME 引擎，觸發拼音/注音處理 |
| 符號輸入（不過 RIME） | `{ symbol: { char: "！" } }` | 直接上屏，跳過 RIME 引擎 |
| 切換鍵盤 | `{ keyboardType: chineseNineGrid }` | 切換到指定鍵盤 |
| 快捷指令 | `{ shortcutCommand: "#左移" }` | 執行內建系統指令 |

#### 內建快捷指令 (shortcutCommand)

| 指令 | 功能 |
|---|---|
| `#重输` | 清空未上屏的輸入緩衝 |
| `#左移` | 光標左移一格 |
| `#右移` | 光標右移一格 |
| `#换行` | 換行（等同 Enter） |
| `#简繁切换` | 簡繁切換 |
| `#中英切换` | 中英模式切換 |
| `#复制` | 複製選中文字 |
| `#粘贴` | 貼上剪貼板 |
| `#剪切` | 剪切選中文字 |

---

### 按鍵手勢配置

#### 划動 (Swipe)

每個按鍵支持四個方向的划動，各自綁定獨立 action：

```yaml
- action: { character: { char: "6" } }
  swipe:
    - direction: up       # 上滑 → 送出注音符號
      action: { character: { char: "6" } }
      label: "ㄧ"
    - direction: down     # 下滑 → 重新輸入
      action: { shortcutCommand: "#重输" }
    - direction: left     # 左滑 → 直接上屏逗號
      action: { symbol: { char: "，" } }
    - direction: right    # 右滑 → 直接上屏句號
      action: { symbol: { char: "。" } }
```

**direction 值**：`up` | `down` | `left` | `right`

划動靈敏度由 `hamster.yaml` 的 `swipe` 區塊全局控制：
- `distanceThreshold`：划動最小距離（px），預設 40
- `tangentThreshold`：角度限制（tan 值），預設 0.577（≈30°），防止誤觸
- `longPressDelay`：長按觸發延遲，預設 0.3 秒

#### 長按呼出 (Callout)

長按按鍵後彈出選字氣泡（類似 iOS 原生長按字母鍵）：

```yaml
- action: { character: { char: "1" } }
  callout:
    - label: "ㄅ"
      action: { character: { char: "1" } }
    - label: "ㄉ"
      action: { character: { char: "1" } }
    - label: "ㄚ"
      action: { character: { char: "1" } }
```

長按延遲由 `keyboard/longPressDelay`（秒）控制，預設 0.3。

---

### T9 九宮格注意事項

- 若九宮格只能輸入數字（不觸發 RIME），檢查「鍵盤設定 → 數字鍵由 RIME 處理」需**關閉**。
- RIME schema 的 `speller/algebra` 必須正確將數字鍵映射至注音符號。
- `processByRIME: true`（預設）表示按鍵輸入送入 RIME；`false` 直接上屏（適合符號鍵）。
- 上傳方案文件後必須**重新部署**才生效。
- 詞庫修改後若啟用 `overrideDictFiles: true`，重新部署會覆蓋用戶自造詞；如需保留請設為 `false`。
- **精確聲母輸入 (Callout)**：Hamster 對非 ASCII 字元（如直接傳送 `ㄅ`）的 `character` action 會直接上屏而不過 RIME。因此，需使用 ASCII 聲母精確碼（如 `b`, `d`, `g` 等）傳送，並由 RIME 端的 `algebra` 進行精確匹配與 `derive` 模糊化。
- **氣泡選單方向與順序 (Callout Alignment)**：iOS 鍵盤在右側的按鍵（例如 T9 鍵盤的第 3 列：`3`、`6`、`9`、`v`），其長按彈出的氣泡會**向左展開**。為了確保畫面上的視覺順序依然是從左到右（與按鈕標籤如 `ㄓㄗㄢㄦ` 一致），在 YAML 裡的 `callout` 陣列順序必須**反轉**定義。
- **精確碼覆蓋範圍 (Callout Precision)**：
  - **聲母 (Initials)**：**支援精確輸入**。長按時送出對應 ASCII 字母做精確篩選：
    * `ㄅ(b)`、`ㄉ(d)`、`ㄍ(g)`、`ㄐ(j)`、`ㄓ(Z)`、`ㄗ(z)`、`ㄆ(p)`、`ㄊ(t)`、`ㄎ(k)`、`ㄑ(q)`、`ㄔ(C)`、`ㄘ(c)`、`ㄇ(m)`、`ㄋ(n)`、`ㄏ(h)`、`ㄒ(x)`、`ㄕ(S)`、`ㄙ(s)`、`ㄈ(f)`、`ㄌ(l)`、`ㄖ(r)`。
  - **介母與韻母 (Medials & Finals)**：**僅支援模糊輸入**。長按時僅送出對應的數字模糊碼（同直接點擊該鍵）：
    * 介母：`ㄧ`、`ㄨ`、`ㄩ`。
    * 韻母：`ㄚ`、`ㄛ`、`ㄜ`、`ㄝ`、`ㄞ`、`ㄟ`、`ㄠ`、`ㄡ`、`ㄢ`、`ㄣ`、`ㄤ`、`ㄥ`、`ㄦ`。
  - *說明*：若未來需支援介母與韻母之精確碼，需為其定義額外的專屬 ASCII 字母並於 RIME schema 新增 `algebra` 與 `alphabet` 映射規則。
