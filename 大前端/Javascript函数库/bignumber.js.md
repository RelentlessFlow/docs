# bignumber.js

```typescript
import BigNumber from "bignumber.js"

const num = BigNumber.clone({ DECIMAL_PLACES:4 })

let a = num(0.3)
let b = num(0.1);
let c = a.minus(b);

console.log(c.toNumber()) // 0.2 number
console.log(typeof c.valueOf()) // string
console.log(typeof c.toString()) // string

new BigNumber(10) // 这样也行
```

