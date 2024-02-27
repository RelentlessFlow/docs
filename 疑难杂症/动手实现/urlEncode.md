# urlEncode

```typescript
const urlEncode = (url: string) => {
	url = url.split('?')[1];
	const rs = url.split('&').map(q => q.split('='));
	return Object.fromEntries(rs);
}

export { urlEncode };
```

