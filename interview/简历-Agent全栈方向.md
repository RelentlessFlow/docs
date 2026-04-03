# 袁子清

全栈开发工程师 | AI Agent 开发专家

## 联系方式

- 学历: 本科 | 物联网工程
- 年龄: 25周岁
- 博客: https://blog.csdn.net/qq_36833171

## 专业技能

### AI/Agentic Engineering

- **Agent 框架开发**
  - 精通 LangGraph 智能体编排框架，掌握状态图(StateGraph)设计、工具调用、人机交互(HITL)机制
  - 熟练使用 Mastra Agent 框架，具备工具定义、Memory系统、结构化输出能力
  - 熟悉 MCP (Model Context Protocol) 协议，实现 Agent 与外部工具的标准化集成
  - 掌握 Function Calling、ReAct、Prompt Chaining 等多种 Agent 设计模式

- **RAG 知识库系统**
  - 具备 RAG 系统全流程开发经验，包括文档解析、向量化、语义检索
  - 熟悉文档解析技术栈 (Docling、RapidOCR、PyMuPDF)
  - 掌握 KeyBERT 关键词提取、Sentence-Transformers 语义嵌入

- **模型工程**
  - 熟悉阿里云百炼、DeepSeek、OpenAI 等多模型平台接入
  - 掌握模型结构化输出、流式输出、Token消耗优化
  - 具备模型微调经验 (LLaMA Factory、百炼平台)

### 后端开发

- 精通 Node.js/TypeScript，深入理解 NestJS 框架架构
- 熟悉 Python (FastAPI)，具备 AI 服务开发能力
- 熟练使用 TypeORM、Prisma 等 ORM 框架
- 熟悉 MySQL 数据库设计、Redis 缓存应用
- 掌握消息队列 (BullMQ、Bull) 任务调度

### 前端开发

- 精通 React 生态，熟练使用 Ant Design、Tailwind CSS
- 掌握 Electron 桌面应用开发
- 熟悉 Vue 3 及相关生态

### DevOps

- 熟练使用 Git、Docker 容器化部署
- 熟悉 CI/CD 自动化流程
- 掌握 Nginx 配置、HTTPS 证书部署

## 工作经历

### 杭州天慧蓝科技有限公司（催化剂加） | 2023.02 - 2024.10

催化剂加是全球领先的科研 AI Copilot 平台，为全球超百万科学家提供信息、数据和 AI 分析支持。

**主要负责：** 桌面端 AI 助手应用开发

### 企研数据 | 2024.10 - 至今

企研数据是专注于社科大数据领域的科技公司，提供数据分析和知识服务。

**主要负责：** AI 产品研发、RAG 知识库系统、数据分析工具开发

## 项目经历

### ChatPython - AI 数据分析桌面应用

**项目描述**

面向社会科学研究者的 AI 数据分析桌面应用，支持自然语言驱动的 Python 代码执行，无需配置编程环境即可完成数据分析任务。

**在线地址：** https://chatpython.qiyansoft.com/

**技术栈**

- **桌面端:** Electron + React 19 + Vite + TypeScript
- **后端:** NestJS + Fastify + TypeORM + MySQL + Redis
- **AI 集成:** Mastra Agent + Vercel AI SDK + Langfuse + MCP Protocol
- **架构:** Turborepo Monorepo (pnpm workspace)

**核心难点与负责内容**

- **Mention @提及组件开发（1000+ 行）**
  - 基于 Tiptap 富文本编辑器扩展，实现多类型 Mention 节点（@智能体、#文件、#文件夹、#表格）
  - 设计 `MentionNodeAttributes` 数据结构，支持节点携带文件路径、智能体 ID、图标等元信息
  - 实现自定义 `NodeView` 渲染，支持点击节点跳转到文件/智能体
  - 设计 `createSuggestionConfig` 工厂函数，统一管理不同触发字符的 Suggestion 配置
  - 实现键盘导航（上下箭头、回车、ESC），支持 `useImperativeHandle` 暴露 `onKeyDown` 接口
  - 解决闭包问题：使用 `useLatest` Hook 保持动态数据最新引用
  - 后续规划：集成 LSP (Language Server Protocol) 实现智能补全与跳转

- **Monaco Editor 多文件编辑器集成**
  - 配置多语言 WebWorker（TypeScript、JavaScript、CSS、HTML），实现语法高亮与智能补全
  - 设计 `upsertModel` 机制，支持多文件 Model 动态创建与切换
  - 实现 `saveModelState` / `initModelState`，持久化编辑器视图状态（滚动位置、光标位置）
  - 开发 `updateModelContent` 方法，支持外部文件变更时保持编辑器状态不变
  - 封装 `execute` 命令系统，支持保存、撤销、重做、查找替换、多光标编辑等 20+ 操作

- **AI 智能体架构设计**
  - 集成 Mastra Agent 框架，实现多轮对话与工具调用
  - 基于 MCP 协议实现文件系统、代码执行器等工具的标准化接入
  - 集成 Langfuse 实现 Prompt 迭代追踪与 Token 消耗监控

- **桌面端工程化**
  - 设计 Electron 主进程与渲染进程 IPC 通信架构
  - 集成 node-pty 实现终端模拟器，支持 Python 解释器管理
  - 实现崩溃日志系统，进程异常监控与自动上报
  - 完成 Windows/macOS 双平台打包与自动更新机制

