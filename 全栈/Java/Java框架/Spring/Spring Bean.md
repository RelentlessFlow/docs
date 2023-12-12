[toc]

# Spring Bean管理

<hr>

### 创建SpringBean的三种方式

**applicationContext.xml**

```xml
    <!--Bean的实例化的三种方式-->
    <!--第一种，无参数构造方法-->
    <bean id="bean1" class="com.imooc.ioc.demo2.Bean1"/>
    <!--第二种，静态工厂的方式-->
    <bean id="bean2" class="com.imooc.ioc.demo2.Bean2Factory" factory-method="createBean2"/>
    <!--第三种，实例工厂的方式-->
    <bean id="bean3Factory" class="com.imooc.ioc.demo2.Bean3Factory"/>
    <bean id="bean3" factory-bean="bean3Factory" factory-method="createBean3"/>
```

Bean 1/2/3

```java
// 一、采用无参数构造方法
public class Bean1 {
    public Bean1(){
        System.out.println("Bean1被实例化了。。。");
    }
}
// 二、静态工厂实例化方式
public class Bean2 {
}

// Bean2的静态工厂
public class Bean2Factory {
    public static Bean2 createBean2(){
        System.out.println("Bean2工厂已经执行了");
        return new Bean2();
    }
}
// 实例工厂实例化
public class Bean3 {}

//三、Bean3的实例工厂
public class Bean3Factory {
    public Bean3 createBean3() {
        System.out.println("Bean3Factory执行了");
        return new Bean3();
    }
}

// 测试类 1/2/3
@Test 
public void demo1() {
	 // 创建工厂
	ApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");
	// 通过工厂获得类的实例
	Bean1 bean1 = (Bean1)applicationContext.getBean("bean1");
}
```

<hr>

### Bean的配置

#### id/name 

> 装配一个Bean时，通过指定一个id属性作为Bean的名称，id属性在IOC容器中必须是唯一的，name用于在bean名有特殊符号（历史遗留问题）

#### class

> 用于设置类完全路径名称，主要用于IOC容器生成类的实例

### Bean的作用域

```xml
<bean id="person" class="com.imooc.ioc.demo3.Person" scope="prototype"/>
<bean id="student" class="com.imooc.ioc.demo3.Student" scope="singleton"/>
```

注意：如果不写scope默认值为singleton（单例）

singleton：单例模式

prototype：多例模式

request：每次HTTP请求返回一个新的Bean

session：同一Session共享一个Bean

<hr>

### Bean生命周期

```xml
<bean id="man" class="com.imooc.ioc.demo3.Man" init-method="Setup" destroy-method="TurnDown"/>
```

init-method：初始化方法

destroy-method：销毁方法（必须指定scope为singleton）

测试类：

```java
    @Test
    public void text() {
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");
        Man man = (Man) applicationContext.getBean("man");
        System.out.println(man);
        applicationContext.close();
    }
```

**注意：ClassPathXmlApplicationContext为ApplicationContext接口的实现类。**

### Bean生命周期详解

> 生命周期分为11步：

applicationContext.xml

```xml
<!--Bean的完整生命周期-->
    <bean id="my_person" class="com.imooc.ioc.demo4.Person" init-method="setup" destroy-method="turndown">
        <property name="name" value="张三"/>
    </bean>
    <bean class="com.imooc.ioc.demo4.MyBeanPostProcessor"/>
```

Person.java

```java
public class Person implements BeanNameAware, ApplicationContextAware, InitializingBean , DisposableBean {
    private String name;

    Person() {
        System.out.println("第一步，对象实例化");
    }

    public void setName(String name) {
        System.out.println("第二步，设置属性");
        this.name = name;
    }

    @Override
    public void setBeanName(String s) {
        System.out.println("第三步，设置Bean的名称");
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("第四步，了解工厂的信息");
    }


    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("第六步，属性设置后执行的");
    }

    public void setup() {
        System.out.println("第七部，执行init初始化方法");
    }

    public void run() {
        System.out.println("第九步，执行业务方法");
    }


    @Override
    public void destroy() throws Exception {
        System.out.println("第十步，执行Spring销毁方法");
    }

    public void turndown() {
        System.out.println("第十一步，执行销毁方法");
    }
}
```

