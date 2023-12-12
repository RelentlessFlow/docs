# 一、Vue基础

## 一、Vue程序基本结构

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <script src="https://unpkg.com/vue@next"></script>
</head>
<body>
    <div id="root"></div>
    <script>
        Vue.createApp({
            data() {
              return {
                content: 1,
                hello: 'hello world!',
                show: true,
                list: ['hello', 'world', 'dell', 'lee'],
                inputValue: '',
              }
            },
            methods: {
                handleBtnClick() {
                    // this.$data.hello = this.$data.hello.split('').reverse().join('')
                    this.$data.show = !this.$.data.show
                },
                handleAddItem() {
                    this.$data.list.push('san')
                }
            },
            mounted() {
                setInterval(() => {
                    this.$data.content +=1;
                }, 1000)
            },
            template: `<div>
                {{content}}
                <span v-if="show">{{hello}}</span>
                    <input v-model="inputValue" />
                    <button v-on:click="handleBtnClick">反转</button>
                    <div>{{inputValue}}</div>
                    <ul>
                        <li v-for="item of list">{{item}}</li>
                    </ul>
                    <button v-on:click="handleAddItem">Push</button>
                </div>`
        }).mount('#root')
    </script>
</body>
</html>
```

## 二、Vue生命周期

```javascript
const app = Vue.createApp({
  data() {
    return { message: 'hello world!' }
  },
  beforeCreate() { // 在实例生成之前会自动执行的函数
    console.log('beforeCreate')
  },
  created() { // 在实例生成之后会自动执行的函数
    console.log('created')
  },
  beforeMount() { // 在组件内容被渲染到页面之前执行的函数
    console.log('beforeMound')
  },
  mounted() { // 在组件内容被渲染到页面之后执行的函数
    console.log('mounted')
  },
  beforeUpdate() { // 当数据发生变化时会立即自动执行的函数
    console.log('beforeUpdate')
  },
  updated() { // // 当数据发生变化，页面重新渲染后，会自动执行的函数
    console.log('updated')
  },
  beforeUnmount() { // 当Vue应用实例失效时，自动执行的函数
    console.log('beforeUnmount')
  },
  unmounted() { // 当Vue应用失效时，且dom完全销毁之后，自动执行的函数
    console.log('unmounted')
  },
  template: "<div>{{message}}</div>"
})
const vm = app.mount('#root')
```

## 三、Vue基础指令

```js
const app = Vue.createApp({
  data() {
    return {
      message: '{{message}}',
      vbindtitle: 'v-bind-title',
      vhtml: '<strong>v-html</strong>',
      disable: false,
      vonce: 'v-once',
      vif: true,
      vtitle: 'title',
    }
  },
  methods: {
    handleClick() {
      alert('click')
    }
  },
  template: `
                <div>{{message}}</div>
                <div v-bind:title="vbindtitle">{{vbindtitle}}</div>
                <div :title="vbindtitle">:title</div>
                <input v-bind:disabled="disable" placeholder="v-bind:disabled" />
                <div v-html="vhtml"></div>
                <div v-once>{{vonce}}</div>
                <div v-if="vif">v-if</div>
                <div v-on:click="handleClick">v-on:click</div>
                <div v-on:click="handleClick">@click</div>
                <div :[vtitle]="message">动态属性</div>
                <form action="https://www.baidu.com" @click.prevent="handleClick">
                    <button type="submit">@click.prevent</button>
                </form>
            `
})
const vm = app.mount('#root')
```

## 四、computed和watcher

1. data & methods & computed & watcher
2. compted和method都能实现一个功能，建议使用computed，因为有缓存
3. computed和watcher都能实现的功能，建议使用computed，因为更加简洁

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <script src="https://unpkg.com/vue@next"></script>
  </head>
  <body>
    <div id="root"></div>
    <script>
      const app = Vue.createApp({
        data() {
          return {
            num: 1,
            count: 2,
            price: 5,
            newTotal: 10,
          };
        },
        watch: {
          count(cur, pre) {
            this.newTotal = cur * this.price
          }
        },
        computed: { // 当计算属性依赖的内容发生变更时，才会重新执行计算
          total() {
            console.log('computed cal')
            return this.count * this.price
          }
        },
        methods: {
          getTotal() {  // 只要页面重新渲染，就会重新计算
            console.log('methods cal')
            return this.count * this.price
          },
          handleClickAddNum() {
            this.$data.num += 1;
          },
          handleClickAddCount() {
            this.$data.count += 1;
          },
        },
        template: `
          <div v-on:click="handleClickAddNum">num:{{num}}</div>
          <div v-on:click="handleClickAddCount">total:{{total}}</div>
          <div v-on:click="handleClickAddCount">getTotal:{{getTotal()}}</div>
          <div>{{newTotal}}</div>
            `,
      });
      const vm = app.mount("#root");
    </script>
  </body>
</html>

```

