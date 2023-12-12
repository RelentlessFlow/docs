# Redux

## 1. Installation

核心库:

```
npm install redux
```

## 2. Base Example

```jsx
import { createStore } from 'redux'

/**
 * This is a reducer - a function that takes a current state value and an
 * action object describing "what happened", and returns a new state value.
 * A reducer's function signature is: (state, action) => newState
 *
 * The Redux state should contain only plain JS objects, arrays, and primitives.
 * The root state value is usually an object. It's important that you should
 * not mutate the state object, but return a new object if the state changes.
 *
 * You can use any conditional logic you want in a reducer. In this example,
 * we use a switch statement, but it's not required.
 */
function counterReducer(state = { value: 0 }, action) {
  switch (action.type) {
    case 'counter/incremented':
      return { value: state.value + 1 }
    case 'counter/decremented':
      return { value: state.value - 1 }
    default:
      return state
  }
}

// Create a Redux store holding the state of your app.
// Its API is { subscribe, dispatch, getState }.
let store = createStore(counterReducer)

// You can use subscribe() to update the UI in response to state changes.
// Normally you'd use a view binding library (e.g. React Redux) rather than subscribe() directly.
// There may be additional use cases where it's helpful to subscribe as well.

store.subscribe(() => console.log(store.getState()))

// The only way to mutate the internal state is to dispatch an action.
// The actions can be serialized, logged or stored and later replayed.
store.dispatch({ type: 'counter/incremented' })
// {value: 1}
store.dispatch({ type: 'counter/incremented' })
// {value: 2}
store.dispatch({ type: 'counter/decremented' })
// {value: 1}
```

## 2.1 Redux DevTools

```jsx
import {applyMiddleware, compose, createStore} from "redux";
import reducer from "./reducer";

const composeEnhancers =
  typeof window === 'object' &&
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({
      // Specify extension’s options like name, actionsBlacklist, actionsCreators, serialize...
    }) : compose;

const enhancer = composeEnhancers(
  applyMiddleware(...middleware),
  // other store enhancers if any
);
const store = createStore(reducer, enhancer);
export default store;
```



## 3. TodoList综合案例

### 1. 定义视图的无状态组件

```jsx
import React from 'react';
import {Button, Input, List} from "antd";

const TodoListUI = (props) => {
  return (
    <div>
      <Input.Group compact>
        <Input
          style={{width: "calc(100% - 200px)"}}
          value={props.inputValue}
          placeholder="todo info"
          onChange={props.handleInputChange}
        />
        <Button
          type="primary"
          onClick={props.handleBtnClick}
        >
          Submit
        </Button>
      </Input.Group>
      <List
        style={{width: "calc(100% - 200px)"}}
        bordered
        dataSource={props.list}
        renderItem={(item, index) => (
          <List.Item
            onClick={() => props.handleItemClickDelete(index)}
          >
            {item}
          </List.Item>
        )}
      />
    </div>
  );
}

export default TodoListUI;
```

### 2. 定义逻辑组件

```jsx
export default class TodoList extends Component {
	render() {
    return (
      <TodoListUI
        inputValue={this.state.inputValue}
        handleInputChange={this.handleInputChange}
        handleBtnClick={this.handleBtnClick}
        handleItemClickDelete={this.handleItemClickDelete}
        list={this.state.list}
      />
    );
  }
}
```

### 3. 定义Redux仓库

1. 新建store/index.js

   ```jsx
   import { createStore } from "redux";
   import reducer from "./reducer";
   const store = createStore(reducer);
   export default store;
   ```

2. 新建store/reducer.js

   ```jsx
   const defaultState = {
     inputValue: '123',
     list: [] 
   }
   const reducer = (state = defaultState, action) => {
   	return state;
   }
   ```

3. 创建业务逻辑的Action

   actionType.js

   ```jsx
   export const CHANGE_INPUT_VALUE = 'change_input_value';
   export const ADD_TODO_ITEM = 'add_todo_item'
   export const DELETE_TODO_ITEM = 'delete_todo_item';
   export const INIT_LIST_ACTION = 'init_list_action';
   export const GET_INIT_LIST = 'get_init_list';
   ```

   actionCreator.js

   ```jsx
   import {ADD_TODO_ITEM, CHANGE_INPUT_VALUE, DELETE_TODO_ITEM, GET_INIT_LIST, INIT_LIST_ACTION} from "./actionTypes";
   
   export const getInputChangeAction = (value) => ({
     type: CHANGE_INPUT_VALUE,
     value
   });
   
   export const getAddTodoItemAction = () => ({
     type: ADD_TODO_ITEM
   })
   
   export const getDeleteTodoItemAction = (index) => ({
     type: DELETE_TODO_ITEM,
     index
   });
   ```

