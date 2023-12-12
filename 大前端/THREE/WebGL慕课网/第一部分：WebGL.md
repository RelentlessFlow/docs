

# 第一部分：WebGL

[toc]

## 一、WebGL

**WebGL 与 Canvas区别：**

1. `<canvas></canvas>`是个标签
2. 二维用Canvas API，三维用WebGL API
3. Canvas API，通过CanvasRederingContext2D接口，`canvas.getContext('2d')`
4. WenGL API，通过WebGLRenderingContext接口，`canvas.getContext('webgl')`

WebGL程序结构包含着色器：GLSL ES，以字符串形式存在JavaScript中

**WebGL开源框架**

Three.js、Babylon.js、ClayGL、PlayCanvas、WebGLStudio

### 1. 最短的webgl程序

```javascript
const ctx = document.getElementById('canvas');
const gl = ctx.getContext('webgl');

gl.clearColor(1.0, 0.0, 0.0, 1.0); // RGBA
gl.clear(gl.COLOR_BUFFER_BIT) // 清空颜色缓存
```

其他几种

```javascript
gl.clear(gl.DEPTH_BUFFER_BIT)
gl.clearDepth(1.0)

gl.clear(gl.STENCIL_BUFFER_BIT)
gl.clearStencil()
```

### 2. 绘制一个点

```html
    <script>
    function initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE) {
        // 创建着色器
        const vertexShader = gl.createShader(gl.VERTEX_SHADER);
        const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);

        gl.shaderSource(vertexShader, VERTEX_SHADER_SOURCE); // 指定顶点着色器的源码
        gl.shaderSource(fragmentShader, FRAGMENT_SHADER_SOURCE); // 指定片元着色器的源码

    // 编译着色器
        gl.compileShader(vertexShader);
        gl.compileShader(fragmentShader);

    // 创建一个程序对象
        const program = gl.createProgram();

        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);

        gl.linkProgram(program);

        gl.useProgram(program);

        return program;
    }
    </script>
    <script>

        const ctx = document.getElementById('canvas');
        const gl = ctx.getContext('webgl');

        // 着色器
        const VERTEX_SHADER_SOURCE = `
            void main() {
                // 要绘制的点的坐标
                gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
                // 点的大小
                gl_PointSize = 10.0;
            }
        `; // 顶点着色器

        // gl_Position：vec4(0.0, 0.0, 0.0, 1.0);   x, y, z, w齐次坐标 （x/w, y/w, z/w）
        // gl_FragColor：vec4(1.0, 0.0, 0.0, 1.0);  r, g, b, a

        const FRAGMENT_SHADER_SOURCE = `
            void main() {
                gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
            }
        `; // 片元着色器

        initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

        // 执行绘制

        // 要绘制的图形时什么，从哪个开始， 使用几个顶点
        gl.drawArrays(gl.POINTS, 0, 1);
    </script>
```

### 3. webgl绘制流程

1. 获取canvas上下文
2. 获取webgl绘图上下文
3. 初始化顶点着色器程序
4. 初始化片元着色器程序
   1. 创建订单着色器
   2. 创建片元着色器
   3. 关联着色器和着色器源码
   4. 编译着色器
   5. 创建program
   6. 关联着色器和program
   7. 使用program

### 4. attribute变量

attribute变量，可以用在顶点着色器中，动态的修改/获取 顶点信息。

```javascript
const VERTEX_SHADER_SOURCE = `
    // 存储限定符，类型，变量名 分号!
    // 只传递顶点数据
    attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
    void main() {
        // 要绘制的点的坐标
        gl_Position = aPosition;
        // 点的大小
        gl_PointSize = 10.0;
    }
`; // 顶点着色器
```

获取attribute变量存储地址

```javascript
gl.getAttribLocation(program, 'aPosition');
```

设置attribute

```javascript
const aPosition = gl.getAttribLocation(program, 'aPosition');
gl.vertexAttrib4f(aPosition, 0.5, 0.5, 0.0, 1.0);
gl.drawArrays(gl.POINTS, 0, 1);
```

lib.dom.d.ts

```typescript
vertexAttrib1f(index: GLuint, x: GLfloat): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib1fv(index: GLuint, values: Float32List): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib2f(index: GLuint, x: GLfloat, y: GLfloat): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib2fv(index: GLuint, values: Float32List): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib3f(index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib3fv(index: GLuint, values: Float32List): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib4f(index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat): void;
/** [MDN Reference](https://developer.mozilla.org/docs/Web/API/WebGLRenderingContext/vertexAttrib) */
vertexAttrib4fv(index: GLuint, values: Float32List): void;
```

### 5. attribute通过鼠标绘图案例

