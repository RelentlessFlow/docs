# 第二部分：Three.js

[toc]

## 一、场景搭建

```typescript
function initThree() {
    // 创建一个场景
    const scene = new THREE.Scene();

    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.shadowMap.enabled = true;
    document.body.appendChild(renderer.domElement);

    const camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 100 );
    camera.position.set( 0, 0, 20);

    const controls = new OrbitControls( camera, renderer.domElement );
    controls.target.set( 0, 0, 0 );
    controls.update();
    controls.enablePan = false;
    controls.enableDamping = true;

    const cubeGeometry = new THREE.BoxGeometry(2, 2, 2);
    const cubeMaterial = new THREE.MeshStandardMaterial({ color: 0xff0000, wireframe: false });
    const cube = new THREE.Mesh(cubeGeometry, cubeMaterial);
    cube.position.z = 2;
    cube.castShadow = true;
    cube.receiveShadow = false;
    scene.add(cube);

    const sphereGeometry = new THREE.SphereGeometry(1,10,10);
    const sphereMaterial = new THREE.MeshStandardMaterial({ color: 0x00ff00, wireframe: false });
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
    sphere.name = 'sphere';
    sphere.position.z = 2;
    sphere.position.x = 5;
    sphere.castShadow = true;
    sphere.receiveShadow = false;
    scene.add(sphere);

    const planeGeometry = new THREE.PlaneGeometry(20,30);
    const planeMaterial = new THREE.MeshStandardMaterial({ color: 0xffffff });
    const plane = new THREE.Mesh(planeGeometry, planeMaterial);
    plane.receiveShadow = true;
    scene.add(plane);

    const directionalLight = new THREE.DirectionalLight( 0xffffff, 2 );
    directionalLight.position.set(0, 0, Math.PI);
    directionalLight.castShadow = true;
    scene.add(directionalLight)

    scene.fog = new THREE.Fog(0xffffff, 1, 50);

    const animation = () => {
        cube.rotation.x += 0.01;
        cube.rotation.y += 0.01;
        
        renderer.render(scene, camera);
        requestAnimationFrame(animation);
    }
    animation()
}
```

## 二、 基础组件

### 1. scene

**方法**

| 方法              | 介绍                                                        |
| ----------------- | ----------------------------------------------------------- |
| add()             | 向场景中添加对象                                            |
| remove()          | 从场景中移除一个对象                                        |
| getObjectByName() | remov()创建对象可以赋一个唯一name，通过此方法可以获取改对象 |

**属性**

| 属性             | 介绍                           |
| ---------------- | ------------------------------ |
| children         | 返回场景中所有对象的列表       |
| fog              | 设置场景中的雾化效果           |
| overrideMaterial | 强制场景中所有对象使用相同材质 |

### 2. 几何体

**创建**

```typescript
const sphereGeometry = new THREE.SphereGeometry(1,10,10);
const sphereMaterial = new THREE.MeshLambertMaterial({ color: 0x00ff00, wireframe: false });
const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
sphere.name = 'sphere';
sphere.position.x = 5;
sphere.position.z = 2;
sphere.castShadow = true;
sphere.receiveShadow = false;
scene.add(sphere);
```

**方法**

- position 位置
- rotation 旋转
- scale 缩放
- translateX
- translateY
- translateY

**赋值**

```
sphere.position.x = 5;
sphere.position.y = 0;
sphere.position.z = 2;

sphere.position.set(5,0, 2);
```

**类型定义**

```typescript
export class Object3D ... {
	....
	readonly position: Vector3;
	readonly rotation: Euler;
	readonly scale: Vector3;
}

export class Vector3 implements Vector {
    constructor(x?: number, y?: number, z?: number);

    /**
     * @default 0
     */
    x: number;

    /**
     * @default 0
     */
    y: number;

    /**
     * @default 0
     */
    z: number;
    readonly isVector3: true;

    /**
     * Sets value of this vector.
     */
    set(x: number, y: number, z: number): this;
    
    /**
     * Sets x value of this vector.
     */
    setX(x: number): Vector3;

    /**
     * Sets y value of this vector.
     */
    setY(y: number): Vector3;

    /**
     * Sets z value of this vector.
     */
    setZ(z: number): Vector3;
}
```

