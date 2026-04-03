# 袁梓清

**求职意向：全栈开发工程师**

电话：138XXXX XXXX | 邮箱：xxxxxx@gmail.com | 年龄：25岁 | 工作年限：2年
GitHub：github.com/yuanziqing | 博客：blog.csdn.net/qq_36833171

---

## 个人简介

2 年全栈开发经验，熟悉 Node.js/NestJS 后端开发和 React/Vue 前端开发。在桌面应用（Electron）、复杂前端组件（Monaco Editor、富文本编辑器）、Python 微服务（FastAPI）方面有实践经验。熟悉 Docker 容器化部署。

---

## 核心技能

| 领域 | 技术栈 |
|------|--------|
| **后端开发** | Node.js/NestJS、FastAPI/Python、PostgreSQL、MySQL、Redis、Elasticsearch |
| **前端开发** | React 18、Vue 3、TypeScript、Electron、Monaco Editor |
| **桌面应用** | Electron 主进程/渲染进程架构、IPC 通信、自动更新 |
| **工程化** | Docker、Webpack/Vite、Turborepo |
| **AI/Agent** | Mastra Agent 框架、MCP 协议、RAG 架构 |

---

## 工作经历

### 企研数据科技（杭州）有限公司 | 全栈开发工程师
**2024.10 - 至今**

**项目经理**：负责 ChatPython、社科大数据平台（R 平台）、企研云桌面（Cloud 平台）、YKY 智能科研平台、数字经济教学实训平台等多个核心产品的开发与维护。

---

#### ChatPython - Python 数据分析 IDE

面向社会科学研究者的数据分析工具，内置 Python 运行时，支持代码编辑、智能对话、数据分析。

**项目链接**：https://chatpython.qiyansoft.com

**技术栈**：Electron 38 + React 18 + NestJS + Monaco Editor + Tiptap + Turborepo

**核心贡献**：

1. **Monaco Editor 深度集成**
   - 实现 Model 生命周期管理，支持多文件切换时状态持久化
   - 外部文件变更智能更新，保持滚动位置和光标状态
   - Web Worker 自定义加载器（HTML/CSS/JS/TS/JSON），解决 CDN 依赖问题
   - 添加中文语言包，实现本地化支持
   - 解决保存编辑器时撤销栈丢失问题

2. **复杂 Mention 组件开发**
   - 基于 Tiptap 扩展实现多种类型提及节点（@智能体、#文件、#文件夹、#数据库表格）
   - 级联触发机制、自定义 NodeView 渲染、建议列表状态同步
   - 优化交互体验，增加 loading 效果

3. **Python 解释器管理系统**
   - 支持系统 Python、Conda 环境、uv 虚拟环境三种模式
   - 解释器自动下载（OSS 流式解压）、Windows 平台 VC++ 运行库自动安装
   - 包管理：支持多选安装/卸载、自定义包名安装、推荐包列表、清华源加速
   - 解决 Win10 系统下退出应用后残留进程的问题

4. **Agent/MCP 架构**
   - 集成 Mastra AI 框架，实现多智能体协作
   - 设计 MCP Bridge 层连接渲染进程和主进程
   - 实现 AI Agent 对编辑器状态的访问（文件读取/写入、终端执行）
   - 支持 Langfuse 可观测性集成

5. **终端与文件管理**
   - 多终端实例管理，终端面板自动聚焦
   - 终端自动配置解释器，实现代码一键运行
   - 资源管理器：文件/文件夹新建、重命名、删除，右键菜单
   - 文件未保存状态检测与提示

6. **用户系统与认证**
   - 微信登录、绑定/换绑功能
   - JWT 令牌自动续期机制
   - 用户邀请功能、首次登录引导

7. **跨平台打包与更新**
   - 支持 macOS（arm64/x64/universal）、Windows 平台打包
   - 实现自动更新机制，崩溃日志收集

---

#### 社科大数据平台-——机构版

面向学术科研人员的数据下载平台，已为多所高校（福建农林大学、浙江工商大学、南京审计大学、华中农业大学等）提供社科数据服务。

**项目链接**：https://r.qiyandata.com

**技术栈**：NestJS + Vue 3 + PostgreSQL + Elasticsearch + Redis

**核心贡献**：

1. **AI 检索与分析系统**
   - 基于向量检索的知识库搜索，优化 Ranking 算法和重排模型
   - 任务队列实现异步重排，优化大文档处理性能
   - 多智能体系统：数据分析、SQL 专家、Echart 专家
   - AI 客服助手（企小喵），支持沉浸式引导和知识库配置
   - 会话管理、消息持久化、满意度反馈、下一步问题建议

2. **企研智图（AI 图表生成）**
   - AI 自动生成 ECharts 图表，支持多表格关联分析
   - 图例配置、图表类型选择、趋势分析、图表导出
   - 利用 QwenCoder 模型优化 SQL 生成效果
   - SQL 语法高亮、格式化展示

3. **知识库管理系统**
   - 支持多种格式文档解析（PDF/Word/图片），优化 Chunk 算法
   - 文档向量化、分段管理、分段预览
   - 知识库文档批量上传、源文件下载
   - 公共/私有访问范围控制

4. **ES 多维度聚合分析工具**
   - 实现 DSL 解析器，将自定义查询语法转换为 ES 查询语句
   - 支持多维度聚合：keyword、text、nested、date_histogram
   - 滚动查询（Scroll API）处理大数据量导出

5. **ES 日志分析系统**
   - 接口日志、下载日志、AI 使用日志的多维度分析
   - 定时任务清理过期日志
   - 云桌面软件日志分析图表

6. **CMS 内容管理系统**
   - 首页排行榜自动更新（基于 ES 聚合统计热门数据表）
   - 分类问答组件、问答管理
   - 富文本编辑器（Tinymce）附件上传优化

