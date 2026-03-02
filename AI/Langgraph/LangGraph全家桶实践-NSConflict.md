# LangGraph 全家桶实践

# LangChain 相关文档

## 阿里云百炼集成

https://help.aliyun.com/zh/model-studio/use-bailian-in-langchain#2d28bf78a17ww

结论：纯百炼平台用**langchain_qwq**，其他平台（**deepseek**）用**OpenAI 兼容** 

### **DashScope**

> 只做百炼平台推荐用这个

```
pip install langchain-community
pip install dashscope
```

模型调用：

```python
from dotenv import load_dotenv
from langchain_community.chat_models.tongyi import ChatTongyi
from langchain_core.messages import HumanMessage

load_dotenv()

chatLLM = ChatTongyi(
    model="qwen-plus",   # 此处以qwen-plus为例，您可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models
    streaming=True,
    # other params...
)
res = chatLLM.stream([HumanMessage(content="hi")], streaming=True)
for r in res:
    print("chat resp:", r.content)
```

配置环境变量

```
DASHSCOPE_API_KEY=sk-XXXXX
```

### **OpenAI 兼容** 

> 兼容部分模型，移植到其他模型平台会比较方便，**不支持Qwen推理模式，不支持Qwen结构化输出**

兼容模型列表：https://help.aliyun.com/zh/model-studio/compatibility-of-openai-with-dashscope?spm=a2c4g.11186623.0.0.1b17323fRkHNxk#eadfc13038jd5

模型信息总览：https://help.aliyun.com/zh/model-studio/models?spm=a2c4g.11186623.0.0.1b17323fRkHNxk#850732b1aabs0

**模型实例方式（推荐这种方式）**

timeout 是模型最大响应时间，如果要开启批量生成，这里建议填大一点

base_url 和 api_key 可以通过环境变量进行配置

max_tokens 指的是模型最大输出，这里参考 模型信息总览

```python
# 环境变量
import os

from dotenv import load_dotenv
from langchain_openai import ChatOpenAI

load_dotenv()

model = ChatOpenAI(
    api_key=os.getenv("DASHSCOPE_API_KEY"),
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
    model="qwen-plus",
    timeout=60 * 10,
    max_tokens=32768
)
```

标识字符串方式

环境变量

```
OPENAI_API_BASE=https://dashscope.aliyuncs.com/compatible-mode/v1
OPENAI_API_KEY=sk-XXXXX
```

注：配置好了环境变量后ChatOpenAI不需要填写api_key、base_url了

模型调用：

```python
agent: CompiledStateGraph[AgentState[ResponseFormat], Context, Any, Any] = create_agent(
    model='openai:qwen-plus',
    system_prompt=SYSTEM_PROMPT,
    tools=[get_user_location, get_weather_for_location],
    context_schema=Context,
    response_format=ToolStrategy(ResponseFormat),
    checkpointer=checkpointer
)
```

### langchain_qwq

我自己尝试了下，坑比较多（无法关闭思考过程、推理模型不支持工具选择等，不推荐）

环境变量（与Dashscope保持一致）：

```
DASHSCOPE_API_BASE=https://dashscope.aliyuncs.com/compatible-mode/v1
DASHSCOPE_API_KEY=sk-xxxxxxxx
```

示例程序：

```python
from langchain_qwq import ChatQwen

qwq_model = ChatQwen(
    model="qwq-plus",
    enable_thinking=True,
    thinking_budget=20,
    timeout=60 * 5,
)

async def test():
    response = qwq_model.astream("你好")
    last_type = None
    
    headers = {
        'reasoning': '\n---------------- reasoning ----------------',
        'text': '\n---------------- text ----------------',
    }
    
    async for chunk in response:
        block = next(iter(chunk.content_blocks or []), None)
        typ = block and block.get("type")
        
        if not typ:
            continue
        
        if typ != last_type:
            last_type = typ
            print(headers.get(typ, f"\n--- {typ} ---"))
        
        print(block.get(typ), end='', flush=True)
         
asyncio.run(test())
```

## Quickstart 快速入门

@dataclass： 自动生成pojo

@tool：自动标注为agent工具

BaseModel：如果展示如下参数警告，需要继承BaseModel类型

```
Expected type 'Command | None | Any' (matched generic type 'InputT ≤: TypedDictLikeV1 | TypedDictLikeV2 | DataclassLike | BaseModel | Command | None'), got 'InputSchema' instead
```

示例代码：

``` python
from dataclasses import dataclass
from typing import Any, List

from langchain.agents import create_agent, AgentState
from langchain.agents.structured_output import ToolStrategy
from langchain.tools import tool, ToolRuntime
from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.graph.state import CompiledStateGraph
from pydantic import BaseModel

from model import model

# 定义系统提示词
SYSTEM_PROMPT = """
You are an expert weather forecaster, who speaks in puns.
You have access to two tools:

- get_weather_for_location: use this to get the weather for a specific location
- get_user_location: use this to get the user's location

If a user asks you for the weather, make sure you know the location. If you can tell from the question that they mean wherever they are, use the get_user_location tool to find their location.
"""

# 定义运行时上下文
class Context(BaseModel):
    """Custom runtime context schema."""
    user_id: str

# 定义输入格式
class InputSchema(BaseModel):
    messages: List[HumanMessage]

# 定义响应格式
@dataclass
class ResponseFormat:
    """Response schema for the agent."""
    # A punny response (always required)
    punny_response: str
    # Any interesting information about the weather if available
    weather_conditions: str | None = None

# 定义工具函数
@tool
def get_weather_for_location(city: str) -> str:
    """Get weather for a given city."""
    return f"It's always sunny in {city}!"

@tool
def get_user_location(runtime: ToolRuntime[Context]) -> str:
    """Retrieve user information based on user ID."""
    user_id = runtime.context.user_id
    return "Florida" if user_id == "1" else "SF"

# 添加记忆功能
checkpointer = InMemorySaver()

# 创建智能体
agent: CompiledStateGraph[AgentState[ResponseFormat], Context, Any, Any] = create_agent(
    model=model,
    system_prompt=SYSTEM_PROMPT,
    tools=[get_user_location, get_weather_for_location],
    context_schema=Context,
    response_format=ToolStrategy(ResponseFormat),
    checkpointer=checkpointer
)

# 运行智能体
config: RunnableConfig = {"configurable": {"thread_id": "1"}}
response = agent.invoke(
    InputSchema(messages=[HumanMessage(role="user", content="what is the weather outside?")]),
    config=config,
    context=Context(user_id="1")
)

print(response['structured_response'])

response = agent.invoke(
    InputSchema(messages=[HumanMessage(role="user", content="thank you")]),
    config=config,
    context=Context(user_id="1")
)

print(response['structured_response'])
```

## Agent 智能体

https://docs.langchain.com/oss/python/langchain/agents

### 动态模型

```python
# 中间件
@wrap_model_call
def dynamic_model_selection(request: ModelRequest, handler) -> ModelResponse:
    """Choose model based on conversation complexity."""
    print(f"len: {len(request.state["messages"])}")
    message_count = len(request.state["messages"])

    if message_count > 5:
        # Use an advanced model for longer conversations
        model = advanced_model
    else:
        model = basic_model

    return handler(request.override(model=model))
  
# 创建智能体
agent: CompiledStateGraph[AgentState[ResponseFormat], Context, Any, Any] = create_agent(
    model=model,
    middleware=[dynamic_model_selection]
)
```

### 动态系统提示词

```python
# 动态系统提示（中文）
@dynamic_prompt
def user_role_prompt(request: ModelRequest) -> str:
    """根据用户角色生成提示词"""
    user_role = cast(UserRole, request.runtime.context.user_role)
    base_prompt = "你是一个乐于助人的助手。"

    if user_role == "expert":
        return f"{base_prompt} 提供详细的技术解答。"
    elif user_role == "beginner":
        return f"{base_prompt} 以简单易懂的方式解释，不使用术语。"

    return SYSTEM_PROMPT
```

### 工具调用错误处理

```python
# 自定义工具错误处理
@wrap_tool_call
def handle_tool_errors(request, handler):
    """处理工具执行错误，返回自定义消息"""
    try:
        return handler(request)
    except Exception as e:
        return ToolMessage(
            content=f"工具执行出错：请检查输入后重试。({str(e)})",
            tool_call_id=request.tool_call["id"]
        )
```

