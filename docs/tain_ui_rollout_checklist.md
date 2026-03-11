# Tain 对标 UI 落地清单（AimGo）

> 目标：以 `Tain` 的视觉语言为参照，提升 AimGo 的密度、整洁度和一致性。  
> 范围：仅 UI/交互样式重构，不改业务规则与统计口径。  
> 状态标记：`先改` = 当前迭代优先落地；`后改` = 次迭代补齐。

## 1. 对标设计基线（统一规则）

- 单主色策略：仅保留一个强调蓝（选中态、关键数字、FAB、主 CTA）。
- 背景分层：浅灰背景 + 白色内容卡，不用重边框，不堆阴影。
- 低负担信息层级：标题清晰、段落短、指标卡简洁，避免“碎卡片”。
- 行组件统一：设置行、列表行、指标行统一行高和内外边距。
- 空状态可用：图标 + 一句话 + 一个操作入口。
- 固定导航逻辑：顶栏/底栏行为一致，不做无意义滑动显隐。

## 2. 页面映射总览（先改/后改）

| AimGo 页面 | 对标 Tain 页面 | 改造重点 | 优先级 |
|---|---|---|---|
| 首页 `Home` | 今天行动 | 顶部日期/时间筛选条、空状态、FAB 视觉统一 | 先改 |
| 目标 `Goals` | 我的目标 | 顶部目标卡 + 模块区结构、列表密度、行动入口统一 | 先改 |
| 专注 `Focus` | 今天行动（操作密度） | 顶部轻量化、目标选择条精致化、主按钮区聚焦 | 先改 |
| 分析 `Analytics` | 进步 | 指标卡组合并、图表区块化、标题与说明精简 | 先改 |
| 我的 `Profile` | 设置 + 我的目标 | 账号区 + 分组列表，弱化框感 | 后改 |
| 设置 `Settings` | 设置 | 图标行规范、分组标题/分隔线统一 | 后改 |
| 历史 `History` | 今天行动（列表逻辑） | 过滤条/时间线/卡片密度统一 | 后改 |

## 3. 逐页落地清单（按代码映射）

## 3.1 首页 Home（先改）

目标：做成“今天行动”结构，一眼可读，当天行动入口明确。

- [x] 顶部区改为：左标题 + 右日期动作，去除冗余说明。
- [ ] 新增横向日期 Chip 条组件（可复用于历史筛选）。
- [ ] 空状态统一为：图标 + 文案 + 引导操作。
- [ ] FAB 风格统一为主色圆形（大小、阴影、位置统一）。
- [x] 卡片圆角/内边距统一到 Token（不再页面手写）。

涉及文件：
- `lib/features/home/presentation/home_page.dart`
- `lib/features/home/presentation/widgets/home_dashboard_cards.dart`
- `lib/core/constants/layout_tokens.dart`

## 3.2 目标页 Goals（先改）

目标：对标“我的目标”页面，形成“头图/摘要 + 模块化区块 + 高密度任务”。

- [x] 目标头区改为单主卡（标题、期限、进度）。
- [x] 里程碑区与任务区做“模块分区”而不是多层卡片嵌套。
- [x] 任务行保留单行信息，次要信息放副标题/右侧，不挤压换行。
- [x] “添加活动/指标”式入口统一样式（图标 + 文案 + 右箭头）。
- [x] 空列表统一空状态组件。

涉及文件：
- `lib/features/goals/presentation/goals_page.dart`
- `lib/features/goals/presentation/widgets/milestone_card.dart`
- `lib/features/goals/presentation/widgets/task_item_tile.dart`

## 3.3 专注页 Focus（先改）

目标：保持当前核心流程不变，进一步收敛视觉噪声，突出计时主任务。

- [x] 保持固定 AppBar，不启用无意义滚动显隐。
- [x] 顶部三点菜单保持紧凑（“专注历史/自定义专注”），宽度统一。
- [x] 专注对象选择条采用单行胶囊 + 面包屑弱分隔（已在做，继续细抠）。
- [x] 番茄钟/自由专注切换区与对象条、圆环区间距统一节奏。
- [x] 圆环下方按钮组尺寸与间距统一（主按钮突出，次按钮弱化）。

涉及文件：
- `lib/features/focus/presentation/focus_page.dart`
- `lib/features/focus/application/focus_timer_controller.dart`

## 3.4 分析页 Analytics（先改）

目标：对标“进步”页，做“少而准”的指标卡 + 两个核心图表区。

- [x] 顶部合并成单一 Summary 区（总时长、变化率、核心结论）。
- [x] 指标卡维持 2+N 结构，减少碎片化小卡。
- [x] 图表区固定两大块：趋势 + 分布，标题和图例语言统一。
- [x] 年/月/周轴标签策略固定（已完成规则继续统一样式）。
- [x] 可读性优先：减少装饰，提升字号/留白一致性。

涉及文件：
- `lib/features/analytics/presentation/analytics_page.dart`
- `lib/features/analytics/application/analytics_page_controller.dart`

## 3.5 我的 Profile（后改）

目标：对标设置页风格，做轻分组列表，不重复入口。

- [ ] 顶部身份区压缩，减少“卡中卡”。
- [ ] 快捷入口/数据管理/关于分组统一样式。
- [ ] 数字统计块保持 3 项并使用统一指标卡组件。
- [ ] 去除重复导航入口和重复说明文案。

涉及文件：
- `lib/features/profile/presentation/profile_page.dart`
- `lib/features/profile/application/profile_dashboard_provider.dart`

## 3.6 设置 Settings（后改）

目标：做标准设置列表模板，视觉和交互可复用。

- [ ] 统一“分组标题 + 列表行 + 分隔线 + 右箭头”样式。
- [ ] Switch 行、普通导航行、说明行三类模板组件化。
- [ ] 图标尺寸、左边距、行高、点击态统一。

涉及文件：
- `lib/features/settings/presentation/settings_page.dart`
- `lib/core/constants/layout_tokens.dart`

## 3.7 历史 History（后改）

目标：保持信息量前提下，降低阅读成本。

- [ ] 顶部过滤条视觉对齐首页/目标页筛选条。
- [ ] 时间线节点与卡片间距统一，弱化重边框。
- [ ] 卡片状态色和标签位置固定，减少视觉跳动。

涉及文件：
- `lib/features/history/presentation/history_page.dart`
- `lib/features/history/application/history_page_controller.dart`

## 4. 公共组件抽取清单（跨页复用）

- [ ] `DateChipStrip`：横向日期筛选条（首页/历史可复用）。
- [ ] `SectionPanel`：浅底容器 + 标题 + 内容（目标/分析/我的/设置）。
- [ ] `MetricCard`：指标数字卡（分析/我的）。
- [ ] `ActionRow`：图标 + 标题 + 右侧值/箭头（设置/我的/目标模块入口）。
- [ ] `AppEmptyState`：空状态模板（首页/目标/历史）。

建议放置：
- `lib/core/widgets/`
- `lib/core/constants/layout_tokens.dart`

## 5. 迭代顺序建议（执行顺序）

1. 先改：`Goals -> Focus -> Analytics -> Home`
2. 后改：`Profile -> Settings -> History`
3. 最后：公共组件抽取 + 页面回归统一

## 6. 验收标准（每页通用）

- [ ] 小屏宽度（约 `360dp`）无文字挤压和异常换行。
- [ ] 圆角、间距、分割线透明度符合统一 Token。
- [ ] 空状态、按钮、菜单交互语义清晰。
- [x] `flutter analyze` 与 `flutter test` 通过。
