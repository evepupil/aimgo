# AimGo 需求-实现对照改造计划（V1）

> 对照基线：`docs/requirements.md`  
> 代码盘点范围：`lib/` 当前实现（2026-03-05）  
> 目标：以“需求条目 ↔ 代码实现”逐条对齐，输出可执行 TODO 改造清单

---

## 1. 对照结论总览

### 1.1 总体状态

- ✅ **已基本满足**：核心数据模型、目标/专注/自评主流程、历史与分析基础能力、语言主题切换
- 🟡 **部分满足**：通用交互细节（Header 显隐、动效统一、小屏适配）、目标页筛选菜单、历史视觉细节
- ❌ **未满足**：设置中的备份恢复与通知行为落地

### 1.2 优先级建议

- **P0（先做）**：会影响主流程体验或与需求明显冲突的项
- **P1（其次）**：体验与一致性增强项
- **P2（最后）**：工程治理与发布前强化项

---

## 2. 需求-实现对照矩阵（按需求章节）

## 2.1 通用需求（需求 1）

### 2.1.1 风格、导航、主题、多语言

- ✅ 灰黑白简约风格：已实现（`lib/app/theme/app_theme.dart`）
- ✅ 底部 4 Tab：已实现（`lib/core/widgets/main_tab_shell.dart`）
- ✅ 中英 + 跟随系统：已实现（`lib/app/l10n/locale_controller.dart`、`lib/features/settings/presentation/settings_page.dart`）
- ✅ 浅/深/系统主题：已实现（`lib/app/theme/theme_mode_controller.dart`、`lib/features/settings/presentation/settings_page.dart`）

### 2.1.2 Header 显隐、页面切换动效、响应式

- ❌ Header 滚动隐藏/显示：未实现（各页面均为普通 `AppBar`，无滚动联动）
- 🟡 页面切换动画：使用默认路由行为，未统一策略（`lib/app/router/app_router.dart`）
- 🟡 响应式适配：仅局部微调，缺少系统化断点/布局策略（多页面固定间距与卡片宽度）

### 2.1.3 核心规则（需求 1.3）

- ✅ 三级模型 Goal→Milestone→Task：已实现（`lib/shared/models/planning_models.dart`、`lib/core/services/database/app_database.dart`）
- ✅ 有效专注时间=时长×效率，默认 60%：已实现（`lib/shared/repositories/drift_aimgo_repository.dart`）
- ✅ 进度可超过 100% 且完成状态独立：已实现（`lib/features/goals/domain/progress_calculator.dart`、`lib/features/goals/application/progress_sync_service.dart`）
- 🟡 超时进度条视觉：已实现基础溢出，但溢出可视宽度目前封顶（`lib/features/goals/presentation/widgets/time_progress_bar.dart`）

---

## 2.2 目标页面（需求 2）

- ✅ 目标切换抽屉、目标/里程碑/任务 CRUD、搜索与高亮：已实现（`lib/features/goals/presentation/goals_page.dart`）
- ✅ 里程碑卡片进度与展开动画：已实现（`lib/features/goals/presentation/widgets/milestone_card.dart`）
- 🟡 任务未完成图标“圈边缘进度”细节：当前为“外圈+内层小进度圈”，与需求描述存在偏差（`lib/features/goals/presentation/widgets/task_item_tile.dart`）
- ✅ Header 的筛选与菜单能力：已实现筛选面板 + 排序/批量操作入口（`lib/features/goals/presentation/goals_page.dart`、`lib/features/goals/application/goals_page_controller.dart`）

---

## 2.3 专注页面（需求 3）

- ✅ 页面结构、番茄/自由模式、预设时长、控制按钮状态机：已实现（`lib/features/focus/presentation/focus_page.dart`）
- ✅ 专注对象选择（目标/里程碑/任务）与上下文路径：已实现（`lib/features/focus/presentation/focus_page.dart`）
- ✅ 完成后自动记录闭环：专注结束即按默认效率入库并回写进度（`lib/features/focus/application/focus_timer_controller.dart`）
- ✅ 番茄完成后流程简化：按产品决策取消休息与强制自评引导入口（`lib/features/focus/presentation/focus_page.dart`）
- 🟡 默认选择“当前目标”策略不够稳健：依赖 `selectedGoalIdProvider`，首次从专注页进入可能为空（`lib/features/focus/application/focus_timer_controller.dart`）

