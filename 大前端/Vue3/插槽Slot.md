# vue3 slot

## 默认插槽

**子组件**

```vue
<template>
  <div class="card">
    <div class="card-header">
      <h2>Card Header</h2>
    </div>
    <div class="card-body">
      <!-- 默认插槽 -->
      <slot></slot>
    </div>
    <div class="card-footer">
      <p>Card Footer</p>
    </div>
  </div>
</template>
```

**父组件**

```vue
<template>
  <Card>
    <!-- 这里是默认插槽的内容 -->
    <p>This is the content of the card. You can put any HTML here!</p>
    <button @click="handleClick">Click Me</button>
  </Card>
</template>
```

## 多插槽、具名插槽

**Card 组件：使用多插槽**

```vue
<template>
  <div class="card">
    <div class="card-header">
      <!-- 具名插槽：header -->
      <slot name="header">
        <h2>Default Card Header</h2> <!-- 默认内容 -->
      </slot>
    </div>
    <div class="card-body">
      <!-- 具名插槽：body -->
      <slot name="body">
        <p>Default Card Body Content</p> <!-- 默认内容 -->
      </slot>
    </div>
    <div class="card-footer">
      <!-- 具名插槽：footer -->
      <slot name="footer">
        <p>Default Card Footer</p> <!-- 默认内容 -->
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
// 这里可以添加相关逻辑或状态管理
</script>

<style scoped>
.card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 16px;
  margin: 16px;
}
.card-header {
  font-weight: bold;
}
.card-body {
  margin: 8px 0;
}
.card-footer {
  text-align: right;
}
</style>
```

**父组件：使用多插槽**

```vue
<template>
  <Card>
    <!-- 具名插槽：header -->
    <template v-slot:header>
      <h2>Custom Card Header</h2>
    </template>

    <!-- 具名插槽：body -->
    <template v-slot:body>
      <p>This is the content of the card. You can put any HTML here!</p>
      <button @click="handleClick">Click Me</button>
    </template>

    <!-- 具名插槽：footer -->
    <template v-slot:footer>
      <p>Custom Footer Content</p>
    </template>
  </Card>
</template>

<script setup lang="ts">
import Card from './Card.vue';

const handleClick = () => {
  alert('Button clicked!');
};
</script>
```

### 将v-slot:body改造成默认插槽

**子组件**

```vue
<template>
    <div class="card-body">
      <!-- 默认插槽 -->
      <slot>
        <p>Default Card Body Content</p> <!-- 默认内容 -->
      </slot>
    </div>
</template>
```

**父组件**

```vue
<Card>
    <!-- 具名插槽：header -->
    <template v-slot:header>
      <h2>Custom Card Header</h2>
    </template>

    <!-- 默认插槽 -->
    <p>This is the content of the card. You can put any HTML here!</p>
    <button @click="handleClick">Click Me</button>
</Card>
```

## 插槽作用域

**父组件**

```vue
<template>
  <div class="card">
    <div class="card-header">
      <slot name="header">
        <h2>Default Card Header</h2>
      </slot>
    </div>
    <div class="card-body">
      <slot name="body" v-bind="{ bodyContent, handleClick }">
        <p>Default Card Body Content</p>
      </slot>
    </div>
    <div class="card-footer">
      <slot name="footer">
        <p>Default Card Footer</p>
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { defineSlots } from 'vue';
import { defineEmits } from 'vue';

// 定义 emit 函数
const emit = defineEmits<{
  (e: 'cardClicked'): void;
}>();

const slots = defineSlots<{
  header?: {};
  body: { bodyContent: string; handleClick: () => void };
  footer?: {};
}>();

const bodyContent = "This is the body content passed from the child component.";

// 处理点击事件
const handleClick = () => {
  emit('cardClicked');
};

</script>

<style scoped>
.card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 16px;
  margin: 16px;
}
.card-header {
  font-weight: bold;
}
.card-body {
  margin: 8px 0;
}
.card-footer {
  text-align: right;
}
</style>
```

**子组件**

```vue
<template>
  <Card @cardClicked="handleCardClick">
    <!-- 具名插槽：header -->
    <template v-slot:header>
      <h2>Custom Card Header</h2>
    </template>

    <!-- 默认插槽 + 作用域插槽 -->
    <template v-slot:body="{ bodyContent, handleClick }">
      <p>{{ bodyContent }}</p>
      <button @click="handleClick">Click Me</button>
    </template>

    <!-- 具名插槽：footer -->
    <template v-slot:footer>
      <p>Custom Footer Content</p>
    </template>
  </Card>
</template>

<script setup lang="ts">
import Card from './Card.vue';

const handleCardClick = () => {
  alert('Card clicked!');
};
</script>
```

其他用法看这个贴子吧，这玩意写法有一点点多

https://www.cnblogs.com/suihung/p/16277287.html

## **写法**

1、默认插槽在具名插槽中的用法

```vue
<slot>插槽后备的内容</slot>
<slot name="content">插槽后备的内容</slot>
```

->>>

```vue
<template v-slot:default>具名插槽</template>
<!-- 具名插槽⽤插槽名做参数 -->
<template v-slot:content>内容...</template>
```

2、作用域插槽

```
<template> 
  <slot name="footer" testProps="子组件的值">
          <h3>没传footer插槽</h3>
    </slot>
</template>
```

->>>

```vue
<child> 
  <!-- 把v-slot的值指定为作⽤域上下⽂对象 -->
  <template v-slot:default="slotProps">
	来⾃⼦组件数据：{{slotProps.testProps}}
  </template>
  <template #default="slotProps">
    来⾃⼦组件数据：{{slotProps.testProps}}
  </template>
</child>
```

