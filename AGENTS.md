# AimGo - Flutter 项目规范

> 适用范围：`G:\my_project\aimgo` 全仓库  
> 需求来源：`docs/requirements.md`  
> 目标：基于 Flutter 实现 AimGo（目标管理 + 专注系统）

## 1. 产品范围与版本策略

- V1 覆盖需求文档第 1~8 节（通用、目标、专注、我的、分析、历史、自评、设置）
- 需求第 9 节（AI 辅助分析、社交、高级导出）仅保留接口扩展位，不进入 V1 开发范围
- 首发平台为移动端（Android / iOS），UI 优先手机尺寸，兼顾大屏手机

## 2. Flutter 技术栈（统一标准）

- **Flutter**：Stable 通道
- **语言**：Dart 3（sound null safety）
- **状态管理**：Riverpod（`flutter_riverpod`）
- **路由**：`go_router`（声明式路由 + 嵌套路由）
- **本地数据库**：SQLite + Drift（支持关系查询与事务）
- **轻量配置存储**：`shared_preferences`
- **国际化**：`flutter_localizations` + `intl` + ARB
- **通知**：`flutter_local_notifications` + `timezone`
- **图表可视化**：`fl_chart`（必要时使用 `CustomPainter` 补齐热力图）
- **日志**：`logger`（开发环境开启，发布环境降级）

## 3. 推荐目录结构（Feature First + 分层）

```text
aimgo/
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── bootstrap.dart
│   │   ├── router/
│   │   ├── theme/
│   │   └── l10n/
│   ├── core/
│   │   ├── constants/
│   │   ├── error/
│   │   ├── services/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/
│   │   ├── home/
│   │   ├── goals/
│   │   ├── focus/
│   │   ├── evaluation/
│   │   ├── history/
│   │   ├── analytics/
│   │   ├── profile/
│   │   └── settings/
│   └── shared/
│       ├── models/
│       ├── repositories/
│       └── extensions/
├── test/
├── docs/
│   ├── requirements.md
│   └── roadmap.md
└── CLAUDE.md
```

## 4. 分层职责（每个 feature 内部遵循）

- `presentation/`：页面、组件、交互状态（不直接访问数据库）
- `application/`：用例编排、状态控制器（Riverpod Notifier）
- `domain/`：实体、值对象、业务规则（纯 Dart，可单测）
- `data/`：DTO、Drift 表定义、Repository 实现

依赖方向必须单向：`presentation -> application -> domain <- data`

## 5. 核心领域模型与业务规则

### 5.1 领域实体

- `Goal`（目标）
- `Milestone`（里程碑）
- `Task`（任务）
- `FocusSession`（专注会话）

### 5.2 关系约束

- 1 个 `Goal` 包含多个 `Milestone`
- 1 个 `Milestone` 包含多个 `Task`
- 1 个 `Task` 包含多个 `FocusSession`
- `FocusSession` 允许绑定到 Goal/Milestone/Task 的任一层级（对应需求 3.4）

### 5.3 必须实现的计算规则（需求 1.3）

- 有效专注时间 = 专注时长 × 效率系数
- 未自评效率时默认 `60%`
- 时间进度允许超过 `100%`，不得截断
- 任务完成状态与时间进度独立
- 里程碑完成状态由子任务是否全部完成自动推导
- 目标完成状态由子里程碑是否全部完成自动推导

## 6. UI / 交互规范

- 底部导航固定 4 Tab：`首页`、`目标`、`专注`、`我的`
- 顶部 Header 支持滚动隐藏/显示（仅在内容滚动页生效）
- 页面切换动画统一使用 Material 动画体系，避免不同页面出现割裂体验
- 进度条超 100% 显示“填满 + 溢出橙色渐变”视觉（需求 1.3.4）
- 风格统一灰黑白极简，不引入高饱和主色作为大面积背景
- 适配策略：以手机竖屏为主，确保小屏（约 360dp 宽）不溢出

## 7. 国际化与主题规范

### 7.1 国际化

- 必须支持 `zh` / `en`
- 默认语言遵循系统语言
- 设置页允许切换：中文、英文、跟随系统
- 所有用户可见文案禁止硬编码，统一走 ARB key

### 7.2 主题

- 支持 `light` / `dark` / `system`
- 深色主题遵循灰黑背景 + 白色文本
- 浅色主题遵循白色背景 + 黑色文本
- 主题切换需要平滑过渡，避免闪屏

## 8. 代码规范（Dart）

### 8.1 命名与文件

- 文件名：`snake_case.dart`
- 类名 / 枚举名：`PascalCase`
- 变量 / 方法：`camelCase`
- 常量：`lowerCamelCase`（仅编译期常量可用 `const`）
- Provider 命名：`xxxProvider`
- Riverpod Notifier：`xxxController`

### 8.2 代码质量

- 启用 `flutter_lints`，禁止随意关闭规则
- 禁止 `dynamic` 滥用；无法确定类型时优先 `Object?`
- UI 层不写 SQL、不直接调持久化 API
- 复杂 Widget 必须拆分，单文件建议不超过 300 行
- 公共组件进入 `core/widgets` 或 `shared`，不做提前抽象

## 9. 状态管理与副作用规范

- 页面状态通过 Riverpod 暴露，统一使用 `AsyncValue`
- 副作用（数据库写入、通知调度）放在 `application` / `data` 层
- 页面中不直接持有全局可变单例
- 定时器状态必须可恢复（前后台切换后可校正）

## 10. 数据与持久化规范

- 所有写操作通过 Repository 统一入口
- 涉及“会话记录 + 进度回写”的操作必须事务化，防止中间态
- 列表页查询要支持分页或按需加载，避免一次性全量读取
- 历史与统计查询优先走聚合 SQL，避免 UI 层循环聚合

## 11. 测试与质量门禁

每次提交前至少执行：

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

最低测试要求：

- 领域规则单元测试（进度计算、完成判定、默认效率）
- 关键流程组件测试（专注启动/暂停/终止、自评提交）
- 路由冒烟测试（主页面可达）

## 12. 文档协同规则

- 功能或架构发生变化时，同步更新 `docs/roadmap.md`
- 需求解释以 `docs/requirements.md` 为准，冲突时先改需求再改实现
- 对“未来规划功能”只补充扩展点，不提前实现