---

## 2.4 我的页面（需求 4）

- ✅ 页面结构与菜单项：已实现（`lib/features/profile/presentation/profile_page.dart`）
- 🟡 通知入口：当前为占位提示（`profileNotificationPlaceholder`）

---

## 2.5 专注分析页面（需求 5）

- ✅ 时间范围（日/周/月/年）：已实现（`lib/features/analytics/application/analytics_page_controller.dart`）
- ✅ 总时长与环比、日柱状图、分时效率、时段效率、目标占比：已实现（`lib/features/analytics/presentation/analytics_page.dart`）
- 🟡 热力图表现形态与需求表述仍可优化（当前为 24 小时块状网格）

---

## 2.6 专注历史页面（需求 6）

- ✅ 时间轴/日历双视图、搜索、目标与时间范围筛选：已实现（`lib/features/history/presentation/history_page.dart`）
- ✅ 时间分组（今天/昨天/本周/上周）：已实现（`lib/features/history/application/history_page_controller.dart`）
- ✅ 默认显示“当前目标”记录：已实现从专注页带入 `goalId` 并应用初始筛选（`lib/features/focus/presentation/focus_page.dart`、`lib/features/history/presentation/history_page.dart`）
- ✅ 时间轴左侧日期点与连接线：已实现节点 + 连线时间骨架（`lib/features/history/presentation/history_page.dart`）
- ✅ 日历“有记录日期指示点”：已实现日期点标记（`lib/features/history/presentation/history_page.dart`）

---

## 2.7 自评页面（需求 7）

- ✅ 摘要、效率滑条、预设值、实时有效时长、备注、提交/跳过：已实现（`lib/features/evaluation/presentation/evaluation_page.dart`）
- ✅ 跳过按 60% 处理与进度回写：已实现（`lib/features/goals/application/progress_sync_service.dart`）

---

## 2.8 设置页面（需求 8）

- ✅ 语言/主题切换：已实现（`lib/features/settings/presentation/settings_page.dart`）
- 🟡 通知/声音开关：仅本地持久化，未驱动真实通知策略（`lib/features/settings/application/settings_controller.dart`）
- ❌ 数据备份与恢复：仍占位提示（`settingsActionPlaceholder`）
- 🟡 清除缓存：目前仅重置设置项，不包含业务缓存/历史聚合缓存

---

## 3. 改造任务分解（带 TODO）

## Phase P0（高优先，先落地）

### P0-1 目标页筛选与菜单能力（需求 2.1）
- [x] 设计并落地筛选模型（完成状态、时间进度区间、更新时间）
- [x] 替换 `goalsActionNotImplemented` 占位，接入真实筛选面板
- [x] 菜单能力落地（至少含排序方式与批量操作入口）

### P0-2 历史页关键缺口（需求 6.2/6.5/6.6）
- [x] 从专注页进入历史时，默认使用当前选中目标过滤
- [x] 时间轴增加左侧时间线（节点+连线）组件
- [x] 日历视图增加“有记录日期”指示点

### P0-3 番茄结束休息引导（需求 3.2）
- [x] 按产品决策移除“休息 X 分钟”入口
- [x] 保留“专注完成即自动记录”路径
- [x] 取消强制自评依赖，记录保留决定权交给用户

### P0-4 设置页能力落地（需求 8.4）
- [ ] 实现本地备份导出（JSON）
- [ ] 实现本地恢复导入（JSON 校验 + 覆盖策略）
- [ ] 接入通知服务（番茄结束提醒）
- [ ] 将通知/声音开关真正作用到提醒行为

---

## Phase P1（体验对齐）

