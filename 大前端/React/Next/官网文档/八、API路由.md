# 八、NEXTjs Route Handlers

## Pages Router

### HTTP Methods

```typescript
import type { NextApiRequest, NextApiResponse } from 'next'
 
export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'POST') {
    // Process a POST request
  } else {
    // Handle any other HTTP method
  }
}
```

### TypeScript types

```typescript
import type { NextApiRequest, NextApiResponse } from 'next'
 
type ResponseData = {
  message: string
}
 
export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<ResponseData>
) {
  res.status(200).json({ message: 'Hello from Next.js!' })
}
```

### 动态路由

API Routes support [dynamic routes](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes), and follow the same file naming rules used for `pages/`.

**pages/api/post/[pid].ts**

```typescript
import type { NextApiRequest, NextApiResponse } from 'next'
 
export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const { pid } = req.query
  res.end(`Post: ${pid}`)
}
```

## App Router

目前API没有 Page Router 丰富

### 获取路由查询参数

```typescript
import { type NextRequest } from 'next/server'
 
export function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const query = searchParams.get('query')
  // query is "hello" for /api/search?query=hello
}
```

动态路由

https://nextjs.org/docs/app/building-your-application/routing/route-handlers#dynamic-route-segments

app/artical/[slug]/route.js

```typescript
import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest, { params: { slug: id } }: { params: { slug: string }}) {
  // simulate IO latency
  await new Promise((r) => setTimeout(r, 500))
  return NextResponse.json({ data: `书籍编号: ${id}` })
}
```