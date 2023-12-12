# 一、vue双向绑定的理解

[toc]

## **前言**

**什么是数据双向绑定**？ 

　　vue是一个mvvm框架，即数据双向绑定，即当数据发生变化的时候，视图也就发生变化，当视图发生变化的时候，数据也会跟着同步变化。这也算是vue的精髓之处了。**值得注意的是，**我们所说的数据双向绑定，一定是对于UI控件来说的，非UI控件不会涉及到数据双向绑定。 单向数据绑定是使用状态管理工具（如redux）的前提。如果我们使用vuex，那么数据流也是单项的，这时就会和双向数据绑定有冲突，[我们可以这么解决](https://github.com/vuejs/vuex/blob/master/docs/zh-cn/forms.md)。 

**为什么要实现数据的双向绑定**？

　　 在vue中，如果使用vuex，实际上数据还是单向的，之所以说是数据双向绑定，这是用的UI控件来说，对于我们处理表单，vue的双向数据绑定用起来就特别舒服了。

　　 **即两者并不互斥， 在全局性数据流使用单项，方便跟踪； 局部性数据流使用双向，简单易操作。**

## 一、访问器属性

　　[Object.defineProperty()函数](http://javascript.ruanyifeng.com/stdlib/attributes.html#toc2)可以定义对象的属性相关描述符， 其中的set和get函数对于完成数据双向绑定起到了至关重要的作用，下面，我们看看这个函数的基本使用方式。 

```javascript
var obj = {
      foo: 'foo'
    }

    Object.defineProperty(obj, 'foo', {
      get: function () {
        console.log('将要读取obj.foo属性');
      }, 
      set: function (newVal) {
        console.log('当前值为', newVal);
      }
    });

    obj.foo; // 将要读取obj.foo属性
    obj.foo = 'name'; // 当前值为 name
```

　　可以看到，get即为我们访问属性时调用，set为我们设置属性值时调用。

## 二、简单的数据双向绑定实现方法

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>forvue</title>
</head>
<body>
  <input type="text" id="textInput">
  输入：<span id="textSpan"></span>
  <script>
    var obj = {},
        textInput = document.querySelector('#textInput'),
        textSpan = document.querySelector('#textSpan');

    Object.defineProperty(obj, 'foo', {
      set: function (newValue) {
        textInput.value = newValue;
        textSpan.innerHTML = newValue;
      }
    });

    textInput.addEventListener('keyup', function (e) {
        obj.foo = e.target.value;
    });

  </script>
</body>
</html>
```

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/1044137-20170825145431808-435745456.png)

可以看到，实现一个简单的数据双向绑定还是不难的： 使用Object.defineProperty()来定义属性的set函数，属性被赋值的时候，修改Input的value值以及span中的innerHTML；然后监听input的keyup事件，修改对象的属性值，即可实现这样的一个简单的数据双向绑定。

## 三、 实现任务的思路

　　上面我们只是实现了一个最简单的数据双向绑定，而我们真正希望实现的时下面这种方式：

```html
<div id="app">
        <input type="text" v-model="text">
        {{ text }}
    </div>  

    <script>
        var vm = new Vue({
            el: '#app', 
            data: {
                text: 'hello world'
            }
        });
    </script>
```

　即和vue一样的方式来实现数据的双向绑定。那么，**我们可以把整个实现过程分为下面几步：** 

- 输入框以及文本节点与 data 中的数据**绑定**
- 输入框内容变化时，data 中的数据同步变化。即 **view => model 的变化**。
- data 中的数据变化时，文本节点的内容同步变化。即 **model => view 的变化**。

## 四、DocumentFragment

　如果希望实现任务一，我们还需要使用到 DocumentFragment 文档片段，可以把它看做一个容器，如下所示：

```html
<div id="app">
        
    </div>
    <script>
        var flag = document.createDocumentFragment(),
            span = document.createElement('span'),
            textNode = document.createTextNode('hello world');
        span.appendChild(textNode);
        flag.appendChild(span);
        document.querySelector('#app').appendChild(flag)
    </script>
```

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/1044137-20170825151130871-477199008.png)

　　使用文档片段的好处在于：在文档片段上进行操作DOM，而不会影响到真实的DOM，操作完成之后，我们就可以添加到真实DOM上，这样的效率比直接在正式DOM上修改要高很多 。

　　**vue进行编译时，就是将挂载目标的所有子节点劫持到DocumentFragment中，经过一番处理之后，再将DocumentFragment整体返回插入挂载目标**。  

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>forvue</title>
</head>
<body>
    <div id="app">
        <input type="text" id="a">
        <span id="b"></span>
    </div>

    <script>
        var dom = nodeToFragment(document.getElementById('app'));
        console.log(dom);

        function nodeToFragment(node) {
            var flag = document.createDocumentFragment();
            var child;
            while (child = node.firstChild) {
                flag.appendChild(child);
            }
            return flag;
        }

        document.getElementById('app').appendChild(dom);
    </script>

</body>
</html>
```

## 五、初始化数据绑定

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>forvue</title>
</head>
<body>
    <div id="app">
        <input type="text" v-model="text">
        {{ text }}
    </div>
        
    <script>
        function compile(node, vm) {
            var reg = /\{\{(.*)\}\}/;

            // 节点类型为元素
            if (node.nodeType === 1) {
                var attr = node.attributes;
                // 解析属性
                for (var i = 0; i < attr.length; i++) {
                    if (attr[i].nodeName == 'v-model') {
                        var name = attr[i].nodeValue; // 获取v-model绑定的属性名
                        node.value = vm.data[name]; // 将data的值赋值给该node
                        node.removeAttribute('v-model');
                    }
                }
            }

            // 节点类型为text
            if (node.nodeType === 3) {
                if (reg.test(node.nodeValue)) {
                    var name = RegExp.$1; // 获取匹配到的字符串
                    name = name.trim();
                    node.nodeValue = vm.data[name]; // 将data的值赋值给该node
                }
            }
        }

        function nodeToFragment(node, vm) {
            var flag = document.createDocumentFragment();
            var child;

            while (child = node.firstChild) {
                compile(child, vm);
                flag.appendChild(child); // 将子节点劫持到文档片段中
            }
            
            return flag;
        }

        function Vue(options) {
            this.data = options.data;
            var id = options.el;
            var dom = nodeToFragment(document.getElementById(id), this);
            // 编译完成后，将dom返回到app中。
            document.getElementById(id).appendChild(dom);
        }

        var vm  = new Vue({
            el: 'app',
            data: {
                text: 'hello world'
            }
        });


    </script>

</body>
</html>
```

以上的代码实现而立任务一，我们可以看到，hello world 已经呈现在了输入框和文本节点中了。 ![img](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/1044137-20170825155926933-1355261671.png)

## 六、响应式的数据绑定

　　我们再来看看任务二的实现思路： 当我们在输入框输入数据的时候，首先触发的时input事件（或者keyup、change事件），在相应的事件处理程序中，我们获取输入框的value并赋值给vm实例的text属性。 我们会利用defineProperty将data中的text设置为vm的访问器属性，因此给vm.text赋值，就会触发set方法。 在set方法中主要做两件事情，第一是**更新属性的值**，第二留在任务三种说。

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>forvue</title>
</head>
<body>
    <div id="app">
        <input type="text" v-model="text">
        {{ text }}
    </div>
        
    <script>
        function compile(node, vm) {
            var reg = /\{\{(.*)\}\}/;

            // 节点类型为元素
            if (node.nodeType === 1) {
                var attr = node.attributes;
                // 解析属性
                for (var i = 0; i < attr.length; i++) {
                    if (attr[i].nodeName == 'v-model') {
                        var name = attr[i].nodeValue; // 获取v-model绑定的属性名
                        node.addEventListener('input', function (e) {
                            // 给相应的data属性赋值，进而触发属性的set方法
                            vm[name] = e.target.value;
                        })


                        node.value = vm[name]; // 将data的值赋值给该node
                        node.removeAttribute('v-model');
                    }
                }
            }

            // 节点类型为text
            if (node.nodeType === 3) {
                if (reg.test(node.nodeValue)) {
                    var name = RegExp.$1; // 获取匹配到的字符串
                    name = name.trim();
                    node.nodeValue = vm[name]; // 将data的值赋值给该node
                }
            }
        }

        function nodeToFragment(node, vm) {
            var flag = document.createDocumentFragment();
            var child;

            while (child = node.firstChild) {
                compile(child, vm);
                flag.appendChild(child); // 将子节点劫持到文档片段中
            }
            
            return flag;
        }

        function Vue(options) {
            this.data = options.data;
            var data = this.data;

            observe(data, this);

            var id = options.el;
            var dom = nodeToFragment(document.getElementById(id), this);
            // 编译完成后，将dom返回到app中。
            document.getElementById(id).appendChild(dom);
        }

        var vm  = new Vue({
            el: 'app',
            data: {
                text: 'hello world'
            }
        });



        function defineReactive(obj, key, val) {
            // 响应式的数据绑定
            Object.defineProperty(obj, key, {
                get: function () {
                    return val;
                },
                set: function (newVal) {
                    if (newVal === val) {
                        return; 
                    } else {
                        val = newVal;
                        console.log(val); // 方便看效果
                    }
                }
            });
        }

        function observe (obj, vm) {
            Object.keys(obj).forEach(function (key) {
                defineReactive(vm, key, obj[key]);
            });
        }


    </script>

</body>
</html>
```

## 七、 订阅/发布模式（subscribe & publish）

　　text属性变化了，set方法触发了，但是文本节点的内容没有变化。 如何才能让同样绑定到text的文本节点也同步变化呢？ 这里又有一个知识点： 订阅发布模式。

　　订阅发布模式又称为观察者模式，**定义了一种一对多的关系**，**让多个观察者同时监听某一个主题对象**，这个主题对象的状态发生改变时就会通知所有的观察者对象。 

　　**发布者发出通知** =>**主题对象收到通知**并**推送给订阅者 => 订阅者执行相应的操作。** 

```javascript
// 一个发布者 publisher，功能就是负责发布消息 - publish
        var pub = {
            publish: function () {
                dep.notify();
            }
        }

        // 多个订阅者 subscribers， 在发布者发布消息之后执行函数
        var sub1 = { 
            update: function () {
                console.log(1);
            }
        }
        var sub2 = { 
            update: function () {
                console.log(2);
            }
        }
        var sub3 = { 
            update: function () {
                console.log(3);
            }
        }

        // 一个主题对象
        function Dep() {
            this.subs = [sub1, sub2, sub3];
        }
        Dep.prototype.notify = function () {
            this.subs.forEach(function (sub) {
                sub.update();
            });
        }


        // 发布者发布消息， 主题对象执行notify方法，进而触发订阅者执行Update方法
        var dep = new Dep();
        pub.publish();
```

## 八、 双向绑定的实现

　　回顾一下，每当new一个Vue，主要做了两件事情：第一是监听数据：observe(data)，第二是编译HTML：nodeToFragment(id)

　　在监听数据的过程中，会为data中的每一个属性生成一个主题对象dep。 

　　在编译HTML的过程中，会为每一个与数据绑定相关的节点生成一个订阅者 watcher，watcher会将自己添加到相应属性的dep中。 

　　我们已经实现了： 修改输入框内容 => 在事件回调函数中修改属性值 => 触发属性的set方法。

　　接下来我们要实现的是： 发出通知 dep.notify() => 触发订阅者update方法 => 更新视图。

　　这里的关键逻辑是： 如何将watcher添加到关联属性的dep中。

```javascript
function compile(node, vm) {
            var reg = /\{\{(.*)\}\}/;

            // 节点类型为元素
            if (node.nodeType === 1) {
                var attr = node.attributes;
                // 解析属性
                for (var i = 0; i < attr.length; i++) {
                    if (attr[i].nodeName == 'v-model') {
                        var name = attr[i].nodeValue; // 获取v-model绑定的属性名
                        node.addEventListener('input', function (e) {
                            // 给相应的data属性赋值，进而触发属性的set方法
                            vm[name] = e.target.value;
                        })


                        node.value = vm[name]; // 将data的值赋值给该node
                        node.removeAttribute('v-model');
                    }
                }
            }

            // 节点类型为text
            if (node.nodeType === 3) {
                if (reg.test(node.nodeValue)) {
                    var name = RegExp.$1; // 获取匹配到的字符串
                    name = name.trim();
                    // node.nodeValue = vm[name]; // 将data的值赋值给该node

                    new Watcher(vm, node, name);
                }
            }
        }
```

在编译HTML的过程中，为每个和data关联的节点生成一个Watcher。那么Watcher函数中发生了什么呢？

```javascript
function Watcher(vm, node, name) {
            Dep.target = this;
            this.name = name;
            this.node = node;
            this.vm = vm;
            this.update();
            Dep.target = null;
        }

        Watcher.prototype = {
            update: function () {
                this.get();
                this.node.nodeValue = this.value;
            },

            // 获取data中的属性值
            get: function () {
                this.value = this.vm[this.name]; // 触发相应属性的get
            }
        }
```

首先，将自己赋值给了一个全局变量 Dep.target;

其次，执行了update方法，进而执行了 get 方法，get方法读取了vm的访问器属性， 从而触发了访问器属性的get方法，get方法将该watcher添加到对应访问器属性的dep中；

再次，获取顺序性的值， 然后更新视图。

最后将Dep.target设置为空。 因为他是全局变量，也是watcher和dep关联的唯一桥梁，任何时候，都必须保证Dep.target只有一个值。

## 最终如下：

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>forvue</title>
</head>
<body>
    <div id="app">
        <input type="text" v-model="text"> <br>
        {{ text }} <br>
        {{ text }}
    </div>
        
    <script>
        function observe(obj, vm) {
            Object.keys(obj).forEach(function (key) {
                defineReactive(vm, key, obj[key]);
            });
        }


        function defineReactive(obj, key, val) {

            var dep = new Dep();

            // 响应式的数据绑定
            Object.defineProperty(obj, key, {
                get: function () {
                    // 添加订阅者watcher到主题对象Dep
                    if (Dep.target) {
                        dep.addSub(Dep.target);
                    }
                    return val;
                },
                set: function (newVal) {
                    if (newVal === val) {
                        return; 
                    } else {
                        val = newVal;
                        // 作为发布者发出通知
                        dep.notify()                        
                    }
                }
            });
        }
        
        function nodeToFragment(node, vm) {
            var flag = document.createDocumentFragment();
            var child;

            while (child = node.firstChild) {
                compile(child, vm);
                flag.appendChild(child); // 将子节点劫持到文档片段中
            }
            
            return flag;
        }

        function compile(node, vm) {
            var reg = /\{\{(.*)\}\}/;

            // 节点类型为元素
            if (node.nodeType === 1) {
                var attr = node.attributes;
                // 解析属性
                for (var i = 0; i < attr.length; i++) {
                    if (attr[i].nodeName == 'v-model') {
                        var name = attr[i].nodeValue; // 获取v-model绑定的属性名
                        node.addEventListener('input', function (e) {
                            // 给相应的data属性赋值，进而触发属性的set方法
                            vm[name] = e.target.value;
                        })
                        node.value = vm[name]; // 将data的值赋值给该node
                        node.removeAttribute('v-model');
                    }
                }
            }

            // 节点类型为text
            if (node.nodeType === 3) {
                if (reg.test(node.nodeValue)) {
                    var name = RegExp.$1; // 获取匹配到的字符串
                    name = name.trim();
                    // node.nodeValue = vm[name]; // 将data的值赋值给该node

                    new Watcher(vm, node, name);
                }
            }
        }

        function Watcher(vm, node, name) {
            Dep.target = this;
            this.name = name;
            this.node = node;
            this.vm = vm;
            this.update();
            Dep.target = null;
        }

        Watcher.prototype = {
            update: function () {
                this.get();
                this.node.nodeValue = this.value;
            },

            // 获取data中的属性值
            get: function () {
                this.value = this.vm[this.name]; // 触发相应属性的get
            }
        }

        function Dep () {
            this.subs = [];
        }

        Dep.prototype = {
            addSub: function (sub) {
                this.subs.push(sub);
            },

            notify: function () {
                this.subs.forEach(function (sub) {
                    sub.update();
                });
            }
        }

        function Vue(options) {
            this.data = options.data;
            var data = this.data;

            observe(data, this);

            var id = options.el;
            var dom = nodeToFragment(document.getElementById(id), this);
            // 编译完成后，将dom返回到app中。
            document.getElementById(id).appendChild(dom);
        }

        var vm  = new Vue({
            el: 'app',
            data: {
                text: 'hello world'
            }
        });

    </script>
</body>
</html>
```