### P1-1 通用交互一致性（需求 1）
- [ ] 统一滚动 Header 显隐方案（列表页复用）
- [ ] 统一路由切换动画（push/pop 过渡规则）
- [ ] 小屏专项适配（360dp 宽度下关键按钮可见性）

### P1-2 目标页视觉细节
- [ ] 调整任务未完成图标为“边缘进度环”样式
- [ ] 复核进度条超时视觉策略（是否放开当前溢出宽度封顶）

### P1-3 历史与分析一致性
- [ ] 历史查询去 N+1（聚合查询或映射缓存）
- [ ] 校验分析口径与历史统计口径完全一致

---

## Phase P2（工程与发布收口）

### P2-1 测试补齐
- [ ] 领域规则边界测试（>100%、默认效率、完成态推导）
- [ ] 核心流程组件测试（专注开始/暂停/终止，自评提交/跳过）
- [ ] 历史/分析一致性回归测试
- [ ] 路由与多语言冒烟测试扩展

### P2-2 工程治理
- [ ] 固化 Flutter SDK 管理（建议 FVM）
- [ ] 增加 Android 工程污染防护脚本（检查非 Flutter 模板文件）
- [ ] README 增补开发联调与设备连接指南

---

## 4. 验收标准（DoD）

- [ ] 与 `docs/requirements.md` 第 1~8 节逐条对齐，不再有占位关键能力
- [ ] `flutter analyze` 与 `flutter test` 通过
- [ ] Android 真机/模拟器完成完整路径验收：目标管理 → 专注 → 自评 → 历史/分析
- [ ] 关键差距项（P0）全部关闭后再进入发布打磨

---

## 5. 范围控制（V1 不做）

- [ ] AI 辅助分析（需求 9.1）
- [ ] 社交功能（需求 9.2）
- [ ] 高级导出（CSV/Excel/PDF，需求 9.3）

说明：本计划仅做 V1 需求 1~8 的“对齐改造”，不扩展未来规划功能。

---

## 6. UI/UX 前端问题补充清单（本轮新增）

> 目标：把当前“能用但不够顺滑”的前端体验问题纳入改造范围

### 6.1 问题分级

- **P0 可用性问题**
  - [ ] 专注页关键操作可达性不足（“开始专注”在部分小屏需滚动后才可见）
  - [x] 目标页筛选/菜单是占位，形成“可见不可用”的挫败体验
  - [x] 按产品决策取消休息引导入口，避免无效步骤

- **P1 可读性问题**
  - [ ] 历史时间轴缺少“点+线+日期锚点”视觉骨架，扫描效率低
  - [ ] 日历页无“有记录日期”明显标记，信息发现成本高
  - [ ] 目标页任务进度图标与需求语义有偏差（边缘进度环表达不够直观）

- **P1 一致性问题**
  - [ ] 各页面间距密度与卡片层级不完全一致（紧凑度不统一）
  - [ ] Header 行为不统一（滚动页未实现显隐策略）
  - [ ] 路由过渡动画缺少统一规范（页面切换体感不一致）

### 6.2 对应改造动作（与前文任务映射）

- [ ] 将“开始专注按钮首屏可见”纳入 Phase P1-1 小屏专项适配验收
- [x] 将“时间轴骨架 + 日历标记”作为 Phase P0-2 的交付硬标准
- [x] 将“专注完成后流程简化（无休息入口）”作为 Phase P0-3 交付项
- [x] 将“筛选/菜单占位清零”作为 Phase P0-1 的出关条件
- [ ] 在 Phase P1 增加统一的间距/组件密度规范（形成 UI tokens 或页面规范）

### 6.3 体验验收指标（前端向）

- [ ] 360dp 宽度设备下，专注页无需滚动即可完成一次开始操作
- [ ] 历史时间轴首屏可一眼区分时间分组与记录归属
- [ ] 关键页面（首页/目标/专注/历史）垂直节奏一致，无明显“忽松忽紧”
- [ ] 用户可在 3 秒内找到“筛选入口并生效”（目标页与历史页）