**MyBeanPostProcessor.java**：对类进行代理与增强

```java
public class MyBeanPostProcessor implements BeanPostProcessor {


    @Override
    public Object postProcessBeforeInitialization(Object o, String s) throws BeansException {
        System.out.println("第五步，初始化前方法。。。");
        return o;
    }

    @Override
    public Object postProcessAfterInitialization(Object o, String s) throws BeansException {
        System.out.println("第八步，初始化后方法。。。");
        return o;
    }
}
```

Text.java

```java
    @Test
    public void demo() {
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");
        Person person = (Person)applicationContext.getBean("my_person");
        person.run();
        applicationContext.close();
    }
}
```

### bean postprocessor的作用

> 利用JDK动态代理可以加强类方法的功能，并且无需修改类源码

```java
@Override
    public Object postProcessAfterInitialization(final Object bean, String beanName) throws BeansException {
//        System.out.println("第八步，初始化后方法。。。");
        if ("userDao".equals(beanName)) {
            Object proxy = Proxy.newProxyInstance(bean.getClass().getClassLoader(), bean.getClass().getInterfaces(), new InvocationHandler() {
                @Override
                public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                    if ("save".equals(method.getName())){
                        System.out.println("权限校验===========");
                        return method.invoke(bean,args);
                    }
                    return method.invoke(bean,args);
                }
            });
            return proxy;
        }else {
            return bean;
        }
    }
```

<hr>

### Bean构造方法、属性注入、Getter、Setter，P、SPEL、复杂类型属性注入

> 首先创建三个类，User，Cat，Text

User类三个成员变量：name，age，cat，创建构造方法，创建toString方法

```xml
     <bean id="user" class="com.imooc.ioc.demo5.User">
            <constructor-arg name="name" value="张三"/>
            <constructor-arg name="age" value="23"/>
            <property name="name" value="李四"/>
            <property name="age" value="26"/>
            <property name="cat" ref="cat"/>
        </bean>

        <bean id="cat" class="com.imooc.ioc.demo5.Cat">
            <property name="name" value="小黄"/>
        </bean>
```

property的set优先级高于constructor-arg，会替代constructor-arg设置的值

利用p名称空间简化属性注入

注入命令空间

将`xmlns:p="http://www.springframework.org/schema/p"`注入命名空间

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
```

将普通的property属性注入更改为p属性注入

```xml
<bean id="user" class="com.imooc.ioc.demo5.User" p:name="张三" p:age="26" p:cat-ref="cat">
        <constructor-arg name="name" value="张三"/>
        <constructor-arg name="age" value="23"/>
</bean>

<bean id="cat" class="com.imooc.ioc.demo5.Cat" p:name="小黄"/>
```

spel属性注入

```xml
		<bean id="category" class="com.imooc.ioc.demo6.Category">
        <property name="name" value="#{'服装'}"/>
		</bean>

    <bean id="productInfo" class="com.imooc.ioc.demo6.ProductInfo"/>

    <bean id="product" class="com.imooc.ioc.demo6.Product">
        <property name="name" value="#{'男装'}"/>
        <property name="category" value="#{category}"/>
        <property name="price" value="#{productInfo.calculatePrice()}"/>
    </bean>
```

复杂类型属性注入

```xml
<bean id="collectionBean" class="com.imooc.ioc.demo6.CollectionBean">
        <property name="args">
            <list>
                <value>aaa</value>
                <value>bbb</value>
                <value>ccc</value>
            </list>
        </property>

        <property name="list">
            <list>
                <value>111</value>
                <value>222</value>
                <value>333</value>
            </list>
        </property>

        <property name="set">
            <list>
                <value>ddd</value>
                <value>eee</value>
                <value>fff</value>
            </list>
        </property>

        <property name="map">
            <map>
                <entry key="aaa" value="111"/>
                <entry key="bbb" value="111"/>
                <entry key="ccc" value="111"/>
            </map>
        </property>

        <property name="properties">
            <props>
                <prop key="username">root</prop>
                <prop key="password">1234</prop>
            </props>
        </property>
    </bean>