### 3. 正射投影相机

**类型定义**

```typescript
export class OrthographicCamera extends Camera {
   /**
     * Creates a new {@link OrthographicCamera}.
     * @remarks Together these define the camera's {@link https://en.wikipedia.org/wiki/Viewing_frustum | viewing frustum}.
     * @param left Camera frustum left plane. Default `-1`.
     * @param right Camera frustum right plane. Default `1`.
     * @param top Camera frustum top plane. Default `1`.
     * @param bottom Camera frustum bottom plane. Default `-1`.
     * @param near Camera frustum near plane. Default `0.1`.
     * @param far Camera frustum far plane. Default `2000`.
     */
    constructor(left?: number, right?: number, top?: number, bottom?: number, near?: number, far?: number);
}
```

**示例**

```
const camera = new THREE.OrthographicCamera(
      -20, 20, 20, -20, -1, 1000
);
```

### 4. 透视投影相机

**类型定义**

```typescript
export class PerspectiveCamera extends Camera {
    /**
     * Creates a new {@link PerspectiveCamera}.
     * @remarks Together these define the camera's {@link https://en.wikipedia.org/wiki/Viewing_frustum | viewing frustum}.
     * @param fov Camera frustum vertical field of view. Default `50`.
     * @param aspect Camera frustum aspect ratio. Default `1`.
     * @param near Camera frustum near plane. Default `0.1`.
     * @param far Camera frustum far plane. Default `2000`.
     */
    constructor(fov?: number, aspect?: number, near?: number, far?: number);
}
```

fov 视场（视角），aspect 宽高比，near 近面，far远面\

**示例**

```typescript
new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 100 );
```

### 5. Controls组件

.js

```javascript
import dat from "dat.gui";
import {DirectionalLight} from "three/src/lights/DirectionalLight.js";
import {PointLight} from "three/src/lights/PointLight.js";

const basicType = {
	color: {
		method: 'addColor',
		getValue: (item) => item.color.getStyle(),
		setValue: (item, value) => item.color.setStyle(value),
	},
	groundColor: {
		method: 'addColor',
		getValue: (item) => item.groundColor.getStyle(),
		setValue: (item, value) => item.groundColor.setStyle(value),
	},
	intensity: {
		extends: [0, 100],
		getValue: (item) => item.intensity,
		setValue: (item, value) => (item.intensity = +value),
	},
	distance: {
		extends: [0, 2],
		getValue: (item) => item.distance,
		setValue: (item, value) => (item.distance = +value),
	},
	angle: {
		extends: [0, Math.PI / 2],
		getValue: (item) => item.angle,
		setValue: (item, value) => (item.angle = +value),
	},
	penumbra: {
		extends: [0, 1],
		getValue: (item) => item.angle,
		setValue: (item, value) => (item.penumbra = +value),
	},
	decay: {
		extends: [0, 10],
		getValue: (item) => item.angle,
		setValue: (item, value) => (item.decay = +value),
	},
};

const itemType = {
	SpotLight: ['color', 'intensity', 'distance', 'angle', 'penumbra', 'decay'], // 聚光灯
	DirectionalLight: ['color', 'intensity'],
	AmbientLight: ['color', 'intensity'],
	DirectionalLight: ['color', 'intensity'],
	PointLight: ['color', 'intensity', 'distance'],
	HemisphereLight: ['groundColor', 'intensity'],
};

function initControls(item, camera, mesh, scene) {
	console.log(item);
	const typeList = itemType[item.type];
	const controls = {};
	if (!typeList || !typeList.length) {
		return;
	}
	const gui = new dat.GUI();

	for (let i = 0; i < typeList.length; i++) {
		const child = basicType[typeList[i]];
		if (child) {
			controls[typeList[i]] = child.getValue(item);

			const childExtends = child.extends || [];

			gui[child.method || 'add'](controls, typeList[i], ...childExtends).onChange((value) => {
				child.setValue(item, value, camera, mesh, scene, controls);
			});
		}
	}
}

export {
	basicType,
	itemType,
	initControls
};
```