4. 在store/reducer.js 编写reducer处理相应的action

   ```jsx
   import { ADD_TODO_ITEM, CHANGE_INPUT_VALUE, DELETE_TODO_ITEM, INIT_LIST_ACTION } from "./actionTypes";
   
   const defaultState = {
     inputValue: '123',
     list: []
   }
   
   // reducer 可以接受state，但是不能修改state
   const reducer = (state = defaultState, action) => {
   
     if (action.type === CHANGE_INPUT_VALUE) {
       const newState = JSON.parse(JSON.stringify(state));
       newState.inputValue = action.value;
       return newState
     }
   
     if (action.type === ADD_TODO_ITEM) {
       const newState = JSON.parse(JSON.stringify(state));
       if (newState.inputValue === '') return state;
       newState.list.push(newState.inputValue);
       newState.inputValue = '';
       return newState;
     }
   
     if (action.type === DELETE_TODO_ITEM) {
       const newState = JSON.parse(JSON.stringify(state));
       newState.list.splice(action.index,1);
       return newState;
     }
   
     return state;
   }
   
   export default reducer
   ```

5. 完善逻辑组件Todolist.js

   1. 添加store数据到Component的state中

   ```jsx
   export default class TodoList extends Component {
     constructor(props) {
         super(props);
         this.state = store.getState();
       }
   }
   ```

   2. 完善组件中的Function，将其绑定到redux的action

      ```jsx
      export default class TodoList extends Component {
        constructor(props) {
          super(props);
          this.state = store.getState();
        }
        handleInputChange = (e) => {
          const action = getInputChangeAction(e.target.value);
          store.dispatch(action);
        }
      
        handleBtnClick = () => {
          const action = getAddTodoItemAction();
          store.dispatch(action);
        }
      
        handleItemClickDelete = (index) => {
          const action = getDeleteTodoItemAction(index);
          store.dispatch(action);
        }
      }
      ```

   3. 订阅store，保证store更新时组件state也会更新。

      ```jsx
      export default class TodoList extends Component {
        constructor(props) {
          super(props);
          this.state = store.getState();
        }
      
        componentDidMount() {
          store.subscribe(this.handleStoreChange);
        }
        
        handleStoreChange = () => {
          this.setState(store.getState())
        }
      }
      ```

   完整的component

   ```jsx
   import React, {Component} from "react";
   import store from './store'
   import {
     getAddTodoItemAction,
     getDeleteTodoItemAction, getInitListAction,
     getInputChangeAction,
   } from "./store/actionCreator";
   import TodoListUI from "./TodoListUI";
   
   export default class TodoList extends Component {
     constructor(props) {
       super(props);
       this.state = store.getState();
     }
   
     componentDidMount() {
       store.subscribe(this.handleStoreChange);
     }
   
     render() {
       return (
         <TodoListUI
           inputValue={this.state.inputValue}
           handleInputChange={this.handleInputChange}
           handleBtnClick={this.handleBtnClick}
           handleItemClickDelete={this.handleItemClickDelete}
           list={this.state.list}
         />
       );
     }
   
     handleInputChange = (e) => {
       const action = getInputChangeAction(e.target.value);
       store.dispatch(action);
     }
   
     handleBtnClick = () => {
       const action = getAddTodoItemAction();
       store.dispatch(action);
     }
   
     handleItemClickDelete = (index) => {
       const action = getDeleteTodoItemAction(index);
       store.dispatch(action);
     }
   
     handleStoreChange = () => {
       this.setState(store.getState())
     }
   }
   ```




## 4. redux-thunk

参考文档：

> https://github.com/reduxjs/redux-thunk

### 1. redux-thunk介绍

redux-thunk是一个redux中间件，可以用于处理异步请求。它可以拦截store.dispatch方法，并判断dispatch传递的对象是否为函数，若为函数则等待其执行完毕后，转为action再交给reducer去执行。

