# JS  工具函数


[TOC]

## 数组

**两数组比较（需要lodash）**

```typescript
/**
 * 比较两个数组中的每一项是否相等
 * @param arr1
 * @param arr2
 * @param sort 是否比较顺序，true比较顺序，默认比较
 */
function compareArray(arr1: any[], arr2: any[], sort: true) {
  return lodash.isEqualWith(
    arr1,
    arr2,
    !sort
      ? (objValue, otherValue) => {
          if (lodash.isArray(objValue) && lodash.isArray(otherValue)) {
            return lodash.isEqual(lodash.sortBy(objValue), lodash.sortBy(otherValue));
          }
        }
      : undefined,
  );
}
```

## 算法

**创建一个整数随机数**

```typescript
/**
 * 创建一个整数的随即是
 * @param minNum
 * @param maxNum
 */
function createRandom(minNum: number, maxNum: number) {
  switch (arguments.length) {
    case 1:
      return parseInt(String(Math.random() * minNum + 1), 10);
    case 2:
      return parseInt(String(Math.random() * (maxNum - minNum + 1) + minNum), 10);
    default:
      return 0;
  }
}
```

## 文件

**获取图片宽高、宽高比**

```typescript
function getImageFileAsync(file: File): Promise<{
  width: number;
  height: number;
  aspectRatio: number;
  image: HTMLImageElement;
}> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    const img = new Image();

    reader.onload = () => {
      img.src = reader.result as string;
    };

    img.onload = () => {
      const width = img.width;
      const height = img.height;
      const aspectRatio = width / height;
      resolve({
        width,
        height,
        aspectRatio,
        image: img,
      });
    };

    img.onerror = () => {
      reject(new Error('图片加载失败'));
    };

    reader.onerror = () => {
      reject(new Error('文件读取错误'));
    };
    // 读取文件内容
    reader.readAsDataURL(file);
  });
}
```

**文件大小格式化**

```typescript
function formatFileSize(bytes: number): string {
  if (bytes < 1024) {
    return bytes + 'B';
  } else if (bytes < 1024 * 1024) {
    return (bytes / 1024).toFixed(2) + 'KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return (bytes / (1024 * 1024)).toFixed(2) + 'MB';
  } else {
    return (bytes / (1024 * 1024 * 1024)).toFixed(2) + 'GB';
  }
}
```

**获取Base64**

```typescript
const getBase64 = (file: File): Promise<string> =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = (error) => reject(error);
  });
```

**文件下载**

```typescript
function downloadFile(file: File) {
  const fileURL = URL.createObjectURL(file);
  const a = document.createElement('a');
  a.href = fileURL;
  // 设置下载文件的名称
  a.download = file.name;
  // 将a标签添加到文档中
  document.body.appendChild(a);
  // 模拟点击a标签，触发下载
  a.click();
  // 下载完成后移除a标签
  document.body.removeChild(a);
  // 释放URL对象，以防内存泄漏
  URL.revokeObjectURL(fileURL);
}
```

## 日期

**日期格式化**

```typescript
/**
 * 将任意日期格式化为中文格式
 * @param day
 */
function formatDayjs(day: Dayjs | string | Date) {
  return dayjs(day).format('YYYY-MM-DD HH:mm:ss');
}

```

## 剪切板

**复制文本到剪切板**

```typescript
class ClipboardError extends Error {
  readonly originError?: any;
  constructor(message: string, originError?: any) {
    super(message);
    this.name = 'ClipboardError';
    this.originError = originError;
  }
}

function copyTextToClipboard(text: string): Promise<boolean> {
  return new Promise((resolve, reject) => {
    if (document.queryCommandSupported('copy')) {
      // 使用 document.execCommand 方法（适用于一些老旧浏览器）
      const textarea = document.createElement('textarea');
      textarea.value = text;

      // 设置样式，确保textarea不可见
      textarea.style.position = 'fixed';
      textarea.style.opacity = '0';

      document.body.appendChild(textarea);

      // 选择并复制文本到剪贴板
      textarea.select();
      try {
        const success = document.execCommand('copy');
        document.body.removeChild(textarea);

        if (success) {
          resolve(true);
        } else {
          reject(new ClipboardError('复制到剪贴板失败'));
        }
      } catch (error) {
        reject(new ClipboardError('复制到剪贴板时发生错误', error));
      }
    } else if (navigator.clipboard && navigator.clipboard.writeText) {
      // 使用 Clipboard API
      navigator.clipboard
        .writeText(text)
        .then(() => {
          resolve(true);
        })
        .catch((error) => {
          reject(new ClipboardError('复制到剪贴板失败', error));
        });
    } else {
      reject(new ClipboardError('不支持复制到剪贴板的方法'));
    }
  });
}

export {
  ClipboardError,
  copyTextToClipboard,
};
```

## 对象操作

**Object.keys Polyfill**

```javascript
if (!Object.keys) {
  Object.keys = (function () {
    var hasOwnProperty = Object.prototype.hasOwnProperty,
        hasDontEnumBug = !({toString: null}).propertyIsEnumerable('toString'),
        dontEnums = [
          'toString',
          'toLocaleString',
          'valueOf',
          'hasOwnProperty',
          'isPrototypeOf',
          'propertyIsEnumerable',
          'constructor'
        ],
        dontEnumsLength = dontEnums.length;

    return function (obj) {
      if (typeof obj !== 'object' && typeof obj !== 'function' || obj === null) throw new TypeError('Object.keys called on non-object');

      var result = [];

      for (var prop in obj) {
        if (hasOwnProperty.call(obj, prop)) result.push(prop);
      }

      if (hasDontEnumBug) {
        for (var i=0; i < dontEnumsLength; i++) {
          if (hasOwnProperty.call(obj, dontEnums[i])) result.push(dontEnums[i]);
        }
      }
      return result;
    }
  })()
};
```

## WebRTC

**视频、相机权限校验**

```typescript
const initCameraPermission = () => {
    return new Promise<boolean>((resolve, reject) => {
        try {
            if (!navigator || !navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                reject(false);
            }
            navigator.mediaDevices.getUserMedia({video: {facingMode: 'user'}})
                .then(res => {
                    resolve(true)
                })
                .catch(err => reject(false))
        } catch (e) {
            reject(false)
        }
    })
}
```

