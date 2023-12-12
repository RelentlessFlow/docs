# GPIO部分

## 一、对GPIO进行初始化

**GPIO的作用是将外部设备连接到单片机上**，连接上之后想使用它需要对IO端口进行初始化，包括设置输入模式、输入频率、输入模式和初始化电平。

**EG：如对一个战舰版集成的LED灯进行初始化：**

A盘>>3.ALIENTEK战舰STM32F1 V3开发板原理图>>WarShip STM32F1_V3.4_SCH.pdf

![image-20211010200449383](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20211010200449383.png)

![image-20211010200503441](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20211010200503441.png)

可以发现一个灯时E组5，一个是B组5

```c
void LED_Init(void){
	GPIO_InitTypeDef GPIO_InitStructure;
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB,ENABLE);//GPIOB
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOE,ENABLE);//GPIOE
	GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;//推挽输出
	GPIO_InitStructure.GPIO_Pin=GPIO_Pin_5;//GPIO5
	GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz;//默认50
	GPIO_Init(GPIOB,&GPIO_InitStructure);
	GPIO_SetBits(GPIOB,GPIO_Pin_5);
	GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Pin=GPIO_Pin_5;
	GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz;
	GPIO_Init(GPIOE,&GPIO_InitStructure);
	GPIO_SetBits(GPIOE,GPIO_Pin_5); //设置为1
}
```

### 常用库函数

1. `RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB,ENABLE);`//GPIOB时钟初始化

2. `GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;`//推挽输出

3. `GPIO_SetBits(GPIOE,GPIO_Pin_5);` //设置为1

4. `GPIO_ResetBits(GPIOE,GPIO_Pin_5); `//设置为0`

5. `GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;`//推挽输出

   ```c
   typedef enum
   { GPIO_Mode_AIN = 0x0,	// 模拟输入
     GPIO_Mode_IN_FLOATING = 0x04,	// 输入浮空
     GPIO_Mode_IPD = 0x28,	// 输入下拉
     GPIO_Mode_IPU = 0x48,	// 输入上拉
     GPIO_Mode_Out_OD = 0x14,	// 开漏输出
     GPIO_Mode_Out_PP = 0x10,	// 推挽式输出
     GPIO_Mode_AF_OD = 0x1C,	// 开漏输出
     GPIO_Mode_AF_PP = 0x18	// 开漏复用功能
   }GPIOMode_TypeDef;
   ```

### 综合实验一：跑马灯实验

main.c

```c
#include "stm32f10x.h"
#include  "led.h"
#include "delay.h"
int main(void){
	delay_init();
	LED_Init();
  while(1){
    GPIO_SetBits(GPIOB,GPIO_Pin_5);
    GPIO_SetBits(GPIOE,GPIO_Pin_5);	
    delay_ms(500);	
    GPIO_ResetBits(GPIOB,GPIO_Pin_5);
    GPIO_ResetBits(GPIOE,GPIO_Pin_5);
    delay_ms(500);
  }
}
// led.h见上面
```

### 综合实验二：蜂鸣器实验

A盘>>3.ALIENTEK战舰STM32F1 V3开发板原理图>>WarShip STM32F1_V3.4_SCH.pdf

![image-20231212134008959](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212134008959.png)

![image-20231212134004756](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212134004756.png)

#### 分析：

1. 根据三极管原理，BEEP输入为高电平，根据**开漏低电平，推挽式高低电平都有**的原则，因此在初始化的时候需要使用**推挽式输入**。
2. 想让蜂鸣器响点平输入为高，不响输入为低。
3. BEEP的IO接口上采用PB8连接。

beep.c

```c
void BEEP_Init(void)
{
 GPIO_InitTypeDef  GPIO_InitStructure;	
 RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);	 //使能GPIOB端口时钟
 GPIO_InitStructure.GPIO_Pin = GPIO_Pin_8;				 //BEEP-->PB.8 端口配置
 GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP; 		 //推挽输出
 GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;	 //速度为50MHz
 GPIO_Init(GPIOB, &GPIO_InitStructure);	 //根据参数初始化GPIOB.8
 GPIO_ResetBits(GPIOB,GPIO_Pin_8);//输出0，关闭蜂鸣器输出
}
```

