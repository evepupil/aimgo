# AimGo - 目标管理 App

## 技术栈

- **基础架构**: Expo SDK 54 (Managed Workflow) + Development Builds
- **语言**: TypeScript (strict mode)
- **路由**: Expo Router (文件系统路由)
- **UI**: Tamagui + Lucide Icons
- **数据库**: WatermelonDB (SQLite, JSI)
- **状态管理**: Zustand + Immer
- **网络请求**: TanStack Query
- **动画/手势**: Reanimated 3 + Gesture Handler
- **图表**: React Native Skia
- **存储**: react-native-mmkv (KV 持久化)
- **日期**: date-fns
- **通知**: expo-notifications

## 目录规范

项目采用 **feature-based** 架构。按功能模块内聚，跨功能复用放 shared。

```
aimgo/
├── app/                        # Expo Router 页面（纯路由胶水，零业务逻辑）
│   ├── _layout.tsx             # 根布局：Provider 串联
│   ├── (tabs)/                 # Tab 导航组
│   │   ├── _layout.tsx         # Tab 配置
│   │   ├── index.tsx           # 首页
│   │   ├── goals.tsx           # 目标
│   │   ├── focus.tsx           # 专注
│   │   └── stats.tsx           # 统计
│   └── goal/[id].tsx           # 目标详情
│
├── src/
│   ├── features/               # 业务功能模块（每个功能自包含）
│   │   ├── goals/              # 目标管理
│   │   │   ├── components/     # 该功能专属组件
│   │   │   ├── hooks/          # 该功能专属 hooks
│   │   │   ├── store.ts        # 该功能 Zustand store
│   │   │   └── types.ts        # 该功能类型定义
│   │   ├── focus/              # 番茄钟/专注
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── store.ts
│   │   │   └── types.ts
│   │   └── stats/              # 数据统计
│   │       ├── components/
│   │       └── types.ts
│   │
│   ├── shared/                 # 跨功能复用
│   │   ├── components/ui/      # 通用 UI 原子组件
│   │   ├── hooks/              # 通用 hooks
│   │   ├── stores/             # 全局 store（appStore 等）
│   │   └── utils/              # 纯工具函数
│   │
│   ├── database/               # WatermelonDB 基础设施
│   │   ├── index.ts            # DB 初始化
│   │   ├── schema.ts           # 表结构定义
│   │   └── models/             # Model 类
│   │
│   ├── services/               # 服务层（通知、持久化、云同步等）
│   │
│   ├── constants/              # 全局常量
│   │   ├── theme.ts            # 主题色系
│   │   └── config.ts           # 应用配置
│   │
│   └── types/                  # 全局类型定义
│
├── assets/                     # 静态资源
├── tamagui.config.ts           # Tamagui 主题配置（根目录，Babel 插件引用）
├── babel.config.js             # Babel 配置（decorators + tamagui）
└── app.json                    # Expo 配置
```

### 规则

1. **`app/` 目录保持"薄"**：页面文件只做路由胶水——import feature 组件、传参、结束。不写业务逻辑。
2. **功能内聚**：一个功能的 components、hooks、store、types 全部放在 `features/<name>/` 下。改一个功能不应跨多个顶层目录。
3. **跨功能复用才进 `shared/`**：组件/hook 被 2 个以上 feature 使用时，才提升到 shared。不要提前抽象。
4. **`database/` 和 `services/` 是全局基础设施**：不属于任何单一 feature，与 features 平级。
5. **新增 feature 时**，在 `features/` 下创建同结构目录：`components/`、`hooks/`、`store.ts`、`types.ts`。
6. **路径别名**：使用 `@/src/features/goals/...` 形式引用。`@/` 指向项目根目录。