### state_schema

 [`state_schema`](https://reference.langchain.com/python/langchain/middleware/#langchain.agents.middleware.AgentMiddleware.state_schema) 参数用来定义仅在工具中使用的自定义状态。

定义方式有两种，在`create_agent`函数中定义或在中间件中定义，官网文档推荐在`中间件`中定义

```python
from pprint import pformat
from typing import Any, TypedDict, cast

from langchain.agents import create_agent, AgentState
from langchain.agents.middleware import AgentMiddleware
from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.graph.state import CompiledStateGraph
from langgraph.typing import StateT_co
from pydantic import BaseModel

from model import model
from schema import BaseInputSchema
from tool import tools

# 运行时上下文
class Context(BaseModel):
    """自运行时上下文 schema"""
    user_id: str = ""


# 用户偏好
class UserPreferences(BaseModel):
    style: str = "technical"
    verbosity: str = "detailed"


# 自状态
class StateSchema(AgentState):
    user_preferences: UserPreferences


# 输入格式
class InputSchema(BaseInputSchema):
    user_preferences: UserPreferences


class CustomMiddleware(AgentMiddleware[StateT_co, Context]):
    state_schema = StateSchema
    tools = tools  # 可以按需替换
    
    def before_model(self, schema: StateSchema, runtime):
        print("context:", runtime.context)
        print("schema:", schema)


# 智能体类型
Agent = CompiledStateGraph[AgentState, Context, Any, Any]

# 创建智能体
agent: Agent = create_agent(
    model=model,
    context_schema=Context,
    middleware=[CustomMiddleware()],
    state_schema=StateSchema  # type: ignore[arg-type]
)

# 运行智能体
context = Context(user_id="1")
config: RunnableConfig = {"configurable": {"thread_id": "1"}}

response = agent.invoke(
    InputSchema(
        messages=[HumanMessage(
            role="user",
            content="我更喜欢技术性的解释"
        )],
        user_preferences=UserPreferences(
            style="technical",
            verbosity="detailed",
        )
    ),
    config=config,
    context=context,
)

print("response:", pformat(response))
```

### 流式输出

```python
response = agent.stream(
    InputSchema(
        messages=[HumanMessage(
            role="user",
            content="今天天气如何"
        )],
        user_preferences=UserPreferences(
            style="technical",
            verbosity="detailed",
        )
    ),
    config=config,
    context=context,
    stream_mode="values"
)

for chunk in response:
    latest_message = chunk["messages"][-1]
    if latest_message.content:
        print(f"Agent: {latest_message.content}")
    elif latest_message.tool_calls:
        print(f"Calling tools: {[tc['name'] for tc in latest_message.tool_calls]}")
```

## Models 模型

https://docs.langchain.com/oss/python/langchain/models#stream

### 模型输出

**Invoke 调用**

```python
conversation = [
    {"role": "system", "content": "You are a helpful assistant that translates Chinese to English."},
    {"role": "user", "content": "翻译：我喜欢编程。"},
    {"role": "assistant", "content": "I love programming."},
    {"role": "user", "content": "翻译：我喜欢开发应用程序。"}
]

response = basic_model.invoke(conversation)
print(response.pretty_print())
```

**Stream 流式输出**

```python
for chunk in model.stream("鹦鹉为什么有五颜六色的羽毛?"):
    print(chunk.text, end="", flush=True)
```

**Batch 批处理**

将一系列独立的模型请求批量处理，可以显著提高性能并降低成本，因为可以并行处理这些请求：

batch：等待全部结果接收后一起接收

batch_as_completed：每个输出完成后立即接收

```python
list_of_inputs = [
    "鹦鹉为什么有五彩的羽毛？",
    "飞机是如何飞行的？",
    "什么是量子计算？"
]
config = RunnableConfig(max_concurrency=5)
responses = model.batch(
    list_of_inputs,
    config=config
)
for response in responses:
    print(response)
```

**阿里百炼 Batch Chat**

https://help.aliyun.com/zh/model-studio/openai-compatible-batch-chat/

**工作原理**

1. **请求提交**：客户端发起请求并建立连接。

2. **连接保持**：请求进入队列排队，客户端保持连接等待。

3. **同步返回**：请求处理完成后，服务端通过之前保持的连接，将完整结果一次性返回给客户端。

   > 如果超过最长等待时间，连接将自动断开并返回超时错误。

**适用范围**

- **支持的地域**：中国大陆（北京）
- **支持的模型**：qwen3-max、qwen-plus、qwen-flash、qwen3-vl-plus、qwen3-vl-flash

**计费说明**

- **计费单价：**所有成功请求的输入和输出Token，单价均为对应模型实时推理价格的**50%**，具体请参见[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。
- **计费范围：**仅对任务中成功执行的请求进行计费。任何失败的请求（包括系统错误或超时）均不计费。

**重要**：批量推理为独立计费项，不支持[预付费](https://common-buy.aliyun.com/?commodityCode=sfm_llminference_spn_public_cn)（节省计划、资源包）、[新人免费额度](https://help.aliyun.com/zh/model-studio/new-free-quota)等优惠，以及[上下文缓存](https://help.aliyun.com/zh/model-studio/context-cache)等功能。

###  Tool calling 工具调用

**绑定工具 bind_tools**

模型可以请求调用工具来执行诸如从数据库获取数据、搜索网络或运行代码等任务。工具是以下各项的组合：

绑定用户自定义工具时，模型的响应包含执行该工具的**请求** 。如果模型与[代理](https://docs.langchain.com/oss/python/langchain/agents)分开使用，则需要您自行执行请求的工具并将结果返回给模型以供后续推理使用。如果使用[代理 ](https://docs.langchain.com/oss/python/langchain/agents)，代理循环将自动处理工具执行循环。

```python
from langchain.tools import tool

@tool
def get_weather(location: str) -> str:
    """Get the weather at a location."""
    return f"It's sunny in {location}."


model_with_tools = model.bind_tools([get_weather])  

response = model_with_tools.invoke("What's the weather like in Boston?")
for tool_call in response.tool_calls:
    # View tool calls made by the model
    print(f"Tool: {tool_call['name']}")
    print(f"Args: {tool_call['args']}")
```

**强制工具调用 Forcing tool calls** 

默认情况下，模型可以根据用户输入自由选择要使用的绑定工具。但是，您可能希望强制选择某个工具，确保模型使用特定工具或给定列表中的任意工具：

```python
model_with_tools = model.bind_tools([tool_1], tool_choice="any")
```

强制使用特定工具

```python
model_with_tools = model.bind_tools([tool_1], tool_choice="tool_1")
```

### Structured output 结构化输出

文档：https://docs.langchain.com/oss/python/langchain/models#typeddict

**基于 Pydantic 结构化输出**

一、基于JSON提示词 + with_structured_output 实现

```python
class Movie(BaseModel):
    """一部电影的详细信息"""
    title: str = Field(..., description="电影名称")
    year: int = Field(..., description="电影上映年份")
    director: str = Field(..., description="导演")
    rating: float = Field(..., description="电影评分（满分 10 分）")

# 使用结构化输出
model_with_structure = model.with_structured_output(Movie)

# 调用模型获取电影信息
prompt = (
    "请用 JSON 格式提供电影《盗梦空间》的详细信息，"
    "确保包含 title, year, director, rating 字段"
)
response = model_with_structure.invoke(prompt)
print(response)
```

**二、基于PromptTemplate + PydanticOutputParser 实现**

```python
# 定义结构化对象
class Movie(BaseModel):
    title: str = Field(..., description="电影名称")
    year: int = Field(..., description="电影上映年份")
    director: str = Field(..., description="导演")
    rating: float = Field(..., description="电影评分（满分 10 分）")

# 创建解析器
parser = PydanticOutputParser(pydantic_object=Movie)

# 定义通用结构化 PromptTemplate
template = """{format_instructions} {question}"""

structured_prompt_template = PromptTemplate(
    template=template,
    input_variables=["item_name"],               # 任意值变量
    partial_variables={"format_instructions": parser.get_format_instructions()}  # 结构化约束
)

# 使用示例
item_name = "电影《盗梦空间》"
prompt = structured_prompt_template.format(question=f"请告诉我关于{item_name}的信息")

# 调用模型
raw_response = model.with_structured_output(Movie).invoke(prompt)
print(raw_response)
```

**或者不使用  with_structured_output 进行输出，而是利用 PydanticOutputParser 对输出进行解析，这种形式会比上面那种节约Token，较为推荐🚀**

修改最下面几行

```python
# ---------- Before ---------- 
raw_response = model.with_structured_output(Movie).invoke(prompt)

# ---------- Now ---------- 
raw_response = model.invoke(prompt)
movie = parser.parse(raw_response.content)
```

其他几种方式暂时用不到

### Multimodal 多模态

百炼：https://help.aliyun.com/zh/model-studio/vision?spm=a2c4g.11186623.help-menu-2400256.d_0_2_0.4c733748ndFNSN&scm=20140722.H_2845871._.OR_help-T_cn~zh-V_1

LangChain：https://docs.langchain.com/oss/python/langchain/models#multimodal

基于 **qwen3-vl-plus** 实现多模态对话能力，这里HumanMessage也可以直接用JSON结构：

`{ type: "user", content: {} }`

代码如下：

```python
vl_model = ChatOpenAI(
    model="qwen3-vl-plus",
    timeout=60 * 5,
    max_tokens=32768
)

vl_message = HumanMessage(
    content=[
        {
            "type": "image_url",
            "image_url": {
                "url": "https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20241022/emyrja/dog_and_girl.jpeg"
            },
        },
        {"type": "text", "text": "图中描绘的是什么景象?"},
    ]
)

response = vl_model.invoke([vl_message])
```

###  Reasoning 推理

百炼文档：https://help.aliyun.com/zh/model-studio/deep-thinking

LangChain：https://docs.langchain.com/oss/python/langchain/models#reasoning

目前 qwen 的所有模型（包括deepseek r1）在 OpenAI兼容模式下均无法打印思考过程： https://github.com/langchain-ai/langchain/issues/33672

只能使用 DashScope 相关 API才能拿到，并且在输出时，无法动态切换是否开发推理模式

```python
from langchain_community.chat_models.tongyi import ChatTongyi

basic_model = ChatTongyi(
    model="qwen-plus",
    model_kwargs={ 
      "enable_thinking": True,
      "incremental_output": True
    },
)
model = basic_model

response = qwq_model.stream("你好")
for chunk in response:
    chunk_content = (
            chunk.content or
            chunk.additional_kwargs.get('reasoning_content')
    )
    print(chunk_content, end="", flush=False)
```

**最佳实践**

环境变量配置

```
DASHSCOPE_API_BASE=https://dashscope.aliyuncs.com/compatible-mode/v1
DASHSCOPE_API_KEY=sk-xxxxxx
```

调用过程

```python
basic_model = ChatTongyi(
    model="qwen-plus",
    model_kwargs={ "enable_thinking": True }
)

model = basic_model

async def test():
    response = model.astream("你好")
    last_type = None
    
    headers = {
        'reasoning': '\n---------------- reasoning ----------------',
        'text': '\n---------------- text ----------------',
    }
    
    async for chunk in response:
        block = next(
            (
                b
                for b in chunk.content_blocks
                if b.get("type") in ("text", "reasoning")
                and b.get(b.get("type"))
            ),
            None
        )
        
        if not block:
            continue
        
        t = block["type"]
        if t != last_type:
            print(headers[t])
            last_type = t
        
        print(block[t], end="", flush=False)
            
asyncio.run(test())
```



### 上下文缓存

Qwen系列有隐式缓存，应该不需要配置什么

隐式缓存的命中逻辑是判断不同请求的**前缀**是否存在重复内容。为提高命中概率，**请将重复内容置于提示词开头，差异内容置于末尾。**

- **文本模型**：假设系统已缓存"ABCD"，则请求"ABE"可能命中"AB"部分，而请求"BCD"则无法命中。
- **视觉理解模型：**
  - 对**同一图像或视频**进行多次提问：将图像或视频放在文本信息前会提高命中概率。
  - 对**不同图像或视频**提问同一问题：将文本信息放在图像或视频前面会提高命中概率。

相关阅读：

- https://help.aliyun.com/zh/model-studio/context-cache

- https://docs.langchain.com/oss/python/langchain/models#prompt-caching

### 联网检索

**百炼模型具备支持联网检索能力，调研了下，在LangChain里坑很多，不建议用，还是接博查吧**

**注意：这里说的 OpenAI 兼容模型包括 ChatTongyi，就是说LangChain 无法启用返回搜索来源等参数**

| **功能特性**     | **DashScope** | **OpenAI 兼容模式** |
| ---------------- | ------------- | ------------------- |
| 基础联网搜索     | 支持          | 支持                |
| 强制联网搜索     | 支持          | 支持                |
| 设置搜索量级策略 | 支持          | 支持                |
| 开启垂域搜索     | 支持          | 支持                |
| 返回搜索来源     | 支持          | 不支持              |
| 角标引用标注     | 支持          | 不支持              |
| 提前返回搜索来源 | 支持          | 不支持              |

```python
response = model.stream(
    "杭州今天多少度?",
    extra_body={
        "enable_search": True,
      	"search_strategy": "agent",
        "search_options": {
            "forced_search": True  # 强制联网搜索
        }
    }
)
```

相关阅读：

https://docs.langchain.com/oss/python/langchain/models#server-side-tool-use

https://help.aliyun.com/zh/model-studio/web-search

### 模型限流

相关阅读：

```python
from langchain_core.rate_limiters import InMemoryRateLimiter

rate_limiter = InMemoryRateLimiter(
    requests_per_second=10,  # 1 request every 10s
    check_every_n_seconds=0.1,  # Check every 100ms whether allowed to make a request
    max_bucket_size=20,  # Controls the maximum burst size.
)

basic_model = ChatOpenAI(
    model="qwen-plus",
    timeout=60 * 2,
    max_tokens=32768,
    rate_limiter=rate_limiter
)
```

https://help.aliyun.com/zh/model-studio/rate-limit

https://help.aliyun.com/zh/model-studio/rate-limit#ecacfc9c27t88

### Token 消耗

https://docs.langchain.com/oss/python/langchain/models#token-usage

通过 UsageMetadataCallbackHandler 自动累加Token消耗

```python
callback = UsageMetadataCallbackHandler()
config: RunnableConfig = {
    "callbacks": [callback],
}
result_1 = basic_model.invoke("Hello", config=config)
result_2 = basic_model.invoke("Hello", config=config)
# {'qwen-plus': {'input_tokens': 18, 'output_token_details': {}, 'output_tokens': 41, 'total_tokens': 59, 'input_token_details': {'cache_read': 0}}}
print(callback.usage_metadata) # 这里会自动累加Token
```

通过 AIMessasge 实例获取 Token消耗

```python
response = model.invoke(messages) # AIMessage
print(response.usage_metadata)

# {'input_tokens': 31, 'output_tokens': 19, 'total_tokens': 50, 'input_token_details': {'cache_read': 0}, 'output_token_details': {}}
```

## Message 消息

LangChain 消息分为三种类型： [System message](https://docs.langchain.com/oss/python/langchain/messages#system-message) 、[Human message](https://docs.langchain.com/oss/python/langchain/messages#human-message) 、 [AI message](https://docs.langchain.com/oss/python/langchain/messages#ai-message) 、[Tool message](https://docs.langchain.com/oss/python/langchain/messages#tool-message)

分别对应系统提示词、用户输入消息、AI生成消息、工具调用消息

详细看LangChain文档和大模型的输出吧

## Tools 工具

Tools are components that [agents](https://docs.langchain.com/oss/python/langchain/agents) call to perform actions. They extend model capabilities by letting them interact with the world through well-defined inputs and outputs.
工具是[代理](https://docs.langchain.com/oss/python/langchain/agents)调用以执行操作的组件。它们通过定义明确的输入和输出，使代理能够与世界进行交互，从而扩展模型的功能。

###  Tool Definition 工具定义

默认加上 `@tool` 装饰器 即可将一个函数转换为Agent Tool，函数的文档字符串会成为工具的描述，参数类型必须写

示例代码：

```python
from langchain.tools import tool, ToolRuntime
@tool
def search_database(query: str, limit: int = 10) -> str:
    """在客户数据库中搜索与查询条件匹配的记录。

    参数：
        query: 要搜索的关键词
        limit: 返回结果的最大数量
    """
    return f"找到 {limit} 条与 '{query}' 相关的结果"
```

更好的实践是给工具一个中文名，这样在ToolMessage那里调用的工具名称也是中文的，可以被某些UI框架识别

```python
from langchain.tools import tool, ToolRuntime
@tool("数据库检索")
def search_database(query: str, limit: int = 10) -> str:
    """在客户数据库中搜索与查询条件匹配的记录。

    参数：
        query: 要搜索的关键词
        limit: 返回结果的最大数量
    """
    return f"找到 {limit} 条与 '{query}' 相关的结果"
```

其他定义方式参考LangChain文档：https://docs.langchain.com/oss/python/langchain/tools#create-tools

### Accessing Context 访问上下文

Use `ToolRuntime` to access all runtime information in a single parameter. Simply add `runtime: ToolRuntime` to your tool signature, and it will be automatically injected without being exposed to the LLM.
使用 `ToolRuntime` 可以通过单个参数访问所有运行时信息。只需将 `runtime: ToolRuntime` 添加到工具签名中，它就会自动注入，而无需暴露给 LLM。

下面这个例子 利用  InMemoryStore、InMemorySaver、ToolRuntime 实现了一个简单的工具

```python
from pprint import pprint, pformat
from typing import Any

from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.store.memory import InMemoryStore
from langchain.agents import create_agent
from langchain.tools import tool, ToolRuntime

from model import model
from schema import BaseInputSchema

# 输入格式
class InputSchema(BaseInputSchema):
    ...

# 访问内存
@tool
def get_user_info(user_id: str, runtime: ToolRuntime) -> str:
    """查找用户信息。"""
    print(f"len: {pformat(len(runtime.state.get("messages")))}") # 2
    store = runtime.store
    store.list_namespaces()
    user_info = store.get(("users",), user_id)
    return str(user_info.value) if user_info else "未知用户"

# 更新内存
@tool
def save_user_info(user_id: str, user_info: dict[str, Any], runtime: ToolRuntime) -> str:
    """保存用户信息。"""
    print(f"len: {pformat(len(runtime.state.get("messages")))}") # 6
    store = runtime.store
    store.put(("users",), user_id, user_info)
    return "用户信息保存成功"

# 创建 agent，绑定工具和内存
agent = create_agent(
    model=model,
    tools=[get_user_info, save_user_info],
    store=InMemoryStore(),
    checkpointer=InMemorySaver()
)

# 第一次会话：保存用户信息
response = agent.invoke(
    input=InputSchema(messages=[HumanMessage("保存以下用户信息：userid: abc123, name: Foo, age: 25, email: foo@langchain.dev")]),
    config=RunnableConfig(configurable={ "thread_id": "1" }),
)
pprint(response)

# 第二次会话：获取用户信息
response = agent.invoke(
    input=InputSchema(messages=[HumanMessage("获取用户ID为 'abc123' 的用户信息？")]),
    config=RunnableConfig(configurable={ "thread_id": "1" }),
)
pprint(response)
```

### Stream Writer 

Stream custom updates from tools as they execute using `runtime.stream_writer`. This is useful for providing real-time feedback to users about what a tool is doing.
使用 `runtime.stream_writer` 在工具执行时流式传输自定义更新。这对于向用户提供有关工具正在执行的操作的实时反馈非常有用。

```python
from langchain.tools import tool, ToolRuntime

@tool
def get_weather(city: str, runtime: ToolRuntime) -> str:
    """Get weather for a given city."""
    writer = runtime.stream_writer

    # Stream custom updates as the tool executes
    writer(f"Looking up data for city: {city}")
    writer(f"Acquired data for city: {city}")

    return f"It's always sunny in {city}!"
```

用 get_stream_writer 也能拿到 writer 对象：用于在工具执行过程中，向外部实时发送“流式更新”。



## Short-term memory 短期记忆

相关阅读：https://docs.langchain.com/oss/python/langchain/short-term-memory#usage

短期记忆实现共有三种方式：

checkpoint.memory

checkpoint.postgres （生产就绪）

state_schema （自定义AgentMemory）

### checkpoint.postgres

With [short-term memory](https://docs.langchain.com/oss/python/langchain/short-term-memory#add-short-term-memory) enabled, long conversations can exceed the LLM’s context window. Common solutions are:
启用[短期记忆](https://docs.langchain.com/oss/python/langchain/short-term-memory#add-short-term-memory)后，长时间的对话可能会超出 LLM 的上下文窗口。常见的解决方案包括 修建消息（只保留最近多少条消息）、删除消息、消息摘要（推荐）、自定义策略。

**Summarize messages 消息摘要**

```python
DB_URI = "postgresql://postgres:postgres@localhost:5432/langchain?sslmode=disable"
with PostgresSaver.from_conn_string(DB_URI) as checkpointer:
    checkpointer.setup() # auto create tables in PostgresSql
    middleware = [
        SummarizationMiddleware(
            model=flash_model,
            trigger=cast(ContextSize, ("tokens", 4000)),
            keep=cast(ContextSize, ("messages", 20))
        )
    ]

    agent = create_agent(
        model=model,
        middleware=middleware, # type: ignore
        checkpointer=checkpointer,
    )

    response = agent.invoke(
        input=InputSchema(messages=[HumanMessage("你可真热情")]),
        config=RunnableConfig(configurable={"thread_id": "1"}),
    )
    pprint(response)
```

## Structured output 结构化输出

Structured output allows agents to return data in a specific, predictable format. Instead of parsing natural language responses, you get structured data in the form of JSON objects, Pydantic models, or dataclasses that your application can directly use.

结构化输出允许代理以特定且可预测的格式返回数据。您无需解析自然语言响应，即可获得以 JSON 对象、Pydantic 模型或数据类形式存在的结构化数据，您的应用程序可以直接使用这些数据。

LangChain’s [`create_agent`](https://reference.langchain.com/python/langchain/agents/#langchain.agents.create_agent) handles structured output automatically. The user sets their desired structured output schema, and when the model generates the structured data, it’s captured, validated, and returned in the `'structured_response'` key of the agent’s state.
LangChain 的 [`create_agent`](https://reference.langchain.com/python/langchain/agents/#langchain.agents.create_agent) 可以自动处理结构化输出。用户设置所需的结构化输出模式，当模型生成结构化数据时，这些数据会被捕获、验证，然后返回到 agent 状态的 `'structured_response'` 键中。

结构化输出回复格式分为三种：

- **`ToolStrategy[StructuredResponseT]`**: Uses tool calling for structured output
  **`ToolStrategy[StructuredResponseT]`** ：使用工具调用结构化输出
- **`ProviderStrategy[StructuredResponseT]`**: Uses provider-native structured output
  **`ProviderStrategy[StructuredResponseT]`** ：使用提供商原生结构化输出
- **`type[StructuredResponseT]`**: Schema type - automatically selects best strategy based on model capabilities
  **`type[StructuredResponseT]`** ：模式类型 - 根据模型功能自动选择最佳策略
- **`None`**: No structured output
  **`None`** ：无结构化输出

这里建议第三种：**根据模型功能自动选择最佳策略**，目前**Qwen系列模型不支持ProviderStrategy**

定义结构化输出格式的模式。支持：

- **Pydantic models**: `BaseModel` subclasses with field validation
- **Dataclasses**: Python dataclasses with type annotations
- **TypedDict**: Typed dictionary classes
- **JSON Schema**: Dictionary with JSON schema specification

一般使用Pydantic models即可。

示例请参考**Quickstart 快速入门**

## Middleware 中间件

### Built-in middleware 内置中间件

注意关注以下几个中间件就可以了

[Summarization 总结](https://docs.langchain.com/oss/python/langchain/middleware/built-in#summarization)

[Human-in-the-loop 人机交互](https://docs.langchain.com/oss/python/langchain/middleware/built-in#human-in-the-loop)

[Model call limit 模型调用限制](https://docs.langchain.com/oss/python/langchain/middleware/built-in#model-call-limit)

[Model fallback 模型回退](https://docs.langchain.com/oss/python/langchain/middleware/built-in#model-fallback)

[Tool retry 工具重试](https://docs.langchain.com/oss/python/langchain/middleware/built-in#tool-retry)

[Model retry 模型重试](https://docs.langchain.com/oss/python/langchain/middleware/built-in#model-retry)

[LLM tool selector LLM 工具选择器](https://docs.langchain.com/oss/python/langchain/middleware/built-in#llm-tool-selector)

[Context editing 上下文编辑](https://docs.langchain.com/oss/python/langchain/middleware/built-in#context-editing)

### Custom middleware 自定义中间件

#### 自定义中间件

如果在运行过程中，只需要一个位置的钩子，没有复杂的配置。使用装饰器的方式是最方便与简洁的。

如果希望在运行过程中执行多个钩子，配置也比较复杂，在多个代理或者多个项目中复用，可以使用子类自定义实现的方式

##### 装饰器

- @before_agent: 在代理启动之前调用。（每次运行只调用一次）
- @after_agent:  在代理运行完成后调用。（每次运行只调用一次）
- @before_model: 每次调用模型之前运行，持久化保存，会将记忆保存到对话历史中。
- @after_model: 每次调用模型之后运行，持久化保存，会将记忆保存到对话历史中。
- @wrap_model_call: 环绕钩子，在模型前后都会调用。（临时修改）
- @wrap_tool_call: 环绕钩子，在工具前后都会调用。（临时修改）
- @dynamic_prompt: 临时修改提示词，不影响state中的内容（相较于@before_mode）。相当于@wrap_model_call修改提示词的方式。

```python
python
@tool
def get_weather(location: str) -> str:
    """Get the weather at a location."""
    return {"messages": [{"role": "assistant", "content": f"It's sunny in {location}."}]}


@before_agent
def before_agent_middleware(state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
    print("调用代理运行前中间件")
    return None


@after_agent
def after_agent_middleware(state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
    print("a调用代理运行后中间件")
    return None


@before_model(can_jump_to=["end"])
def before_model_middleware(state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
    print("调用模型运行前中间件")
    return None


@after_model
def after_model_middleware(state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
    print("调用模型运行后中间件")
    return None


@wrap_model_call
def wrap_model_call_middleware(
        request: ModelRequest,
        handler: Callable[[ModelRequest], ModelResponse],
) -> ModelResponse:
    print("调用模型环绕中间件")
    if len(request.messages) > 10:
        print("选择使用基础模型")
        request.model = base_model
    else:
        print("选择使用高级模型")
        request.model = base_model
    return handler(request)


@wrap_tool_call
def wrap_tool_call_middleware(request: ToolCallRequest,
                              handler: Callable[[ToolCallRequest], ToolMessage | Command],
                              ) -> ToolMessage | Command:
    print("调用工具环绕中间件")
    print(f"Executing tool: {request.tool_call['name']}")
    print(f"Arguments: {request.tool_call['args']}")

    try:
        result = handler(request)
        print(f"Tool completed successfully")
        return result
    except Exception as e:
        print(f"Tool failed: {e}")
        raise


@dynamic_prompt
def personalized_prompt(request: ModelRequest) -> str:
    user_id = "BaqiF2"
    print("进入动态修改提示词中间件")
    return f"You are a helpful assistant for user {user_id}. Be concise and friendly."


base_model = ChatOpenAI(api_key=os.getenv("DASHSCOPE_API_KEY"),
                        base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
                        model="qwen3-max")

agent = create_agent(
    base_model,
    tools=[get_weather],
    middleware=[before_agent_middleware, before_model_middleware, personalized_prompt, wrap_model_call_middleware,
                wrap_tool_call_middleware, after_model_middleware, after_agent_middleware],
    checkpointer=InMemorySaver()
)

# 输出
# 调用代理运行前中间件
# 调用模型运行前中间件
# 进入动态修改提示词中间件
# 调用模型环绕中间件
# 选择使用高级模型
# 调用模型运行后中间件
# 调用工具环绕中间件
# Executing tool: get_weather
# Arguments: {'location': '北京'}
# Tool completed successfully
# 调用模型运行前中间件
# 进入动态修改提示词中间件
# 调用模型环绕中间件
# 选择使用高级模型
# 调用模型运行后中间件
# 调用代理运行后中间件
```

##### 子类自定义

继承AgentMiddleware类，自定义实现 before_agent/after_agent/before_model/after_model/wrap_model_call/wrap_tool_call

```python
class CustomMiddleware(AgentMiddleware):
    """
    自定义的AgentMiddleware
    """

    def before_agent(self, state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
        print("调用代理运行前中间件")
        return None

    def before_model(self, state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
        """Logic to run before the model is called."""
        print("调用模型运行前中间件")
        return None

    def after_model(self, state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
        """Logic to run after the model is called."""
        print("调用模型运行后中间件")
        return None

    def after_agent(self, state: CustomState, runtime: Runtime) -> dict[str, Any] | None:
        """Logic to run after the agent execution completes."""
        print("调用代理运行后中间件")
        return None

    def wrap_model_call(
            self,
            request: ModelRequest,
            handler: Callable[[ModelRequest], ModelResponse],
    ) -> ModelCallResult:
        print("调用模型环绕中间件")
        if len(request.messages) > 10:
            print("选择使用基础模型")
            request.model = base_model
        else:
            print("选择使用高级模型")
            request.model = base_model
        return handler(request)

    def wrap_tool_call(
            self,
            request: ToolCallRequest,
            handler: Callable[[ToolCallRequest], ToolMessage | Command],
    ) -> ToolMessage | Command:
        print("调用工具环绕中间件")
        print(f"Executing tool: {request.tool_call['name']}")
        print(f"Arguments: {request.tool_call['args']}")

        try:
            result = handler(request)
            print(f"Tool completed successfully")
            return result
        except Exception as e:
            print(f"Tool failed: {e}")
            raise


agent = create_agent(
    base_model,
    tools=[get_weather],
    middleware=[CustomMiddleware()],
    checkpointer=InMemorySaver()
)
# 输出
调用代理运行前中间件
调用模型运行前中间件
调用模型环绕中间件
选择使用高级模型
调用模型运行后中间件
调用工具环绕中间件
Executing
tool: get_weather
Arguments: {'location': '北京'}
Tool
completed
successfully
调用模型运行前中间件
调用模型环绕中间件
选择使用高级模型
调用模型运行后中间件
调用代理运行后中间件
```

##### 执行流程

- `before_*`钩子：从第一个到最后一个
- `after_*`钩子：从后到前（反向）
- `wrap_*`hooks：嵌套式（第一个中间件包裹所有其他中间件）

##### 特殊跳跃

要提前退出中间件，请返回一个包含以下内容的字典`jump_to`：

可跳跃目标：

- `"end"`跳转到代理执行的末尾
- `"tools"`跳转到工具节点
- `"model"`跳转到模型节点（或第一个`before_model`钩子）



## Model Context Protocol (MCP) 

安装相关依赖：

```
uv add langchain-mcp-adapters
```

接入 shadcn mcp

注意这里必须用异步 ainvoke 方法

```python
import asyncio
from pprint import pprint

from langchain_core.messages import HumanMessage
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain.agents import create_agent

from model import model
from schema import BaseInputSchema


# 输入格式
class InputSchema(BaseInputSchema):
    ...

async def test():
    client = MultiServerMCPClient({
        "shadcn": {
            "command": "npx",
            "args": ["shadcn@latest", "mcp"],  # 就是你 JSON 里的内容
            "transport": "stdio"
        }
    })
    
    tools = await client.get_tools()
    
    agent = create_agent(
        model=model,
        tools=tools,
    )
    
    result = await agent.ainvoke(
        input=InputSchema(
            messages=[
                HumanMessage("帮我搜索一个 button 组件")
            ]
        ),
    )
    pprint(result)

asyncio.run(test())
```

## Human-in-the-loop

The Human-in-the-Loop (HITL) [middleware](https://docs.langchain.com/oss/python/langchain/middleware/built-in#human-in-the-loop) lets you add human oversight to agent tool calls. When a model proposes an action that might require review — for example, writing to a file or executing SQL — the middleware can pause execution and wait for a decision.
人机交互[中间件 ](https://docs.langchain.com/oss/python/langchain/middleware/built-in#human-in-the-loop)(HITL) 允许您在代理工具调用中添加人工监督。当模型提出可能需要审核的操作（例如，写入文件或执行 SQL）时，中间件可以暂停执行并等待决策。It does this by checking each tool call against a configurable policy. If intervention is needed, the middleware issues an [interrupt](https://reference.langchain.com/python/langgraph/types/#langgraph.types.interrupt) that halts execution. The graph state is saved using LangGraph’s [persistence layer](https://docs.langchain.com/oss/python/langgraph/persistence), so execution can pause safely and resume later.
它通过检查每个工具调用是否符合可配置的策略来实现这一点。如果需要干预，中间件会发出[中断](https://reference.langchain.com/python/langgraph/types/#langgraph.types.interrupt)以暂停执行。图状态使用 LangGraph 的[持久层](https://docs.langchain.com/oss/python/langgraph/persistence)保存，因此执行可以安全地暂停并在稍后恢复。A human decision then determines what happens next: the action can be approved as-is (`approve`), modified before running (`edit`), or rejected with feedback (`reject`).
然后，由人来决定接下来会发生什么：该操作可以按原样批准（ `approve` ），在运行之前进行修改（ `edit` ），或者拒绝并给予反馈（ `reject` ）。

决策类型：approve、edit、reject

一个生成SQL、执行SQL、保存SQL的案例

```python
from pathlib import Path
from typing import Any

from langchain.agents import create_agent, AgentState
from langchain.agents.middleware import HumanInTheLoopMiddleware, InterruptOnConfig
from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.graph.state import CompiledStateGraph
from langgraph.types import Command
from langchain.tools import tool
from pydantic import BaseModel

# 假设你的模型对象在 model.py 中
from model import model
from schema import BaseInputSchema


# =========================
# 工具函数
# =========================
@tool
def generate_sql() -> str:
    """生成 SQL，不执行"""
    return "SELECT id, name FROM users WHERE active = 1 ORDER BY created_at DESC LIMIT 5;"


@tool
def execute_sql(sql: str) -> str:
    """执行 SQL（这里只打印模拟执行）"""
    print(f"[execute_sql] SQL 已执行：{sql}")
    return f"[execute_sql] SQL 已执行：{sql}"


@tool
def save_sql_to_file(sql: str, filename: str = "generated.sql") -> str:
    """保存 SQL 到文件"""
    path = Path.cwd() / filename
    path.write_text(sql, encoding="utf-8")
    print(f"[save_sql_to_file] SQL 已保存到 {path}")
    return f"[save_sql_to_file] SQL 已保存到 {path}"


tools = [generate_sql, execute_sql, save_sql_to_file]


# =========================
# 上下文 Schema
# =========================
class Context(BaseModel):
    user_id: str = ""
    
    
# =========================
# 输入格式
# =========================
class InputSchema(BaseInputSchema):
    ...


# =========================
# HITL 中间件
# =========================
hitl_middleware = HumanInTheLoopMiddleware(
    interrupt_on={
        "execute_sql": InterruptOnConfig(
            allowed_decisions=["approve", "edit", "reject"],
            description="⚠️ SQL 执行需人工审批："
        ),
        "save_sql_to_file": InterruptOnConfig(
            allowed_decisions=["approve", "reject"],
            description="⚠️ SQL 保存到文件需人工审批："
        )
    }
)
middleware = [hitl_middleware]

# =========================
# 短期记忆
# =========================
checkpointer = InMemorySaver()

# =========================
# 创建 Agent
# =========================
Agent = CompiledStateGraph[AgentState, Context, Any, Any]
agent: Agent = create_agent(
    model=model,
    tools=tools,
    middleware=middleware,  # type: ignore[arg-type]
    checkpointer=checkpointer,
    context_schema=Context,
)


# =========================
# 用户输入审批函数
# =========================
def get_user_decision(action_request):
    tool_name = action_request["name"]
    args = action_request["args"]
    print("\n工具调用需人工审批：")
    print(f"Tool: {tool_name}")
    if "sql" in args:
        print("SQL:\n", args["sql"])
    user_input = input("请选择操作 (y=执行, n=拒绝, e=修改 SQL)：").strip().lower()
    
    if user_input in ["y", "yes"]:
        return {"type": "approve"}
    elif user_input in ["n", "no"]:
        return {"type": "reject"}
    elif user_input == "e":
        if "sql" in args:
            new_sql = input("请输入修改后的 SQL：").strip()
            return {
                "type": "edit",
                "edited_action": {
                    "name": tool_name,
                    "args": {"sql": new_sql}
                }
            }
        else:
            print("无法编辑该工具参数，默认拒绝执行")
            return {"type": "reject"}
    else:
        print("输入无效，默认拒绝执行")
        return {"type": "reject"}


# =========================
# 主执行函数
# =========================
def run_agent():
    config = RunnableConfig(configurable={"thread_id": "hitl_sql_demo"})
    context = Context(user_id="user_1")
    user_message = HumanMessage(content="请生成 SQL 并执行，执行后保存到文件")
    
    # 第一次调用 Agent
    result = agent.invoke(
        input=InputSchema(messages=[user_message]),
        config=config,
        context=context
    )
    
    # 循环处理所有 interrupt
    while "__interrupt__" in result:
        interrupt = result["__interrupt__"]
        decisions = []
        for action_request in interrupt[0].value["action_requests"]:
            decision = get_user_decision(action_request)
            decisions.append(decision)
        result = agent.invoke(
            Command(resume={"decisions": decisions}),
            config=config
        )
    
    print("\n=== 最终执行结果 ===")
    print(result)


run_agent()

```

## Long-term memory 长期记忆

### Memory storage 内存存储

LangGraph 将长期记忆以 JSON 文档的形式存储在[memory storage ](https://docs.langchain.com/oss/python/langgraph/persistence#memory-store)中。

**长时记忆存储在 LangGraph 的 Store 里**

- 每条记忆是一个 JSON 文档。
- 通过 `(namespace, key)` 组织：
  - `namespace` 类似文件夹，可以按用户、应用或其他标签划分。
  - `key` 类似文件名，标识具体的记忆。
- 支持跨 namespace 搜索和向量相似度查询。

**读写记忆**

- **读取**：可以在 Agent 的工具中读取指定用户的记忆，比如用户信息、偏好等。
- **写入**：也可以在工具中更新记忆，实现用户数据的持久化更新。

**示例**

- 使用 `InMemoryStore` 做示例，生产环境应换成 DB-backed store。
- 工具函数通过 `runtime.store` 获取 Store，再通过 `runtime.context` 获取用户信息来操作记忆。
- `create_agent(..., store=store)` 将 store 注入 Agent，工具就能访问了。

示例中使用 InMemoryStore，真实场景需更换为向量数据库

**读取、写入用户偏好的例子**

```python
from typing import Any
from typing_extensions import TypedDict

from langchain.agents import create_agent, AgentState
from langchain_core.messages import HumanMessage, AIMessage
from langchain_core.runnables import RunnableConfig
from langgraph.graph.state import CompiledStateGraph
from langchain.tools import tool, ToolRuntime
from pydantic import BaseModel
from langgraph.store.memory import InMemoryStore

# 假设你的模型对象在 model.py 中
from model import model
from schema import BaseInputSchema

# =========================
# 长期记忆 Store
# =========================
store = InMemoryStore()

# =========================
# 上下文 Schema
# =========================
class Context(BaseModel):
    user_id: str

# =========================
# 用户偏好类型
# =========================
class UserPreferences(TypedDict, total=False):
    language: str        # 用户希望的编程语言
    code_style: str      # 用户偏好代码风格，如 TS/JS/Python
    ui_language: str     # 用户偏好界面语言，如 繁体中文/简体中文/英文

# =========================
# 工具函数（Agent 自动调用）
# =========================
@tool
def get_user_preferences(runtime: ToolRuntime[Context]) -> str:
    """读取用户偏好"""
    user_id = runtime.context.user_id
    print("读取用户偏好")
    prefs = store.get(("users",), user_id)
    return str(prefs.value) if prefs else "没有记录"

@tool
def save_user_preferences(prefs: UserPreferences, runtime: ToolRuntime[Context]) -> str:
    """保存/更新用户偏好，非必要时不要调用"""
    user_id = runtime.context.user_id
    print("保存/更新用户偏好", prefs)
    store.put(("users",), user_id, prefs)
    return f"用户偏好已保存: {prefs}"

tools = [get_user_preferences, save_user_preferences]

# =========================
# 创建 Agent（纯长期记忆，无短期记忆）
# =========================
Agent = CompiledStateGraph[AgentState, Context, Any, Any]
agent: Agent = create_agent(
    model=model,
    tools=tools,
    context_schema=Context,
)

# =========================
# 多轮对话示例
# =========================
def run_multi_round_dialog():
    context = Context(user_id="user_123")
    config = RunnableConfig(configurable={"thread_id": "pure_longterm_demo"})

    # 模拟用户消息
    user_messages = [
        "我喜欢使用简体中文，请用简中回答",
        "帮我生成一个队列的数据结构",
        "我是写TS的，以后尽量发TS代码",
        "写个链表",
        "实现一个数组去重",
        "帮我写一个栈",
        "帮我写一个队列的 pop 和 push 方法",
    ]

    for i, msg in enumerate(user_messages, 1):
        print(f"\n=== 用户第 {i} 次消息 ===\n{msg}")
        user_message = HumanMessage(content=msg)

        # Agent 自动调用工具，读取/更新长期记忆
        result = agent.invoke(
            input=BaseInputSchema(messages=[user_message]),
            config=config,
            context=context
        )

        # 输出 Agent 回覆
        if isinstance(result, dict) and "messages" in result:
            for m in result["messages"]:
                if isinstance(m, AIMessage):
                    print("\nAgent 回复：")
                    print(m.content)
        else:
            print("\nAgent 回复：")
            print(result)

    # 最终查看长期记忆
    prefs = store.get(("users",), "user_123")
    print("\n=== 最终长期记忆 ===")
    print(prefs.value if prefs else "无记录")

# =========================
# 执行
# =========================
if __name__ == "__main__":
    run_multi_round_dialog()
```

# LangGraph

## QuickStart

该案例展示了下模型调用工具的核心原理，也是个非常简单的图应用

流程图：

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251204163848156.png" alt="image-20251204163848156" style="zoom:40%;" />

```python
# 定义工具
import io
import operator
from typing import TypedDict, Annotated, Literal

from langchain_core.messages import AnyMessage, SystemMessage, ToolMessage
from langchain_core.tools import tool
from langgraph.constants import START, END
from langgraph.graph import StateGraph

import sys, os

from langgraph.graph.state import CompiledStateGraph

sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from common.model import model

@tool
def add(a: int, b: int) -> int:
    """计算 a + b

    参数:
        a: 第一个整数
        b: 第二个整数
    """
    return a + b


class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], operator.add]
    llm_calls: int


# 为 LLM 增加工具
tools = [add]
tools_by_name = {tool.name: tool for tool in tools}
model_with_tools = model.bind_tools(tools)


def llm_call(state: dict):
    """LLM 决定是否调用工具"""
    return {
        "messages": [
            model_with_tools.invoke(
                [
                    SystemMessage(
                        content="你是一个助手，负责根据输入执行算术操作。"
                    )
                ]
                + state["messages"]
            )
        ],
        "llm_calls": state.get('llm_calls', 0) + 1
    }


def tool_node(state: dict):
    """执行工具调用"""
    
    result = []
    for tool_call in state["messages"][-1].tool_calls:
        tool = tools_by_name[tool_call["name"]]
        observation = tool.invoke(tool_call["args"])
        result.append(ToolMessage(content=observation, tool_call_id=tool_call["id"]))
    return {"messages": result}


def preview_graph(agent: CompiledStateGraph):
    try:
        import threading
        from PIL import Image as PILImage
        import io
        
        def _show():
            img_data = agent.get_graph(xray=True).draw_mermaid_png()
            PILImage.open(io.BytesIO(img_data)).show()  # 阻塞显示，但在线程里运行
        
        threading.Thread(target=_show, daemon=True).start()
    
    except Exception:
        pass


def should_continue(state: MessagesState) -> Literal["tool_node", END]:
    """判断是否继续循环或结束

    如果 LLM 发起了工具调用，则继续执行工具节点，否则结束。
    """
    messages = state["messages"]
    last_message = messages[-1]
    
    if last_message.tool_calls:
        return "tool_node"
    
    return END


# 构建工作流
agent_builder = StateGraph(MessagesState)

# 添加节点
agent_builder.add_node("llm_call", llm_call)
agent_builder.add_node("tool_node", tool_node)

# 添加边以连接节点
agent_builder.add_edge(START, "llm_call")
agent_builder.add_conditional_edges(
    "llm_call",
    should_continue,
    ["tool_node", END]
)
agent_builder.add_edge("tool_node", "llm_call")

# 编译 agent
agent = agent_builder.compile()

# 预览图表
preview_graph(agent)

# 调用 agent
from langchain_core.messages import HumanMessage

messages = [HumanMessage(content="Add 3 and 4.")]
messages = agent.invoke({"messages": messages})
for m in messages["messages"]:
    m.pretty_print()
```

## Local Server

一、使用 cli 创建项目并安装依赖

```
langgraph new path/to/your/app
cd path/to/your/app
uv sync
cp .env.example .env
```

二、配置 LANGSMITH_API_KEY

```
https://smith.langchain.com/o/5ff92d72-d65c-4cbf-9619-b17a2066953f/settings/apikeys
```

三、启动代理服务器

```
langgraph dev
```

示例输出

```
>    Ready!
>
>    - API: [http://localhost:2024](http://localhost:2024/)
>
>    - Docs: http://localhost:2024/docs
>
>    - LangGraph Studio Web UI: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024
```

四、导入OpenAPI JSON

```
http://127.0.0.1:2024/openapi.json
```

## LangGraph SDK

```
uv add langgraph-sdk
```

SDK示例代码：

```python
from langgraph_sdk import get_client
import asyncio

client = get_client(url="http://localhost:2024")

async def main():
    async for chunk in client.runs.stream(
        None,  # Threadless run
        "agent", # Name of assistant. Defined in langgraph.json.
        input={
            "messages": [{
                "role": "human",
                "content": "What is LangGraph?",
            }],
        },
    ):
        print(f"Receiving new event of type: {chunk.event}...")
        print(chunk.data)
        print("\n\n")

def test_langgraph_stream():
    import asyncio
    asyncio.run(main())
```

## API接口解读

### 1. 核心概念 (Core Concepts)

在深入通过 API 端点之前，需要理解三个核心概念：

- **Assistant (助手)**: 是图（Graph）的配置化实例。它包含了图的定义（代码逻辑）以及特定的配置（Config）。你可以把它看作是代码里的“类”或“蓝图”。
- **Thread (线程)**: 是对话或任务执行的容器。它保存了所有的状态（State）和历史记录。你可以把它看作是“实例”或“会话”。
- **Run (运行)**: 是对助手的一次调用。它在线程中执行，改变线程的状态。

### 2. API 模块详解

####  Assistants (助手管理)

这一组 API 用于管理你的智能体定义。

- **创建与查找**:
  - `POST /assistants`: 创建一个新的助手。可以指定它使用的 `graph_id` 和配置。
  - `POST /assistants/search`: 搜索或列出所有助手。
- **版本控制**:
  - `POST /assistants/{assistant_id}/versions`: 获取助手的所有历史版本。
  - `POST /assistants/{assistant_id}/latest`: 将某个版本设置为“最新”版本。
- **图结构自省 (Introspection)**:
  - `GET /assistants/{assistant_id}/graph`: 获取助手对应的图结构数据（节点、边等）。
  - `GET /assistants/{assistant_id}/schemas`: 获取图的输入、输出和状态的 JSON Schema 定义，方便前端生成表单。

#### Threads (线程与状态管理)

这一组 API 用于管理对话上下文和“状态旅行”（Time Travel）。

- **基础操作**:
  - `POST /threads`: 创建一个新线程（对话 ID）。
  - `GET /threads/{thread_id}`: 获取线程详情。
  - `POST /threads/{thread_id}/copy`: 复制一个线程（包括其状态和历史），常用于调试或分支测试。
- **状态 (State) 与 检查点 (Checkpoint)**:
  - `GET /threads/{thread_id}/state`: 获取线程当前的最新状态。
  - `GET /threads/{thread_id}/history`: 获取线程的历史状态记录。
  - `POST /threads/{thread_id}/state`: **重要**。直接更新线程状态。这允许“Human-in-the-loop”（人在回路）干预，比如修改 Agent 的记忆或修正下一步操作。
  - LangGraph 支持“时间旅行”，你可以获取特定 `checkpoint_id` 的状态。

#### Thread Runs (有状态运行)

这是最常用的功能，用于在特定线程中执行任务。

- **执行**:
  - `POST /threads/{thread_id}/runs`: 创建一个后台运行（异步）。
  - `POST /threads/{thread_id}/runs/wait`: 创建运行并等待结果（同步）。
  - `POST /threads/{thread_id}/runs/stream`: **流式运行**。创建运行并通过 SSE (Server-Sent Events) 实时流式传输输出（Token 或状态更新）。
- **管理**:
  - `GET /threads/{thread_id}/runs`: 列出该线程下的所有运行记录。
  - `POST /threads/{thread_id}/runs/{run_id}/cancel`: 取消或中断正在进行的运行。

####  Stateless Runs (无状态运行)

如果不需要保存对话历史，可以使用这些端点。

- `POST /runs/stream`: 类似于有状态运行，但系统会创建一个临时线程，运行结束后（根据配置）可能会删除。
- `POST /runs/batch`: 批量处理多个输入。

#### Crons (定时任务)

仅限 Plus 层级功能，用于周期性执行 Agent。

- `POST /threads/{thread_id}/runs/crons`: 在指定线程上创建定时任务。
- `POST /runs/crons`: 创建全新的定时任务（每次运行都可能在不同线程）。
- 支持 Cron 表达式来定义调度时间。

#### Store (长期记忆存储)

LangGraph 的 `Store` 是一个全局的、跨线程的键值对（Key-Value）存储系统。

- **功能**: 允许 Agent 记住跨越不同对话（Threads）的信息，例如用户的全局偏好设置。
- **操作**:
  - `PUT /store/items`: 存储数据。
  - `GET /store/items`: 读取数据。
  - `POST /store/items/search`: 搜索存储的记忆（支持语义搜索/Vector Search，如果配置了的话）。

#### Protocols (协议集成)

为了更好的互操作性，API 支持了两种新兴协议：

1. **A2A (Agent-to-Agent)**:
   - `POST /a2a/{assistant_id}`: 允许其他 Agent 通过标准化的 JSON-RPC 2.0 协议与当前 Assistant 通信。
2. **MCP (Model Context Protocol)**:
   - `POST /mcp/`: 实现 MCP 协议，这是一种标准，允许 AI 模型与外部数据和工具进行交互。这使得 LangGraph Agent 可以被其他支持 MCP 的客户端（如 IDE、编辑器）直接调用。

#### System (系统)

- `/ok`: 健康检查。
- `/metrics`: 获取 Prometheus 格式或 JSON 格式的系统运行指标（如队列状态、Worker 状态）。
- `/info`: 获取服务器版本和功能标志。

## LangGraph 注意事项

1、State 尽量继承pydantic.BaseModel，不要直接继承TypeDict，TypeDict不支持默认值，在Pycharm中会报类型不匹配。

2、如无必要，请将原始值存入State，而不是润色后的值（https://docs.langchain.com/oss/python/langgraph/thinking-in-langgraph#keep-state-raw,-format-prompts-on-demand）

3、区分好Steps，包含LLM Steps、Dates steps、Actions steps、User inputs steps（https://docs.langchain.com/oss/python/langgraph/thinking-in-langgraph#step-2%3A-identify-what-each-step-needs-to-do）

4、只连接必要的边（START、END等），动态连接的部分，在Node中返回Command函数即可，图在编译时会自动寻找相关的边。

5、控制好节点颗粒度，保持节点可观测

6、注意维护好智能体上下文（messages字段）

7、尽量使用create_agent创建子图，而不是自己编写llm

8、涉及中断的节点，请讲中断部分写成独立节点，使用Command跳转到下一节点

9、writer函数可以向messages写入AI消息，可用于打印提示语、流式输出等

## LangGraph 相关案例

### LangGraph 入门案例：邮件客服

想象一下，你需要构建一个处理客户支持邮件的 AI Agent。产品团队给了你以下需求：

```
Agent 应该能够：

- 读取传入的客户邮件
- 按紧急程度和主题对其进行分类
- 搜索相关文档以回答问题
- 起草合适的回复
- 将复杂问题升级给人工客服
- 在需要时安排后续跟进

需要处理的示例场景：

1. 简单产品问题：“如何重置我的密码？”
2. Bug 报告：“当我选择 PDF 格式时，导出功能崩溃了”
3. 紧急账单问题：“我的订阅被扣了两次费！”
4. 功能请求：“你们能在移动应用中添加深色模式吗？”
5. 复杂技术问题：“我们的 API 集成间歇性失败，报 504 错误”
```

**相关实现：**

**图预览**

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251205163948533.png" alt="image-20251205163948533" style="zoom:50%;" />



**代码实现：**

**1、Graph State：**

```python
# 定义与邮件分类相关的数据结构
from typing import Literal

from langchain_core.messages import AnyMessage
from pydantic import BaseModel


class EmailClassification(BaseModel):
    """邮件分类结果结构，包括意图、紧急程度、主题与摘要."""
    intent: Literal["question", "bug", "billing", "feature", "complex"]
    urgency: Literal["low", "medium", "high", "critical"]
    topic: str
    summary: str


class EmailAgentState(BaseModel):
    """邮件代理的状态结构，包含原始邮件、分类结果、检索数据与生成内容."""
    # 原始邮件数据
    email_content: str = ""
    sender_email: str = ""
    email_id: str = ""
    
    # 分类结果
    classification: EmailClassification | None = None
    
    # 原始搜索/API 结果
    search_results: list[str] = []  # 原始文档片段列表
    customer_history: dict | None = None  # 来自 CRM 的原始客户数据
    
    # 生成内容
    draft_response: str | None = None
    messages: list[AnyMessage] = []
```

**2、node 节点定义：**

```python
from typing import Literal

from langchain_core.messages import HumanMessage
from langgraph.types import Command

from src.model import llm
from src.state import EmailClassification
from src.state import EmailAgentState


def read_email(state: EmailAgentState) -> dict:
    """提取和解析邮件内容。"""
    # 在生产环境中，这里会连接到你的邮件服务
    return {
        "messages": [HumanMessage(content=f"Processing email: {state.email_content}")]
    }


def classify_intent(state: EmailAgentState) -> Command[Literal["search_documentation", "human_review", "draft_response", "bug_tracking"]]:
    """使用 LLM 对邮件意图和紧急程度进行分类，然后相应地路由。"""
    # 创建返回 EmailClassification 字典的结构化 LLM
    structured_llm = llm.with_structured_output(EmailClassification)
    # 按需格式化 Prompt，而不是存储在状态中
    classification_prompt = f"""
        分析这封客户邮件并对其进行分类

        Email: {state.email_content}
        From: {state.sender_email}

        提供包括意图、紧急程度、主题和摘要的分类。
        """
    
    classification = structured_llm.invoke(classification_prompt)
    
    # 根据分类决定下一个节点
    if classification.intent in ['question', 'feature']:
        goto = "search_documentation"  # 问题或功能请求 -> 搜文档
    elif classification.intent == 'bug':
        goto = "bug_tracking"  # Bug -> 追踪系统
    else:
        goto = "draft_response"  # 起草回复后再决定是否人工审查
    
    
    # 将分类作为一个字典存入状态，并返回路由指令
    return Command(
        update={"classification": classification},
        goto=goto
    )

from typing import Literal
from langgraph.types import Command
from src.state import EmailAgentState


def search_documentation(state: EmailAgentState) -> Command[Literal["draft_response"]]:
    """在知识库中搜索相关信息."""
    # 从分类构建搜索查询
    classification = state.classification
    search_results = [
        "通过 设置 > 安全 > 修改密码 来重置密码",
        "密码必须至少 12 个字符",
        "包含大写、小写、数字和符号"
    ]
    
    return Command(update={"search_results": search_results}, goto="draft_response")

def bug_tracking(state: EmailAgentState) -> Command[Literal["draft_response"]]:
    """创建或更新 Bug 追踪工单."""
    # 在你的 Bug 追踪系统中创建工单
    ticket_id = "BUG-12345"  # 通常通过 API 创建
    
    return Command(update={"search_results": [f"Bug ticket {ticket_id} created"]}, goto="draft_response")


from typing import Literal

from langgraph.constants import END
from langgraph.types import Command, interrupt

from src.model import llm
from src.state import EmailAgentState


def draft_response(state: EmailAgentState) -> Command[Literal["human_review", "send_reply"]]:
    """利用上下文生成回复，并根据质量进行路由。"""
    classification = state.classification
    
    # 按需从原始状态数据格式化上下文
    context_sections = []
    
    if state.search_results:
        # 为 Prompt 格式化搜索结果
        formatted_docs = "\n".join([f"- {doc}" for doc in state.search_results])
        context_sections.append(f"Relevant documentation:\n{formatted_docs}")
    
    if state.customer_history:
        context_sections.append(f"Customer tier: {state.customer_history.get('tier', 'standard')}")
    draft_prompt = f"""
        起草对此客户邮件的回复：
        {state.email_content}

        邮件意图: {(classification.intent if classification else 'unknown')}
        紧急程度: {(classification.urgency if classification else 'medium')}
        
        {chr(10).join(context_sections)}
        
        指南：
        - 专业且乐于助人
        - 解决他们的具体顾虑
        - 相关时使用提供的文档
        """
    response_obj = llm.invoke(draft_prompt)
    response_text = response_obj.content
    needs_review = ((classification and classification.urgency in ['high', 'critical']) or (classification and classification.intent == 'complex'))
    goto = "human_review" if needs_review else "send_reply"
    return Command(
        update={"draft_response": response_text},
        goto=goto
    )
    
def human_review(state: EmailAgentState) -> Command[Literal["send_reply", END]]:
    """使用 interrupt 暂停以进行人工审查，并根据决策路由。"""
    classification = state.classification
    
    # interrupt() 必须最先执行 - 它之前的任何代码在恢复时都会重新运行
    # 这里会暂停执行，等待用户输入
    human_decision = interrupt({
        "email_id": state.email_id,
        "original_email": state.email_content,
        "draft_response": state.draft_response or "",
        "urgency": getattr(classification, "urgency"),
        "intent": getattr(classification, "intent"),
        "action": "Please review and approve/edit this response"
    })
    
    approved = human_decision.get("approved")
    response = human_decision.get("edited_response", state.draft_response or "")
    
    # 现在处理人类的决策（恢复后执行）
    if approved:
        return Command(update={"draft_response":response}, goto="send_reply")
    else:
        print("human_review rejected")
        # 拒绝意味着人类将直接处理，流程结束
        return Command(update={}, goto=END)
    
def send_reply(state: EmailAgentState) -> dict:
    """发送邮件回复。"""
    # 集成邮件服务
    return {}
```

**3、构建Graph**

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.constants import START, END
from langgraph.graph import StateGraph
from langgraph.types import RetryPolicy

from src.node import (
    read_email,
    classify_intent,
    search_documentation,
    bug_tracking,
    draft_response,
    human_review,
    send_reply
)
from src.state import EmailAgentState

builder = StateGraph(EmailAgentState)

# 阅读邮件节点
builder.add_node("read_email", read_email)
# 分类意图节点
builder.add_node("classify_intent", classify_intent)
# 搜索文档
builder.add_node(
    "search_documentation",
    search_documentation,
    retry_policy=RetryPolicy(max_attempts=3)
)
builder.add_node("bug_tracking", bug_tracking)
# 起草回复
builder.add_node("draft_response", draft_response)
# 人工审查
builder.add_node("human_review", human_review)
# 发送回复
builder.add_node("send_reply", send_reply)

# 仅添加必要的边
builder.add_edge(START, "read_email")
builder.add_edge("read_email", "classify_intent")
builder.add_edge("send_reply", END)

# 必要的边
builder.add_edge(START, "read_email")
builder.add_edge("send_reply", END)

# 编译图，使用内存检查点保存器实现持久化
memory = MemorySaver()
graph = builder.compile()
app = builder.compile(checkpointer=memory)
```

### LangGraph 节点控制案例：笑话生成

### Prompt chaining

图结构：

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251208095826778.png" alt="image-20251208095826778" style="zoom:80%;" />

相关代码：

```python
from pydantic import BaseModel
from typing_extensions import TypedDict
from langgraph.graph import StateGraph, START, END
from IPython.display import Image, display

from src.model import llm


# 图状态
class State(BaseModel):
    topic: str
    joke: str = ''
    improved_joke: str = ''
    final_joke: str = ''


# 节点
def generate_joke(state: State):
    """第一次 LLM 调用：生成初始笑话"""

    msg = llm.invoke(f"请写一个关于 {state.topic} 的简短笑话")
    return {"joke": msg.content}


def check_punchline(state: State):
    """判断笑话是否有包袱的函数（Gate）"""

    # 简单检查：是否包含 ? 或 !
    if "?" in state.joke or "!" in state.joke:
        return "Pass"
    return "Fail"


def improve_joke(state: State):
    """第二次 LLM 调用：增强笑话"""

    msg = llm.invoke(f"请让这个笑话更搞笑，加上一些文字游戏：{state.joke}")
    return {"improved_joke": msg.content}


def polish_joke(state: State):
    """第三次 LLM 调用：对笑话进行最终润色"""

    msg = llm.invoke(f"请为这个笑话添加一个出人意料的反转：{state.improved_joke}")
    return {"final_joke": msg.content}


# 构建工作流
workflow = StateGraph(State)

# 添加节点
workflow.add_node("generate_joke", generate_joke)
workflow.add_node("improve_joke", improve_joke)
workflow.add_node("polish_joke", polish_joke)

# 添加边连接节点
workflow.add_edge(START, "generate_joke")
workflow.add_conditional_edges(
    "generate_joke",
    check_punchline,
    {"Fail": "improve_joke", "Pass": END}
)
workflow.add_edge("improve_joke", "polish_joke")
workflow.add_edge("polish_joke", END)

# 编译
chain = workflow.compile()
```

### Parallelization

图结构：

![image-20251208103926070](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251208103926070.png)

相关代码：

```python
from langgraph.constants import START, END
from langgraph.graph import StateGraph
from pydantic import BaseModel

from src.model import llm


# Graph state（图状态）
class State(BaseModel):
    topic: str
    joke: str | None = None
    story: str | None = None
    poem: str | None = None
    combined_output: str | None = None


# Nodes（节点）
async def call_llm_1(state: State):
    """第一次 LLM 调用，用于生成笑话"""
    
    msg = await llm.ainvoke(f"请写一个关于 {state.topic} 的笑话")
    return {"joke": msg.content}


async def call_llm_2(state: State):
    """第二次 LLM 调用，用于生成故事"""
    
    msg = await llm.ainvoke(f"请写一个关于 {state.topic} 的故事")
    return {"story": msg.content}


async def call_llm_3(state: State):
    """第三次 LLM 调用，用于生成诗"""
    
    msg = await llm.ainvoke(f"请写一首关于 {state.topic} 的诗")
    return {"poem": msg.content}


def aggregator(state: State):
    """将笑话、故事和诗整合成一个输出"""
    
    combined = f"以下是关于 {state.topic} 的故事、笑话和诗！\n\n"
    combined += f"【故事】:\n{state.story}\n\n"
    combined += f"【笑话】:\n{state.joke}\n\n"
    combined += f"【诗】:\n{state.poem}"
    return {"combined_output": combined}


# 构建工作流
parallel_builder = StateGraph(State)

# 添加节点
parallel_builder.add_node("call_llm_1", call_llm_1)
parallel_builder.add_node("call_llm_2", call_llm_2)
parallel_builder.add_node("call_llm_3", call_llm_3)
parallel_builder.add_node("aggregator", aggregator)

# 添加边来连接各节点
parallel_builder.add_edge(START, "call_llm_1")
parallel_builder.add_edge(START, "call_llm_2")
parallel_builder.add_edge(START, "call_llm_3")
parallel_builder.add_edge("call_llm_1", "aggregator")
parallel_builder.add_edge("call_llm_2", "aggregator")
parallel_builder.add_edge("call_llm_3", "aggregator")
parallel_builder.add_edge("aggregator", END)

parallel_workflow = parallel_builder.compile()
```

### Routing

官网这个案例存在一些问题，首先是step只定义了三种类型（"poem", "story", "joke"），如果用户询问”你好“，则不在这三种类型中，route_decision执行后，无法通过映射获取下一步要执行的节点，会报错。

这里要在 route_decision 里处理下，而且要注意空对象的情况：

```python
decision = getattr(decision, 'step', None) or 'irrelevant'
```

图结构：

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251208112538320.png" alt="image-20251208112538320" style="zoom:80%;" />

相关代码：

```python
# ===========================
#  imports
# ===========================
from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import END, START
from langgraph.graph import StateGraph
from typing_extensions import Literal
from pydantic import BaseModel, Field

from src.model import llm   # 你的 LLM（如 ChatGPT / Claude 等）


# ===========================
#  结构化输出 Schema（用于分类路由）
# ===========================
class Route(BaseModel):
    # 增加 irrelevant，并给予默认值
    step: Literal["poem", "story", "joke", "irrelevant"] = Field(
        "irrelevant",
        description="下一步应该进入的节点（story / joke / poem / irrelevant）"
    )


# LLM：带结构化输出能力，用于路由
router = llm.with_structured_output(Route)


# ===========================
#  状态 State
# ===========================
class State(BaseModel):
    input: str                        # 用户输入
    decision: str | None = None       # 分类结果
    output: str | None = None         # 最终输出


# ===========================
#  各节点逻辑
# ===========================
def llm_call_1(state: State):
    """写故事"""
    result = llm.invoke(state.input)
    return {"output": result.content}


def llm_call_2(state: State):
    """讲笑话"""
    result = llm.invoke(state.input)
    return {"output": result.content}


def llm_call_3(state: State):
    """写诗"""
    result = llm.invoke(state.input)
    return {"output": result.content}


def llm_call_irrelevant(state: State):
    """无关分类"""
    return {
        "output": "你的输入不属于故事、笑话或诗的类型，我无法分类。"
    }


# ===========================
#  路由节点：调用结构化 LLM 判断下一步
# ===========================
def llm_call_router(state: State):
    """路由节点：由 LLM 决定类别"""

    decision = router.invoke([
        SystemMessage(
            content=(
                "请根据用户需求判断类别：story（故事）、joke（笑话）、poem（诗）。"
                "如果无法判断，请返回 irrelevant。"
            )
        ),
        HumanMessage(content=state.input),
    ])
    
    decision = getattr(decision, 'step', None) or 'irrelevant'
    return {"decision": decision}


# ===========================
#  条件路由（match-case 精简版）
# ===========================
def route_decision(state: State):
    match state.decision:
        case "story": return "llm_call_1"
        case "joke": return "llm_call_2"
        case "poem": return "llm_call_3"
        case _: return "llm_call_irrelevant"


# ===========================
#  构建 Graph
# ===========================
router_builder = StateGraph(State)

# 添加节点
router_builder.add_node("llm_call_1", llm_call_1)
router_builder.add_node("llm_call_2", llm_call_2)
router_builder.add_node("llm_call_3", llm_call_3)
router_builder.add_node("llm_call_router", llm_call_router)
router_builder.add_node("llm_call_irrelevant", llm_call_irrelevant)

# 起点 → router
router_builder.add_edge(START, "llm_call_router")

# 条件路由（自动选择分支）
router_builder.add_conditional_edges(
    "llm_call_router",
    route_decision,
    {
        "llm_call_1": "llm_call_1",
        "llm_call_2": "llm_call_2",
        "llm_call_3": "llm_call_3",
        "llm_call_irrelevant": "llm_call_irrelevant",
    },
)

# 每个节点 → END
router_builder.add_edge("llm_call_1", END)
router_builder.add_edge("llm_call_2", END)
router_builder.add_edge("llm_call_3", END)
router_builder.add_edge("llm_call_irrelevant", END)

# 编译 workflow
router_workflow = router_builder.compile()
```

### Orchestrator Worker

- 编排器（Orchestrator）将任务拆分给多个工作节点（Worker Node），每个节点独立处理任务，并将结果写入共享状态（WorkerState）。编排器最终收集所有节点输出，生成完整结果，适用于深度研究或需要动态的进行任务规划的场景。
  - 使用 `Send` API 为每个工作节点分配任务和输入。
  - 每个工作节点保持独立状态，但输出会写入共享状态。
  - 编排器可访问共享状态，汇总所有节点输出生成最终结果。

**图结构：**

![image-20251208182618178](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251208182618178.png)

**实现说明：**

Send API 传递的数据类型是TypeDict，这种类型的数据BaseModel想要使用需要使用`parse_state`转换

completed_sections 在图状态和子进程状态是共享的

**相关代码：**

```python
# parse_state.py
from functools import wraps

def parse_state(model_cls):
    """
    这个装饰器干两件事：
    1. 进门前：把 LangGraph 传进来的 dict 自动转成你的 Pydantic Model
    2. 让你在函数里爽用对象（IDE会有提示，因为我们在函数签名里写了类型）
    """
    def decorator(func):
        @wraps(func)
        def wrapper(state: dict):
            # 自动把字典转成对象
            state_obj = model_cls.model_validate(state)
            # 调用你的函数，传入对象
            return func(state_obj)
        return wrapper
    return decorator

# orchestrator-worker.py
import operator
from typing import List
from pydantic import BaseModel, Field
from typing_extensions import Annotated

from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import START, END
from langgraph.graph import StateGraph
from langgraph.types import Send

from src.decorator import parse_state
from src.model import llm


# -------- Section models --------

class Section(BaseModel):
    name: str = Field(description="Name for this section of the report.")
    description: str = Field(description="Brief overview of what will be covered.")


class Sections(BaseModel):
    sections: List[Section] = Field(description="Sections of the report.")


# -------- State Models (converted from TypedDict → BaseModel) --------

class State(BaseModel):
    topic: str
    sections: List[Section] = Field(default_factory=list)
    completed_sections: Annotated[List[str], operator.add] = Field(default_factory=list)
    final_report: str = ""


class WorkerState(BaseModel):
    section: Section
    completed_sections: Annotated[List[str], operator.add] = Field(default_factory=list)


# ------ planner -------
planner = llm.with_structured_output(Sections)


# -------- Nodes --------

def orchestrator(state: State):
    report_sections = planner.invoke(
        [
            SystemMessage(content="Generate a plan for the report."),
            HumanMessage(content=f"Here is the report topic: {state.topic}"),
        ]
    )
    return {"sections": report_sections.sections}


@parse_state(WorkerState)
def llm_call(state: WorkerState):
    result = llm.invoke(
        [
            SystemMessage(
                content="Write a report section following the name and description. No preamble. Use markdown."
            ),
            HumanMessage(
                content=f"Section name: {state.section.name}\n"
                        f"Description: {state.section.description}"
            ),
        ]
    )
    
    return {"completed_sections": [result.content]}


def synthesizer(state: State):
    final = "\n\n---\n\n".join(state.completed_sections)
    return {"final_report": final}


def assign_workers(state: State):
    return [Send("llm_call", {"section": s}) for s in state.sections]


# -------- Build workflow --------

orchestrator_worker_builder = StateGraph(State)

orchestrator_worker_builder.add_node("orchestrator", orchestrator)
orchestrator_worker_builder.add_node("llm_call", llm_call)
orchestrator_worker_builder.add_node("synthesizer", synthesizer)

orchestrator_worker_builder.add_edge(START, "orchestrator")
orchestrator_worker_builder.add_conditional_edges(
    "orchestrator", assign_workers, ["llm_call"]
)
orchestrator_worker_builder.add_edge("llm_call", "synthesizer")
orchestrator_worker_builder.add_edge("synthesizer", END)

orchestrator_worker = orchestrator_worker_builder.compile()
```

**llm_call 流式输出改造**

```python
@parse_state(WorkerState)
def llm_call(state: WorkerState):
    # 假设 llm.stream() 支持生成 token 流
    tokens = []
    for chunk in llm.stream(
            [
                SystemMessage(
                    content="Write a report section following the name and description. No preamble. Use markdown."
                ),
                HumanMessage(
                    content=f"Section name: {state.section.name}\n"
                            f"Description: {state.section.description}"
                ),
            ]
    ):
        # chunk 是 AIMessageChunk
        tokens.append(chunk.content)
```

### Evaluator

图结构：

![image-20251208151640374](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251208151640374.png)

相关代码：

```python
from typing import Literal, Optional

from langgraph.constants import START, END
from langgraph.graph import StateGraph
from pydantic import BaseModel

from src.model import llm


# ----------------------------
#  State 使用 BaseModel
# ----------------------------
class State(BaseModel):
    joke: Optional[str] = None
    topic: str
    feedback: Optional[str] = None
    funny_or_not: Optional[str] = None


# ----------------------------
#  Structured Output 模型
# ----------------------------
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"]
    feedback: str


# 带结构化输出的 evaluator
evaluator = llm.with_structured_output(Feedback)


# ----------------------------
#  Nodes
# ----------------------------
def llm_call_generator(state: State):
    """LLM 生成笑话"""

    if state.feedback:
        # 有反馈时，重新生成更好的笑话
        msg = llm.invoke(
            f"请根据以下反馈，重新写一个关于「{state.topic}」的笑话：{state.feedback}"
        )
    else:
        # 第一次生成笑话
        msg = llm.invoke(f"请写一个关于「{state.topic}」的笑话。")

    return {"joke": msg.content}


def llm_call_evaluator(state: State):
    """LLM 评价笑话是否好笑"""

    grade = evaluator.invoke(
        f"请评价以下笑话是否好笑，并根据结构化格式返回：{state.joke}"
    )

    return {
        "funny_or_not": grade.grade,
        "feedback": grade.feedback,
    }


# ----------------------------
#  Conditional Router
# ----------------------------
def route_joke(state: State):
    if state.funny_or_not == "funny":
        return "Accepted"
    elif state.funny_or_not == "not funny":
        return "Rejected + Feedback"


# ----------------------------
#  Build Graph
# ----------------------------
optimizer_builder = StateGraph(State)

optimizer_builder.add_node("llm_call_generator", llm_call_generator)
optimizer_builder.add_node("llm_call_evaluator", llm_call_evaluator)

optimizer_builder.add_edge(START, "llm_call_generator")
optimizer_builder.add_edge("llm_call_generator", "llm_call_evaluator")

optimizer_builder.add_conditional_edges(
    "llm_call_evaluator",
    route_joke,
    {
        "Accepted": END,
        "Rejected + Feedback": "llm_call_generator",
    },
)

optimizer_workflow = optimizer_builder.compile()
```

### Agents

LangGraph 可以更加灵活的控制 Agent 调用工具、输出的过程。

以下代码与 `from langchain.agents import create_agent` 效果几乎一致，create_agent实际上返回的也是LangGraph的一个图，也可以直接被LangSmith Studio观测

**节点图：**

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251210105227533.png" alt="**image-20251210105227533**" style="zoom:80%;" />

**代码实现：**

```python
from typing import Literal

from langchain_core.messages import SystemMessage, ToolMessage
from langgraph.constants import END, START
from langgraph.graph import MessagesState, StateGraph

from src.model import llm
from src.tools import add, multiply, divide

tools = [add, multiply, divide]
tools_by_name = {tool.name: tool for tool in tools}
llm_with_tools = llm.bind_tools(tools)

# ----------------------------
# 节点：LLM 调用
# ----------------------------
def llm_call(state: MessagesState):
    """LLM 决定是否调用工具"""

    return {
        "messages": [
            llm_with_tools.invoke(
                [
                    SystemMessage(
                        content="你是一个有用的助手，任务是对给定输入执行算术运算。"
                    )
                ]
                + state["messages"]
            )
        ]
    }

# ----------------------------
# 工具执行节点
# ----------------------------
def tool_node(state: dict):
    """执行工具调用"""

    result = []
    for tool_call in state["messages"][-1].tool_calls:
        tool = tools_by_name[tool_call["name"]]
        observation = tool.invoke(tool_call["args"])
        result.append(ToolMessage(content=observation, tool_call_id=tool_call["id"]))

    return {"messages": result}

# ----------------------------
# 条件边：判断下一步走向工具节点还是结束
# ----------------------------
def should_continue(state: MessagesState) -> Literal["tool_node", END]:
    """根据 LLM 是否发出工具调用，决定继续循环还是停止"""

    messages = state["messages"]
    last_message = messages[-1]

    # 如果 LLM 发出了工具调用，则进入工具节点
    if last_message.tool_calls:
        return "tool_node"

    # 否则结束（直接回复用户）
    return END

# ----------------------------
# 构建工作流
# ----------------------------
agent_builder = StateGraph(MessagesState)

# 添加节点
agent_builder.add_node("llm_call", llm_call)
agent_builder.add_node("tool_node", tool_node)

# 添加边：启动 → llm_call
agent_builder.add_edge(START, "llm_call")

# llm_call 根据是否有 tool call 进入不同分支
agent_builder.add_conditional_edges(
    "llm_call",
    should_continue,
    ["tool_node", END]
)

# 工具节点执行完再回到 llm_call
agent_builder.add_edge("tool_node", "llm_call")

# 编译 agent
agent = agent_builder.compile()
```

### Mutiply-Agents

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251210105403463.png" alt="image-20251210105403463" style="zoom:80%;" />

该例子实现了基于多智能体的深度研究，并进行了上下文管理，可直接在Chat模式中通过会话的形式调试

```python
from typing import TypedDict, Annotated, Literal, List, Dict, Optional

from langchain.agents import create_agent
from langgraph.config import get_stream_writer
from langgraph.types import Command, interrupt
from pydantic import BaseModel, Field

from langgraph.graph import StateGraph, END, START, add_messages
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage, BaseMessage, AnyMessage

from src.model import llm


# ==================== 数据模型定义 ====================

class IntentCheckResult(BaseModel):
    need_report: bool = Field(default=False, description="是否需要生成研究报告")


class TaskInfo(BaseModel):
    """单个任务信息"""
    task_type: Literal["product", "tech", "ui", "fullstack"] = Field(description="任务类型")
    task_title: str = Field(description="任务标题")
    report_content: str = Field(default="", description="调研报告内容")
    status: Literal["pending", "in_progress", "completed"] = Field(default="pending", description="任务状态")


class ResearchPlan(BaseModel):
    tasks: List[TaskInfo] = Field(description="任务列表")
    overall_summary: str = Field(description="整体研究计划概述")


class AgentState(TypedDict):
    """主图的状态定义"""
    messages: Annotated[list[AnyMessage], add_messages]  # 用户可见的展示层
    need_report: bool  # 是否需要生成报告
    research_plan: Optional[ResearchPlan]  # 结构化的任务列表（数据层）
    current_task_index: int  # 当前执行的任务索引
    summary_report: str  # 最终摘要


# ==================== 工具函数 ====================

def get_latest_user_content(state: AgentState) -> str:
    """从消息历史中提取最新的用户文本内容"""
    messages = state.get("messages", [])
    for msg in reversed(messages):
        if isinstance(msg, HumanMessage):
            if isinstance(msg.content, str):
                return msg.content
            elif isinstance(msg.content, list):
                return " ".join([item.get("text", "") for item in msg.content if item.get("type") == "text"])
    return ""


def format_task_list(plan: ResearchPlan) -> str:
    """格式化任务列表为用户可见的文本"""
    result = f"## 📋 研究计划\n{plan.overall_summary}\n\n### 任务列表：\n\n"
    
    for i, task in enumerate(plan.tasks, 1):
        status_emoji = {
            "pending": "⏳",
            "in_progress": "🔄",
            "completed": "✅"
        }[task.status]
        
        result += f"{status_emoji} **任务 {i}**: {task.task_title}\n"
        result += f"   - 类型: {task.task_type}\n"
        result += f"   - 状态: {task.status}\n"
        
        if task.report_content:
            # 展示报告的前100字
            preview = task.report_content[:100] + "..." if len(task.report_content) > 100 else task.report_content
            result += f"   - 报告预览: {preview}\n"
        
        result += "\n"
    
    return result


def format_progress(current: int, total: int) -> str:
    """格式化任务进度"""
    return f"📊 任务进度: {current}/{total} 已完成"


# ==================== 核心节点 ====================

def intent_checker(state: AgentState) -> AgentState:
    """意图检查：判断是否需要深度研究"""
    system_msg = """你是一个意图分析专家。判断用户的问题是否需要生成深度研究报告。
    需要报告的情况：要求深入调研、多角度分析、技术方案、复杂任务。
    不需要报告的情况：简单问答、闲聊、明确不需要深度分析。"""
    
    structured_llm = llm.with_structured_output(IntentCheckResult)
    user_query = get_latest_user_content(state)
    response = structured_llm.invoke([
        SystemMessage(content=system_msg),
        HumanMessage(content=user_query)
    ]) or IntentCheckResult()
    
    return {"need_report": response.need_report}


async def tutoring_llm(state: AgentState) -> AgentState:
    """简单辅导模式"""
    writer = get_stream_writer()
    sys_msg = SystemMessage(content="用户的问题不需要深度报告。请直接简短回答，并引导用户如果需要深度报告该怎么问。")
    msg = [sys_msg] + state["messages"]
    
    full_content = ""
    async for chunk in llm.astream(msg):
        content = chunk.content
        if content:
            full_content += content
            writer(content)
    
    return {"messages": [AIMessage(content=full_content)]}


def project_manager(state: AgentState) -> AgentState:
    """项目经理：生成任务列表（不包含具体报告内容）"""
    
    system_prompt = """你是一位经验丰富的项目经理。负责将用户的研究需求分解为具体的调研任务。
    现有专家团队:
    1. product (产品经理)
    2. tech (技术总监)
    3. ui (UI设计师)
    4. fullstack (全栈开发)

    请生成一份研究计划。

    【重要约束】
    1. 将子任务数量控制在 5 个以内 (<= 5)
    2. 任务标题必须具体明确
    3. 不要生成报告内容，只需要任务标题和类型
    """
    
    structured_llm = llm.with_structured_output(ResearchPlan)
    user_query = get_latest_user_content(state)
    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=f"用户需求: {user_query}")
    ]
    
    plan = structured_llm.invoke(messages)
    
    # 格式化任务列表展示给用户
    task_list_message = format_task_list(plan)
    
    return {
        "research_plan": plan,
        "current_task_index": 0,
        "messages": [AIMessage(content=task_list_message)]
    }


# ==================== 专家 Agent 子图 ====================

def create_specialist_subgraph(role_name: str, role_description: str):
    """创建专家 Agent 子图"""
    
    class SpecialistSubgraphState(TypedDict):
        messages: Annotated[List[BaseMessage], add_messages]
        current_task: TaskInfo
        user_requirement: str
    
    async def prepare_context(state: SpecialistSubgraphState):
        """准备专家的独立上下文"""
        current_task = state["current_task"]
        user_requirement = state["user_requirement"]
        
        independent_messages = [
            SystemMessage(content=f"你是一位资深的{role_name}。{role_description}\n请只关注你专业领域的分析。"),
            HumanMessage(content=f"""
【用户需求】
{user_requirement}

【当前任务】
{current_task.task_title}

请提供专业、详实的分析报告。
""")
        ]
        
        return {"messages": independent_messages}
    
    async def specialist_analysis(state: SpecialistSubgraphState):
        """专家分析 - 流式输出"""
        writer = get_stream_writer()
        
        # 先输出任务开始信息
        task_title = state["current_task"].task_title
        writer(f"\n\n🔄 **开始执行**: {task_title}\n\n")
        
        full_content = ""
        async for chunk in llm.astream(state["messages"]):
            content = chunk.content
            if content:
                full_content += content
                writer(content)  # 流式更新报告内容
        
        return {"current_task": TaskInfo(
            task_type=state["current_task"].task_type,
            task_title=state["current_task"].task_title,
            report_content=full_content,
            status="completed"
        )}
    
    # 构建子图
    subgraph = StateGraph(SpecialistSubgraphState)
    subgraph.add_node("prepare", prepare_context)
    subgraph.add_node("analyze", specialist_analysis)
    
    subgraph.add_edge(START, "prepare")
    subgraph.add_edge("prepare", "analyze")
    subgraph.add_edge("analyze", END)
    
    compiled_subgraph = subgraph.compile()
    
    # 主图节点包装函数
    async def invoke_specialist(state: AgentState):
        """调用子图并更新主图状态"""
        idx = state["current_task_index"]
        plan = state["research_plan"]
        current_task = plan.tasks[idx]
        
        # 更新任务状态为进行中
        current_task.status = "in_progress"
        
        # 调用子图
        subgraph_input = {
            "messages": [],
            "current_task": current_task,
            "user_requirement": get_latest_user_content(state)
        }
        
        result = await compiled_subgraph.ainvoke(subgraph_input)
        
        # 更新任务信息
        plan.tasks[idx] = result["current_task"]
        
        # 更新任务进度展示
        writer = get_stream_writer()
        progress_msg = f"\n\n{format_progress(idx + 1, len(plan.tasks))}\n"
        writer(progress_msg)
        
        # 全量更新任务列表
        task_list_update = format_task_list(plan)
        
        return {
            "research_plan": plan,
            "current_task_index": idx + 1,
            "messages": [AIMessage(content=f"\n\n✅ **任务完成**: {current_task.task_title}\n\n{task_list_update}")]
        }
    
    return invoke_specialist


# 创建所有专家
product_node = create_specialist_subgraph("产品经理", "精通产品规划、用户需求分析、市场调研")
tech_node = create_specialist_subgraph("技术总监", "精通技术架构设计、技术选型、性能优化")
ui_node = create_specialist_subgraph("UI设计师", "精通用户界面设计、交互体验、视觉风格")
fullstack_node = create_specialist_subgraph("全栈工程师", "精通前后端开发、数据库设计、代码实现")


# ==================== 路由与汇总 ====================

def task_router(state: AgentState) -> Literal["product", "tech", "ui", "fullstack", "summary"]:
    """任务路由器"""
    plan = state.get("research_plan")
    idx = state.get("current_task_index", 0)
    
    if not plan or idx >= len(plan.tasks):
        return "summary"
    
    next_task = plan.tasks[idx]
    return next_task.task_type


async def generate_summary(state: AgentState) -> AgentState:
    """生成最终摘要 - 流式输出"""
    writer = get_stream_writer()
    
    # 先输出标题
    writer("\n\n## 📝 研究报告摘要\n\n")
    
    # 收集所有任务报告
    plan = state["research_plan"]
    reports = [f"### {task.task_title}\n{task.report_content}" for task in plan.tasks]
    results_text = "\n\n".join(reports)
    
    user_query = get_latest_user_content(state)
    msg = [
        SystemMessage(content="你是项目经理。请根据团队的研究成果生成一份简明的摘要报告，突出核心要点和建议。"),
        HumanMessage(content=f"用户需求: {user_query}\n\n详细研究结果:\n{results_text}")
    ]
    
    full_summary = ""
    async for chunk in llm.astream(msg):
        content = chunk.content
        if content:
            full_summary += content
            writer(content)
    
    # 保存摘要到状态
    return {
        "summary_report": full_summary,
        "messages": [AIMessage(content=full_summary)]
    }


async def ask_full_report(state: AgentState) -> Command[Literal["send_full_report", END]]:
    """询问是否需要完整报告 - 独立节点"""
    writer = get_stream_writer()
    
    # 询问是否需要完整报告
    prompt_msg = "\n\n---\n\n💬 **是否需要查看完整的研究报告？**"
    writer(prompt_msg)
    
    # 使用 interrupt 中断，提供两个选项
    user_choice = interrupt({
        "question": "是否需要查看完整的研究报告？",
        "options": ["查看", "跳过"]
    })
    
    # 根据用户选择进行路由
    if user_choice == "查看":
        return Command(goto="send_full_report")
    else:
        return Command(goto=END)


async def send_full_report(state: AgentState) -> AgentState:
    """发送完整报告 - 流式输出"""
    writer = get_stream_writer()
    plan = state["research_plan"]
    
    # 构建完整报告
    writer("\n\n# 📑 完整研究报告\n\n")
    writer(f"## 研究概述\n{plan.overall_summary}\n\n")
    
    for i, task in enumerate(plan.tasks, 1):
        section = f"## {i}. {task.task_title}\n"
        section += f"**负责人**: {task.task_type}\n\n"
        section += f"{task.report_content}\n\n"
        section += "---\n\n"
        writer(section)
    
    writer(f"## 总结\n{state['summary_report']}")
    
    # 构建完整报告内容用于保存到消息历史
    full_report = f"\n\n# 📑 完整研究报告\n\n"
    full_report += f"## 研究概述\n{plan.overall_summary}\n\n"
    
    for i, task in enumerate(plan.tasks, 1):
        full_report += f"## {i}. {task.task_title}\n"
        full_report += f"**负责人**: {task.task_type}\n\n"
        full_report += f"{task.report_content}\n\n"
        full_report += "---\n\n"
    
    full_report += f"## 总结\n{state['summary_report']}"
    
    return {"messages": [AIMessage(content=full_report)]}


# ==================== 构建主图 ====================

def create_workflow():
    """创建工作流"""
    workflow = StateGraph(AgentState)
    
    # 添加节点
    workflow.add_node("intent_checker", intent_checker)
    workflow.add_node("tutoring_llm", tutoring_llm)
    workflow.add_node("project_manager", project_manager)
    
    # 专家节点
    workflow.add_node("product", product_node)
    workflow.add_node("tech", tech_node)
    workflow.add_node("ui", ui_node)
    workflow.add_node("fullstack", fullstack_node)
    
    # 摘要和报告节点
    workflow.add_node("summary", generate_summary)
    workflow.add_node("ask_full_report", ask_full_report)  # 新增：询问节点
    workflow.add_node("send_full_report", send_full_report)
    
    # 流程编排
    workflow.add_edge(START, "intent_checker")
    
    # 意图路由
    def intent_route(state):
        return "project_manager" if state["need_report"] else "tutoring_llm"
    
    workflow.add_conditional_edges(
        "intent_checker",
        intent_route,
        {
            "project_manager": "project_manager",
            "tutoring_llm": "tutoring_llm"
        }
    )
    workflow.add_edge("tutoring_llm", END)
    
    # PM -> 任务循环
    workflow.add_conditional_edges(
        "project_manager",
        task_router,
        {
            "product": "product",
            "tech": "tech",
            "ui": "ui",
            "fullstack": "fullstack",
            "summary": "summary"
        }
    )
    
    # 每个专家完成后回到路由器
    experts = ["product", "tech", "ui", "fullstack"]
    for expert in experts:
        workflow.add_conditional_edges(
            expert,
            task_router,
            {
                "product": "product",
                "tech": "tech",
                "ui": "ui",
                "fullstack": "fullstack",
                "summary": "summary"
            }
        )
    
    # 摘要生成后 -> 询问是否需要完整报告
    workflow.add_edge("summary", "ask_full_report")
    
    # ask_full_report 节点通过 Command(goto=...) 进行路由
    # send_full_report 完成后结束流程
    workflow.add_edge("send_full_report", END)
    
    return workflow.compile()


# ==================== 创建应用实例 ====================
app = create_workflow()
```

### Google 深度研究开源项目

**项目地址：**https://github.com/google-gemini/gemini-fullstack-langgraph-quickstart

**项目预览：**

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251211154221330.png" alt="image-20251211154221330" style="zoom:100%;" />

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251211154158204.png" alt="image-20251211154158204" style="zoom:80%;" />

**图结构：**

大体流程：

- 根据用户问题，生成相关问题的数组。
- 然后将查询问题分发给web_research节点，待全部web_research 都执行完毕后，通过reflection节点评估是否已经满足调研需求了，
  - 如果不满足，生成follow_up_queries用于填补缺口的具体搜索关键词列表，然后重新分发给web_research，再进行评估。
  - 如果满足，就跳转到 finalize_answer节点，
- fialize_answer 主要是拼接了所有的上下文摘要，一起交给大模型生成调研报告。

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251211145006898.png" alt="image-20251211145006898" style="zoom:67%;" />

**代码实现：**

把原项目中的gemmi模型更换为通义千问系列大模型，并且将提示词、注释替换为了中文。

由于联网检索 API 返回的数据结构不太兼容，最终生成报告中的引用可能无法溯源。

```python
import os
import operator
import re
from dataclasses import dataclass, field
from typing import Any, Dict, List, TypedDict, Optional

import dashscope
from dashscope.api_entities.dashscope_response import Message as DSMessage
from dotenv import load_dotenv
from langchain_community.chat_models import ChatTongyi
from langchain_core.messages import AnyMessage, AIMessage, HumanMessage
from langchain_core.runnables import RunnableConfig
from pydantic import BaseModel, Field
from typing_extensions import Annotated
from langgraph.graph import StateGraph, add_messages
from langgraph.graph import START, END
from langgraph.types import Send


# ----------------------------
#  图、节点状态
# ----------------------------

class OverallState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    search_query: Annotated[list, operator.add]
    web_research_result: Annotated[list, operator.add]
    sources_gathered: Annotated[list, operator.add]
    initial_search_query_count: int
    max_research_loops: int
    research_loop_count: int
    reasoning_model: str


class ReflectionState(TypedDict):
    is_sufficient: bool
    knowledge_gap: str
    follow_up_queries: Annotated[list, operator.add]
    research_loop_count: int
    number_of_ran_queries: int


class QueryGenerationState(TypedDict):
    search_query: List[str]


class WebSearchState(TypedDict):
    search_query: str
    id: str


@dataclass(kw_only=True)
class SearchStateOutput:
    running_summary: str = field(default=None)


# ----------------------------
#  运行时参数配置
# ----------------------------

class Configuration(BaseModel):
    """代理运行配置：模型选择、初始查询数量、研究循环上限等。"""

    query_generator_model: str = Field(
        default="qwen-plus",
        metadata={
            "description": "用于生成初始查询的模型名称",
        },
    )

    reflection_model: str = Field(
        default="qwen-plus",
        metadata={
            "description": "用于反思评估的模型名称",
        },
    )

    answer_model: str = Field(
        default="qwen3-max",
        metadata={
            "description": "用于最终答案生成的模型名称",
        },
    )

    number_of_initial_queries: int = Field(
        default=3,
        metadata={"description": "初始生成的搜索查询数量"},
    )

    max_research_loops: int = Field(
        default=2,
        metadata={"description": "最多允许的研究循环次数"},
    )

    @classmethod
    def from_runnable_config(
        cls, config: Optional[RunnableConfig] = None
    ) -> "Configuration":
        """从 `RunnableConfig` 或环境变量生成配置。优先级：环境变量 > config.configurable > 默认值"""
        configurable = (
            config["configurable"] if config and "configurable" in config else {}
        )

        raw_values: dict[str, Any] = {
            name: os.environ.get(name.upper(), configurable.get(name))
            for name in cls.model_fields.keys()
        }
        values = {k: v for k, v in raw_values.items() if v is not None}
        return cls(**values)


# ----------------------------
#  提示词与说明
# ----------------------------

from datetime import datetime


def get_current_date():
    """获取当前日期的可读字符串形式，如 "December 11, 2025"。"""
    return datetime.now().strftime("%B %d, %Y")


# 查询生成阶段提示词
query_writer_instructions = """你的目标是生成专业且多样化的网络搜索查询词（Queries）。这些查询将用于自动化研究工具，以分析复杂问题。

指令：
1. 每个查询都应侧重于原始问题的一个具体方面。
2. 最多生成 {number_queries} 个查询。
3. 查询应多样化，覆盖不同角度。
4. 确保查询能够获取最新的信息。当前日期是 {current_date}。

输出格式：
请输出一个 JSON 对象，包含以下确切的键：
- "rationale": string (简要解释为什么生成这些查询)
- "query": list[string] (搜索查询列表)

示例：
Topic: 苹果去年的营收增长快还是买iPhone的人数增长快？
```json
{{
    "rationale": "为了回答这个比较性增长问题，我们需要苹果公司上一财年的具体财务数据和iPhone的销量数据。",
    "query": ["Apple revenue growth fiscal year 2024", "iPhone unit sales growth 2024", "Apple stock vs iPhone sales growth comparison"]
}}
Context: {research_topic}"""

# 网页搜索阶段提示词（用于指导模型使用 Search 工具进行可信信息检索与整合）。
# 网页搜索阶段提示词
web_searcher_instructions = """请针对研究主题 "{research_topic}" 进行深入的联网搜索，并收集最新、可信的信息。

指令：
1. **时效性**：确保信息是最新的。当前日期是 {current_date}。
2. **多角度**：进行多次、多样化的搜索以收集全面的信息。
3. **基于事实**：仅使用搜索结果中的信息，严禁编造内容。
4. **引用来源**：在整合信息时，必须严格保留信息来源的引用标记（例如 [1], [2]）。这非常重要，不要遗漏。
5. **输出形式**：输出一篇结构清晰、内容详实的中文研究摘要或报告。

研究主题：
{research_topic}
"""


# 反思评估阶段提示词
reflection_instructions = """你是一名专业的那个研究助理，正在分析关于 "{research_topic}" 的搜索摘要。

指令：
1. **评估信息量**：目前的摘要是否已经充分、详实地回答了用户的原始问题？
2. **识别缺口**：如果信息不足，或者有些技术细节、具体数据、最新趋势没有覆盖到，请指出“知识缺口”。
3. **生成后续查询**：针对这些缺口，生成 1 个或多个具体的搜索查询词（Query）。
4. **结束条件**：如果摘要已经足够回答问题，或者没有明显的缺口，请将 "is_sufficient" 设为 true，并不再生成后续查询。

输出格式要求（必须为 JSON）：
请输出一个 JSON 对象，包含以下确切的键（Key）：
- "is_sufficient": boolean (true 或 false)
- "knowledge_gap": string (描述缺失的信息，如果已满足则留空)
- "follow_up_queries": list[string] (用于填补缺口的具体搜索关键词列表)

示例：
```json
{{
    "is_sufficient": false,
    "knowledge_gap": "摘要中提到了该技术的优势，但缺乏具体的性能基准测试数据和2024年的市场份额数据。",
    "follow_up_queries": ["2024年 Qwen-Max 性能基准测试对比", "2024年 大模型市场份额分析报告"]
}}
现在，请根据以下摘要进行反思分析：

现有摘要： {summaries} """


# 答案生成阶段提示词（用于整合所有研究结果并生成含引用的高质量答案）。
# 答案生成阶段提示词
answer_instructions = """你是一名专业的智能研究助手。请基于提供的【研究摘要】，为用户的【原始问题】生成一份高质量的最终回答。

指令：
1. **时效性**：当前日期是 {current_date}。
2. **直接回答**：直接针对问题进行回答，不要在开头提及“经过搜索”、“根据之前的步骤”或“我是最后一步”。
3. **综合整合**：摘要可能包含重复或碎片化的信息，请将其整合成逻辑流畅、结构清晰的文本。
4. **强制引用（关键）**：
   - 必须在回答中保留信息来源。
   - 使用 Markdown 链接格式：`[来源名称](URL)`。
   - 例如：`根据最新的报道[新华网](https://www.news.cn/...)，该技术...`
   - 只能引用【研究摘要】中真实存在的 URL，严禁编造链接。

用户问题：
{research_topic}

研究摘要集：
{summaries}"""


# ----------------------------
#  工具与辅助方法
# ----------------------------

def get_research_topic(messages: List[AnyMessage]) -> str:
    """从消息历史中提取研究主题：若只有一条消息则直接取其内容；否则按人类/助手角色拼接为上下文。"""
    if len(messages) == 1:
        research_topic = messages[-1].content
    else:
        research_topic = ""
        for message in messages:
            if isinstance(message, HumanMessage):
                research_topic += f"User: {message.content}\n"
            elif isinstance(message, AIMessage):
                research_topic += f"Assistant: {message.content}\n"
    return research_topic


def resolve_urls(urls_to_resolve: List[Any], id: int) -> Dict[str, str]:
    """将 Vertex AI Search 返回的长链接映射为含唯一编号的短链接，便于在文本中引用与节省令牌。"""
    prefix = f"https://vertexaisearch.cloud.google.com/id/"
    urls = [site.web.uri for site in urls_to_resolve]

    resolved_map: Dict[str, str] = {}
    for idx, url in enumerate(urls):
        if url not in resolved_map:
            resolved_map[url] = f"{prefix}{id}-{idx}"
    return resolved_map

# ----------------------------
#  环境与客户端初始化
# ----------------------------

load_dotenv()
if os.getenv("DASHSCOPE_API_KEY") is None:
    raise ValueError("DASHSCOPE_API_KEY is not set")


# ----------------------------
#  节点实现
# ----------------------------

def generate_query(state: OverallState, config: RunnableConfig) -> QueryGenerationState:
    """查询生成节点：基于用户问题与上下文，用 Gemini 2.0 Flash 生成优化的检索查询列表（结构化输出）。"""
    configurable = Configuration.from_runnable_config(config)
    if state.get("initial_search_query_count") is None:
        state["initial_search_query_count"] = configurable.number_of_initial_queries
    llm = ChatTongyi(
        model=configurable.query_generator_model,
        streaming=True,
        max_retries=2,
        api_key=os.getenv('DASHSCOPE_API_KEY')
    )
    structured_llm = llm.with_structured_output(SearchQueryList)

    current_date = get_current_date()
    formatted_prompt = query_writer_instructions.format(
        current_date=current_date,
        research_topic=get_research_topic(state["messages"]),
        number_queries=state["initial_search_query_count"],
    )
    result = structured_llm.invoke(formatted_prompt) or SearchQueryList()
    return {"search_query": result.query}


def continue_to_web_research(state: QueryGenerationState):
    """调度辅助：将每个生成的查询分发到并行的网页检索节点。"""
    return [
        Send("web_research", {"search_query": search_query, "id": int(idx)})
        for idx, search_query in enumerate(state["search_query"])
    ]


def build_citations_from_dashscope(text: str, search_results: list):
    """
    直接提取被引用的来源，不搞复杂的嵌套结构。
    """
    citations = []
    # 匹配 [1], [2] 这种引用
    pattern = r'\[(\d+)\]'
    matches = list(re.finditer(pattern, text))
    
    # 用一个集合去重，防止同一个来源被添加多次
    seen_urls = set()
    
    for m in matches:
        num = int(m.group(1))
        if num > len(search_results):
            continue
        
        src = search_results[num - 1]
        url = src.get("url", "")
        
        if url and url not in seen_urls:
            # 直接存简单的字典
            citations.append({
                "title": src.get("title", ""),
                "url": url,
            })
            seen_urls.add(url)
    
    return citations


def web_research(state: WebSearchState, config: RunnableConfig) -> OverallState:
    """网页检索节点：调用原生 Google Search 工具并结合 Gemini 模型，生成带可验证引用的研究片段。"""
    configurable = Configuration.from_runnable_config(config)
    formatted_prompt = web_searcher_instructions.format(
        current_date=get_current_date(),
        research_topic=state["search_query"],
    )


    response = dashscope.Generation.call(
        model='qwen-turbo',
        # model=configurable.query_generator_model,
        messages=[DSMessage(role="user", content=formatted_prompt)],
        enable_search=True,
        search_options={
            "forced_search": True,
            "enable_source": True,
            "enable_citation": True,
            "citation_format": "[<number>]",
        },
        result_format="message",
        api_key=os.getenv("DASHSCOPE_API_KEY"),
    )

    text = response.output.choices[0].message.content
    search_results = response.output.search_info["search_results"]

    citations = build_citations_from_dashscope(text, search_results)

    return {
        "sources_gathered": citations,
        "search_query": [state["search_query"]],
        "web_research_result": [text]
    }



class SearchQueryList(BaseModel):
    query: List[str] = Field(default=[], description="用于网页研究的搜索查询列表")
    rationale: str = Field(default='', description="为何这些查询与研究主题相关的简要说明")


class Reflection(BaseModel):
    is_sufficient: bool = Field(description="当前摘要是否足以回答用户问题")
    knowledge_gap: str = Field(description="尚缺失或需澄清的信息描述")
    follow_up_queries: List[str] = Field(description="用于弥补知识缺口的后续查询列表")


def reflection(state: OverallState, config: RunnableConfig) -> ReflectionState:
    """反思评估节点：分析已收集的摘要，识别知识缺口并生成后续查询（结构化输出）。"""
    configurable = Configuration.from_runnable_config(config)
    state["research_loop_count"] = state.get("research_loop_count", 0) + 1
    reasoning_model = state.get("reasoning_model", configurable.reflection_model)

    current_date = get_current_date()
    formatted_prompt = reflection_instructions.format(
        current_date=current_date,
        research_topic=get_research_topic(state["messages"]),
        summaries="\n\n---\n\n".join(state["web_research_result"]),
    )
    
    llm = ChatTongyi(
        model=reasoning_model,
        streaming=True,
        max_retries=2,
        api_key=os.getenv('DASHSCOPE_API_KEY')
    )
    result = llm.with_structured_output(Reflection).invoke(formatted_prompt)

    return {
        "is_sufficient": result.is_sufficient,
        "knowledge_gap": result.knowledge_gap,
        "follow_up_queries": result.follow_up_queries,
        "research_loop_count": state["research_loop_count"],
        "number_of_ran_queries": len(state["search_query"]),
    }


def evaluate_research(state: ReflectionState, config: RunnableConfig) -> Any:
    """路由决策：根据是否足够或是否达到研究循环上限，选择继续检索或进入最终答案阶段。"""
    configurable = Configuration.from_runnable_config(config)
    max_research_loops = (
        state.get("max_research_loops")
        if state.get("max_research_loops") is not None
        else configurable.max_research_loops
    )
    if state["is_sufficient"] or state["research_loop_count"] >= max_research_loops:
        return "finalize_answer"
    else:
        return [
            Send(
                "web_research",
                {
                    "search_query": follow_up_query,
                    "id": state["number_of_ran_queries"] + int(idx),
                },
            )
            for idx, follow_up_query in enumerate(state["follow_up_queries"])
        ]


def finalize_answer(state: OverallState, config: RunnableConfig) -> Dict[str, Any]:
    """答案整合节点：生成回答，并整理最终用到的来源列表。"""
    configurable = Configuration.from_runnable_config(config)
    reasoning_model = state.get("reasoning_model") or configurable.answer_model
    
    current_date = get_current_date()
    
    # 拼接所有的上下文摘要
    summaries = "\n---\n\n".join(state["web_research_result"])
    
    formatted_prompt = answer_instructions.format(
        current_date=current_date,
        research_topic=get_research_topic(state["messages"]),
        summaries=summaries,
    )
    
    llm = ChatTongyi(
        model=reasoning_model,
        streaming=True,
        max_retries=2,
        api_key=os.getenv('DASHSCOPE_API_KEY')
    )
    result = llm.invoke(formatted_prompt)
    
    # --- 简化后的逻辑 ---
    # 我们不再做文本替换 (replace)，因为 Qwen 会直接输出 Markdown 链接。
    # 我们只需要确认一下 answer 里到底包含了哪些链接，用来展示“参考来源”列表。
    
    final_content = result.content
    unique_sources = []
    seen_urls = set()
    
    for source in state["sources_gathered"]:
        url = source.get("url")
        # 如果 URL 出现在了最终回答里，或者我们宽容一点，只要是之前搜到的都算
        # 这里做个简单判断：如果 answer 里提到了这个链接，就加入最终来源
        if url and (url in final_content) and (url not in seen_urls):
            unique_sources.append(source)
            seen_urls.add(url)
    
    # 如果大模型没有显式输出 URL 文本，你也可以选择直接把 state["sources_gathered"] 全部返回
    unique_sources = state["sources_gathered"]
    
    return {
        "messages": [AIMessage(content=final_content)],
        "sources_gathered": unique_sources,
    }

# ----------------------------
#  图构建与编译
# ----------------------------

builder = StateGraph(OverallState, config_schema=Configuration)
builder.add_node("generate_query", generate_query)
builder.add_node("web_research", web_research)
builder.add_node("reflection", reflection)
builder.add_node("finalize_answer", finalize_answer)

builder.add_edge(START, "generate_query")
builder.add_conditional_edges("generate_query", continue_to_web_research, ["web_research"])
builder.add_edge("web_research", "reflection")
builder.add_conditional_edges("reflection", evaluate_research, ["web_research", "finalize_answer"])
builder.add_edge("finalize_answer", END)

graph = builder.compile(name="pro-search-agent-cn")


```

# LangGraph React SDK 

通过 useStream API 即可连接远程 LangGraph Cloud，useStream 会返回 thread 内全部信息，React 此时可作为 UI 状态机 对 LangGraph 图的运行状态（State）以及上下文进行观测，从而展示 消息列表、工具调用状态等信息。

## 基本用法

```tsx
import { useStream } from "@langchain/langgraph-sdk/react";
import type { Message } from "@langchain/langgraph-sdk";

const thread = useStream<{
  messages: Message[];
  initial_search_query_count: number;
  max_research_loops: number;
  reasoning_model: string;
}>({
	apiUrl: "http://localhost:2024",
	assistantId: "agent-gemini",
	messagesKey: "messages",
	onUpdateEvent: (event) => {},
  onFinish: (state) => {},
  onError: (error) => {},
  threadId,
  onThreadId: (threadId: string) => {},
})
```

thread 返回的是react state，可直接渲染或通过useEffect监听

# DeepAgents

本质是个带有任务编排、任务执行、文件系统能力的深度研究智能体，是LangChain内部的玩具项目，技术尚不成熟，无法应用于生产环境，暂无进一步调研计划

# 相关集成

## Agent 工具

### 获取URL页面内容

1. 可替换Tavily Extract
2. 与 Bocha 组合使用可轻松实现Agent联网检索任务

```python
import httpx
from markdownify import markdownify

def internet_webpage(url: str, timeout: float = 10.0) -> str:
    """
    基于URL互联网搜索工具。
    输入URL获取并转换网页内容为 Markdown 格式。
    参数：
    url: 要获取的网页 URL
    timeout: 请求超时时间（秒）
    
    返回：
    网页内容（Markdown 格式）
    """
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    try:
        response = httpx.get(url, headers=headers, timeout=timeout)
        response.raise_for_status()
        return markdownify(response.text)
    except Exception as e:
        return f"Error fetching content from {url}: {str(e)}"
```

### 基于 tavily 联网检索（国外方案）

环境变量

```
# Tavily API key
TAVILY_API_KEY=tvly-dev-xxxxxxxxxxxxxxxxxx
```

代码实现

```python
def internet_search(
        query: str,
        max_results: int = 5,
        topic: Literal["general", "news", "finance"] = "general",
        include_raw_content: bool = False,
):
    """
    基于关键词的互联网搜索工具。
    输入搜索关键词，返回搜索结果摘要，可按主题分类。
    """
    return tavily_client.search(
        query,
        max_results=max_results,
        include_raw_content=include_raw_content,
        topic=topic,
    )
```

网页爬取

```python
def internet_crawl(
    url: str,
    instructions: Optional[str] = None,
    max_depth: Optional[int] = 1,
):
    """
    网页内容抓取工具。
    适合深入获取指定 URL 的页面内容，可设置爬取深度（1~5）。
    """
    return tavily_client.crawl(
        url=url,
        instructions=instructions,
        max_depth=max_depth,
    )
```





### 基于 Bocha 联网检索（国内方案）

https://bocha-ai.feishu.cn/wiki/XXCsw2Dyjiny8OkJl0KcWjyOnDb LangChain 工具（推荐该方案）

https://bocha-ai.feishu.cn/wiki/DCZTwH6OMidCbTkWFRVcVkHonag MCP 服务（需本地部署）

# DashScope百炼平台

## 图像生成

**百炼文本生成图像**

文档：https://help.aliyun.com/zh/model-studio/text-to-image?spm=a2c4g.11186623.help-menu-2400256.d_0_6_0.71db7c3bMtd6bh

**模型选型**

- **复杂文字渲染**（如海报、对联）：首选`qwen-image-plus`**、**`wan2.5-t2i-preview`。

- **写实场景和摄影风格**（通用场景）：可选通义万相模型，如`wan2.5-t2i-preview`、`wan2.2-t2i-flash`。

- **需要自定义输出图像分辨率：**推荐通义万相模型，如`wan2.2-t2i-flash`，支持 [512, 1440] 像素范围内的任意宽高组合。

  > 通义千问Qwen-Image仅支持5种固定尺寸：1664*928(16:9)、928*1664(9:16)、1328*1328(1:1)、1472*1140(4:3)、1140*1472(3:4)。

- **成本极度敏感，可接受基础质量：**可选择`wanx2.0-t2i-turbo`，价格较低，请参见[计费与限流](https://help.aliyun.com/zh/model-studio/text-to-image?spm=a2c4g.11186623.help-menu-2400256.d_0_6_0.71db7c3bMtd6bh#a585cbf27dck8)。

**模型价格**

| **模型名称**    | **单价**  | **免费额度**[（注）](https://help.aliyun.com/zh/model-studio/new-free-quota#591f3dfedfyzj) |
| --------------- | --------- | ------------------------------------------------------------ |
| qwen-image      | 0.2元/张  | 各100张有效期：阿里云百炼开通后90天内                        |
| qwen-image-plus | 0.25元/张 | 各100张有效期：阿里云百炼开通后90天内                        |

百炼文生图不兼容OpenAI，必须使用dashscrope相关SDK

```python
import os
import requests
from http import HTTPStatus
from dotenv import load_dotenv
from urllib.parse import urlparse, unquote
from pathlib import PurePosixPath
from dashscope import ImageSynthesis

# 加载环境变量
load_dotenv()
# 获取API秘钥
api_key = os.getenv("DASHSCOPE_API_KEY")

# 文本生图
def generate_image(prompt: str):
    rsp = ImageSynthesis.call(
        api_key=api_key,
        model="qwen-image-plus",
        prompt=prompt,
        n=1,
        size='1328*1328',
        prompt_extend=True,
        watermark=True
    )
    
    print('response: %s' % rsp)
    if rsp.status_code == HTTPStatus.OK:
        # 在当前目录下保存图片
        for result in rsp.output.results:
            file_name = PurePosixPath(unquote(urlparse(result.url).path)).parts[-1]
            with open('./%s' % file_name, 'wb+') as f:
                f.write(requests.get(result.url).content)
    else:
        print('同步调用失败, status_code: %s, code: %s, message: %s' %
              (rsp.status_code, rsp.code, rsp.message))

def main():
    prompt = """
    一副典雅庄重的对联悬挂于厅堂之中，房间是个安静古典的中式布置，
    桌子上放着一些青花瓷，对联上左书“义本生知人机同道善思新”，
    右书“通云赋智乾坤启数高志远”， 横批“智启通义”，字体飘逸，
    在中间挂着一幅中国风的画作，内容是岳阳楼。
    """
    generate_image(prompt)

if __name__ == '__main__':
    main()
```

# 其他

## pytest 编写测试用例

相关依赖

```
[dependency-groups]
dev = [
    "pytest-asyncio>=1.3.0",
    "anyio>=4.11.0",
    "pytest>=8.3.5",
]
```

示例代码：

``` python
import pytest

pytestmark = pytest.mark.asyncio # 如需对异步函数进行测试，需要添加此行代码

async def test_structured():
	...
```

