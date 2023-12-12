# react-redux中container简写

```javascript
import { connect } from "react-redux";
import CountUI from "../../components/Count";
import { INCREMENT, DECREMENT } from "../../redux/constant";
import {
  createIncrementAction,
  createDecrementAction,
  createIncrementAsyncAction,
} from "../../redux/count_action";

const mapStateToProps = state => ({ count: state })

const mapDispatchToProps = (dispatch) => ({
    [INCREMENT]: (number) => dispatch(createIncrementAction(number * 1)),
    [DECREMENT]: (number) => dispatch(createDecrementAction(number * 1)),
    [INCREMENT + "Async"]: (number, time = 500) =>
      dispatch(createIncrementAsyncAction(number * 1, time))
})

export default connect(mapStateToProps, mapDispatchToProps)(CountUI);
```

可简化为

```javascript
import { connect } from "react-redux";
import CountUI from "../../components/Count";
import { INCREMENT, DECREMENT } from "../../redux/constant";
import {
  createIncrementAction,
  createDecrementAction,
  createIncrementAsyncAction,
} from "../../redux/count_action";

export default connect(state => ({ count: state }), 
{
  [INCREMENT]:createIncrementAction,
  [DECREMENT]:createDecrementAction,
  [INCREMENT + "Async"]:createIncrementAsyncAction
}
)(CountUI);
```



index.js

```javascript
import React from "react";
import ReactDOM from "react-dom";
import store from "./redux/store";
import "./index.css";
import App from "./App";

ReactDOM.render(<App />, document.getElementById("root"));

store.subscribe(() => {
  ReactDOM.render(<App />, document.getElementById("root"));
});
```

可简化为

````javascript
import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";

ReactDOM.render(<App />, document.getElementById("root"));
````





App.jsx

```javascript
export default class App extends Component {
  render() {
    return (
      <div>
        <Count store={store}/>
      </div>
    )
  }
}
```

可简化为

```javascript
export default class App extends Component {
  render() {
    return (
      <div>
        <Count/>
      </div>
    )
  }
}
```

index.js

```javascript
ReactDOM.render(
   <App /> ,document.getElementById("root")
);
```

需要添加Provider

```javascript
import { Provider } from "react-redux";
ReactDOM.render(
  <Provider>
    <App />
  </Provider>,
  document.getElementById("root")
);
```

