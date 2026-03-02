### TriggerArea组件

增大按钮触发区域的组件

```tsx
import { View } from '@tarojs/components';
import classNames from 'classnames';
import React, { useMemo } from 'react';
import styles from './index.less';

interface TriggerAreaProps {
    /**
     * 触发区域放大倍数，默认2倍
     */
    zoom?: number;
    /**
     * 调试模式，展示触发区域
     */
    debug?: boolean;
    children: React.ReactNode;
}

/**
 * 触控区域放大组件，必须传入唯一的绑定了onClick事件的根组件
 * @param zoom
 * @param debug
 * @param children
 * @constructor
 */
const TriggerArea: React.FC<TriggerAreaProps> = ({ zoom = 2, debug, children }) => {
    const element = useMemo(() => {
        const childCount = React.Children.count(children);

        if (childCount !== 1) {
            throw new Error('TriggerArea组件必须传入有且一个子节点');
        }

        return React.Children.map(children, (_child) => {
            if (typeof _child !== 'object') {
                throw new Error('TriggerArea组件必须传入一个React节点');
            }

            const child = _child as React.ReactElement;
            const childProps = child.props;
            const onClickEvent = childProps.onClick;

            if (!onClickEvent || typeof onClickEvent !== 'function') {
                throw new Error('TriggerArea组件的第一个子节点必须绑定onClick事件');
            }

            return (
                <View className={styles.trigger}>
                    {React.cloneElement(child, {
                        ...childProps
                    })}
                    <View
                        className={classNames(styles.triggerArea, {
                            [styles.triggerAreaDebug]: debug
                        })}
                        onClick={onClickEvent}
                        style={{
                            width: `${zoom * 100}%`,
                            height: `${zoom * 100}%`,
                            left: `-${(zoom * 100) / 2 - 50}%`,
                            top: `-${(zoom * 100) / 2 - 50}%`
                        }}
                    />
                </View>
            );
        });
    }, [children, debug, zoom]);

    return <>{element}</>;
};

export default TriggerArea;

export type { TriggerAreaProps };
```

index.less

```less
.trigger {
  width: fit-content;
  height: fit-content;
  position: relative;
  z-index: 1;


  .triggerArea {
    position: absolute;
    z-index: -1;

    &Debug {
      background: rgba(255, 255, 0, 0.31);
    }
  }
}
```