```html
<script>
    const ctx = document.getElementById('canvas');
    const gl = ctx.getContext('webgl');

    const VERTEX_SHADER_SOURCE = `
        // 存储限定符，类型，变量名 分号!
        // 只传递顶点数据
        attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
        void main() {
            // 要绘制的点的坐标
            gl_Position = aPosition;
            // 点的大小
            gl_PointSize = 10.0;
        }
    `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
        void main() {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
    `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);

    gl.drawArrays(gl.POINTS, 0, 1);

    const points = [];

    ctx.onclick = function (ev) {
        const { clientX, clientY } = ev;
        const { x, y, height, width } = ev.target.getBoundingClientRect();

        const canvasX = clientX - x;
        const canvasY = clientY - y;

        const attr_x = (canvasX - width / 2) / (width / 2)
        const attr_y = -(canvasY - height / 2) / (height / 2)

        points.push({ attr_x, attr_y });

        // 返回变量的存储地址
        const aPosition = gl.getAttribLocation(program, 'aPosition');

        for (let i = 0; i < points.length; i++) {
            // 为attribute坐标赋值
            gl.vertexAttrib4f(aPosition, points[i].attr_x, points[i].attr_y, 0.0, 1.0);

            gl.drawArrays(gl.POINTS, 0, 1);
        }
    }
</script>
```

### 6. uniform变量

`precision mediump float;` 设置精度，highp高精度，lowp低精度

`uniform vec4 uColor;` uniform 变量

`gl.uniform4f(uColor, 1.0, 0.0, 0.0, 1.0)` 设置uniform  变量

uniform 四种赋值方式
第一种 vector4

```javascript
const ctx = document.getElementById('canvas');
const gl = ctx.getContext('webgl');

const VERTEX_SHADER_SOURCE = `
    // 存储限定符，类型，变量名 分号!
    // 只传递顶点数据
    attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
    void main() {
        // 要绘制的点的坐标
        gl_Position = aPosition;
        // 点的大小
        gl_PointSize = 10.0;
    }
`; // 顶点着色器

const FRAGMENT_SHADER_SOURCE = `
    // 中精度
    precision mediump float;
    uniform vec4 uColor;
    void main() {
        gl_FragColor = uColor;
    }
`; // 片元着色器

const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

const aPosition = gl.getAttribLocation(program, 'aPosition');
gl.vertexAttrib4f(aPosition, 0.5, 0.5, 0.0, 1.0);

const uColor = gl.getUniformLocation(program, 'uColor');
gl.uniform4f(uColor, 1.0, 0.0, 0.0, 1.0)

gl.drawArrays(gl.POINTS, 0, 1);
```

vector3

```javascript
const FRAGMENT_SHADER_SOURCE = `
    // 中精度
    precision mediump float;
    uniform vec3 uColor;
    void main() {
        gl_FragColor = vec4(uColor.r, uColor.g, uColor.b, 1.0);
    }
`; // 片元着色器

const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

const aPosition = gl.getAttribLocation(program, 'aPosition');
gl.vertexAttrib4f(aPosition, 0.5, 0.5, 0.0, 1.0);

const uColor = gl.getUniformLocation(program, 'uColor');
gl.uniform3f(uColor, 1.0, 0.0, 0.0)

gl.drawArrays(gl.POINTS, 0, 1);
```

vector2 同上

vector1

```javascript
const FRAGMENT_SHADER_SOURCE = `
    // 中精度
    precision mediump float;
    uniform float uColor;
    void main() {
        gl_FragColor = vec4(uColor, 0, 0, 1.0);
    }
`; // 片元着色器

const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

const aPosition = gl.getAttribLocation(program, 'aPosition');
gl.vertexAttrib4f(aPosition, 0.5, 0.5, 0.0, 1.0);

const uColor = gl.getUniformLocation(program, 'uColor');
gl.uniform1f(uColor, 1.0);

