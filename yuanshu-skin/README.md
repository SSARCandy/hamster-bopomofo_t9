# T9 注音九宮格 — 元書輸入法皮膚

本資料夾是 `bopomofo_t9` 方案在 **元書輸入法（Hamster v3）** 上的鍵盤皮膚，
完整復刻 Hamster v2 版 `t9bopomo.yaml` 的鍵位排佈與長按功能。

基於 [空山素影](https://github.com/luozikuan/kongshan-suying) 皮膚框架修改
（該倉庫未附授權條款，公開再發佈前請先徵得原作者同意）。

## 鍵盤佈局

```
ˉ | ㄅㄉㄚ | ㄍㄐㄞ  | ㄓㄗㄢㄦ | =
ˊ | ㄆㄊㄛ | ㄎㄑㄟ  | ㄔㄘㄣㄧ | 123
ˇ | ㄇㄋㄜ | ㄏㄒㄠㄡ | ㄕㄙㄤㄨ | ⌫
ˋ | ㄈㄌㄝ | 空格    | ㄖㄥㄩ  | ⏎
```

- **注音鍵長按**：精確選注音（所選即所得）
- **空格長按**：？ ！ ， 。 、 # @
- **= 長按**：$ ~ % < >
- **⌫ 長按**：清空（#重输）；打字中上滑：刪一個音節
- **⏎ 長按**：換行；上滑行首、下滑行尾
- **123**：切換到 T9 數字鍵盤（+−*/、=長按符號、「中」返回注音）
- 中英切換／方案切換：使用工具列按鈕（可在 `jsonnet/Settings.libsonnet`
  的 `toolbarSlideButtons` 調整）

## 安裝

1. **RIME 方案照舊**：`bopomofo_t9.schema.yaml`、`bopomofo_t9.dict.yaml`、
   `rime.lua`（以及語法模型 `.gram`）放入元書的 RIME 使用者目錄，重新部署。
   元書與倉輸入法同為 librime 引擎，方案檔完全不用改。
2. **安裝皮膚**：把本資料夾內容**包在一層資料夾裡**（資料夾名＝皮膚顯示名稱，
   檔案不能直接放在 zip 根目錄）壓縮成 zip，副檔名改為 `.cskin`，
   傳到手機後點擊該檔案即可導入元書。打包前需先產生編譯產物
   （`config.yaml`、`light/`、`dark/`，指令見下方「修改與重新編譯」；
   這些產物不進版控）。

   > 💡 上述編譯＋打包可用一鍵工具完成（在 repo 根目錄執行）：
   > `python scripts/package_skin.py`
   > 會自動編譯並產生 `T9注音九宮格.cskin`；`-n` 改皮膚名稱、`-o` 改輸出位置，
   > 詳見 `python scripts/package_skin.py -h`。
3. 在元書中選用此皮膚。

## 修改與重新編譯

- 鍵位/按鍵功能：編輯 `jsonnet/Buttons/LayoutT9Zhuyin.libsonnet`（注音鍵盤）、
  `jsonnet/Buttons/LayoutNumericT9.libsonnet`（數字鍵盤）
- 佈局結構：`jsonnet/Components/Pinyin/PinyinT9Zhuyin.libsonnet`、
  `jsonnet/Components/Numeric/NumericT9.libsonnet`
- 一般設定（主題色、工具列、滑動提示等）：`jsonnet/Settings.libsonnet`
- 改完後：**手機上**長按皮膚 → 「運行 main.jsonnet」；
  **電腦上**在本資料夾執行
  `jsonnet -S -m . --tla-code debug=true jsonnet/main.jsonnet`

`config.yaml`、`light/`、`dark/` 為編譯產物，請勿手改。