## 五、样式绑定

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <script src="https://unpkg.com/vue@next"></script>
    <style>
      .red {
        color: red
      }
      .green {
        color: green;
      }
    </style>
  </head>
  <body>
    <div id="root"></div>
    <script>
      const app = Vue.createApp({
        data() {
          return {
           classString: 'red',
           classArray: ['red', 'green'],
           classObject: {
            'red': true,
            'green': true,
           }
          };
        },
        watch: {
          
        },
        computed: { // 当计算属性依赖的内容发生变更时，才会重新执行计算
          
        },
        methods: {
          handleClick() {
            this.$data.classString = this.$data.classString === 'green' ? 'red' : 'green' 
          }
        },
        template: `
          <div v-bind:class="classString" v-on:click="handleClick">
            v-bind:class && :class
          </div>
          <div :class="classString" @click="handleClick">
            v-bind:class && :class
          </div>
          <div :class="classArray">
            v-bind:class && :class
          </div>
          <div :class="classObject">
            v-bind:class && :class
            <demo />
          </div>
            `,
      });

      app.component('demo', {
        template: `<div>single</div>`
      })

      const vm = app.mount("#root");
    </script>
  </body>
</html>
```

## 六、条件渲染

`v-if` `v-show` `v-if-else` `v-else`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <script src="https://unpkg.com/vue@next"></script>
  </head>
  <body>
    <div id="root"></div>
    <script>
      const app = Vue.createApp({
        data() {
          return {
           show: false,
           conditionOne: false,
           conditionTwo: true,
          };
        },  
        template: `
          <div v-if="show">v-if</div>
          <div v-else-if="conditionOne">v-else-if</div>
          <div v-else="conditionTwo">v-else</div>

          <div v-show="show">v-show</div>
            `,
      });
      const vm = app.mount("#root");
    </script>
  </body>
</html>
```

## 七、列表循环渲染

1、使用数组的变更函数

2、直接替换数组（Vue3）

3、直接更新数组的内容（Vue3）

```html
        <div v-for="(value, key, index) in listObject" :key="index">
        <div v-for="(item, index) in list" :key="index">
```

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <script src="https://unpkg.com/vue@next"></script>
  </head>
  <body>
    <div id="root"></div>
    <script>
      const app = Vue.createApp({
        data() {
          return {
           list: ['dell', 'lee', 'teacher'],
           listObject: {
            firstName: 'dell',
            lastName: 'lee',
            job: 'teacher',
           }
          };
        },
        watch: {
          
        },
        computed: { // 当计算属性依赖的内容发生变更时，才会重新执行计算
          
        },
        methods: {
        },
        template: `
          <div>
            <div v-for="(item, index) in list" :key="index">
              {{item}} -- {{index}}
            </div>
            <div v-for="(value, key, index) in listObject" :key="index">
              {{key}} -- {{value}} -- {{index}}
            </div>
          </div>
            `,
      });
      const vm = app.mount("#root");
    </script>
  </body>
</html>
```

## 八、Vue事件绑定

1. 绑定一个事件

```html
<button @click="handleBtnClick1">Button</button>
```

2. 绑定多个事件

```html
<button @click="handleBtnClick1(), handleBtnClick2()">Button</button>
```

3. @click.stop 阻止事件冒泡

```html
<button @click.stop="handleBtnClick1(), handleBtnClick2()">Button</button>
```

4. @click.self 只触发本DOM事件

```html
<div @click.self="handleDivClick">...</div>
```

5. 其他修饰符

- 事件修饰符：stop、prevent、capture、self、once、passive
- 按键修饰符：enter、tab、delete、esc、up、down、left、right
- 鼠标修饰符：left、right、middle
- 精确修饰符：exact（@click.ctrl）

## 九、双向数据绑定

语法：v-model

可用：input, textarea, checkbox, radio, select

修饰符：lazy，number，trim

**<input v-model.number.lazy="message"/>**