gl.drawArrays(gl.POINTS, 0, 1);
```

### 7.  缓冲区对象

**缓冲区对象**

**缓冲区对象**是WebGL系统中的一块**内存区域**，可以一次性的向缓冲区对象中**填充大量的顶点数据**，然后将这些数据保存在其中，供顶点着色器使用。

**类型化数组-Float32Array**

在WebGL中，需要处理大量的相同类型数据，引入类型化数组，程序可以预知数组中的数据类型， 提高性能。

**类型化数组种类**

- Int32Array
- UInt32Array
- Float32Array
- Float64Array

### 8. 使用缓冲区

`gl.createBuffer()` 创建缓冲区

`gl.bindBuffer(gl.ARRAY_BUFFER, buffer);` 绑定缓冲区 类型数组

- gl.ARRAY_BUFFER 缓冲区存储的是**顶点的数据**

- gl.ELEMENT_ARRAY_BUFFER 缓冲区存储的是**顶点的索引值**

`gl.bufferData()` 

```
bufferData(target: GLenum, data: BufferSource | null, usage: GLenum): void;
```

- target：同gl.bindBuffer
- data：写入缓冲区的顶点数据，如程序中的points
- type(usage): 
  - gl.STATIC_DRAO：写入一次，多次绘制
  - gl.STEAM_DRAW：写入一次，绘制若干次
  - gl.DYNAMIC_DRAW：写入多次，绘制多次

`gl.vertexAttribPointer(location, size, type, normalized, stride, offset)`

```
vertexAttribPointer(index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, offset: GLintptr): void;
```

- location：attribute 变量的存储位置
- size：指定每个顶点所使用数据的个数
- type：指定数据格式
  - gl.FLOAT
  - gl.UNSIGEND_BUTE：无符号字节
  - gl.SHORT 短整型
  - gl.UNSIGEND_SHORT
  - gl.INT 整形
  - gl.UNSIGEND_INT 整形
- normalized：表示是否将数据归一化到 [0, 1] [-1, 1] 这个区间
- stride：两个相邻顶点之间的字节数
- offset：数据偏移量

#### 缓冲区使用流程

**示例程序**

```html
<script>
	// 获取Canvas元素，初始化程序对象
    const ctx = document.getElementById('canvas');
    const gl = ctx.getContext('webgl');
	// 创建顶点着色器程序
    const VERTEX_SHADER_SOURCE = `
        attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
        void main() {
            // 要绘制的点的坐标
            gl_Position = aPosition;
            // 点的大小
            gl_PointSize = 10.0;
        }
    `; // 顶点着色器
    const FRAGMENT_SHADER_SOURCE = `
        void main() {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
    `; // 片元着色器
	
    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);
    const aPosition = gl.getAttribLocation(program, 'aPosition');
    // 创建顶点数据
    const points = new Float32Array([
       -0.5, -0.5,
        0.5, -0.5,
        0.0, 0.5
    ]);
    // 创建缓冲区对象
    const buffer = gl.createBuffer();
    // 绑定缓冲区对象
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    // 将数据写入缓冲区
    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);
    // 将缓冲区对象 分配给一个attribute变量
    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0 ,0);
    // 开启attribute变量
    gl.enableVertexAttribArray(aPosition);
    gl.drawArrays(gl.POINTS, 0, 3);
</script>
```

#### 多数据区和数据偏移

```html
<script>
    const ctx = document.getElementById('canvas');
    const gl = ctx.getContext('webgl');

    const VERTEX_SHADER_SOURCE = `
        attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
        attribute float aPointSize;
        void main() {
            // 要绘制的点的坐标
            gl_Position = aPosition;
            // 点的大小
            gl_PointSize = aPointSize;
        }
    `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
        void main() {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
    `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);
    const aPosition = gl.getAttribLocation(program, 'aPosition');
    const aPointSize = gl.getAttribLocation(program, 'aPointSize');

    const points = new Float32Array([
       -0.5, -0.5, 10.0,
        0.5, -0.5, 20.0,
        0.0, 0.5, 30.0
    ]);
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);
	
    // 获取 一个点 的 字节大小
    const BYTES = points.BYTES_PER_ELEMENT;

    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, BYTES * 3 ,0);
    gl.enableVertexAttribArray(aPosition);
	
    // BYTES * 3 代表 一个点的数据 占 3个字节
    // BYTES * 2 代表 点大小的数据 有两个 偏移量
    gl.vertexAttribPointer(aPointSize, 1, gl.FLOAT, false, BYTES * 3 ,BYTES * 2);
    gl.enableVertexAttribArray(aPointSize);

    gl.drawArrays(gl.POINTS, 0, 3);
</script>
```

### 9. 实现多种图形绘制

| 值                | 作用   | 说明                                       |
| ----------------- | ------ | ------------------------------------------ |
| gl.POINTS         | 点     | 一系列点                                   |
| gl.LINES          | 线段   | 一系列单独的线段                           |
| gl.LINE_LOOP      | 闭合线 | 一系列连接的线段，结束时，会闭合众点和起点 |
| gl.LINE_STRIP     | 线条   | 一系列连接的线段，不会闭合众点和起点       |
| gl.TRIANGLE       | 三角形 | 一系列单独的三角形                         |
| gl.TRIANGLE_STRIP | 三角形 | 一系列条带状的三角形                       |
| gl.TRIANGLE_FUN   | 三角形 | 飘带装三角形                               |

```javascript
<script>
    const ctx = document.getElementById('canvas');
    const gl = ctx.getContext('webgl');

    const VERTEX_SHADER_SOURCE = `
        attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
        attribute float aPointSize;
        void main() {
            // 要绘制的点的坐标
            gl_Position = aPosition;
            // 点的大小
            gl_PointSize = aPointSize;
        }
    `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
        void main() {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
    `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);
    const aPosition = gl.getAttribLocation(program, 'aPosition');
    const aPointSize = gl.getAttribLocation(program, 'aPointSize');

    const points = new Float32Array([
       -0.5, -0.5,
        0.5, -0.5,
        -0.5, 0.5,
        0.5, 0.5
    ]);
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);

    const BYTES = points.BYTES_PER_ELEMENT;

    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, BYTES * 2 ,0);
    gl.enableVertexAttribArray(aPosition);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
