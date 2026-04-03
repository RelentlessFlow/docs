# 袁梓清

全栈开发工程师

## 联系方式

- 学历: 本科 | 物联网工程
- 年龄: 25周岁
- 毕业时间: 2023年6月

## 专业技能

### AI/Agentic Engineering

- 熟练使用 Mastra / Vercel AI SDK 开发 AI Agent 应用
- 掌握 LangGraph / LangChain 框架进行工作流编排
- 熟悉 MCP (Model Context Protocol) 协议
- 具备大模型微调实践经验（基于百炼、硅基流动等平台）
- 基于 Langfuse 进行提示词迭代
- 熟悉 RAG (检索增强生成) 架构，包括文档解析、向量化、知识库管理

### 后端

- 掌握 JavaScript (ES6+)、TypeScript
- 熟练使用 NestJS 框架构建企业级后端应用
- 熟练使用 TypeORM、Prisma 等 ORM 框架
- 熟悉 PostgreSQL (pgvector)、MySQL 数据库设计
- 熟悉 Elasticsearch 全文检索、聚合分析
- 熟悉 Redis 缓存应用
- 熟悉 MinIO 对象存储
- 熟悉 RabbitMQ、BullMQ 消息队列

### 前端 & 桌面端

- 掌握 Vue 3、React 前端框架
- 熟练使用 UnoCSS、Tailwind CSS
- 熟练使用 Electron 进行跨平台桌面应用开发
- 熟悉主进程/渲染进程架构、IPC 通信、自动更新

### DevOps

- 熟练使用 pnpm workspace 管理 Monorepo 项目
- 熟悉 Turborepo 构建优化
- 熟悉 Docker 容器化部署
- 熟悉 CI/CD 自动化部署

## 工作经历

### 企研数据 | 2024.10 - 至今

公司自主研发的社科大数据平台，为高校及研究机构提供数据检索、AI 分析等服务。核心产品包括：社科大数据平台（R/YKY）、ChatPython AI 分析助手、实训平台等。

### 杭州天慧蓝科技有限公司（催化剂加） | 2023.02 - 2024.10

全球首个专门针对科学研究洞察与知识自动化的生产级 AI 平台，为世界一流高校、国防科工类研究机构和企业研发团队提供信息、数据和 AI 分析支持。已被全球超百万科学家采用。

## 项目经历

### ChatPython - AI 数据分析桌面应用

项目描述

面向社会科学研究者的 AI 数据分析桌面应用，用户通过自然语言描述分析需求，AI Agent 自动拆解任务、编写 Python 代码、执行并返回分析结果。支持 CSV、Excel、Stata 等多种数据格式，无需配置 Python 环境即可开箱即用。

技术栈

Electron + React + TypeScript + Mastra + MCP + Monaco Editor + Tiptap

核心难点与负责内容

**Monaco Editor 深度集成**
- 实现 Model 生命周期管理，设计 `upsertModel` 机制支持多文件动态创建与切换，避免重复创建
- 开发 `saveModelState` / `initModelState`，持久化编辑器视图状态（滚动位置、光标位置、折叠状态）
- 实现 `updateModelContent` 方法，外部文件变更时智能更新，保持光标不跳动、滚动位置不变
- 配置多语言 WebWorker（TypeScript、JavaScript、CSS、HTML、JSON），解决 CDN 依赖问题
- 解决保存编辑器时撤销栈丢失问题

**复杂 Mention 组件开发**
- 基于 Tiptap 富文本编辑器扩展，实现多类型 Mention 节点（@智能体、#文件、#文件夹、#表格）
- 设计 `MentionNodeAttributes` 数据结构，支持节点携带文件路径、智能体 ID、图标等元信息
- 实现自定义 `NodeView` 渲染，支持点击节点跳转到文件/智能体
- 使用 `useLatest` Hook 解决闭包问题

**Python 解释器管理系统**
- 支持系统 Python、Conda 环境、uv 虚拟环境三种模式
- 解释器自动下载（OSS 流式解压）、Windows 平台 VC++ 运行库自动安装
- 包管理：支持多选安装/卸载、自定义包名安装、推荐包列表、清华源加速
- 解决 Win10 系统下退出应用后残留进程的问题

**Agent/MCP 架构**
- 集成 Mastra AI 框架，实现多智能体协作
- 设计 MCP Bridge 层连接渲染进程和主进程，实现 AI Agent 对编辑器状态的访问
- 支持 Langfuse 可观测性集成

**桌面端工程化**
- 设计 Electron 主进程与渲染进程 IPC 通信架构，实现类型安全的 IPC 调用
- 集成 node-pty 实现多终端实例管理
- 实现崩溃日志系统，完成 macOS/Windows 双平台打包与自动更新

### RAG Agent 微服务系统

项目描述

为企业级知识库平台提供 RAG 能力的微服务集群，包含文档解析、关键词提取、AI 网关三个核心服务，采用 Python FastAPI 开发，支持 GPU 加速。

技术栈

Python + FastAPI + Docling + KeyBERT + RapidOCR + MinIO

核心难点与负责内容

