# React 工具函数

## 样式相关

### 灵活的classNames

```typescript
export const classNames = (...classes: (string | null | undefined)[]) => classes.filter(Boolean).join(' ');
```

