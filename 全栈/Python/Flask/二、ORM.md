# Flask ORM

## 1.1 ORM

python 本身是可以操作数据库的，但是在开发中这些步骤却显得有些复杂，同时数据库可移植性差和开发人员数据库技术参差不齐等问题也尤为突出。为了解决以上问题，从而有了ORM（object relationship mapping）。

数据库关系映射：用面向对象的类对应数据库当中的表，开发者通过面向对象编程来描述数据库表、结构和增删改查，然后将描述映射到数据库，完成对数据库的操作。用户不需要再去和SQL语句打交道，只要像平时操作对象一样操作即可。

![image-20211115191443346](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20211115191443346.png)

由于[flask](https://so.csdn.net/so/search?from=pc_blog_highlight&q=flask)本身没有操作数据库的能力，需要借助flask_sqlalchemy（ORM框架）进行操作。

```
pip install flask_sqlalchemy
```

## 1.2 数据库初始化

>  sqlite数据库，是和[python](https://so.csdn.net/so/search?from=pc_blog_highlight&q=python)最契合的轻量级关系型数据库，python在安装同时已经携带了sqlite数据库。sqlite数据库就是一个.sqlite文件。

### 3、数据库初始化

创建数据库并将数据库文件的存放到指定位置、创建表。

```python
import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy  # 导入flask_sqlalchemy模块

base_dir = os.path.dirname(  
    os.path.abspath(__file__)  # 获取当前文件的绝对路径
)  # 返回当前文件的目录

app = Flask(__name__)  # 实例化app
# 设置数据库文件存放的路径为当前文件目录下，以OA.sqlite命名
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///"+os.path.join(base_dir, "OA.sqlite")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = True  # 设置数据库支持追踪修改
db = SQLAlchemy(app)  # 加载数据库

class Person(db.Model):  # 定义数据表，db.Model是所有创建表的父类
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    # Column：列，primary_key：主键，autoincrement：自增长
    username = db.Column(db.String(32), unique=True)  # 用户名不能重复
    password = db.Column(db.String(32))
    nickname = db.Column(db.String(32))
    age = db.Column(db.Integer, default=18)  # 年龄默认十八岁
    gender = db.Column(db.String(16))
    score = db.Column(db.Float, nullable=True)  # 值可以为空

 
db.create_all()  # 同步数据库
```

数据表字段常用的数据类型：

| 数据类型 | 描述         |
| -------- | ------------ |
| Integer  | 整形         |
| Float：  | 浮点型       |
| String   | 字符串       |
| Date     | 年月日       |
| Datetime | 年月日时分秒 |
| Text     | 长文本       |

字段的常用参数

| 参数        | 描述       |
| ----------- | ---------- |
| primary_key | 主键       |
| unique      | 键值唯一性 |
| nullable    | 空值       |
| default     | 默认值     |
| index       | 索引       |

### 4、增

添加数据到数据库中

```python
person1 = Person(
    username="laoli",
    password="123456",
    nickname="老李",
    age=18,
    gender="男",
    score=96.5
)
person2 = Person(
    username="laosun",
    password="123456",
    nickname="老孙",
    age=18,
    gender="男",
    score=92.5
)
# 增加单条数据 
db.session.add(person1)
db.session.commit()

# 增加多条数据
db.session.add_all([person1, person2])
db.session.commit()
```