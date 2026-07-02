# UI 设计系统 · The Daybook（奶油纸 × 古铜）

> 归档范围：全局视觉层（主题、色板、字体、共享表面语汇），以及各页面对它的套用。
> 目标：不看代码就能看懂这套 UI 怎么搭、为什么这么搭、改的时候动哪里。

## 一、为什么重做（旧版的两个病）

改造前的 UI 有两个肉眼可见的问题：

1. **割裂**：每张卡片是一块白板浮在灰底上，彼此没有关系——首页 4 块互不相干的白方块、专注页白卡+透明面包屑+圆环三种语言并存、个人页又是另一种卡。
2. **廉价**：用 Inter（最烂大街的字体）+ 靛蓝/灰白（2020 年以来每个效率 App 的默认皮）；强调色以十几种透明度（0.035 / 0.045 / 0.055 / 0.10 / 0.12…）到处糊，颜色从不真正下场，成了「靛蓝糊糊」；卡片阴影只有 0.03 透明度等于看不见，卡片像贴纸不像有层次的纸。

## 二、设计方向：一本有质感的手账

把 AimGo 做成**一本暖纸手账 / 编辑级刊物**：暖纸底、墨色字、单一克制的强调色、衬线展示字。这对应用户管理目标时的真实习惯（写在纸本上），也跟冷冰冰的靛蓝 SaaS 拉开最大距离。

三条铁律：

- **一种强调色贯穿全场**：古铜（浅色 `#8E5A1A` / 深色 `#D9A85F`）。进度、百分比、选中、图标强调都用它，不再满屏透明度糊色。
- **同一张纸**：所有卡片是同一张暖纸上的区块，用 1px 发丝规则线勾边 + 分隔，不用看不见的阴影堆假层次。
- **溢出同源**：进度 >100% 用同色系更深一档的锈红（浅色 `#B5471B` / 深色琥珀 `#E08A2B`），跟主色既区分又同源，替换旧的突兀纯橙 `#F57C00`。

### 字体

- **展示字 / 数字**：Fraunces（可变衬线，温暖、有编辑感）。用于专注倒计时、百分比、大数字、页面标题、章节标题。带等宽数字（tabular figures），数值不左右跳动。
- **正文 / UI**：Hanken Grotesk（人文无衬线，温暖干净），替掉 Inter。
- 二者都经 `google_fonts` 运行时拉取（已在 pubspec 依赖 `google_fonts`）。中文字符由系统字体回退（PingFang / 思源），跟衬线展示字搭配即编辑刊物味。

## 三、代码结构（改哪里看哪里）

| 关注点 | 文件 | 说明 |
| --- | --- | --- |
| 色板 + 字体 + 组件主题 | `lib/app/theme/app_theme.dart` | 浅/深两套 `ThemeData`，Fraunces + Hanken Grotesk 文字体系，各控件主题 |
| 语义色扩展 | `lib/app/theme/daybook_extension.dart` | `DaybookColors`（`ThemeExtension`）：ColorScheme 表达不了的语义色集中在这里 |
| 表面 / 留白 / eyebrow | `lib/core/constants/layout_tokens.dart` | `daybookSurface`（统一卡片）、`daybookWell`（内嵌凹槽）、`daybookRule`（分隔线）、`daybookEyebrow`（章节小标） |

### DaybookColors 语义色（`daybook_extension.dart`）

一处集中，别再散落透明度：

- `overflow` / `overflowSoft`：进度 >100% 的锈红 + 轨道柔色。
- `rule`：发丝规则线（比 outline 略柔，专门用来在同一张纸上分块）。
- `eyebrow`：章节小标 / 次要标签的暖灰。
- `accentSoft`（≈8%）/ `accentSofter`（≈5%）：强调色的两档柔和底色，统一替代旧代码里散落的 `primary.withValues(alpha: 0.0x)`。
- `paperTint` / `paperWell`：暖底 / 更深一档的「纸井」（热力图底盘、内嵌区块）。
- `heatmapEmpty` + `heatmapRamp`（5 级暖阶）：热力图配色，替换旧蓝阶。
- `scrim`：sheet / 菜单蒙层色。
- `positive`：正向状态剂色（连续打卡等），不抢主色。

