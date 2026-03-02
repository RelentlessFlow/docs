# 二、Function Call

## 判断是否在语料库，不在去调用工具

```python
def function_call_new(prompt, tools):
    # 初始化变量
    prompt = prompt
    judge_words = "这个问题的答案是否在你的语料库里？\n请回答“这个问题答案在我的语料库里”或者“这个问题的答案不在我的语料库里”\n不要回答其他额外的文字"

    # 构建消息
    message = [
        {"role": "user", "content": prompt + judge_words}
    ]

    # 第一次调用模型
    response1 = client.chat.completions.create(
        model="glm-4",
        messages=message
    )

    # 判断答案是否在语料库中
    if "这个问题答案在我的语料库里" in response1.choices[0].message.content:
        # 重新构建消息，仅包含原始 prompt
        message = [
            {"role": "user", "content": prompt}
        ]
        
        # 第二次调用模型
        response2 = client.chat.completions.create(
            model="glm-4",
            messages=message
        )
```