**文档解析服务 (file-parse-docling)**
- 支持 PDF、Word、Excel、PPT、Markdown 等多格式文档解析
- 集成 RapidOCR 实现 GPU 加速，替换 TesseractOCR 提升识别准确率
- 实现 OSS 多存储桶管理，设计并发控制机制

**关键词提取服务 (keyword-parse-kerbert)**
- 基于 KeyBERT 实现中英文关键词自动提取
- 解决 jieba 分词多线程导出接口崩溃问题

**AI 模型网关 (neurol-gateway)**
- 统一封装 DeepSeek、阿里百炼、Ollama 等多个 LLM 提供商的调用接口
- 实现基于 JWT 的服务间认证、IP 白名单访问控制

### 社科大数据平台（R平台）

项目描述

企研数据核心产品，面向高校及研究机构的社科大数据检索与分析平台。采用 Monorepo 架构，集成 AI 智能检索、知识库管理、智能体配置、科研空间等功能。

技术栈

Monorepo (pnpm workspace) + NestJS + TypeORM + PostgreSQL (pgvector) + Redis + MinIO + Vue 3 + UnoCSS

核心难点与负责内容

**AI 检索功能**
- 负责 AI 检索功能全栈开发，实现自然语言查询、向量检索、Ranking 重排序
- 设计 LRU 缓存机制，缓存工具生成的 SQL，优化重复查询响应速度

**知识库管理**
- 开发知识库管理模块，支持文档上传、分段策略配置、向量化、重新嵌入
- 设计文档嵌入任务队列，支持批量处理、失败重试

**智能体/模型管理**
- 开发智能体 CRUD 接口及管理后台，支持自定义 System Prompt、工具绑定、模型配置
- 开发供应商、向量化模型、对话模型管理接口，支持多供应商接入

**TypeORM 查询封装**
- 封装复杂查询工具、游标分页工具类，采用字段+ID 组合排序
- 封装 metadata 查询，简化向量检索、元数据过滤

**其他**
- 实现上传变量清单功能，支持 Excel 批量导入、字段智能匹配、分库上传
- 开发 AI 分析功能，支持样例数据、原始数据查看、SQL 格式化、图表导出

### 社科大数据平台（YKY）

项目描述

企研数据第一代产品，集成 AI 对话功能的社科大数据平台，为高校师生提供数据检索、云桌面、AI 辅助研究等服务。

技术栈

Monorepo (pnpm workspace) + NestJS + TypeORM + MySQL + Elasticsearch + Redis + Vue 3

核心难点与负责内容

**Mastra Agent 集成**
- 集成 Mastra Agent 框架，实现 AI 对话、代码生成、自动执行的完整工作流
- 实现 SSE 推流，开发 SSE 装饰器、fetchEventSource 封装

**CMS 内容管理系统**
- 从 WangEditor 迁移至 Tinymce，解决富文本样式污染问题
- 使用 ShadowDOM 隔离富文本样式

**Elasticsearch 聚合分析**
- 实现多维度聚合分析，支持按时间、机构、学科等维度统计
- 开发数据趋势柱状图、日志分析图表等统计功能

**游标分页封装**
- 封装游标分页工具类，解决 cursor 无数据依然返回游标问题
- 增加 ORM 日期转换精度

**用户系统**
- 开发用户认证管理、邮件通知（支持邮件队列、超时机制、磁盘容量告警）
- 开发积分系统，支持签到、积分消耗、日历签到

### 实训平台

项目描述

面向高校的在线实训教学平台，集成课程管理、班级管理、数据资源、JupyterHub 在线编程环境。

技术栈

NestJS + TypeORM + MySQL + Redis + Vue 3 + Quasar + JupyterHub

核心难点与负责内容

- 实现多端管理架构：学生端、教师端、高校管理端、企研管理端
- 实现 JupyterHub 集成，开发 Python Authenticator 实现用户自动登录、容器资源隔离

### 催化剂加桌面客户端

项目描述

催化剂加是一款全面的科研信息平台。平台以科研桌面为核心，内置 AI 语义化分析的论文阅读器、专攻科研模型的 AI GPT，以及强大的科研万能检索功能。

技术栈

- 客户端：TypeScript、React、Electron、MobX、Framer Motion、Webpack
- 数据中台：TypeScript、React、Ant Design Pro、Hox、UmiJS
- 信息流模块：TypeScript、Vue 3、Pinia、Qiankun、Vite

核心难点与负责内容

**Electron 桌面客户端开发**
- 负责 Electron 组件、IPC 通信等模块封装
- 开发科研资产云盘模块、钱包功能、组合订阅支付功能

**前端性能优化**
- 使用 React Query SWR 缓存模块，为复杂数据查询、第三方 API 调用添加缓存
- 通过 React Virtualized 优化长列表，解决期刊订阅列表的卡顿白屏问题

**组件化重构**
- 参与平台客户端组件化重构与 Web 化
- 负责数据中台技术迭代，将 Ant Design Pro 从 V4 迁移至 V5

## 技术沉淀

- 封装通用 TypeScript 工具库，包含数组、对象、日期、文件、IP、加密等常用工具函数
- 封装通用 TypeScript 类型定义库，统一项目类型规范
