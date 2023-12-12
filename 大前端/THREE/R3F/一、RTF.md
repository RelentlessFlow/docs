# 一、RTF

[toc]

## 一、React Three Fiber基础

### 1. 基础场景搭建

```tsx
function App() {

  const cameraSettings = {
    fov: 1,
    zoom: 100,
    near: 0.1,
    far: 200,
    position: new Vector3(3, 2, 6)
  }

  return (
    <>
      <Canvas
        orthographic={true}
        camera={{ ...cameraSettings }}
      >
        <Experience />
      </Canvas>
    </>
  )
}
```

相机场景配置

```tsx
const cameraSettings = {
  // fov: 1,
  // zoom: 100,
  near: 0.1,
  far: 200,
  position: new Vector3(3, 2, 6)
}

<Canvas
  gl={ {
    antialias: true,
    toneMapping: ACESFilmicToneMapping,
    outputEncoding: LinearEncoding
  } }
  // orthographic={true}  // orthographic 会影响Environment组件
  camera={{ ...cameraSettings }}
  shadows={true}
  onCreated={created}
>
  <Experience />
</Canvas>
```

Experience.tsx

```tsx
import "@react-three/fiber";
import { useRef } from "react";
import { Group } from "three";
import {extend, useFrame, useThree} from "@react-three/fiber";
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import CustomObject from "./CustomObject.tsx";

extend({ OrbitControls })

export default function Experience() {

	const { camera, gl } = useThree();

	const cubeRef = useRef<any>(null!);
	const groupRef = useRef<Group>(null!);

	useFrame(() => {
		cubeRef.current.rotation.y += 0.01;
	})
    
	return <>

		{/* eslint-disable-next-line @typescript-eslint/ban-ts-comment */}
		{/* @ts-ignore */}
		<orbitControls args={ [camera, gl.domElement] } />
		<directionalLight position={ [ 1, 2, 3 ] } intensity={ 1.5 } />
		<ambientLight intensity={ 0.5 } />

		<group ref={groupRef}>
			<mesh>
				<sphereGeometry/>
				<meshStandardMaterial color={'orange'}/>
			</mesh>
			<mesh ref={cubeRef} rotation-y={Math.PI * 0.25} position-x={2} scale={1.5}>
				<boxGeometry/>
				<meshStandardMaterial color={"mediumpurple"} wireframe={false}/>
			</mesh>
			<mesh position-y={-1} rotation-x={-Math.PI * 0.5} scale={10}>
				<planeGeometry/>
				<meshStandardMaterial color={"greenyellow"}/>
			</mesh>
		</group>
	</>
}
```

### 2. 自定义Geometry

```tsx
import { DoubleSide, BufferGeometry } from "three";
import {useEffect, useMemo, useRef} from "react";

export default function CustomObject() {

	const geometryRef = useRef<BufferGeometry>(null!);

	const verticesCount = 10 * 3;
	
	const positions = useMemo(() => {
		const positions = new Float32Array(verticesCount * 3);
		for (let i = 0; i < verticesCount; i++) {
			positions[i] = (Math.random() - 0.5) * 3;
		}
		
		return positions;
	}, [verticesCount]);

	useEffect(() => {
		geometryRef.current.computeVertexNormals();
	}, []);

	return <mesh>
		<bufferGeometry ref={geometryRef}>
			<bufferAttribute
				attach={"attributes-position"}
				count={verticesCount}
				itemSize={3}
				array={positions}
			/>
		</bufferGeometry>
		<meshBasicMaterial color={"red"} side={ DoubleSide } />
	</mesh>
}
```

### 3. useFrame

```tsx
useFrame((state, delta) => {

  // delta 一直是 1.33
  console.log(delta);
  // 开始渲染时间
  console.log(state.clock.getElapsedTime());
  console.log(state.clock.elapsedTime);

  cubeRef.current.rotation.y += delta;
})
```

摄像机周期运动

```tsx
useFrame((state, delta) => {
    const angle = state.clock.elapsedTime;
    state.camera.position.x = Math.sin(angle);
    state.camera.position.z = Math.cos(angle);
    state.camera.lookAt(0, 0, 0);
})
```

让Canvas绘制得更好的一些效果