</script>
```

### 10. 通过着色器实现图形偏移

```html
<script>
    const ctx = document.getElementById('canvas');
    const gl = ctx.getContext('webgl');

    const VERTEX_SHADER_SOURCE = `
        attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
        attribute float aPointSize;
        attribute float aTranslate;
        void main() {
            // 要绘制的点的坐标，通过aPosition和aTranslate共同确定位置
            gl_Position = vec4(aPosition.x + aTranslate, aPosition.y, aPosition.z, 1.0);
            // 点的大小
            gl_PointSize = aPointSize;
        }
    `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
        void main() {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
    `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);
    const aPosition = gl.getAttribLocation(program, 'aPosition');
    const aPointSize = gl.getAttribLocation(program, 'aPointSize');
    const aTranslate = gl.getAttribLocation(program, 'aTranslate');


    const points = new Float32Array([
       -0.5, -0.5,
        0.5, -0.5,
        0, 0.5,
    ]);
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);

    const BYTES = points.BYTES_PER_ELEMENT;

    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, BYTES * 2 ,0);
    gl.enableVertexAttribArray(aPosition);

    let x = -1;
    setInterval(() => {
        x += 0.01;
        if(x > 1) x = -1;
        gl.vertexAttrib1f(aTranslate, x);
        gl.drawArrays(gl.TRIANGLES, 0, 4);
    }, 60);
</script>
```

### 11. 通过着色器实现图形缩放

思路同图形偏移

```html
<script>
	// ...
	const VERTEX_SHADER_SOURCE = `
        attribute vec4 aPosition; // 默认值 vec4(0.0, 0.0, 0.0, 1.0);
        attribute float aPointSize;
        attribute float aScale;
        void main() {
            // 要绘制的点的坐标，通过aPosition和aTranslate共同确定位置
            gl_Position = vec4(aPosition.x * aScale, aPosition.y, aPosition.z, 1.0);
            // 点的大小
            gl_PointSize = aPointSize;
        }
    `; // 顶点着色器
    
    // ...
    const aScale = gl.getAttribLocation(program, 'aScale');
    // ..
    
    let x = -1;
    setInterval(() => {
        x += 0.01;
        if(x > 1) x = -1;
        gl.vertexAttrib1f(aScale, x);
        gl.drawArrays(gl.TRIANGLES, 0, 4);
    }, 60);
</script>
```

### 12.通过着色器实现图形旋转

**关键代码**

```
gl_Position.x = aPosition.x * cos(deg) - aPosition.y * sin(deg);
gl_Position.y = aPosition.x * sin(deg) + aPosition.y * cos(deg);

requestAnimationFrame(animation)
```

**示例代码**

```html
<script>

    const ctx = document.getElementById('canvas')

    const gl = ctx.getContext('webgl')

    // 创建着色器源码
    const VERTEX_SHADER_SOURCE = `
    attribute vec4 aPosition;
    attribute float deg;
    void main() {
      gl_Position.x = aPosition.x * cos(deg) - aPosition.y * sin(deg);
      gl_Position.y = aPosition.x * sin(deg) + aPosition.y * cos(deg);
      gl_Position.z = aPosition.z;
      gl_Position.w = aPosition.w;
    }
  `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
    void main() {
      gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    }
  `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

    const aPosition = gl.getAttribLocation(program, 'aPosition');
    const deg = gl.getAttribLocation(program, 'deg');

    const points = new Float32Array([
        -0.5, -0.5,
        0.5, -0.5,
        0.0,  0.5,
    ])

    const buffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);

    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0, 0);

    gl.enableVertexAttribArray(aPosition)

    let x = 1;
    function animation() {
        x += -0.01;
        gl.vertexAttrib1f(deg, x);
        gl.drawArrays(gl.TRIANGLES, 0, 3);

        requestAnimationFrame(animation)
    }
    animation();
</script>
```

### 13. 平移矩阵

#### 核心算法

```javascript
function getTranslateMatrix(x = 0, y = 0, z = 0) {
    return new Float32Array([
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
            x,   y,   z,   1,
    ]);
}
```

#### 示例工程

```html
<script>

    const ctx = document.getElementById('canvas')

    const gl = ctx.getContext('webgl')

    // 创建着色器源码
    const VERTEX_SHADER_SOURCE = `
    attribute vec4 aPosition;
    uniform mat4 mat;
    void main() {
      gl_Position = mat * aPosition;
    }
  `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
    void main() {
      gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    }
  `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

    const aPosition = gl.getAttribLocation(program, 'aPosition');
    const mat = gl.getUniformLocation(program, 'mat');

    function getTranslateMatrix(x = 0, y = 0, z = 0) {
        return new Float32Array([
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
              x,   y,   z,   1,
        ]);
    }

    const points = new Float32Array([
        -0.5, -0.5,
        0.5, -0.5,
        0.0,  0.5,
    ]);

    const buffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);

    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0, 0);

    gl.enableVertexAttribArray(aPosition)

    let x = -1;
    function animation() {
        x += 0.01;
        if(x > 1) x = -1;

        const matrix = getTranslateMatrix(x, x);

        gl.uniformMatrix4fv(mat, false, matrix);
        gl.drawArrays(gl.TRIANGLES, 0, 3);

        requestAnimationFrame(animation);
    }
    animation();
</script>
```

