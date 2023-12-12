1. src/redux/store.js

```javascript
import { createStore, applyMiddleware } from "redux";
// applyMiddleware为函数：允许传入中间件
// createStore用来创建store
import countReducer from "./count_reducer";
// redux-thunk用来执行异步函数，它是一个中间件
import thunk from "redux-thunk";
export default createStore(countReducer, applyMiddleware(thunk));
```

2. count_reducer.js

Reducer对象，他是一个函数

```javascript
import {INCREMENT,DECREMENT} from './constant'
const initState = 0;
/**
 * 返回Reducer函数对象计算数据返回给Store，再由Store返回给Component
 * @param {状态数据} preState 
 * @param {方法类型} action 
 * @returns 
 */
export default function counterReducer(preState = initState, action) {
  // action对象需要包含两个属性，type对动作类型，data为传入数据
  const { type, data } = action;
  switch (type) {
    case INCREMENT:
      return preState + data;
    case DECREMENT:
      return preState - data;
    default:
      return preState;
  }
}
```

3. 封装常量池 constant.js

```javascript
export const INCREMENT = 'increment'
export const DECREMENT = 'decrement'
```

4. 封装action对象 count_action.js

```javascript
import { INCREMENT, DECREMENT } from "./constant";
export const createIncrementAction = (data) => ({ type: INCREMENT, data });
export const createDecrementAction = (data) => ({ type: DECREMENT, data });
export const createIncrementAsyncAction = (data, time) => {
  return (dispatch) => {
    setTimeout(() => {
      dispatch(createIncrementAction(data));
    }, time);
  };
};
```

5. 组件内通知action_creators

```javascript
import React, { Component } from "react";
import store from "../../redux/store";
import { INCREMENT, DECREMENT } from '../../redux/constant'

export default class Count extends Component {
  increment = () => {
    const { value } = this.selectNumber;
    this.props[INCREMENT](value);
  };
  decrement = () => {
    const { value } = this.selectNumber;
    this.props[DECREMENT](value);
  };
  incrementIfOdd = () => {
    const { value } = this.selectNumber;
    const {count} = this.props;
    if (count % 2 !== 0) {
      this.props[INCREMENT](value);
    }
  };
  incrementAsync = () => {
    const { value } = this.selectNumber;
    this.props[INCREMENT+"Async"](value);
    // this.props.incrementAsync(value, 2000);
  };
  render() {
    return (
      <div className="App">
        <div>当前求和为：{store.getState()}</div>
        <select ref={(c) => (this.selectNumber = c)}>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="4">4</option>
          <option value="5">5</option>
        </select>
        &nbsp;&nbsp;
        <button onClick={this.increment}>+</button>
        <button onClick={this.decrement}>-</button>
        <button onClick={this.incrementIfOdd}>奇数+</button>
        <button onClick={this.incrementAsync}>异步+</button>
      </div>
    );
  }
}
```

