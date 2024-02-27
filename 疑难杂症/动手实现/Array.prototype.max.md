# Array.prototype.max

array.polyfill.ts

```typescript
interface Array<T> {
	max: Max
}

type Max = (...args: number[]) => number

Array.prototype.max = function () {
	const args = [...this]
	if(args.length === 0) throw new Error('function max must passes at least two parameters.')

	let max = args[0];

	for (let i = 1; i < args.length - 1; i ++) {
		const next = args[i];
		if(next > max) max = next;
	}

	return max
};

// main.ts
import './array.extensions'

const arr = [1,2,34342,3213];
const max = arr.max() // 34342
```

