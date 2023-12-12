# PWM

## PWM工作流程

![image-20231212133841656](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133841656.png)

### PWM 配置项

- 定时器计数模式
  - `TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up  // 向上计数模式`
  - 计数模式选择
    - TIM_CounterMode_Up
    - TIM_CounterMode_Down
    - TIM_CounterMode_CenterAligned1
    - TIM_CounterMode_CenterAligned2
    - TIM_CounterMode_CenterAligned3
- 定时器自动装载值ARR
  - `TIM_TimeBaseStructure.TIM_Period = arr;` //设置在下一个更新事件装入活动的自动重装载寄存器周期的值
  - ARR 值越低，LED亮度越低，周期越大 范围：0-65536
- 定时器时钟频率预分频值PSC
  - `	TIM_TimeBaseStructure.TIM_Prescaler =psc;` //设置用来作为TIMx时钟频率除数的预分频值 
  - psc值越大，频率越低
- ARR，PSC决定了周期频率
  - `TIM3_PWM_Init(899,999);`	 //不分频。
  - 周期频率计算公式：PWM频率=72000000/900=80Khz
  - arr越低，亮度越低   psc越大 频率越低