.d.ts

```typescript
export const basicType: Record<string, {
	method: string
	extends: number[]
	getValue: (item : any) => void
	setValue: (item: any, value: any) => void
}> = {}

export const itemType: Record<string, string[]> = {}

export const initControls: (item: any, camera?: any, mesh?: any, scene?: any) => void = () => {}
```

### 6. 测试场景

```typescript
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { createMultiMaterialObject } from 'three/addons/utils/SceneUtils.js';


function initThree() {
    // 创建一个场景
    const scene = new THREE.Scene();

    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.shadowMap.enabled = true;
    document.body.appendChild(renderer.domElement);

    const camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 100 );
    camera.position.set( 0, 0, 20);

    const controls = new OrbitControls( camera, renderer.domElement );
    controls.target.set( 0, 0, 0 );
    controls.update();
    controls.enablePan = false;
    controls.enableDamping = true;

    const cubeGeometry = new THREE.BoxGeometry(2, 2, 2);
    const cubeMaterial = new THREE.MeshLambertMaterial({ color: 0xff0000, wireframe: false });
    const cube = new THREE.Mesh(cubeGeometry, cubeMaterial);

    cube.position.z = 2;
    cube.castShadow = true;
    cube.receiveShadow = false;
    scene.add(cube);

    const sphereGeometry = new THREE.SphereGeometry(1,10,10);
    const sphereMaterial = new THREE.MeshLambertMaterial({ color: 0x00ff00, wireframe: false });
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
    sphere.name = 'sphere';

    sphere.position.x = 5;
    sphere.position.z = 2;

    sphere.position.set(5,0, 2);

    sphere.castShadow = true;
    sphere.receiveShadow = false;
    scene.add(sphere);

    const planeGeometry = new THREE.PlaneGeometry(20,30);
    const planeMaterial = new THREE.MeshStandardMaterial({ color: 0xffffff });
    const plane = new THREE.Mesh(planeGeometry, planeMaterial);
    plane.receiveShadow = true;
    scene.add(plane);

    const spotLight = new THREE.SpotLight(0xffffff, 100);
    spotLight.position.set(0, 0, 5);
    spotLight.castShadow = true;
    scene.add(spotLight);

    const animation = () => {
        cube.rotation.x += 0.01;
        cube.rotation.y += 0.01;

        renderer.render(scene, camera);
        requestAnimationFrame(animation);
    }
    animation()
}

export {
    initThree
};
```

## 三、光源

### 1. AmbientLight

```typescript
constructor(color?: ColorRepresentation, intensity?: number);
```

环境光会均匀的照亮场景中的所有物体。

环境光不能用来投射阴影，因为它没有方向。

```typescript
// 环境光
const ambientLight = new THREE.AmbientLight(0x000000, 1);
scene.add(ambientLight);
```

### 2. PointLight

```typescript
constructor(color?: ColorRepresentation, intensity?: number, distance?: number, decay?: number);
```

从一个点向各个方向发射的光源。一个常见的例子是模拟一个灯泡发出的光。

```typescript
// 点光源
const pointLight = new THREE.PointLight(0xffffff, 100);
pointLight.position.set(0, 0, 5);
pointLight.castShadow = true;
scene.add(pointLight);
```

### 3. SpotLight

```typescript
constructor(
    color?: ColorRepresentation,
    intensity?: number,
    distance?: number,
    angle?: number,
    penumbra?: number,
    decay?: number,
);
```

光线从一个点沿一个方向射出，随着光线照射的变远，光线圆锥体的尺寸也逐渐增大。

```typescript
// 聚光灯
const spotLight = new THREE.SpotLight(0xffffff, 100);
spotLight.position.set(0, 0, 5);
spotLight.castShadow = true;
scene.add(spotLight);
initControls(spotLight);
```

### 4. DirectionalLight

```typescript
constructor(color?: ColorRepresentation, intensity?: number);
```

平行光是沿着特定方向发射的光。这种光的表现像是无限远，从它发出的光线都是平行的。常常用平行光来模拟太阳光的效果。 太阳足够远，因此我们可以认为太阳的位置是无限远，所以我们认为从太阳发出的光线也都是平行的。

