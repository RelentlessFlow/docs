# DIfy 环境变量

> 参考这个文档：https://docs.dify.ai/zh-hans/getting-started/install-self-hosted/environments

## 有点用的环境变量：

- LOG_LEVEL

  日志输出等级，默认为 INFO。生产建议设置为 ERROR。

- MIGRATION_ENABLED：

  数据库自动迁移开关

- CHECK_UPDATE_URL

  版本更新开关，默认false

- TEXT_GENERATION_TIMEOUT_MS

  文本、工作流超时时间

### Redis 配置：看官网

### CORS 配置

用于设置前端跨域访问策略。

- CONSOLE_CORS_ALLOW_ORIGINS

  控制台 CORS 跨域策略，默认为 *，即所有域名均可访问。

- WEB_API_CORS_ALLOW_ORIGINS

  WebAPP CORS 跨域策略，默认为 *，即所有域名均可访问。

详细配置可参考：跨域 / 身份相关指南


### 文件存储配置

- STORAGE_TYPE
  
  默认local，可以配置s3

### 向量数据库配置

- VECTOR_STORE

  默认weaviate

### 知识库配置

- UPLOAD_FILE_SIZE_LIMIT

  上传文件大小限制，默认 15M。

- UPLOAD_FILE_BATCH_LIMIT

  每次上传文件数上限，默认 5 个。


### 多模态模型配置

- UPLOAD_IMAGE_FILE_SIZE_LIMIT

  上传图片文件大小限制，默认 10M。

### 邮件相关配置

看官网吧，SMTP那套

### 模型供应商 & 工具 位置配置

这个看着还挺重要的，可以隐藏某些模型供应商


