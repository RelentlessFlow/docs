# Vue3 Props

[toc]

Vue3 Props支持两种写法，一种选项式、一种组合式

组合式支持两种写法，一种是类型声明，一种是运行声明，最后类型声明也会转换为运行声明。

## 选项式

```typescript
export default defineComponent({
  name: 'Button',
  components: {
    IconLoading,
  },
  props: {
    /**
     * @zh 按钮的类型，分为五种：次要按钮、主要按钮、虚框按钮、线性按钮、文字按钮。
     * @en Button types are divided into five types: secondary, primary, dashed, outline and text.
     * @defaultValue 'secondary'
     */
    type: {
      type: String as PropType<ButtonTypes>,
    },
    /**
     * @zh 按钮的形状
     * @en Button shape
     */
    shape: {
      type: String as PropType<BorderShape>,
    },
    /**
     * @zh 按钮的状态
     * @en Button state
     * @values 'normal','warning','success','danger'
     * @defaultValue 'normal'
     */
    status: {
      type: String as PropType<Status>,
    },
   //...
```

## 组件式API

defineProps支持两种声明，要么使用运行时声明，要么使用类型声明。

**运行时写法**

```typescript
export const buttonProps = {
  type: {
    type: String,
    values: buttonTypes,
    default: 'default',
  },
  disabled: {
    type: Boolean,
    default: () => false,
  },
  icon: {
    type: String,
  },
} as const

const props = defineProps(buttonProps);
```

如果使用运行时写法，还想要标注复杂类型参考下面两篇文章：

Props类型工具：https://cn.vuejs.org/api/utility-types#proptype-t

类型标注指南：https://cn.vuejs.org/guide/typescript/options-api#typing-component-props

**类型声明写法**

```typescript
const props = withDefaults(defineProps<Props>(), {
  msg: 'hello',
  labels: () => ['one', 'two']
})
```

使用类型声明的时候，静态分析会自动生成等效的运行时声明，从而在避免双重声明的前提下确保正确的运行时行为。

具体使用时候还会有一些限制：

- 使用类型声明的时候，静态分析会自动生成等效的运行时声明，从而在避免双重声明的前提下确保正确的运行时行为。

  - 在开发模式下，编译器会试着从类型来推导对应的运行时验证。例如这里从 `foo: string` 类型中推断出 `foo: String`。如果类型是对导入类型的引用，这里的推导结果会是 `foo: null` (与 `any` 类型相等)，因为编译器没有外部文件的信息。
  - 在生产模式下，编译器会生成数组格式的声明来减少打包体积 (这里的 props 会被编译成 `['foo', 'bar']`)。

- 在 3.2 及以下版本中，`defineProps()` 的泛型类型参数只能使用类型字面量或者本地接口的引用。

  这个限制已经在 3.3 版本中解决。最新版本的 Vue 支持在类型参数的位置引用导入的和有限的复杂类型。然而，由于类型到运行时的转换仍然基于 AST，因此并不支持使用需要实际类型分析的复杂类型，例如条件类型等。你可以在单个 prop 的类型上使用条件类型，但不能对整个 props 对象使用。

**其他：**

Props 校验：https://cn.vuejs.org/guide/components/props.html#prop-validation

响应式 Props 解构 ：https://cn.vuejs.org/guide/components/props.html#reactive-props-destructure

Props细节：https://cn.vuejs.org/guide/components/props.html#prop-passing-details

### TS开发下的一些细节

1. 如果你在另外一个TS文件中编写Props类型，导入下ComponentPropsOptions类型，它是defineProps函数参数props的具体类型，这样就有类型提示了。
2. Props校验支持工厂模式，Vue官网是这样写的。

```
propF: {
  type: Object,
  // 对象或数组的默认值
  // 必须从一个工厂函数返回。
  // 该函数接收组件所接收到的原始 prop 作为参数。
  default(rawProps) {
    return { message: 'hello' }
  }
},
```

这种写法，rawProps是没类型的

最佳实践

```
import type { ComponentPropsOptions, ExtractPropTypes, PropType } from 'vue'
import type icon from './icon.vue'

export type ButtonTypes = 'default' | 'primary' | 'success' | 'warning' | 'danger';
export type ButtonSize = 'small' | 'default' | 'large'

export const buttonProps = {
  disabled: {
    type: Boolean,
    default: () => {}
  },
  type: {
    type: String as PropType<ButtonTypes>,
    default: 'default',
  },
  loading: {
    type: Boolean,
    default: () => false,
  },
  round: {
    type: Boolean,
    default: () => false,
  },
  icon: {
    type: String,
  },
  size: {
    type: String as PropType<ButtonSize>,
    default: 'default',
  },
  plain: {
    type: Boolean,
    default: false,
  },
  ikun: {
    type: Boolean,
    default: false,
  }
} satisfies ComponentPropsOptions

export type ButtonProps = ExtractPropTypes<typeof buttonProps>
export type ButtonInstance = InstanceType<typeof icon>


```