7. **系统监控**
   - 系统运行状态监控
   - 接口日志记录与分析

---

#### 社科大数据平台-——云桌面版

企业级云桌面管理平台，支持虚拟机管理、用户管理、权限控制，已服务多个机构客户。

**项目链接**：https://cloud.qiyandata.com

**技术栈**：NestJS + Vue 3 + Guacamole + Elasticsearch

**核心贡献**：

1. **AI 中心**
   - 从 R 平台移植 AI 检索、AI 数据推荐功能
   - AI 客服集成
   - 多条件表格筛选
   - AI 日志记录

2. **ES 日志分析**
   - 用户操作日志、下载日志的多维度分析
   - 日志聚合统计与可视化

3. **域控集成**
   - Windows 域控制器对接，实现用户认证与同步

4. **用户管理**
   - 用户认证信息管理、审核流程
   - 云桌面申请、分配、到期管理
   - 用户信息导出功能

---

#### YKY 智能科研平台

面向高校的 AI 科研辅助平台，集成 AI 助手、联网检索、会话管理、积分系统等功能。

**技术栈**：NestJS + Vue 3 + PostgreSQL + Mastra + fastembed

**核心贡献**：

1. **AI 助手系统**
   - 基于 Mastra 框架实现 AI 对话，支持语义召回（fastembed）
   - 会话管理：消息组分页、会话重命名、历史记录
   - 云桌面内外 AI 会话隔离
   - Markdown 解析器（数学公式、代码高亮、懒加载）
   - SSE 流式推送，支持停止生成
   - 消息重新生成、编辑问题功能

2. **联网检索**
   - AI 联网搜索功能

3. **用户认证与管理**
   - 用户认证信息管理、审核流程
   - 用户身份配置、认证材料导出
   - 云桌面到期后禁用操作

4. **积分系统**
   - 每日签到赠送积分
   - 积分明细、Token 消耗记录
   - 积分不足错误处理

5. **通知系统**
   - 邮件队列、任务超时机制
   - 磁盘容量不足自动通知管理员
   - 大文件外发邮件通知

6. **自定义页面**
   - 分类问答组件
   - 自定义页面配置

---

#### 数字经济教学实训平台

面向高校的在线编程实训平台，JupyterHub + Docker 架构。

**项目链接**：https://gdufe-yky.qiyandata.com:6234

**技术栈**：Vue 3 + NestJS + JupyterHub + Docker

**核心贡献**：

- JupyterHub 集成，Docker 容器化实训环境管理
- 多端管理后台开发（学院端/教师端/企研端）
- 容器磁盘容量管理
- Docker/JupyterHub SSL 证书配置
- 教师端作业管理

---

#### RAG 平台微服务架构

**技术栈**：FastAPI + Python + Docker

**核心贡献**：

1. **文档解析服务**（Docling）
   - PDF/图片/Word 转 Markdown，支持 VLM（Qwen2-VL-2B）精准 OCR
   - 图片/表格自动提取上传 OSS
   - 支持 500M 大文件上传

2. **关键词提取服务**（KeyBERT）
   - 基于 SentenceTransformer + KeyBERT 多语言关键词提取
   - MMR 算法优化关键词多样性
   - 解决多线程 jieba 导出接口崩溃问题

3. **API 网关**（NeuroL Gateway）
   - JWT 认证 + API 代理转发
   - IP 白名单中间件、全局异常处理

---

### 催化剂加（杭州）科技有限公司 | 前端开发工程师
**2022.02 - 2023.10**

#### 催化剂加桌面客户端

催化剂加是一款全面的科研信息平台。平台以科研桌面为核心，内置 AI 语义化分析的论文阅读器、专攻科研模型的 AI GPT，以及强大的科研万能检索功能。

**项目链接**：https://www.researchercosmos.com

**技术栈**：
- 客户端：TypeScript、React、Electron、MobX、Framer Motion、Webpack
- 数据中台：TypeScript、React、Ant Design Pro、Hox、UmiJS
- 信息流模块：TypeScript、Vue 3、Pinia、Qiankun、Vite
- 浏览器插件：TypeScript、React、CRXJS、Service Worker

**项目职责**：

1. 根据 Figma 设计图，利用 CSS3、Sass、Less、Tailwind CSS 精准还原设计稿

2. 负责科研客户端功能迭代，负责 Electron 组件、IPC 等模块封装

3. 维护用于功能检索的求是台模块，新增下班倒计时、天气、日历卡片，增加过渡动画、高斯模糊、异步加载效果

4. 通过 Node.js、Express 为备忘录、天气等求是台卡片做数据持久化，开发期刊文献海报生成、数据采集等接口

5. 参与平台客户端组件化重构与 Web 化，主要负责 SVG、知识卡片、树状筛选表单、树形菜单、动画组件等

6. 使用 React Query SWR 缓存模块，为复杂数据查询、第三方 API 调用等添加缓存，节约服务器资源

7. 通过 React Virtualized 优化长列表，解决了期刊订阅列表的卡顿白屏问题

8. 负责数据中台技术迭代，将 Ant Design Pro 从 V4 迁移至 V5，Ant Design 从 V3 迁移至 V4

9. 对前端工程化、组件化、缓存、UI、骨架屏、动画交互、分包加载、界面性能进行调优

---

## 教育背景

**浙江万里学院** | 物联网工程 | 本科 | 2019.09 - 2023.06

---

## 项目链接

- ChatPython：https://chatpython.qiyansoft.com
- 社科大数据平台：https://r.qiyandata.com
- 企研云桌面：https://cloud.qiyandata.com
- 数字经济实训平台：https://gdufe-yky.qiyandata.com:6234
- 催化剂加：https://www.researchercosmos.com
