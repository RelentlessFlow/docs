```typescript
interface TreeNode {
  id: string;
  name: string;
  children?: TreeNode[];
}

interface AntdNode {
  value: string;
  title: string;
  key: string;
  children?: AntdNode;
}

interface TreeFlattenRule<T> {
  sourceField: keyof T;
  targetField: string;
}

interface TreeMappingRule<T, U> {
  sourceField: keyof T;
  targetField: keyof U;
}

/**
 * 把任意标准树形数据转换为一维数组, 支持泛型，T：原树形数组T数据结构，U：返回数组每一项的数据结构
 * @param sourceTree 原 树型数据
 * @param mappingRules 映射规则 { sourceField: 'id', targetField: 'key' }, { sourceField: 'name', targetField: 'title' },
 */
function treeFlatten<T, U>(sourceTree: T[], mappingRules: TreeFlattenRule<T>[]): U[] {
  const result: U[] = [];

  function traverse(node: T) {
    const mappedNode: any = {};
    mappingRules.forEach((rule) => {
      mappedNode[rule.targetField] = node[rule.sourceField];
    });
    result.push(mappedNode);

    if (Array.isArray(node)) {
      node.forEach((child: T) => traverse(child));
    }
  }

  sourceTree.forEach((rootNode) => traverse(rootNode));

  return result;
}

function treeMapping<T, U>(sourceTree: T[], mappingRules: TreeMappingRule<T, U>[]): U[] {
  const targetTree: U[] = [];

  sourceTree.forEach((sourceItem) => {
    const targetItem: U = {} as U;

    mappingRules.forEach((rule) => {
      if ((sourceItem as any).hasOwnProperty(rule.sourceField)) {
        (targetItem as any)[rule.targetField] = sourceItem[rule.sourceField];
      }
    });

    for (const key in sourceItem) {
      if (
        (sourceItem as any).hasOwnProperty(key) &&
        !mappingRules.find((rule) => rule.sourceField === key)
      ) {
        if (key === 'children' && Array.isArray((sourceItem as any)[key])) {
          (targetItem as any)[key] = (sourceItem as any)[key].map(
            (child: T[keyof T]) => treeMapping([child as any], mappingRules)[0],
          );
        } else if (
          typeof (sourceItem as any)[key] === 'object' &&
          (sourceItem as any)[key] !== null
        ) {
          (targetItem as any)[key] = treeMapping([(sourceItem as any)[key]], mappingRules)[0];
        } else {
          (targetItem as any)[key] = (sourceItem as any)[key];
        }
      }
    }

    targetTree.push(targetItem);
  });

  return targetTree;
}

export type { TreeNode, AntdNode, TreeFlattenRule, TreeMappingRule };

export { treeFlatten, treeMapping };
```