取用方式：`DaybookColors.of(context)`（组件里）或 `DaybookColors.ofTheme(theme)`（只有 ThemeData 时，如 LayoutTokens 内部）。

### 「同一张纸」语汇（`layout_tokens.dart`）

- `LayoutTokens.daybookSurface(theme)`：**全场卡片的统一表面**——暖纸 + 1px 发丝规则线，无幽灵阴影。新代码一律用它。
- `LayoutTokens.tainCardDecoration(theme)`：旧名兼容别名，等价 `daybookSurface`。历史调用点（history/analytics/profile/about/concept/evaluation/goals sheet 等）无需改动即自动继承新表面。
- `LayoutTokens.daybookWell(theme)`：内嵌凹槽（热力图底盘等）。
- `LayoutTokens.daybookEyebrow(context)`：章节小标样式（字距拉开、暖灰、`.toUpperCase()` 搭配使用）。

## 四、各页面套用要点

- **首页 `home_dashboard_cards.dart`**：4 张卡统一为「同一张纸」区块；日期 / 「当前目标」/「上次专注」标题改为 eyebrow；今日有效专注、当前目标进度用 Fraunces 大数字；指标 chip 改为发丝描边 + accentSoft；热力图换暖阶（`heatmapRamp` / `heatmapEmpty`）、底盘用 `paperWell`。
- **专注页 `focus_page.dart` + `focus_session_widgets.dart`**：计时环是招牌——暖纸圆盘 + `CustomPaint` 自绘圆头进度弧（`_FocusRingPainter`），番茄按进度走弧、自由模式满弧，暂停降透明度；Fraunces 大时间 + eyebrow 状态标签。模式 Tab 去掉内层重复卡片（页面提供外层卡），选中态用 accentSoft。`_PickerCard` 改 daybookSurface。
- **目标页 `goals_page.dart` + `milestone_card.dart`**：目标摘要卡改 daybookSurface + eyebrow + Fraunces 百分比 + `TimeProgressBar`（带溢出）；里程碑卡去阴影改发丝表面；摘要 chip、浏览态 bar、空状态面板统一为发丝描边 / accent 柔底。
- **个人页 `profile_page.dart`**：hero 头像改发丝描边方块；概览大数字用 Fraunces；分区标题改 eyebrow。
- **分析页 `analytics_page.dart`**：分类色板换成暖色系大地色（古铜领衔，松绿 / 赤陶 / 李紫 / 青灰 / 玫红），柱状 / 热力图渐变改用 `primary` 与 `heatmapEmpty`。
- **共享组件**：`time_progress_bar.dart` 溢出改 `daybook.overflow`；`anchored_action_menu.dart` 改发丝描边 + `scrim` 蒙层；`app_confirm_dialog.dart` 标题改 Fraunces。
- **底部导航**：`navigationBarTheme` 统一处理选中/未选图标与文字色，`MainTabShell` 无需改。

## 五、改动历史

- **2026-07-03**：落地 The Daybook 设计系统。新增 `daybook_extension.dart`；重写 `app_theme.dart`（奶油×古铜双主题 + Fraunces/Hanken Grotesk）与 `layout_tokens.dart`（同一张纸语汇）；收敛首页/目标/专注/个人/分析/概念页及共享组件（进度条、热力图、菜单、对话框）到统一语言。门禁：`flutter analyze` 0 问题、`flutter test` 71 全过、`dart format` 已跑。

## 六、扩展点 / 注意

- 想调整整体色温（如换成松绿或黑曜主题）：只改 `app_theme.dart` 的两套 ColorScheme + `daybook_extension.dart` 的两套 `DaybookColors`，页面无需动。
- 新页面 / 新卡片：一律用 `LayoutTokens.daybookSurface` + `daybookEyebrow`，取语义色走 `DaybookColors.of(context)`，不要再写裸 `primary.withValues(alpha: …)`。
- 纯展示层不写单测（遵循 CLAUDE.md：UI 问题肉眼可见）。
