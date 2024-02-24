# 手写bind

```javascript
Function.prototype.bind = function() {
    const args = Array.prototype.slice.call(arguments);
    const that = args.shift();
    const self = this;
    return function() {
        return self.apply(that, args);
    }
}

function A() {
    this.name = 'A'
}

function B() {
    this.name = 'B'
    this.sayName = function() {
        return this.name;
    }
}

const b = new B()
const a = new A();
b.sayName.bind(a)() // A
```

