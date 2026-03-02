# TreeFlatten

```typescript
/* eslint-disable @typescript-eslint/no-explicit-any */
interface TreeFlattenRule<T> {
  sourceField: keyof T;
  targetField: string;
}

/**
 * 把任意标准树形数据转换为一维数组, 支持泛型，T：原树形数组T数据结构，U：返回数组每一项的数据结构
 * @param sourceTree 原 树型数据
 * @param mappingRules 映射规则 { sourceField: 'id', targetField: 'key' }, { sourceField: 'name', targetField: 'title' },
 * @param childrenPaths 子节点字段路径，可以是字符串数组或单个字符串
 */
function treeFlatten<T, U>(
  sourceTree: T[],
  mappingRules: TreeFlattenRule<T>[],
  childrenPaths: string | string[] = 'children'
): U[] {
  const result: U[] = [];

  function traverse(node: T, depth: number) {
    // 映射当前节点
    const mappedNode: any = {};
    mappingRules.forEach((rule) => {
      mappedNode[rule.targetField] = node[rule.sourceField];
    });
    result.push(mappedNode);

    // 处理子节点字段
    let childrenField: string;
    if (Array.isArray(childrenPaths)) {
      childrenField = childrenPaths[depth] || childrenPaths[childrenPaths.length - 1]; // 支持层数不足时使用最后一个字段
    } else {
      childrenField = childrenPaths; // 单一字段名
    }

    const children = (node as any)[childrenField];
    if (Array.isArray(children)) {
      children.forEach((child: T) => traverse(child, depth + 1));
    }
  }

  // 遍历根节点
  sourceTree.forEach((rootNode) => traverse(rootNode, 0));

  return result;
}

// 定义树形数据
const sourceTree = [
  {
    id: 1,
    name: 'Root',
    nodes: [
      {
        id: 2,
        name: 'Child 1',
        nodes: [
          {
            id: 3,
            name: 'Grandchild 1',
          },
        ],
      },
      {
        id: 4,
        name: 'Child 2',
      },
    ],
  },
];

// 定义树形数据
const sourceTree2 = [
  {
    id: 1,
    name: 'Root',
    nodes_1: [
      {
        id: 2,
        name: 'Child 1',
        nodes_2: [
          {
            id: 3,
            name: 'Grandchild 1',
          },
        ],
      },
      {
        id: 4,
        name: 'Child 2',
      },
    ],
  },
];

// 定义映射规则
const mappingRules: TreeFlattenRule<typeof sourceTree[0]>[] = [
  { sourceField: 'id', targetField: 'key' },
  { sourceField: 'name', targetField: 'title' },
];

const mappingRules2: TreeFlattenRule<typeof sourceTree2[0]>[] = [
  { sourceField: 'id', targetField: 'key' },
  { sourceField: 'name', targetField: 'title' },
];

// 调用 treeFlatten 函数，传递子节点路径
const flatArray1 = treeFlatten(sourceTree, mappingRules, 'nodes'); // 每一层字段名相同
console.log('Single children field:', flatArray1);

// 调用 treeFlatten 函数，传递多个字段路径
const flatArray2 = treeFlatten(sourceTree2, mappingRules2, ['nodes_1', 'nodes_2']);
console.log('Multiple children fields:', flatArray2);
```