```typescript
// 直射光、太阳光
const directionalLight = new THREE.DirectionalLight( 0x000000, 1 );
directionalLight.position.set(0, 0, Math.PI);
directionalLight.castShadow = true;
scene.add(directionalLight);
```

### 5. HemisphereLight（半球光）

```typescript
constructor(skyColor?: ColorRepresentation, groundColor?: ColorRepresentation, intensity?: number);
```

光源直接放置于场景之上，光照颜色从天空光线颜色渐变到地面光线颜色。

半球光不能投射阴影。

skyColor只能在构造函数里修改

```typescript
// 半球光
const hemisphereLight = new THREE.HemisphereLight(0x000000, 0x00ff00, 10);
hemisphereLight.position.set(-10, 10, 90);
scene.add(hemisphereLight);
```

### 6. RectAreaLight

平面光光源从一个矩形平面上均匀地发射光线。这种光源可以用来模拟像明亮的窗户或者条状灯光光源。

## 四、材质

### 1. 基础材质

不会对光源做出反应

| 名称                           | 描述                                   |
| ------------------------------ | -------------------------------------- |
| 网络基础材质 MeshBasicMaterial | 基础材质，显示几何体线框或添加简单颜色 |
| 网络深度材质 MeshDepthMaterial | 根据网格到相机的距离，决定如何染色     |
| 网络法向材质 MeshNormalMateria | 根据物体表面法向向量计算               |

### 2. 高级材质

郎伯材质和 phone材质 会对光源做出反应

| 名称                              | 描述                                 |
| --------------------------------- | ------------------------------------ |
| 网络郎伯材质 MeshLambertMaterial  | 一种非光泽表面的材质，没有镜面高光   |
| 网络 Phong 材质 MeshPhongMaterial | 一种用于具有镜面高光的光泽表面的材质 |
| 着色器材质 ShaderMaterial         | 使用自定义shader渲染的材质           |
| 直线基础材质 LineBasicMaterial    | 用于绘制线框样式几何体的材质         |
| 虑线材质 LineDashedMaterial       | 用于绘制虚线样式几何体的材质         |

### 3. MeshBasicMaterial

根据网格到相机的距离，决定如何染色

```typescript
 const cubeGeometry = new THREE.BoxGeometry(2, 2, 2);
 const cubeMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000, wireframe: false });
 const cube = new THREE.Mesh(cubeGeometry, cubeMaterial);
```

**控制器**

```typescript
MeshBasicMaterial: ['color', 'opacity', 'transparent', 'wireframe', 'visible'],
```

```typescript
opacity: {
    extends: [0, 1],
    getValue: (item) => item.opacity,
    setValue: (item, value) => (item.opacity = +value),
},
transparent: {
    getValue: (item) => item.transparent,
    setValue: (item, value) => (item.transparent = value),
},
wireframe: {
    getValue: (item) => item.wireframe,
    setValue: (item, value) => (item.wireframe = value),
},
visible: {
    getValue: (item) => item.visible,
    setValue: (item, value) => (item.visible = value),
}
```

### 4. MeshDepthMaterial

```typescript
constructor(parameters?: MeshDepthMaterialParameters);
```

```typescript
export interface MeshDepthMaterialParameters extends MaterialParameters {
    map?: Texture | null | undefined;
    alphaMap?: Texture | null | undefined;
    depthPacking?: DepthPackingStrategies | undefined;
    displacementMap?: Texture | null | undefined;
    displacementScale?: number | undefined;
    displacementBias?: number | undefined;
    wireframe?: boolean | undefined;
    wireframeLinewidth?: number | undefined;
}
```

没玩明白干啥的

```typescript
MeshDepthMaterial: ['opacity', 'transparent', 'wireframe', 'visible'],
```

### 5. MeshNormalMaterial

根据物体表面法向向量计算

```typescript
constructor(parameters?: MeshNormalMaterialParameters);
```

