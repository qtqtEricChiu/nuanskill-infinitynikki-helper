# Changelog

> 完整版版本历史。当前版本请见 `SKILL.md` 或 `README.md`。

---

## v1.3.2（2026-06-28）

- **全面重构用户数据持久化方案**：所有用户数据从 Skill 目录迁移至 `{USER_DATA_DIR}` 抽象路径，不硬编码 Agent 平台或用户标识
- **新增 `references/nuanskill-data-spec.md`**：合并原 data-format.md + data-persistence.md 为单文规范
- **Cookie 文件升级为 `nuan_profile.json`**：子域名 key 化 + 时间戳条目 + 根级 `_note` 标注只增补
- **新增 support token 回退策略**：myl.nuanpaper.com token 失效时可用 support 分支 token 登录
- **SKILL.md 大幅精简**：删除重复的"初次使用引导"和"核心工作流"章节（内容已迁至各 reference），新增阅读优先级指引，总行数减少 ~32%
- **新增阅读优先级**：明确 Agent 首次加载的阅读顺序
- **文件引用全面修复**：`nuanskill-data-persistence.md` 死引用 → `nuanskill-data-spec.md`
- **新增 `{USER_DATA_DIR}` 解析规则**：在 data-spec.md 定义多平台（Marvis/QClaw/OpenClaw/Claw/Chatwise/MindMac 等）路径解析表 + 环境变量优先级 + 通用回退方案

## v1.3.1（2026-06-28）

- **新增氪条消费历史持久化存储**：每次查询氪条后自动追加到 `user-data/nuan_recharge_history.json`，含订单明细与汇总
- **新增强制规则 #15**：数据内容只能增补，严禁覆写删除
- **新增数据格式**：`nuan_recharge_history.json` 格式规范
- **氪条查询流程补充**：持久化存储步骤
- **文件清单更新**：新增 `nuan_recharge_history.json`

---

## v1.3.0（2026-06-28）

- **新增「兑换码查询」**：通过客服页面自动获取当前有效兑换码列表及福利详情
- **新增能力⑤子功能「氪条查询」**：通过发票中心查询近 6 个月充值记录
- **兑换码流程 v3 重写**：改为文本发送方案（聊天框发「兑换码」→ DOM 正则扫描全部名称 → 逐一请求详情），替代模拟点击
- **完善兑换码踩坑**：iframe 跨域处理、contenteditable 输入框标注、干净会话检测、正则过滤规则、超时兜底、主动释放进程
- **Cookie 文件拆分重构**：`nuan_user_profile.json` → `nuan_cookie_nuanpaper.json`（myl/support 子域名分组）+ `nuan_cookie_papegames.json`
- **Cookie 格式升级**：按子域名分组，时间戳命名（`current_YY-MM-DD`），每条标注"只能增补，严禁覆写删除"
- **昵称搜索精度优化**：gacha-query.md 搜索步骤增强（多词交叉验证、视觉误导踩坑记录）
- **毕业定义 + 陪跑四星概念**：game-knowledge.md 新增核心规则 #9/#10、陪跑四星章节
- **抽卡规划指南**：game-knowledge.md 新增零氪/小月卡/中高氪资源积累表
- **PC 配置指南**：game-knowledge.md 新增设备要求与常见问题排查
- **强制规则 #13/#14**：SteamDB 必须可见窗口、流程细节不透露
- **禁止行为清单扩充**：新增使用浏览器配置工具的禁令、Skill 规则优先级声明
- **代码清理**：删除 `nuan_session.json`、`nuan_gacha_history (2).json` 残留文件、全量审计 references 关联关系
- **版本历史独立**：版本历史从 SKILL.md/README.md 拆出为独立 `CHANGELOG.md`

---

## v1.2.0（2026-06-27）

- **新增游戏常识库**：`references/nuanskill-game-knowledge.md` — 日活、抽卡规则、大世界探索、奇想手账结构
- **新增卡池倒计时支持**：journal 数据常态化写入 `current_banner_pool`、定时任务卡池结束前提醒
- **满进判断规则固化**：`secondSuit.drawNum > 0` 为准，gacha-query + game-knowledge 双文档记录
- **限定池完整规则**：版本周期、按稀有度分、五星池细分、抽取道具对照、核心规则表
- **移除 localStorage 必须可见窗口限制**（实测无头可用）
- **参考文献整体审计**：8 个 references 全量关联关系校验通过
- **清理残留文件**：nuan_session.json、nuan_gacha_history (2).json 已删除

---

## v1.1.1（2026-06-27）

- **新增第 11、12 条强制规则**：实时数据必须联网查询、页面数据缺失必须重试
- **重写 Chrome 用户凭据管理章节**：新增浏览器降级策略（Chrome→Edge→agent 内置）、三级凭据优先级、禁止行为清单
- **gacha-query.md 新增 localStorage 提取** + 提取流程增强（保底计数、部件明细、reasonance_summary）
- **新增数据文件格式规范**：5 个 JSON 文件精确 schema；gacha_history 字段补全
- **新增定时任务配置模板**：每日监控 + 每月抽卡 + 引导话术
- **data-format 和 schedule-templates 从 SKILL.md 拆分到 references**
- **术语统一**：全部 `browser agent` → `Chrome（Cache\chrome_temp_profile\）`
- **冲突修复**：steamdb-check 验证项数 7→8、昵称确认修正、共用 Chrome Profile 清理保护

---

## v1.1.0（2026-06-27）

- **新增探索进度查询能力（能力③）**：流转之柱/奇想星/灵感露珠/子区域收集项
- 新增 `references/nuanskill-explore-overview.md`
- **意图路由表重构**：新增能力编号列，Agent 按能力路由
- **能力编号统一**：所有 references 标注能力编号
- **gacha-query.md 重写**：React fiber 采集流程、clothesPress 直达、首次初始化流程、5 条踩坑
- **文件清单重构**：按能力分组，删除 nuan_session.json
- **新增抽卡记录初始化**：首次使用触发，告知 5-15 分钟

---

## v1.0.1（2026-06-26）

- **新增首次初始化工作流**：首次使用或 Cookie 缺失时弹出可见 Chrome 引导手动登录
- 新增第 9 条强制规则：初始化必须可见 Chrome
- 意图路由表新增初始化 / Cookie 过期触发行
- 错误处理速查补充

---

## v1.0.0（2026-06-25）

- **正式发布版本**：整合 Steam 管理与奇想手账两大能力集
- SKILL.md 采用 Agent Skill 标准格式（YAML front matter + 强制规则 + 意图路由表 + 错误处理速查）
- 脚本统一 `nuanskill-` 命名前缀
- 8 条不可违反的执行规则

### 废弃版本

以下为开发迭代过程中的废弃版本，仅供参考：

- **v4.0.0** — 前一次 SKILL.md 重写版本（已废弃）
- **v3.2.0** — reference 文档统一命名阶段（已废弃）
- **v3.1.0** — 奇想手账能力整合阶段（已废弃）
- **v3.0.0** — 工具集架构重构阶段（已废弃）
- **v1.0.0** — 初始原型版本（已废弃）