---

### 企研社科智链 - RAG 知识库平台

**项目描述**

面向社会科学研究的企业级 RAG 知识库平台，支持智能体创建、知识库管理、联网检索等功能。

**在线地址：** https://r.qiyandata.com/

**技术栈**

- **前端:** Vue 3 + Vite + Tailwind CSS + UnoCSS
- **后端:** NestJS + Fastify + TypeORM + MySQL + Redis + BullMQ
- **AI:** 阿里云百炼 + ElasticSearch + 自研 RAG Pipeline
- **架构:** Turborepo Monorepo

**核心难点与负责内容**

- **RAG 知识库核心功能**
  - 设计知识库数据模型，支持公共/私有访问权限控制与按管理员隔离
  - 实现文档批量上传与分段解析，支持 PDF/Word/PPT/图片等多种格式
  - 开发知识库引用预览与溯源功能，点击引用跳转到原文位置
  - 实现分段策略配置（固定长度、语义分割）

- **智能体系统**
  - 设计智能体创建、配置、发布完整流程
  - 开发提示词润色与下一步问题建议功能（基于 AI 二次调用）
  - 实现智能体与知识库的关联机制，支持多知识库绑定
  - 集成联网检索能力，扩展智能体知识获取范围

- **AI 服务网关（NeuroL Gateway）**
  - 设计统一网关代理多个 AI 微服务（关键词解析、文档解析）
  - 实现路由配置管理，支持动态路由规则
  - 为 RAG 平台提供统一的 AI 能力接入层

---

### IRC 智能研究中心 - 多端 SaaS 平台

**项目描述**

面向高校科研机构的综合性 SaaS 平台，集成 AI 助手、云桌面、用户管理等功能，支持多端适配。

**技术栈**

- **前端:** Vue 3 + Vite + Tailwind CSS
- **后端:** NestJS + TypeORM + MySQL + Redis + BullMQ
- **架构:** Turborepo Monorepo + 多端适配 (Admin/Client/Screen)

**核心难点与负责内容**

- **AI 会话系统**
  - 实现云桌面内外会话隔离机制（基于环境变量动态切换 API）
  - 开发会话历史管理与标题自动生成（AI 总结）
  - 集成联网检索扩展 AI 知识边界

- **邮件通知系统**
  - 设计基于 BullMQ 的邮件队列系统，支持任务超时与重试机制
  - 实现磁盘容量监控与自动告警通知
  - 开发队列异常处理与死信队列

- **文件管理**
  - 实现附件/图片上传功能，支持时间戳命名规则防止冲突
  - 开发文件外发控制与权限管理
  - 实现富文本编辑器附件管理

---

### 数字教育实验室平台

**项目地址：** https://gdufe-yky.qiyandata.com:6234/home

**项目描述**

面向高校的数字化教学实验平台，基于 JupyterHub + Docker 架构，支持 Jupyter Notebook 在线编程与教学管理。

**技术栈**

- **前端:** Vue 3 + Vite + Tailwind CSS（多端：Client/Teacher/College）
- **后端:** NestJS + TypeORM + MySQL + Redis
- **基础设施:** JupyterHub + DockerSpawner + Docker + Minio

**核心难点与负责内容**

- **JupyterHub + DockerSpawner 架构**
  - 开发 `docker_spawn_hook.py`，实现用户容器启动前的动态配置
  - 从 Node 后端动态获取用户对应的 Docker 镜像、存储限制、文件夹映射配置
  - 实现基于用户类型（学生/教师/学院）的差异化资源配置

- **容器资源管理**
  - 实现磁盘配额控制（`storage_opt`），防止用户占满磁盘
  - 开发 `getDiskPartition` 方法，实时获取容器磁盘使用情况
  - 实现容器内命令执行（`execCommand`），支持文件检查、目录创建、文件下载
  - 集成 Minio 文件服务，实现容器内从对象存储下载文件

- **自定义认证器**
  - 开发 `MySqlAuthenticator`，实现基于 MySQL 的用户认证
  - 对接学校统一身份认证系统

- **自动空闲关闭**
  - 配置 `idle-culler` 服务，用户 30 分钟无操作自动关闭容器释放资源

---

### Docling 文档解析服务

**项目描述**

基于 Docling 的高性能文档解析微服务，支持 PDF/图片/Word/PPT 等格式的结构化解析与 OCR 识别。

**技术栈**

- Python 3.12 + FastAPI + Docling + RapidOCR + Aliyun OSS

**核心难点与负责内容**

- 设计 RESTful API 接口，支持多格式文档解析
- 集成 RapidOCR 引擎实现图片 OCR，支持 GPU 加速
- 实现阿里云 OSS 文件存储与多存储桶管理
- 完成服务 Docker 容器化与部署

---

### KeyBERT 关键词提取服务

**项目描述**

基于 KeyBERT 的关键词提取微服务，支持中英文关键词自动提取与语义分析。

**技术栈**

- Python 3.12 + FastAPI + KeyBERT + Sentence-Transformers + Jieba

**核心难点与负责内容**

- 实现关键词提取 API，支持多语言文本处理
- 集成 Sentence-Transformers 实现语义嵌入
- 优化模型加载与推理性能
