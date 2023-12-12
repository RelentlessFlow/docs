# THREE 开发经验

### 问题：Deprecated symbol used, consult docs for better alternative 
TS6385:  encoding  is deprecated.

#### 色彩空间

```typescript
texture.encoding = SRGBColorSpace;
// Deprecated symbol used, consult docs for better alternative 
// TS6385:  encoding  is deprecated.
```

encoding被弃用了，用 colorSpace

```typescript
texture.colorSpace = SRGBColorSpace;
```

#### 色域列表

```typescript
export const NoColorSpace: '';
export const SRGBColorSpace: 'srgb';
export const LinearSRGBColorSpace: 'srgb-linear';
export const DisplayP3ColorSpace: 'display-p3';
export const LinearDisplayP3ColorSpace = 'display-p3-linear';
export type ColorSpace =
    | typeof NoColorSpace
    | typeof SRGBColorSpace
    | typeof LinearSRGBColorSpace
    | typeof DisplayP3ColorSpace
    | typeof LinearDisplayP3ColorSpace;
```