### 14. 矩阵变换

```javascript
// 平移矩阵
function getTranslateMatrix(x = 0,y = 0,z = 0) {
  return new Float32Array([
    1.0,0.0,0.0,0.0,
    0.0,1.0,0.0,0.0,
    0.0,0.0,1.0,0.0,
    x  ,y  ,z  , 1,
  ])
}
// 缩放矩阵
function getScaleMatrix(x = 1,y = 1,z = 1) {
  return new Float32Array([
    x  ,0.0,0.0,0.0,
    0.0,y  ,0.0,0.0,
    0.0,0.0,z  ,0.0,
    0.0,0.0,0.0, 1,
  ])
}
// 绕z轴旋转的旋转矩阵
function getRotateMatrix(deg) {
  return new Float32Array([
    Math.cos(deg)  ,Math.sin(deg) ,0.0,0.0,
    -Math.sin(deg)  ,Math.cos(deg) ,0.0,0.0,
    0.0,            0.0,            1.0,0.0,
    0.0,            0.0,            0.0, 1,
  ])
}

// 矩阵复合函数
function mixMatrix(A, B) {
  const result = new Float32Array(16);

  for (let i = 0; i < 4; i++) {
    result[i] = A[i] * B[0] + A[i + 4] * B[1] + A[i + 8] * B[2] + A[i + 12] * B[3]
    result[i + 4] = A[i] * B[4] + A[i + 4] * B[5] + A[i + 8] * B[6] + A[i + 12] * B[7]
    result[i + 8] = A[i] * B[8] + A[i + 4] * B[9] + A[i + 8] * B[10] + A[i + 12] * B[11]
    result[i + 12] = A[i] * B[12] + A[i + 4] * B[13] + A[i + 8] * B[14] + A[i + 12] * B[15]
  }

  return result;
}
```

### 15. varying变量

varying可以允许顶点着色器向片元着色器传递数据.

示例代码

```javascript
<script>
    const ctx = document.getElementById('canvas')

    const gl = ctx.getContext('webgl')

    // 创建着色器源码
    const VERTEX_SHADER_SOURCE = `
    attribute vec4 aPosition;

    varying vec4 vColor;

    void main() {
      vColor = aPosition;
      gl_Position = aPosition;
    }
  `; // 顶点着色器

    const FRAGMENT_SHADER_SOURCE = `
    precision lowp float;
    varying vec4 vColor;

    void main() {
      gl_FragColor = vColor;
    }
  `; // 片元着色器

    const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

    const aPosition = gl.getAttribLocation(program, 'aPosition');

    const points = new Float32Array([
        -0.5, -0.5,
        0.5, -0.5,
        0.0,  0.5,
    ])

    const buffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

    gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);

    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0, 0);

    gl.enableVertexAttribArray(aPosition)

    gl.drawArrays(gl.TRIANGLES, 0, 3);
</script>
```

### 16. 从顶点到图形渲染流程

1. 整体流程
   1. 顶点坐标
   2. 图元装配 gl.drawArrays() 第一个参数决定
   3. 光栅化，将装配好的图形转换成片元
      1. 剔除
      2. 裁剪
   4. 图形绘制

### 17. 纹理

#### 纹理坐标

在WebGl里需要通过纹理坐标和图形顶点坐标的映射关系来确定贴图。



<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20230908141723425.png" alt="image-20230908141723425" style="zoom:50%;" />

#### 进行Y轴反转

```
gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
```

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20230908142412907.png" alt="image-20230908142412907" style="zoom:50%;" />

#### 纹理对象

纹理对象主要用于存储纹理图像数据。

```javascript
// 创建纹理对象
const texture = gl.createTexture();

// 删除纹理对象
gl.deleteTexture(texture);
```

#### 纹理单元

Webgl是通过纹理单元来管理纹理对象，每个纹理单元管理一张纹理图像。

```javascript
// 创建纹理对象
const texture = gl.createTexture();
// 翻转 图片 Y轴
gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
// 开启一个纹理单元
gl.activeTexture(gl.TEXTURE0);
// 绑定纹理单元
gl.bindTexture(gl.TEXTURE_2D, texture);
```

#### 纹理渲染流程

##### 主要流程

1. 创建缓冲区，包含顶点数据和纹理顶点数据；

   ```javascript
   // 缓冲区顶点数据数据
   const points = new Float32Array([
     -0.5, 0.5, 0.0, 1.0, -0.5, -0.5, 0.0, 0.0, 0.5, 0.5, 1.0, 1.0, 0.5, -0.5, 1.0,
     0.0,
   ]);
   
   const buffer = gl.createBuffer();
   const BYTES = points.BYTES_PER_ELEMENT;
   gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
   gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);
   ```

