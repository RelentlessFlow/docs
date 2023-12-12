# THREE 函数封装

## 纹理相关

### 加载纹理

```typescript
type TextureLoaderAsync = (texturePath: string, textureLoader?: TextureLoader) => Promise<Texture>

// texture加载器Promise化
export const textureLoaderAsync: TextureLoaderAsync = (texturePath, textureLoader) => {
	return new Promise(resolve => {
		textureLoader = textureLoader ?? new TextureLoader()
		textureLoader.load(texturePath, (texture) => {
			resolve(texture)
		});
	});
    // 原生Promise方法
    // textureLoader = textureLoader ?? new TextureLoader()
	// return textureLoader.loadAsync(texturePath)
}
```

### 获取图片纹理的图片宽高比

```typescript
export const getTexturePicScale = (texture: Texture) => {
	const imageWidth = texture.image.width;
	const imageHeight = texture.image.height;
	const imageAspectRatio = imageWidth / imageHeight;
	const widthScale = 1; // 你可以设置一个基础的宽度
	const heightScale = widthScale / imageAspectRatio;

	return {
		widthScale,
		heightScale
	}
}
```

## 模型相关

### 模型加载

```typescript
// 模型异步加载
export const gltfLoadAsync = (path: string,  config?: {
	loader?: GLTFLoader | undefined
} | undefined) => {
	return new Promise<GLTF>((resolve) => {
		const loader = config?.loader ?? new GLTFLoader();
		loader.load(path, (gltf) => {
			resolve(gltf);
		})
	});
    // 原生Promise方法
    // const loader = config?.loader ?? new GLTFLoader();
	// return loader.loadAsync(path)
}
```

