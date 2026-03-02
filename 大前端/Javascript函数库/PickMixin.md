```typescript
type Constructor<T = any> = new (...args: any[]) => T

/**
 * 选择性继承属性，eg：class Student extend PickMixin(Person, 'name', 'age')
 * @param Base 基类
 * @param props 要抽离的属性
 * @returns
 */
export function PickMixin<TBase extends Constructor, TPicked extends keyof InstanceType<TBase>>(
  Base: TBase,
  ...props: TPicked[]
) {
  return class extends Base {
    constructor(...args: any[]) {
      // 构建一个只包含选定属性的参数对象
      const selectedArgs = props.reduce((acc, prop, index) => {
        acc[prop] = args[index]
        return acc
      }, {} as Record<TPicked, unknown>)

      super(...Object.values(selectedArgs)) // 只传递选中的属性

      for (const key in this) {
        if (Object.prototype.hasOwnProperty.call(this, key)) {
          if (!props.includes(key as unknown as TPicked))
            delete this[key]
        }
      }
    }
  } as Constructor<Pick<InstanceType<TBase>, TPicked>>
}
```