main.c

```c
 int main(void){
	delay_init();	    	 //延时函数初始化	  
	LED_Init();		  	 	//初始化与LED连接的硬件接口
	BEEP_Init();         	//初始化蜂鸣器端口
	while(1){
		LED0=0;BEEP=0;		  
		delay_ms(300);//延时300ms
		LED0=1;BEEP=1;  
		delay_ms(300);//延时300ms
	}
 }
```

### 综合实验三：按键实验

A盘>>3.ALIENTEK战舰STM32F1 V3开发板原理图>>WarShip STM32F1_V3.4_SCH.pdf

![image-20231212133948267](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133948267.png)

![image-20231212133943485](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133943485.png)

key.c

```c
void KEY_Init(void) //IO初始化
{ 
 	GPIO_InitTypeDef GPIO_InitStructure;
 
 	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA|RCC_APB2Periph_GPIOE,ENABLE);//使能PORTA,PORTE时钟

	GPIO_InitStructure.GPIO_Pin  = GPIO_Pin_2|GPIO_Pin_3|GPIO_Pin_4;//KEY0-KEY2
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU; //设置成上拉输入
 	GPIO_Init(GPIOE, &GPIO_InitStructure);//初始化GPIOE2,3,4

	//初始化 WK_UP-->GPIOA.0	  下拉输入
	GPIO_InitStructure.GPIO_Pin  = GPIO_Pin_0;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPD; //PA0设置成输入，默认下拉	  
	GPIO_Init(GPIOA, &GPIO_InitStructure);//初始化GPIOA.0
}
// 按键扫描函数
u8 KEY_Scan(u8 mode)
{	 
	static u8 key_up=1;//按键按松开标志
	if(mode)key_up=1;  //支持连按		  
	if(key_up&&(KEY0==0||KEY1==0||KEY2==0||WK_UP==1))
	{
		delay_ms(10);//去抖动 
		key_up=0;
		if(KEY0==0)return KEY0_PRES;
		else if(KEY1==0)return KEY1_PRES;
		else if(KEY2==0)return KEY2_PRES;
		else if(WK_UP==1)return WKUP_PRES;
	}else if(KEY0==1&&KEY1==1&&KEY2==1&&WK_UP==0)key_up=1; 	    
 	return 0;// 无按键按下
}
```

main.c

```c
int main(){
	 	vu8 key=0;
	 	KEY_Init();          //初始化与按键连接的硬件接口
	 	while(1){
	 		key=KEY_Scan(0);	//得到键值
	 	}
}
```

## 二、GPIO端口复用

### 什么是端口复用？

>STM32有很多的内置外设，这些外设的外部引脚都是与GPIO复用的。也就是说，一个GPIO如果可以复用为内置外设的功能引脚，那么当这个GPIO作为内置外设使用的时候，就叫做复用。

例如串口1 的发送接收引脚是PA9,PA10，当我们把PA9,PA10不用作GPIO，而用做复用功能串口1的发送接收引脚的时候，叫端口复用。

### 端口复用配置流程

以PA9,PA10配置为串口1为例

**STM32F103ZET6.pdf**

![image-20231212133850761](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133850761.png)

**STM32中文参考手册_V10.pdf**

![image-20231212133854258](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133854258.png)

**STM32F103ZET6.pdf**

![image-20231212133904068](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133904068.png)

STM32中文参考手册_V10.pdf P110

![image-20231212133910163](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20231212133910163.png)

- GPIO端口时钟使能。`RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);`

- 复用外设时钟使能。比如你要将端口PA9,PA10复用为串口，所以要使能串口时钟。

  `RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);`

- 端口模式配置。 GPIO_Init（）函数。

  查表：《STM32中文参考手册V10》P110的表格“8.1.11外设的GPIO配置”

```c
RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);//①IO时钟使能

RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);//②外设时钟使能

//③初始化IO为对应的模式
GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9; //PA.9//复用推挽输出
GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP; 
GPIO_Init(GPIOA, &GPIO_InitStructure);
  
GPIO_InitStructure.GPIO_Pin = GPIO_Pin_10;//PA10 PA.10 浮空输入
GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;//浮空输入
GPIO_Init(GPIOA, &GPIO_InitStructure);  
```

