# Trim 实现

```typescript
const trim = (str: string) => {
  let start = 0;
  let end = str.length - 1;

  while (start < str.length && str[start] === ' ') start ++;
  while (end > 0 && !!str[end] && str[end] === ' ') end --;
  
  return str.substring(start, end + 1);
}
```