```tsx
<Canvas
    gl={ {
    	antialias: true // 抗锯齿
    } }
    orthographic={true} // 效果不详
    camera={{ ...cameraSettings }}
>
```

### 4. toneMapping (色调映射)

> https://threejs.org/docs/#api/en/constants/Renderer

CineonToneMapping，ACESFilmicToneMapping（HDR）

```
<Canvas
    gl={ {
    	antialias: true,
    	toneMapping: ACESFilmicToneMapping
    } }
	orthographic={true}
	camera={{ ...cameraSettings }}
>
```

## 二、@react-three/drei

### 1. OrbitControls

自由旋转镜头组件

```tsx
import {extend, useFrame, useThree} from "@react-three/fiber";
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

extend({ OrbitControls })

const { camera, gl } = useThree();
<orbitControls args={ [camera, gl.domElement] } />
```

↓

```tsx
import {OrbitControls} from "@react-three/drei";
<OrbitControls />
```

### 2. TransformControls

物体Transform组件（会在物体中心多出一个坐标系）

```tsx
import { TransformControls } from "@react-three/drei";
<TransformControls>
    <mesh ref={cubeRef} rotation-y={Math.PI * 0.25} position-x={2} scale={1.5}>
    	<boxGeometry/>
    	<meshStandardMaterial color={"mediumpurple"} wireframe={false}/>
    </mesh>
</TransformControls>
```

另一种写法：

```tsx
<TransformControls object={ cubeRef } />
```

**注意**

同时使用OrbitControls和TransformControls，OrbitControls要给makeDefault属性。

```tsx
<OrbitControls makeDefault={true}/>
```

**Props**

```tsx
TransformControlsProps:
	mode?: 'translate' | 'rotate' | 'scale';
```

### 3. PivotControls

效果类似TransformControls，但是好像比它好用。

```tsx
<PivotControls anchor={[2, 0, 0]} depthTest={false}>
```

**Props**

```tsx
PivotControlsProps
	scale?: number;
	lineWidth?: number;
	rotation?: [number, number, number];
	axisColors?: [string | number, string | number, string | number];
	anchor?: [number, number, number];
	depthTest?: boolean;
```

### 4. Html

创建3D字体（HTML标签）

```tsx
<mesh position-x={-2}>
    <sphereGeometry/>
    <meshStandardMaterial color={'orange'}/>
    <Html
        wrapperClass={ 'label' } // label > div { color: white }
        position={ [1, 1, 0] }
        center
        distanceFactor={ 0.01 } // 越大，字体越大
        occlude={ [ cubeRef ] } // 文字遮挡效果
    >
    	This is sphere.
    </Html>
</mesh>
```

**Generating a 3D text geometry has its limits**

1. We can notice the polygons
2. Takes a lot of CPU resources
3. Some fonts won't look very good
4. Doesn't support line breaks

### 5. Text

一个更好的，性能开销更少的文字组件，但是不支持occlude。

```tsx
<Text
	font={ '' }
    fontSize={ 1 }
    color={'salmon'}
    position-y={ 2 }
    maxWidth={ 3 }
    textAlign={ 'center' }
>
	I Love R3F
</Text>
```

### 6. Float

让一个物体 飘来飘去

```tsx
<Float speed={4}>
    <Text
        font={''}
        fontSize={ 1 }
        color={'salmon'}
        position-y={ 2 }
        maxWidth={ 3 }
        textAlign={ 'center' }
    >
    I Love R3F
    </Text>
</Float>
```

### 7. 镜面反射材质

**注意：仅可用于平面**

```tsx
<mesh rotation={[-Math.PI / 2, 0, 0]} position={[-10, 0, 25]}>
    <planeGeometry args={[250, 250]} />
    <MeshReflectorMaterial
        blur={[300, 100]}
        resolution={2048}
        mixBlur={1}
        mixStrength={80}
        roughness={1}
        depthScale={1.2}
        minDepthThreshold={0.4}
        maxDepthThreshold={1.4}
        color="#050505"
        metalness={0.5}
        mirror={0}
    />
</mesh>
```

## 三、Debugger

### 1. leva

**useControls**