2. 在顶点着色器创建用于存放 纹理的顶点数据，并将该顶点数据 传递给varying变量，以供片元着色器使用；

   着色器程序

   ```c
   attribute vec4 aPosition;
   attribute vec4 aTex;
   varying vec2 vTex;
   void main() {
   	gl_Position = aPosition;
   	vTex = vec2(aTex.x, aTex.y);
   }
   ```

   JS程序

   ```javascript
   // 获取并设置顶点坐标
   const aPosition = gl.getAttribLocation(program, "aPosition");
   gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, BYTES * 4, 0);
   gl.enableVertexAttribArray(aPosition);
   // 通过aTex向vTex传递数据
   // 通过vTex将顶点着色器发送给片元着色器
   const aTex = gl.getAttribLocation(program, "aTex");
   gl.vertexAttribPointer(aTex, 2, gl.FLOAT, false, BYTES * 4, BYTES * 2);
   gl.enableVertexAttribArray(aTex);
   ```

3. 在片元着色器中接受vTex，创建纹理采样器，创建2D纹理，将纹理采样器和纹理顶点数据（vTex）进行绑定

   ```c
   precision lowp float;
   uniform sampler2D uSampler;
   varying vec2 vTex;
   void main() {
   	gl_FragColor = texture2D(uSampler, vTex);
   }
   ```

4. 处理uSampler纹理采样器的数据更新

   ```javascript
   const img = new Image();
   img.onload = function () {
     // 创建纹理对象
     // 纹理对象主要用于存储纹理图像数据。
     const texture = gl.createTexture();
   
     // 翻转 图片 Y轴
     gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
   
     // 开启一个纹理单元
     // Webgl是通过纹理单元来管理纹理对象，每个纹理单元管理一张纹理图像。
     gl.activeTexture(gl.TEXTURE0);
   
     /**
      * 绑定纹理单元：  gl.bindTexture(type, texture)
      * type参数：     gl.TEXTURE_2D 2维纹理，gl.TEXTURE_CUBE_MAP 立方体纹理
      * texture：     纹理对象
      */
     gl.bindTexture(gl.TEXTURE_2D, texture);
   
     /**
      *  处理纹理填充：
      *  texParameteri(target: GLenum, pname: GLenum, param: GLint): void;
      *      type(target):      gl.TEXTURE_2D 2维纹理，gl.TEXTURE_CUBE_MAP 立方体纹理
      *      pname纹理参数：     gl.TEXTURE_MAG_FILTER 放大
      *                         gl.TEXTURE_MIN_FILTER 缩小
      *                         gl.TEXTURE_WRAP_S     横向（水平填充）
      *                         gl.TEXTURE_WRAP_T     纵向（垂直填充）
      *      param：  当 pname 为 gl.TEXTURE_MAG_FILTER，gl.TEXTURE_MIN_FILTER时
      *                  gl.LINEAR    使用像素颜色值
      *                  gl.NEAREST   使用四周的加权平均值
      *              当 pname 为 gl.TEXTURE_WRAP_S，gl.TEXTURE_WRAP_T
      *                  gl.REPEAT           平铺重复
      *                  gl.MIRRORED_REPEAT  镜像对称
      *                  gl.CLAMP_TO_EDGE    边缘延伸
      *
      */
     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
   
     /**
      * 指定了二维纹理图像填充：
      * gl.textImage2D(type, level, internalformat, format, dataType, image)
      *      type:           gl.TEXTURE_2D 2维纹理，gl.TEXTURE_CUBE_MAP 立方体纹理
      *      level:          写 0
      *      internalformat: 图像的内部格式
      *                      gl.RGB  gl.RGBA  gl.ALPHA, gl.LUMINANCE，gl.LUMINANCE_ALPHA
      *      format:         纹理的内部样式，和internalformat 相同
      *      dataType:       纹理数据的数据类型
      *                          gl.UNSIGNED_BYTE
      *                          gl.UNSIGNED_SHORT_5_6_5
      *                          gl.UNSIGNED_SHORT_4_4_4_4
      *                          gl.UNSIGNED_SHORT_5_5_5_1
      *      image:          图片对象
      */
     gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, img);
   
     const uSampler = gl.getUniformLocation(program, "uSampler");
     gl.uniform1i(uSampler, 0);
   
     gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
   };
   img.src = "../assets/border.png";
   ```

##### 完整代码

```javascript
const ctx = document.getElementById("canvas");

const gl = ctx.getContext("webgl");

// 创建着色器源码
const VERTEX_SHADER_SOURCE = `
    attribute vec4 aPosition;

    attribute vec4 aTex;

    varying vec2 vTex;

    void main() {
      gl_Position = aPosition;
      vTex = vec2(aTex.x, aTex.y);
    }
