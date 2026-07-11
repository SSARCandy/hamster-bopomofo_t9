# =====================================
# 此文件用於自定義鍵盤按鍵功能。
# 可根據需要修改下方內容，調整各類按鍵的行為
# 修改完成後，保存本文件，然後回到皮膚界面，
# 長按皮膚，選擇「運行 main.jsonnet」生效。
#
# 包含 T9 注音九宮格佈局的按鍵
# （對應 bopomofo_t9 方案：數字鍵 1-0 + v 為注音組，
#   q/w/x/y 為聲調鍵，長按可精確選注音）
# =====================================

local colors = import '../Constants/Colors.libsonnet';
local fonts = import '../Constants/Fonts.libsonnet';
local settings = import '../Settings.libsonnet';
local commonButtons = import './Common.libsonnet';

{
  local root = self,

  // ===== 聲調鍵（左側欄）：q=ˉ w=ˊ x=ˇ y=ˋ =====
  toneFlatButton: {
    name: 'toneFlatButton',
    params: {
      text: 'ˉ',
      action: { character: 'q' },
    },
  },
  toneRiseButton: {
    name: 'toneRiseButton',
    params: {
      text: 'ˊ',
      action: { character: 'w' },
    },
  },
  toneDipButton: {
    name: 'toneDipButton',
    params: {
      text: 'ˇ',
      action: { character: 'x' },
    },
  },
  toneFallButton: {
    name: 'toneFallButton',
    params: {
      text: 'ˋ',
      action: { character: 'y' },
    },
  },

  // ===== 九宮格注音鍵：長按可精確選注音 =====
  t9OneButton: {
    name: 't9OneButton',
    params: {
      text: 'ㄅㄉㄚ',
      action: { character: '1' },
      swipeUp: { action: { symbol: '1' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄅ', action: { character: 'b' }, selected: true },
        { text: 'ㄉ', action: { character: 'd' } },
        { text: 'ㄚ', action: { character: 'a' } },
      ],
    },
  },
  t9TwoButton: {
    name: 't9TwoButton',
    params: {
      text: 'ㄍㄐㄞ',
      action: { character: '2' },
      swipeUp: { action: { symbol: '2' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄍ', action: { character: 'g' }, selected: true },
        { text: 'ㄐ', action: { character: 'j' } },
        { text: 'ㄞ', action: { character: 'I' } },
      ],
    },
  },
  t9ThreeButton: {
    name: 't9ThreeButton',
    params: {
      text: 'ㄓㄗㄢㄦ',
      action: { character: '3' },
      swipeUp: { action: { symbol: '3' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄓ', action: { character: 'Z' } },
        { text: 'ㄗ', action: { character: 'z' } },
        { text: 'ㄢ', action: { character: 'M' } },
        { text: 'ㄦ', action: { character: 'R' }, selected: true },
      ],
    },
  },
  t9FourButton: {
    name: 't9FourButton',
    params: {
      text: 'ㄆㄊㄛ',
      action: { character: '4' },
      swipeUp: { action: { symbol: '4' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄆ', action: { character: 'p' }, selected: true },
        { text: 'ㄊ', action: { character: 't' } },
        { text: 'ㄛ', action: { character: 'o' } },
      ],
    },
  },
  t9FiveButton: {
    name: 't9FiveButton',
    params: {
      text: 'ㄎㄑㄟ',
      action: { character: '5' },
      swipeUp: { action: { symbol: '5' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄎ', action: { character: 'k' }, selected: true },
        { text: 'ㄑ', action: { character: 'A' } },
        { text: 'ㄟ', action: { character: 'J' } },
      ],
    },
  },
  t9SixButton: {
    name: 't9SixButton',
    params: {
      text: 'ㄔㄘㄣㄧ',
      action: { character: '6' },
      swipeUp: { action: { symbol: '6' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄔ', action: { character: 'C' } },
        { text: 'ㄘ', action: { character: 'c' } },
        { text: 'ㄣ', action: { character: 'N' } },
        { text: 'ㄧ', action: { character: 'i' }, selected: true },
      ],
    },
  },
  t9SevenButton: {
    name: 't9SevenButton',
    params: {
      text: 'ㄇㄋㄜ',
      action: { character: '7' },
      swipeUp: { action: { symbol: '7' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄇ', action: { character: 'm' }, selected: true },
        { text: 'ㄋ', action: { character: 'n' } },
        { text: 'ㄜ', action: { character: 'e' } },
      ],
    },
  },
  t9EightButton: {
    name: 't9EightButton',
    params: {
      text: 'ㄏㄒㄠㄡ',
      action: { character: '8' },
      swipeUp: { action: { symbol: '8' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄏ', action: { character: 'h' }, selected: true },
        { text: 'ㄒ', action: { character: 'B' } },
        { text: 'ㄠ', action: { character: 'K' } },
        { text: 'ㄡ', action: { character: 'L' } },
      ],
    },
  },
  t9NineButton: {
    name: 't9NineButton',
    params: {
      text: 'ㄕㄙㄤㄨ',
      action: { character: '9' },
      swipeUp: { action: { symbol: '9' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄕ', action: { character: 'S' } },
        { text: 'ㄙ', action: { character: 's' } },
        { text: 'ㄤ', action: { character: 'O' } },
        { text: 'ㄨ', action: { character: 'u' }, selected: true },
      ],
    },
  },
  t9ZeroButton: {
    name: 't9ZeroButton',
    params: {
      text: 'ㄈㄌㄝ',
      action: { character: '0' },
      swipeUp: { action: { symbol: '0' } },  // 上滑直接輸入數字
      longPress: [
        { text: 'ㄈ', action: { character: 'f' }, selected: true },
        { text: 'ㄌ', action: { character: 'l' } },
        { text: 'ㄝ', action: { character: 'E' } },
      ],
    },
  },
  t9VButton: {
    name: 't9VButton',
    params: {
      text: 'ㄖㄥㄩ',
      action: { character: 'v' },
      longPress: [
        { text: 'ㄖ', action: { character: 'r' } },
        { text: 'ㄥ', action: { character: 'P' } },
        { text: 'ㄩ', action: { character: 'v' }, selected: true },
      ],
    },
  },

  // 聲調鍵列表（統一生成樣式用）
  toneButtons: [
    self.toneFlatButton,
    self.toneRiseButton,
    self.toneDipButton,
    self.toneFallButton,
  ],

  // 注音鍵列表（統一生成樣式用）
  t9Buttons: [
    self.t9OneButton,
    self.t9TwoButton,
    self.t9ThreeButton,
    self.t9FourButton,
    self.t9FiveButton,
    self.t9SixButton,
    self.t9SevenButton,
    self.t9EightButton,
    self.t9NineButton,
    self.t9ZeroButton,
    self.t9VButton,
  ],

  // ===== 右側欄功能鍵 =====

  // 等號鍵：直接上屏，長按選其他符號
  equalButton: {
    name: 'equalButton',
    params: {
      action: { symbol: '=' },
      # 右緣按鍵：依 v2 視覺順序（> < % ~ $），預設選最右的 $
      longPress: [
        { text: '>', action: { symbol: '>' } },
        { text: '<', action: { symbol: '<' } },
        { text: '%', action: { symbol: '%' } },
        { text: '~', action: { symbol: '~' } },
        { text: '$', action: { symbol: '$' }, selected: true },
      ],
    },
  },

  // 切換到數字鍵盤
  numericSwitchButton: {
    name: 'numericSwitchButton',
    params: {
      action: { keyboardType: 'numeric' },
      text: '123',
    },
  },

  // 退格鍵：在通用退格鍵基礎上，增加長按「清空」
  t9BackspaceButton: {
    name: commonButtons.backspaceButton.name,
    params: commonButtons.backspaceButton.params + {
      longPress: [
        { text: '清空', action: { shortcut: '#重输' } },
      ],
    },
  },

  // 空格鍵：長按快速輸入標點
  t9SpaceButton: {
    name: 'spaceButton',
    params: {
      action: 'space',
      systemImageName: 'space',
      longPress: [
        { text: '？', action: { symbol: '？' }, selected: true },
        { text: '！', action: { symbol: '！' } },
        { text: '，', action: { symbol: '，' } },
        { text: '。', action: { symbol: '。' } },
        { text: '、', action: { symbol: '、' } },
        { text: '#', action: { symbol: '#' } },
        { text: '@', action: { symbol: '@' } },
      ],
    },
  },
}