```typescript
import { useControls, button } from 'leva';
const {
	position: ct_position,
	color: ct_color,
	visible: ct_visible,
} = useControls('sphere', {
	position: {
		value: { x: -2, y: 0 },
		step: 0.01,
		joystick: 'invertY'
	},
	color: '#ff0000',
	visible: true,
	myInterval: {
		min: 0,
		max: 10,
		value: [ 4, 5 ]
	},
	choice: { options: ['a', 'b', 'c'] },
	clickMe: button(() => console.log('ok'))
})
```

### 2. r3f-perf

```tsx
import { Perf } from "r3f-perf";
<Perf position={'top-left'}/>
```

### 3. useHelper

可以展示光线的路径

```tsx
import { useHelper, } from "@react-three/drei";
import { DirectionalLightHelper, DirectionalLight } from "three";

const directionalLight = useRef<DirectionalLight>(null!);
useHelper(directionalLight, DirectionalLightHelper);
```

## 三、Environment

### 1. 设置背景颜色

1. 通过 color 标签

```tsx
<Canvas
  gl={ {
    antialias: true,
    toneMapping: ACESFilmicToneMapping,
    outputEncoding: LinearEncoding
  } }
  orthographic={true}
  camera={{ ...cameraSettings }}
  shadows={true}
>
  <color args={ ['#ff0000'] } attach={"background"} />
  <Experience />
</Canvas>
```

2. 通过 onCreated 钩子函数

```tsx
const created = (state: RootState) => {
  console.log('canvas created! ');
  const { gl, scene } = state;
  gl.setClearColor('#ff0000', 1);
  scene.background = new Color('red');
}

<Canvas
  gl={ {
    antialias: true,
    toneMapping: ACESFilmicToneMapping,
    outputEncoding: LinearEncoding
  } }
  orthographic={true}
  camera={{ ...cameraSettings }}
  shadows={true}
  onCreated={created}
>
  <Experience />
</Canvas>
```

3. 通过CSS样式

```css
*, html, body {
  padding: 0;
  margin: 0;
}

html,
body,
#root {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
}
```

### 2. 配置阴影

1. 阴影参数

```tsx
{/*shadow-mapSize：阴影精度，越大精度越高*/}
{/*shadow-camera-top,right,bottom,left 阴影是否柔和，越大阴影越柔和*/}
<directionalLight
  ref={ directionalLight }
  position={ [ 1, 2, 3 ] }
  intensity={ 1.5 }
  castShadow={ true }
  shadow-mapSize={ [1024 * 4, 1024 * 4] }
  shadow-camera-near={ 1 }
  shadow-camera-far={ 10 }
  shadow-camera-top={ 200 }
  shadow-camera-right={ 200 }
  shadow-camera-bottom={ - 200 }
  shadow-camera-left={ - 200 }
/>
```

2. 阴影烘焙，在适当的场景下 添加BakeShadows组件

```tsx
<BakeShadows />
```

3. 柔和阴影`SoftShadows`

```tsx
<SoftShadows
  size={100}
  focus={0}
  samples={10}
/>
```

4. 累积阴影`AccumulativeShadows`

```tsx
<AccumulativeShadows
  position={ [ 0, - 0.99, 0 ] }
  scale={ 10 }
  color={ '#316d39' }
  opacity={ 0.8 }
  // frames={ Infinity }
  // temporal={ true }
  // blend={ 100 }
>
  <RandomizedLight
    amount={ 8 }
    radius={ 1 }
    ambient={ 0.5 }
    intensity={ 1 }
    position={ [ 1, 2, 3 ] }
    bias={ 0.001 }
  />
</AccumulativeShadows>
```

5. 接触阴影`ContactShadows`

```tsx
const {
  position: cs_position,
  color: cs_color,
  opacity: cs_opacity,
  blur: cs_blur,
} = useControls('ContactShadows', {
  position: { value: { x: 0, y: - 0.99 }, step: 0.01, joystick: 'invertY' },
  color: '#000000',
  opacity: { value: 0.5, min: 0, max: 1 },
  blur: { value: 1, min: 0, max: 10 },
  clickMe: button(() => console.log('ok'))
})

<ContactShadows
  position={ [cs_position.x, cs_position.y, 0] }
  scale={ 10 }
  resolution={ 128 }
  far={ 5 }
  color={ cs_color }
  blur={ cs_blur }
  opacity={ cs_opacity }
/>
```