`; // 顶点着色器

const FRAGMENT_SHADER_SOURCE = `
    precision lowp float;
    uniform sampler2D uSampler;
    varying vec2 vTex;

    void main() {
      gl_FragColor = texture2D(uSampler, vTex);
    }
`; // 片元着色器

const program = initShader(gl, VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);

// 缓冲区顶点数据数据
const points = new Float32Array([
  -0.5, 0.5, 0.0, 1.0, -0.5, -0.5, 0.0, 0.0, 0.5, 0.5, 1.0, 1.0, 0.5, -0.5, 1.0,
  0.0,
]);

const buffer = gl.createBuffer();
const BYTES = points.BYTES_PER_ELEMENT;
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, points, gl.STATIC_DRAW);

// 获取并设置顶点坐标
const aPosition = gl.getAttribLocation(program, "aPosition");
gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, BYTES * 4, 0);
gl.enableVertexAttribArray(aPosition);
// 通过aTex向vTex传递数据
// 通过vTex将顶点着色器发送给片元着色器
const aTex = gl.getAttribLocation(program, "aTex");
gl.vertexAttribPointer(aTex, 2, gl.FLOAT, false, BYTES * 4, BYTES * 2);
gl.enableVertexAttribArray(aTex);

const img = new Image();
img.onload = function () {
  // 创建纹理对象
  // 纹理对象主要用于存储纹理图像数据。
  const texture = gl.createTexture();

  // 翻转 图片 Y轴
  gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);

  // 开启一个纹理单元
  // Webgl是通过纹理单元来管理纹理对象，每个纹理单元管理一张纹理图像。
  gl.activeTexture(gl.TEXTURE0);

  /**
   * 绑定纹理单元：  gl.bindTexture(type, texture)
   * type参数：     gl.TEXTURE_2D 2维纹理，gl.TEXTURE_CUBE_MAP 立方体纹理
   * texture：     纹理对象
   */
  gl.bindTexture(gl.TEXTURE_2D, texture);

  /**
   *  处理纹理填充：
   *  texParameteri(target: GLenum, pname: GLenum, param: GLint): void;
   *      type(target):      gl.TEXTURE_2D 2维纹理，gl.TEXTURE_CUBE_MAP 立方体纹理
   *      pname纹理参数：     gl.TEXTURE_MAG_FILTER 放大
   *                         gl.TEXTURE_MIN_FILTER 缩小
   *                         gl.TEXTURE_WRAP_S     横向（水平填充）
   *                         gl.TEXTURE_WRAP_T     纵向（垂直填充）
   *      param：  当 pname 为 gl.TEXTURE_MAG_FILTER，gl.TEXTURE_MIN_FILTER时
   *                  gl.LINEAR    使用像素颜色值
   *                  gl.NEAREST   使用四周的加权平均值
   *              当 pname 为 gl.TEXTURE_WRAP_S，gl.TEXTURE_WRAP_T
   *                  gl.REPEAT           平铺重复
   *                  gl.MIRRORED_REPEAT  镜像对称
   *                  gl.CLAMP_TO_EDGE    边缘延伸
   *
   */
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

  /**
   * 指定了二维纹理图像填充：
   * gl.textImage2D(type, level, internalformat, format, dataType, image)
   *      type:           gl.TEXTURE_2D 2维纹理，gl.TEXTURE_CUBE_MAP 立方体纹理
   *      level:          写 0
   *      internalformat: 图像的内部格式
   *                      gl.RGB  gl.RGBA  gl.ALPHA, gl.LUMINANCE，gl.LUMINANCE_ALPHA
   *      format:         纹理的内部样式，和internalformat 相同
   *      dataType:       纹理数据的数据类型
   *                          gl.UNSIGNED_BYTE
   *                          gl.UNSIGNED_SHORT_5_6_5
   *                          gl.UNSIGNED_SHORT_4_4_4_4
   *                          gl.UNSIGNED_SHORT_5_5_5_1
   *      image:          图片对象
   */
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, img);

  const uSampler = gl.getUniformLocation(program, "uSampler");
  gl.uniform1i(uSampler, 0);

  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
};
img.src = "../assets/border.png";
```

##### 纹理渲染函数

```javascript
function getImage(gl, img_src, texture_unit, u_sampler) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = function () {
      const texture = gl.createTexture();
      gl.activeTexture(gl[`TEXTURE${texture_unit}`]);
      gl.bindTexture(gl.TEXTURE_2D, texture);

      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, img);

      const uSampler = gl.getUniformLocation(program, u_sampler);
      gl.uniform1i(uSampler, texture_unit);

      resolve();
    };
    img.src = img_src;
  });
}

```

## 二、OpenGL ES语言

### 1. 语言规则