> GitHub介绍：Thunk [middleware](https://redux.js.org/tutorials/fundamentals/part-4-store#middleware) for Redux. It allows writing functions with logic inside that can interact with a Redux store's `dispatch` and `getState` methods.

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20220208112347523.png" alt="image-20220208112347523" style="zoom:50%;" />

### 2. 在todolist中集成redux-thunk进行ajax请求

1. 安装redux-thunk

   ```
   npm install redux-thunk
   yarn add redux-thunk
   ```

2. 在store/index.js 添加中间件

   ```jsx
   import {applyMiddleware, compose, createStore} from "redux";
   import thunk from "redux-thunk";
   import reducer from "./reducer";
   
   const composeEnhancers =
     typeof window === 'object' &&
     window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
       window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({
         // Specify extension’s options like name, actionsBlacklist, actionsCreators, serialize...
       }) : compose;
   
   const enhancer = composeEnhancers(
     applyMiddleware(thunk),
   );
   const store = createStore(reducer, enhancer);
   export default store;
   ```

3. 在actionType和actionCreator中创建用于list初始化的INIT_LIST_ACTION

   ```jsx
   // actionTypes.js
   ...
   export const INIT_LIST_ACTION = 'init_list_action';
   // actionCreator.js
   ...
   export const initListAction = (data) => ({
     type: INIT_LIST_ACTION,
     data
   });
   ```

4. 在reducer中接受INIT_LIST_ACTION，并对INIT_LIST_ACTION进行处理

   ```jsx
     ...
   const reducer = (state = defaultState, action) => {
   	if (action.type === INIT_LIST) {
       const newState = JSON.parse(JSON.stringify(state));
       newState.list = action.data;
       return newState;
     }
     ...
   ```

5. 在actionCreator中创建用于发送ajax请求的getListAjaxAction

   ```jsx
   export const getListAjaxAction = () => {
     return (dispatch) => {
       axios.get("http://localhost:3001/list")
         .then((res) => {
         const data = res.data;
         const action = initListAction(data);
         dispatch(action);
       }).catch(() => {console.log("error")})
     }
   }
   ```

6. 在Todolist组件生命周期函数中运用getListAjaxAction对组件数据进行初始化

   ```jsx
   class Todolist extends Component {
     ...
     componentDidMount() {
       store.subscribe(this.handleStoreUpdate);
       const action = getListAjaxAction();
       store.dispatch(action);
     }
   	...
   }
   ```



## 5. redux-saga简单实践

> 参考文档：https://github.com/redux-saga/redux-saga

个人理解：redux-sega可以接受redux流程中的action，拦截action，并对action进行处理。

### 使用redux-sega实现ajax请求

#### 1.  安装

```
npm install redux-saga
```

#### 2. 对Store进行配置

```jsx
import {createStore, compose, applyMiddleware} from "redux";
import reducer from "./reducer";
import createSagaMiddleware from 'redux-saga'
import todoSagas from './segas'

const composeEnhancers =
  typeof window === 'object' &&
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({
    }) : compose;

const sagaMiddleware = createSagaMiddleware()
const enhancer = composeEnhancers(
  applyMiddleware(sagaMiddleware),
);

const store = createStore(reducer, enhancer);
sagaMiddleware.run(todoSagas)

export default store;
```

### 3. 新建getInitListAction，并且在组件中引用它

actionCreator.js

```jsx
export const getInitListAction = () => ({
  type: GET_INIT_LIST
});
```

Todolist.js

```jsx
export default class TodoList extends Component {
  ...
	componentDidMount() {
    store.subscribe(this.handleStoreChange);
    const action = getInitListAction()
    store.dispatch(action);
  }
	...
}
```

#### 4. 在segas.js中编写逻辑，处理异步Action

```jsx
function* getInitList() {``
  try {
    const res = yield axios.get("http://localhost:3001/list");
    const action = initListAction(res.data);
    yield put(action);
  }catch (e) {
    console.log('list网络请求失败');
  }
}

function* mySaga() {
  yield takeEvery(GET_INIT_LIST, getInitList)
}

export default mySaga;
```

#### 5. 编写reducer

```jsx
const reducer = (state = defaultState, action) => {

  if (action.type === INIT_LIST_ACTION) {
    const newState = JSON.parse(JSON.stringify(state));
    newState.list = action.data;
    return newState;
  }
 	...
```