### 3. 天空盒

```tsx
<Sky distance={20} />
```

### 4. 场景HDR文件

HDR文件下载：https://polyhaven.com/

```tsx
<Environment
	background
	files={ '/industrial.hdr' }
    // ground={{
	//   radius: 1,
	//   scale: 100,
	//   height: 0
	// }}
    // preset="apartment" 预设场景
/>
```

通过`suspend-react`，可将Environment转为异步组件，支持`Suspense`的方式调用

```tsx
import { suspend } from 'suspend-react'
const city = import('@pmndrs/assets/hdri/city.exr').then((module) => module.default)

<Environment files={suspend(city)} />
```

## 四、Load Models

### 1. useLoader

```tsx
import {GLTFLoader} from "three/examples/jsm/loaders/GLTFLoader.js";

const modelCyberpunk = useLoader(GLTFLoader, './cyberpunk.glb');
```

自定义加载器

https://threejs.org/docs/#examples/en/loaders/DRACOLoader

[Draco](https://google.github.io/draco/)是一个用于压缩和解压缩 3D 网格和点云的开源库。压缩后的几何图形可以明显更小，但代价是客户端设备上需要额外的解码时间。

```tsx
const modelCyberpunk = useLoader(GLTFLoader, './cyberpunk.glb', loader => {
	const dracoLoader = new DRACOLoader()
	dracoLoader.setDecoderPath('./draco/')
	loader.setDRACOLoader(dracoLoader);
});
```

### 2. Suspense

```tsx
<Suspense fallback={<PlaceHolder scale={5}/>}>
	<ModelCyberpunk />
</Suspense>
```

PlaceHolder.tsx

```tsx
const PlaceHolder = (props: MeshProps) => {
	return <mesh {...props}>
		<boxGeometry />
		<meshStandardMaterial wireframe={true} color={ 'red' } />
	</mesh>
}

export default PlaceHolder;
```

### 3. useGLTF

**Secondary Encapsulation of useLoadler（useLoadler的二次封装）**

```typescript
export declare function useGLTF<T extends string | string[]>(path: T, useDraco?: boolean | string, useMeshOpt?: boolean, extendLoader?: (loader: GLTFLoader) => void): T extends any[] ? import("three-stdlib").GLTF[] : import("three-stdlib").GLTF;
```

可选配置：useDraco，useMeshOpt，extendLoader

**Extend the useGLTF return value type（对useGLTF 的返回值类型进行拓展）**

```typescript
declare type GLTFEnhance = import('three-stdlib').GLTF & {
	nodes: Record<string, import("three").Mesh>;
	materials: Record<string, import("three").MeshStandardMaterial>;
};

const { nodes, materials } = useGLTF('/cyberpunk.glb', true) as C_GLTF;
```

**GLTF 预加载（preload）**

```typescript
// Remember to write outside the component.
useGLTF.preload('/cyberpunk.glb')
```

### 4. GLTF Clone（模型克隆）

**Object3D.clone()**

```tsx
/**
  * Returns a clone of `this` object and optionally all descendants.
  * @param recursive If true, descendants of the object are also cloned. Default `true`
  *
  * clone(recursive?: boolean): this;
  */
<primitive object={scene.clone()}></primitive>
```

**Clone Component**

https://github.com/pmndrs/drei#clone

Declarative abstraction around THREE.Object3D.clone. This is useful when you want to create a shallow copy of an existing fragment (and Object3D, Groups, etc) into your scene, for instance a group from a loaded GLTF. This clone is now re-usable, but it will still refer to the original geometries and materials.

```tsx
import {Clone} from "@react-three/drei";

<group {...props} dispose={null}>
    <Clone object={scene.clone()} position-x={ -10 }></Clone>
    <Clone object={scene.clone()} position-x={ 0 }></Clone>
    <Clone object={scene.clone()} position-x={ 10 }></Clone>
</group>
```

### 5. GLTF Animation

```tsx
const { animations: gAnimations, scene} = useGLTF('./dog.glb', true) as GLTFEnhance;
const { actions } = useAnimations(gAnimations, scene);

useEffect(() => {
  const play_dead =  actions["0|play_dead_0"]!
  const rollover =  actions["0|rollover_0"]!
  const shake =  actions["0|shake_0"]!
  const sitting =  actions["0|sitting_0"]!
  const standing =  actions["0|standing_0"]!


  shake.play();

  window.setTimeout(() => {
    rollover.play();
    rollover.crossFadeFrom(
      shake, 1, false
    )
  }, 10000)

}, []);
```

**useController**

```tsx
const { 
  animations: gAnimations, 
  scene
} = useGLTF('./dog.glb', true) as GLTFEnhance;

const { actions, names } = useAnimations(gAnimations, scene);
const { animationName } = useControls({ animationName: { options: names } })

useEffect(() => {
  const action = actions[animationName]!
  action.fadeIn(0.5).play()
  return () => { 
    action.fadeOut(0.5) 
  }
}, [animationName]);
```

### 6. Text3D

 Documentation：https://github.com/pmndrs/drei#text3d

**Example：**

```tsx
const [ matcapTexture ] = useMatcapTexture('3E2335_D36A1B_8E4A2E_2842A5', 256);

<Text3D
  font={'./Regular.json'}
  size={ 0.75 }
  height={ 0.2 }
  curveSegments={ 12 }
  bevelEnabled={ true }
  bevelThickness={ 0.02 }
  bevelSize={ 0.02 }
  bevelOffset={ 0 }
  bevelSegments={ 5 }
>
```

The purpose of bevel-ralated properties is to make the font smoother.

bevel 的作用是让字体变得更加圆滑。

font属性需要填写一个被称作 typeface.json的字体文件，可在这个网站 https://gero3.github.io/facetype.js/ 将原始的ttf文件经过转化后得到。

The font props requires filling in a font file called typeface.json，which can be obtained by converting the orignal ttf file on  https://gero3.github.io/facetype.js website. 

### 7. useMatcapTexture

https://github.com/pmndrs/drei#usematcaptexture

The built in Texture can use in testing, not in the production environment.

内置的Texture，可用于测试，别使用在生产环境。

```typescript
/**
  * The name of seconds parameters is format, we can choose between 64, 128, 256, 512, 1024
  * In our case, 256 is more than enough and you should try to use the smallest possible size   for performance reasons.
  */
const [ matcapTexture ] = useMatcapTexture('3E2335_D36A1B_8E4A2E_2842A5', 256);
```

### 8. Multiple model processing

You shoud write the geometry, materal in mesh property when repeatedly rendering a model of the same geometry with the same materal. It performance better this way.

```tsx
{
	[...Array(100)].map((_, index) =>
		<mesh
			key={new Date().toString() + index}
			position={[
				(Math.random() - 0.5) * 10,
				(Math.random() - 0.5) * 10,
				(Math.random() - 0.5) * 10,
			]}
			scale={0.2 + Math.random() * 0.2}
			rotation={[
				Math.random() + Math.PI,
				Math.random() + Math.PI,
				Math.random() + Math.PI,
			]}
			geometry={torusGeometry}
			material={material}
		>
			<torusGeometry args={[1, 0.6, 16, 32]} />
			<meshMatcapMaterial matcap={matcapTexture}/>
		</mesh>
	)
}
```

↓↓↓

```tsx
const Text3DHello: FC = memo(() => {
	
	const [matcapTexture] = useMatcapTexture('3E2335_D36A1B_8E4A2E_2842A5', 256);

	const [torusGeometry, setTorusGeometry] = useState<TorusGeometry>();
	const [material, setMaterial] = useState<MeshMatcapMaterial>();

	return <>
		<torusGeometry ref={(torusGeometry) => setTorusGeometry(torusGeometry!)} args={[1, 0.6, 16, 32]} />
		<meshMatcapMaterial ref={(material) => setMaterial(material!) } matcap={matcapTexture}/>

		<Center>
			<Text3D
				font={'./Regular.json'}
				size={0.75}
				height={0.2}
				curveSegments={12}
				bevelEnabled={true}
				bevelThickness={0.02}
				bevelSize={0.02}
				bevelOffset={0}
				bevelSegments={5}
			>
				你好，React Three Fiber !
				<meshMatcapMaterial matcap={matcapTexture}/>
			</Text3D>
		</Center>
		{
			[...Array(100)].map((_, index) =>
				<mesh
					key={new Date().toString() + index}
					position={[
						(Math.random() - 0.5) * 10,
						(Math.random() - 0.5) * 10,
						(Math.random() - 0.5) * 10,
					]}
					scale={0.2 + Math.random() * 0.2}
					rotation={[
						Math.random() + Math.PI,
						Math.random() + Math.PI,
						Math.random() + Math.PI,
					]}
					geometry={torusGeometry}
					material={material}
				/>
			)
		}
	</>
});
```

**The better approach is to use OOP.**

```tsx
import {FC, memo, useEffect} from "react";
import {Center, Text3D, useMatcapTexture} from "@react-three/drei";
import {MeshMatcapMaterial, TorusGeometry} from "three";

const torusGeometry = new TorusGeometry(1, 0.6, 16, 32);
const material = new MeshMatcapMaterial();

const Text3DHello: FC = memo(() => {
	
	const [matcapTexture] = useMatcapTexture('3E2335_D36A1B_8E4A2E_2842A5', 256);

	useEffect(() => {
        matcapTexture.needsUpdate = true;
		material.matcap = matcapTexture;
		material.needsUpdate = true;
	}, [matcapTexture]);

	return <>

		<Center>
			<Text3D
				font={'./Regular.json'}
				size={0.75}
				height={0.2}
				curveSegments={12}
				bevelEnabled={true}
				bevelThickness={0.02}
				bevelSize={0.02}
				bevelOffset={0}
				bevelSegments={5}
			>
				你好，React Three Fiber !
				<meshMatcapMaterial matcap={matcapTexture}/>
			</Text3D>
		</Center>
		{
			[...Array(100)].map((_, index) =>
				<mesh
					key={new Date().toString() + index}
					position={[
						(Math.random() - 0.5) * 10,
						(Math.random() - 0.5) * 10,
						(Math.random() - 0.5) * 10,
					]}
					scale={0.2 + Math.random() * 0.2}
					rotation={[
						Math.random() + Math.PI,
						Math.random() + Math.PI,
						Math.random() + Math.PI,
					]}
					geometry={torusGeometry}
					material={material}
				/>
			)
		}
	</>
});

export default Text3DHello;
```

**Use useFrame and useRef to add animation.**

```tsx
const donuts = useRef<Mesh[]>([]);

useFrame((_, delta) => {
	for (const donut of donuts.current) donut.rotation.y += delta * 0.5
})

// ...
<mesh ref={(mesh) => { donuts.current[index] = mesh! }}
// ...
```

or use group tag**(not recommanded)**

```tsx
const donutsGroup = useRef<Group>(null!);

useFrame((_, delta) => {
	for (const donut of donutsGroup.current.children) donut.rotation.y += delta * 0.1
}

<group ref={ donutsGroup }>
	{ [...Array(100)].map((_, index) => <mesh 
	// ... }
```

## 五、Mouse Event

### 1. EventHandler

```tsx
const eventHandler = (event: ThreeEvent<MouseEvent>) => {
	console.log('event.uv', event.distance) // distance between camera and hit point.
	console.log('event.uv', event.uv)
	console.log('event.point', event.point) // Hit point coordinates (坐标).
	console.log('event.object', event.object)
	console.log('event.eventObject', event.eventObject) // Usually, eventObject is the same as object
	console.log('event.x', event.x) // 2D Screen coordinates of the pointer
	console.log('event.y', event.y)
	console.log('event.shiftKey', event.shiftKey)
	console.log('event.ctrlKey', event.ctrlKey)
	console.log('event.metaKey', event.metaKey) // Click while holding down command / win key.
}
```

### 2. Event Kind

- onClick
  - CLICK or CLICK with CTRL、SHIFT、COMMAND（WIN）、ALT 
  - `shiftKey,ctrlKey,metaKey,altKey`

- onContextMenu
  - RIGHT CLICK or CTRL + LEFT CLICK.
  - On a mobile, by pressing down for some time.
- onDoubleClick
  - It works bisically the same as onClick.
  - The delay between the first and second click/tap is defined by the OS

- onPointerUp
- onPointerDown
- onPointerOver and onPointerEnter
  - When the cursor or finger just went above the object
- onPointerMove
- onPointerMissed
  - When the user clicks outside of the object. ( Cannot get the event.object parameter ).

## 六、Post Processing

### 1. Install

We need tow dependencies，`@react-three/postprocessing，`postprocesssing, But for now, the only we neeed to install is `@react-three/postprocessing` since the dependency will also install `postprocesssing`.

```json
"@react-three/drei": "^9.85.1",
"@react-three/fiber": "^8.14.2",
"@react-three/postprocessing": "2.6",
"postprocessing": "~6.31.2",
"r3f-perf": "^7.1.2",
"three": "~0.151.0",
"three-stdlib": "^2.27.0"
```

### 2. multisampling 多重采样

The default value is 8.

```tsx
<EffectComposer multisampling={16} />
```

### 3. vignette 晕映

The default effect is add a black mask around the sceen.

```tsx
<Vignette offset={0.3} darkness={0.9} />
```

You can specify the blending（混合、交融） method.

```tsx
import { BlendFunction } from "postprocessing";
<Vignette
    offset={0.3}
    darkness={0.9}
    blendFunction={ BlendFunction.ALPHA }
/>
```

### 4. Glitch 失灵

Create snowflake(雪花) glitch effect like an old-fashioned TV.

```tsx
<Glitch delay={ new Vector2(1, 1) } mode={ GlitchMode.SPORADIC } />
```

Delay attribute reviews a value of type Vector2.It represents the delay time for the horizontal and vertical axes.

The same effect to other attributes. 

```tsx
delay?: import("three").Vector2;
duration?: import("three").Vector2;
strength?: import("three").Vector2;
```

Effect Mode

```tsx
mode: typeof GlitchMode[keyof typeof GlitchMode];

export enum GlitchMode {
	DISABLED,
    SPORADIC,
    CONSTANT_MILD,
    CONSTANT_WILD,
}
```

### 5. Noise 噪点

```tsx
<Noise 
    blendFunction={ BlendFunction.SOFT_LIGHT } 
    premultiply  // effect overlay
/>
```

BlendFunction

```tsx
BlendFunction.OVERLAY // 叠加
BlendFunction.SCREEN  // It doesn't work well in bright scenes
BlendFunction.SOFT_LIGHT
BlendFunction.AVERAGE
```

### 6. Bloom 

Bloom can be used to build an object glow（发光，同luminescence）effect

**1、Set material attriblue.**

Set larger value for color attriblue. 

```tsx
<meshStandardMaterial 
	color={ [ 1.5 * 30, 1 * 30, 4 * 30 ] } 
	toneMapped={ false } 
/>
```

Or set standard color, and set emissive attriblue and emissiveIntensity attibute.

```
<meshStandardMaterial 
	color={ 'white' } 
	emissive={ 'yellow' } 
	emissiveIntensity={ 10 } 
	toneMapped={ false } 
/>
```

2、Set Bloom effect component attriblue.

```tsx
<Bloom
	mipmapBlur={ true } // always true
	intensity={ 1 }
	luminanceSmoothing={ 2 } // 滤波
	luminanceThreshold={ 10 } // 阈值
/>
```

### 7. DepthOfField 景深

```tsx
<DepthOfField
    focusDistance={ 0.025 }
    focalLength={ 0.025 }
    bokehScale={ 6 }
/>
```

## 七、Physics

### 1. Installation

```shell
pnpm install @react-three/rapier
```

### **2. RigidBody：刚体**

- colliders：对撞机，设置刚体碰撞形状，ball 球，cuboid 矩形，hull Mesh的船体形状，trimesh Mesh网线形状

  ```typescript
  export declare type RigidBodyAutoCollider = "ball" | "cuboid" | "hull" | "trimesh" | false;
  ```

Scene Example：

```tsx
<Physics debug={true}>

	<RigidBody colliders={'ball'} type={"dynamic"}>
		<mesh castShadow={true} position={[0, 10, 0]}>
			<sphereGeometry />
			<meshStandardMaterial color={'orange'} />
		</mesh>
	</RigidBody>

	<RigidBody colliders={'trimesh'}>
		<mesh castShadow={true} position={[0, 1, 0]} rotation={[Math.PI * 0.5, 0, 0]}>
			<torusGeometry args={[1, 0.5, 16, 32]} />
			<meshStandardMaterial color={'mediumpurple'} />
		</mesh>
	</RigidBody>

	<RigidBody type={"fixed"}>
		<mesh receiveShadow={true} position={[0, 0, 0]} scale={1}>
			<boxGeometry args={[10, 0.5, 10]}/>
			<meshStandardMaterial color={"greenyellow"}/>
		</mesh>
	</RigidBody>

</Physics>
```

You can use CuboidCollider Component to add rigid body shape manually.

```tsx
<RigidBody colliders={false} position={[0, 1, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<CuboidCollider args={[1.5, 1.5, 0.5]} />
	<CuboidCollider args={[1, 1, 1]} />
	<mesh castShadow={true}>
		<torusGeometry args={[1, 0.5, 16, 32]} />
		<meshStandardMaterial color={'mediumpurple'} />
	</mesh>
</RigidBody>
```

BallCollider, the ball shape of rigid bidy.

```tsx
<RigidBody colliders={false} position={[0, 1, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<BallCollider args={[1.5]} />
	<mesh castShadow={true}>n
		<torusGeometry args={[1, 0.5, 16, 32]} />
		<meshStandardMaterial color={'mediumpurple'} />
	</mesh>
</RigidBody>
```

 ### 3. Controll rigidbody movement

```tsx
const cubeRigid = useRef<RapierRigidBody>(null!);

const { camera } = useThree();

const cubeJump = (event: ThreeEvent<MouseEvent>) => {
	cubeRigid.current.applyImpulse({ x: 0, y: 2, z: 0 }, false)
	cubeRigid.current.applyTorqueImpulse({ x: 0, y: 1, z: 0 }, false)

	const { eventObject } = event;

	// console.log(eventObject.position)

	const [epx,epy,epz] = eventObject.position

	camera.position.set(epx, epy - 4, epz + 4);
	camera.rotation.set(0, 0, 0);
}

<Physics debug={true}>

	<RigidBody
		colliders={'cuboid'}
		type={"dynamic"}
		ref={cubeRigid}
	>
		<mesh
			castShadow={true}
			position={[0, 10, 0]}
			onClick={cubeJump}
		>
			<boxGeometry/>
			<meshStandardMaterial color={'orange'} />
		</mesh>
	</RigidBody>

	<RigidBody type={"fixed"}>
		<mesh receiveShadow={true} position={[0, 0, 0]} scale={1}>
			<boxGeometry args={[10, 0.5, 10]}/>
			<meshStandardMaterial color={"greenyellow"}/>
		</mesh>
	</RigidBody>

</Physics>
```

### 4. grvity 重力

You can set the gravity size and direction.

```tsx
<Physics
  debug={true}
  gravity={[0, -1.6, 0]}
>
```

### 5. gravityScale，restitution，friction

- gravityScale 重力倍率
- restitution 恢复原状
- friction 摩擦力（摩擦力是两个对象作用）

```tsx
<RigidBody
    colliders={'cuboid'}
    type={"dynamic"}
    ref={cubeRigid}
    gravityScale={ 1 }
    restitution={ 1 }
>
```

### 6. RigidBody mass 刚体重力

```tsx
const cubeRigid = useRef<RapierRigidBody>(null!);
const cubeMesh = useRef<Mesh>(null!);
const cubeJump = (_: ThreeEvent<MouseEvent>) => {
	const mass = cubeRigid.current.mass();
	cubeRigid.current.applyImpulse({ x: 0, y: 5 * mass, z: 0 }, false)
	cubeRigid.current.applyTorqueImpulse({ x: 0, y: 1 * mass, z: 0 }, false)
}
return <Physics
	debug={true}
	gravity={[0, -8, 0]}
>
    <RigidBody
        colliders={false}
        type={"dynamic"}
        ref={cubeRigid}
        gravityScale={ 1 }
        restitution={ 1 }
        friction={1}
    >
        <CuboidCollider
            args={[0.5, 0.5, 0.5]}
            position={[0, 10, 0]}
            mass={10}
        />
        <mesh
            ref={cubeMesh}
            castShadow={true}
            position={[0, 10, 0]}
            onClick={cubeJump}
        >
            <boxGeometry/>
            <meshStandardMaterial color={'orange'} />
        </mesh>
    </RigidBody>
</Physics>
```