- 大小写敏感、强制分号
- 通过main函数作为程序入口，没返回值 `void main()`
- 单行注释 `//` 多行注释 `/**/` 
- 强类型语言，使用和赋值必须是相同类型
- 基本类型包括：
  - float
  - int
  - boolean
- 变量声明：`float f`，
- 变量命名规则： 数字、字母、下划线，不能以 `gl_`，`webg_`，`_webgl_`作为开头，不能使用保留字、关键字，不能以数字开头
- 类型转换：int()，float()，bool()
- 运算符和JS一样

### 2. 矩阵

- vec2、vec3、vec4具有2，3，4个浮点数元素的矢量
- ivec2、ivec3、ivec4具有2，3，4个整数元素的矢量
- bvec2、bvec3、bvec4具有2，3，4个布尔值元素的矢量

**需要通过构造函数来赋值**

```cpp
vec4 position = vec4(0.1, 0.2, 0.3, 1.0);
```

**访问矢量中的分量**

x, y, z, w	访问顶点坐标分量

s, t, p, q	访问纹理坐标分量

```cpp
position.x; // 0.1
position.y; // 0.2
```

**可以通过混合的方式获取多个值，获取到的是个新的矢量内容**

```
position.xy // vec2(0.1, 0.2);
position.yx // vec2(0.2, 0.1);
position.zyx // vec2(0.3, 0.2, 0.1);
```

**mat、mat3、mat4 2 * 2，3 * 3， 4 * 4的浮点数元素矩阵**

**矩阵入参**，参数是列主序的。

```c
mat m = mat4(
	1.0,  5.0,  9.0,  13.0，
	2.0， 6.0， 10.0， 14.0，
	3.0， 7.0， 12.0， 15.0，
	4.0， 8.0， 13.0， 16.0
);
```

### 3. 纹理取样器

取样器包括：`sampler2D`和`smplerCube`

**声明**

```c
uniform sampler2D uSampler;
uniform smplerCube usmplerCube;
```

**二维纹理使用**

```javascript
function getImage(gl, img_src, texture_unit, u_sampler) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = function () {
      const texture = gl.createTexture();
      gl.activeTexture(gl[`TEXTURE${texture_unit}`]);
      gl.bindTexture(gl.TEXTURE_2D, texture);

      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, img);

      const uSampler = gl.getUniformLocation(program, u_sampler);
      gl.uniform1i(uSampler, texture_unit);

      resolve();
    };
    img.src = img_src;
  });
}
```

**Cube纹理的使用**

```javascript
const cubeMap = gl.createTexture();
gl.activeTexture(gl[`TEXTURE${texture_unit}`]);
gl.bindTexture(gl.TEXTURE_CUBE_MAP, cubeMap);
gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);

gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR);

gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, images[0]);
gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, images[0]);
gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, images[0]);
gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, images[0]);
gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, images[0]);
gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, images[0]);

const uSampler = gl.getUniformLocation(program, u_sampler);
gl.uniform1i(uSampler, texture_unit);
```

### 4. 分支与循环

和JS基本一致。

跳出循环除了`continue`，多了个`discard`，`discard`**只能在片元着色器**中使用，表示**放弃当前片元直接处理下一个片元**。

### 5. 函数

和C语言和JS一样，没啥花里胡哨的，返回值类型、参数类型、函数名

### 6. 内置函数

**角度函数**

`radians` 角度转弧度，`degress` 弧度转角度

**三角函数**

`sin`，`cos`，`tan`，`asin`，`acos`，`atan`

**指数函数**

`pow` 次方 `exp` 自然质数 `log` 对数 `sort` 开平方 `inversesqrt` 开平方的倒数

**通用函数**

`abs`，`min`，`max`，`mod` 取余数，`sign` 取符号，

`floor` 向下取整，`ceil` 向上取整，`clamp` 限定范围，`fract` 获取小数部分

`length(x)` 计算向量 x 的长度 `distance(x,y)` 计算向量xy之间的距离

`dot(x,y)` 计算向量 xy 的 点积 `cross(x, y)` 计算向量 xy 的差积 `normalize` 返回方向同x，长度为1的向量

### 7. 存储限定词

- `const`
- `attribute：`
  - 只能出现在顶点着色器
  - 只能声明为全局变量
  - 表示逐顶点信息。单个顶点的信息。
- `uniform：`
  - 可同时出现在 顶点着色器 和 片元着色器
  - 只读类型，强调一致性
  - 用来存储的是 影响所有顶点的数据，如变换矩阵
- `varying`
  - 从顶点着色器向片元着色器传递数据
- `meduim float f`
  - 精度限定
  - 提升运行效率，消减内存开支
  - 劣势：会出现精度歧义，也不利于后期维护
- `precision mediump float`
  - 修改着色器的默认精度
  - 精度枚举
    - 高精度 highg
    - 中精度 mediump
    - 低精度 lowp

**何时使用精度限定：**

片元着色器中的 float 类型没有默认精度，所以需要在**片元着色器**中使用**浮点型数据**的时候，需要修改默认精度