```typescript
export interface MeshNormalMaterialParameters extends MaterialParameters {
    bumpMap?: Texture | null | undefined;
    bumpScale?: number | undefined;
    normalMap?: Texture | null | undefined;
    normalMapType?: NormalMapTypes | undefined;
    normalScale?: Vector2 | undefined;
    displacementMap?: Texture | null | undefined;
    displacementScale?: number | undefined;
    displacementBias?: number | undefined;
    wireframe?: boolean | undefined;
    wireframeLinewidth?: number | undefined;

    flatShading?: boolean | undefined;
}
```

**控制器**

```
MeshNormalMaterial: ['wireframe', 'visible', 'side']
```

```typescript
side: {
    extends: ['0', '1', '2'],
    getValue: (item) => item.side,
    setValue: (item, value) => item.side = Number(value),
}
```

### 6. MeshLambertMaterial

一种非光泽表面的材质，没有镜面高光

**控制器**

```typescript
MeshLambertMaterial: [
    'opacity', 'transparent', 'wireframe', 'visible',
    'color', 'emissive',
]
```

```typescript
// 材料本身发出的颜色
emissive: {
    method: 'addColor',
    getValue: (item) => item.emissive.getStyle(),
    setValue: (item, value) => item.emissive.setStyle(value),
}
```

### 7. MeshPhongMaterial

镜面高光材质

**控制器**

```
MeshPhongMaterial: [
    'opacity', 'transparent', 'wireframe', 'visible',
    'color', 'emissive', 'specular', 'shininess'
]
```

```typescript
specular: {
    // 高光颜色
    method: 'addColor',
    getValue: (item) => item.specular.getStyle(),
    setValue: (item, value) => item.specular.setStyle(value),
},
shininess: {
    // 高光强度
    extends: [0, 100],
    getValue: (item) => item.shininess,
    setValue: (item, value) => (item.shininess = +value),
},
```

### 8. ShaderMaterial

着色器材质

**使用**

```typescript
const cubeMaterial = new THREE.ShaderMaterial({
    uniforms: {
        a: { type: 'f', value: 1.0 } as IUniform<any>,
        r: { type: 'f', value: 1.0 } as IUniform<any>,
    },
    vertexShader: `
        void main() {
            gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
    `,
    fragmentShader: `
        uniform float r;
        uniform float a;
        
        void main() {
            gl_FragColor = vec4(r,0.0,0.0,a);
        }
    `,
    transparent: true
});
```

**控制器**

```typescript
ShaderMaterial: ['red', 'alpha'],
```

```typescript
alpha: {
    extends: [0, 1],
    getValue: (item) => item.uniforms.a.value,
    setValue: (item, value) => item.uniforms.a.value = value,
},
```

### 9. 联合材质

```typescript
import { createMultiMaterialObject } from 'three/addons/utils/SceneUtils.js';

const cubeGeometry = new THREE.BoxGeometry(2, 2, 2);
const lambert = new THREE.MeshLambertMaterial({ color: 0xff0000 });
const basic = new THREE.MeshBasicMaterial({ wireframe: true });
const cube = createMultiMaterialObject(cubeGeometry, [lambert, basic]);
cube.position.z = 2;
cube.castShadow = true;
cube.receiveShadow = false;
scene.add(cube);
```

## 五、几何体

### 1. 二维几何体

| 名称                | 描述                    |
| ------------------- | ----------------------- |
| PlaneGeometry       | 二维平面                |
| PlaneBufferGeometry | 二维平面 (降低内存占用) |
| CircleGeometry      | 二维圆                  |
| ShapeGeometry       | 自定义二维图形          |

### 1. 三维几何体

| 名称                | 描述                     |
| ------------------- | ------------------------ |
| CubeGeometry        | 立方体                   |
| SphereGeometry      | 球体                     |
| CylinderGeometry    | 圆柱体                   |
| TorusGeometry       | 圆环                     |
| TorusKnotGeometry   | 纽结                     |
| PolyhedronGeometry  | 多面体，可以自定义多面体 |
| IcosahedronGeometry | 正20面体                 |
| TetrahedronGeometry | 正四面体                 |
| OctahedronGeometry  | 正八面体                 |
| TextGeometry        | 文本                     |
