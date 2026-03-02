```typescript
type PickMap<
  T, R extends Partial<Record<keyof T, string>>,
> = {
  [P in keyof R as Exclude<R[P], undefined>]: P extends keyof T ? T[P] : never;
}

/**
 * 从对象中取出指定的属性，并设置映射规则组成新的对象
 * @param obj 原始对象
 * @param mapper 映射规则
 * @returns 新对象
 * eg:
 * ...objectMap(classE, {
 *  name: 'className',
 *  startAt: 'classStartAt',
 *  endAt: 'classEndAt',
 * }),
 */
export function objectMap<
  T extends object, R extends Partial<Record<keyof T, string>>,
>(obj: T, mapper: R): PickMap<T, R> {
  return Object.entries(mapper).reduce((acc, [originalKey, newKey]) => {
    if (newKey && originalKey in obj) {
      // @ts-expect-error 强制类型推断
      acc[newKey] = obj[originalKey as keyof T]
    }
    return acc
  }, {} as PickMap<T, R>)
}
```

