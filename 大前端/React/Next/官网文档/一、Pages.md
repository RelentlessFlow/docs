# 一、Pages 页面

## 构建新页面

1. 在创建时不适用App Router
2. 创建了一个命名为 `pages/about.js` 的文件并导出（export）

路由是约定式路由，pages下文件名即为路由名

### 嵌套路由

若使用嵌套路由，新建文件夹a，在文件夹下创建b.jsx，路由即为a/b

### 动态路由

Next.js 支持具有动态路由的 pages（页面）。例如，如果你创建了一个命名为 `pages/posts/[id].js` 的文件，那么就可以通过 `posts/1`、`posts/2` 等类似的路径进行访问。

#### 获取动态路由中的参数

```tsx
const Post = () => {
	const router = useRouter()
	const { id } = router.query
	return <div className={'grid'}>
		<div> Router Id: {id} </div>
	</div>
}
```

## 两种形式的预渲染

- [**静态生成 （推荐）**](https://www.nextjs.cn/docs/basic-features/pages#static-generation-recommended)：HTML 在 **构建时** 生成，并在每次页面请求（request）时重用。

- [**服务器端渲染**](https://www.nextjs.cn/docs/basic-features/pages#server-side-rendering)：在 **每次页面请求（request）时** 重新生成 HTML。

### 静态生成（Static Generation）

**两个关键函数**

- 您的页面 **内容** 取决于外部数据：使用 `getStaticProps`

- 你的页面 **paths（路径）** 取决于外部数据：使用 `getStaticPaths` （通常还要同时使用 `getStaticProps`）。

```tsx
import { useRouter } from 'next/router'

type CommonObj = Record<string, string> & { id : string }
type Post = { id: string, title: string, author: string }

const url = 'http://localhost:3001/posts'

// 此函数在构建时被调用
export async function getStaticPaths() {
	// 调用外部 API 获取博文列表
	const res = await fetch(url)
	const posts = await res.json() as Array<CommonObj>

	// 据博文列表生成所有需要预渲染的路径
	const paths = posts.map((post) => ({
		params: { id: String(post.id) },
	}))

	// We'll pre-render only these paths at build time.
	// { fallback: false } means other routes should 404.
	return { paths, fallback: false }
}

export const getStaticProps: GetStaticProps = async (
	{ params }
) => {
	// params 包含此片博文的 `id` 信息。
	// 如果路由是 /posts/1，那么 params.id 就是 1
	const res = await fetch(`${url}/${params!.id}`)
	const post = await res.json()

	// 通过 props 参数向页面传递博文的数据
	return { props: { post } }
}


const Post = ({ post } : {
	post: Post
}) => {
	const router = useRouter()
	const { id } = router.query
	console.log(post)
	return <div className={'grid'}>
		<div> Router Id: {id} </div>
		<div> Post Title: { post.title } </div>
		<div> Post Author: { post.author } </div>
	</div>
}

export default Post
```

### 服务端渲染（Server-side Rendering）

```tsx
export async function getServerSideProps(
	{ params } : { params: CommonObj }
) {
	// params 包含此片博文的 `id` 信息。
	// 如果路由是 /posts/1，那么 params.id 就是 1
	const res = await fetch(`${url}/${params.id}`)
	const post = await res.json()

	// 通过 props 参数向页面传递博文的数据
	return { props: { post } }
}


const Post = ({ post } : {
	post: Post
}) => {
	const router = useRouter()
	const { id } = router.query
	return <div className={'grid'}>
		<div> Router Id: {id} </div>
		<div> Post Title: { post.title } </div>
		<div> Post Author: { post.author } </div>
	</div>
}

export default Post
```

如你所见，`getServerSideProps` 类似于 `getStaticProps`，但两者的区别在于 `getServerSideProps` 在每次页面请求时都会运行，而在构建时不运行。