```

### 注解定义Bean

> Spring2.5之后使用注解定义Bean

`@Component`描述Spring框架中的Bean

除了Component外，Spring提供了三个功能基础和@Component等效的注解

`@Repository`用于对DAO实现类进行标注

`@Service`用于对Service实现类进行标注

`@Controller`用于对Controller实现类进行标注

注意：使用注解定义Bean时首先应配置

```xml
// applicationContext.xml 添加包名
<!--开启注解扫描-->
<context:component-scan base-package="com.company"/> 
```

#### 属性输入注解

```java
@Service("userService")
public class UserService {
    @Value("米饭")
    private String someThing;
    @Autowired
    @Qualifier("userDao")
    private UserDao userDao;
  	// ...
}

@Repository("userDao")
public class UserDao {
    public void save() {
        System.out.println("DAO保存用户");
    }
}
```

对于普通类型的数据，可以使用`@Value()`注解。

对于复杂类型的数据，可以使用@Autowired注解，@Autowired会根据对象的类型（类名）自动进行查找，此时`@Repository("userDao")`没有作用。

如果通过@Repository指定的ID进行查找就需要利用`@Qualifier("userDao")`注解进行ID的查找访问

注意：`@Autowired	@Qualifier("userDao")`可以简化为`@Resource(name = "userDao")`

#### 其余注解

```java
@Component("bean1")
@Scope("prototype")
public class Bean {

    @PostConstruct
    public void init() {
        System.out.println("initBean...");
    }

    public void say() {
        System.out.println("say...");
    }

    @PreDestroy
    public void destroy() {
        System.out.println("destroy");
    }
}
```

`@Scope("prototype")`为多例模式，默认为singleton单例模式。

`@PostConstruct`、`@PreDestroy`指定初始化生命周期方法，销毁生命周期方法

#### XML与注解混合开发

##### 传统XML开发

类文件：

```java
public class CategoryDao { public void save() { System.out.println("The method of CategoryDao executed"); }}

public class ProductDao { public void save() { System.out.println("The method of ProductDao executed"); }}

public class ProductService {
    private CategoryDao categoryDao;
    private ProductDao productDao;

    public void setCategoryDao(CategoryDao categoryDao) {
        this.categoryDao = categoryDao;
    }

    public void setProductDao(ProductDao productDao) {
        this.productDao = productDao;
    }

    public void save(){
        System.out.println("The method of ProductService executed");
        categoryDao.save();
        productDao.save();
    }
}
```

 配置文件：

```xml
<bean id="productService" class="com.company.demo3.ProductService">
        <property name="productDao" ref="productDao"/>
        <property name="categoryDao" ref="categoryDao"/>
    </bean>

    <bean id="productDao" class="com.company.demo3.ProductDao"/>

    <bean id="categoryDao" class="com.company.demo3.CategoryDao"/>
```

##### XML与注解混合

类文件更改为

```java
public class ProductService {
    @Resource(name = "categoryDao")
    private CategoryDao categoryDao;
    @Resource(name = "productDao")
    private ProductDao productDao;

    public void save(){
        System.out.println("The method of ProductService executed");
        categoryDao.save();
        productDao.save();
    }
}
```

配置文件添加

```xml
    <!-- 属性注入配置-->
		<context:annotation-config/>

    <bean id="productService" class="com.company.demo3.ProductService"/>

    <bean id="productDao" class="com.company.demo3.ProductDao"/>

    <bean id="categoryDao" class="com.company.demo3.CategoryDao"/>
```

<context:annotation-config/>为属性注入配置，之前用包扫描的方式中包含了这条配置

   