[toc]

# AOP

> Aspect Oriented Programing 面向切面编程

> AOP采用横向抽取机制，取代了传统纵向继承体系重复性代码（性能监视，事务管理，安全检查，缓存）

## AOP相关概念

Joinpoint：连接点

> 那些被拦截的点，在Spring中，这些点指的是方法,因为Spring只支持方法类型的连接点

Poincut：切入点

> 指真正被拦截到的点，如果我们想对save方法进行增强，save方法就是切入点

Advice：通知

> 对save方法进行增强，添加权限校验的功能。这里权限校验的方法就是通知。

Target：目标

>被增强的对象

Wearving：织入

>讲Advice应用到Target的过程

Proxy：代理

>被应用了增强后产生的代理对象

Aspect：切面

>切入点和通知的组合。

## AOP底层实现：

### JDK动态代理

首先创建接口

```java
public interface UserDao {
    public void save();
    public void update();
    public void delete();
    public void find();
}
```

创建实现类

```java
public class UserDaoImpl implements UserDao {
    @Override
    public void save() { System.out.println("保存用户..."); }
    @Override
    public void update() { System.out.println("修改用户..."); }
    @Override
    public void delete() { System.out.println("删除用户..."); }
    @Override
    public void find() { System.out.println("查询用户..."); }
}
```

创建动态代理类

```java
// 继承自InvocationHandler，一是满足ProxyInstance的构造参数需要，二是实现接口中的invoke方法
public class MyJdkProxy implements InvocationHandler {
    private UserDao userDao;
    public MyJdkProxy(UserDao userDao) {
        this.userDao = userDao;
    }

    public Object createProxy() {
        // newProxyInstance构建代理对象需要三个参数，第一个是类的加载器，第二个是接口的所以实现类，第二个需要传入InvocationHandler的实现类
        Object proxy = Proxy.newProxyInstance(userDao.getClass().getClassLoader(),userDao.getClass().getInterfaces(),this);
        return proxy;
    }

    /**
     * InvocationHandler中的实现方法
     * invoke方法相当于类的在执行方法时做执行的方法，这里可以对invoke进行改造即可满足动态代理的需求
     */
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        if ("save".equals(method.getName())) {
            System.out.println("权限校验");
        }
        // 如果方法名不正确直接返回原始的invoke，参数为接口的实现类和方法的全部参数（args）
        return method.invoke(userDao,args);
    }
}
```

测试方法

```java
@Test
    public void demo1() {
        UserDao userDao = new UserDaoImpl();
        UserDao proxy = (UserDao)new MyJdkProxy(userDao).createProxy();
        proxy.save();
        proxy.find();
        proxy.update();
        proxy.delete();
    }
```

运行结果

```
权限校验
保存用户...
查询用户...
修改用户...
删除用户...
```

### 使用CCGLIB生成代理

对于不使用接口的业务类，无法使用JDK动态代理。CCGLIB采用字节码技术，可以为一个类创建一个字类。

创建一个没有接口的实体类

```java
public class ProductDao {
    public void save() { System.out.println("保存商品..."); }
    public void update() { System.out.println("修改商品..."); }
    public void delete() { System.out.println("删除商品..."); }
    public void find() { System.out.println("查询商品..."); }
}
```

创建动态代理类

```java
public class MyCglibProxy implements MethodInterceptor {

    private ProductDao productDao;

    public MyCglibProxy(ProductDao productDao) {
        this.productDao = productDao;
    }

    public Object createProxy() {
        // 1. 创建核心类
        Enhancer enhancer = new Enhancer();
        // 2, 设置父类
        enhancer.setSuperclass(productDao.getClass());
        // 3. 设置回调
        enhancer.setCallback(this);
        // 4. 生成代理
        Object proxy = enhancer.create();
        return proxy;
    }

    @Override
    public Object intercept(Object proxy, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
        if ("save".equals(method.getName())) {
            System.out.println("权限校验=======");
            // invokeSuper相当于调用父类productDao中的方法
            return methodProxy.invokeSuper(proxy, args);
        }
        return methodProxy.invokeSuper(proxy, args);
    }
}

```

```java
@Test
public void demo1() {
    ProductDao productDao = new ProductDao();
    ProductDao proxy = (ProductDao)new MyCglibProxy(productDao).createProxy();
    proxy.save();
    proxy.delete();
    proxy.find();
    proxy.update();
}
```

注意：

	- 优先对接口进行代理，便于解耦维护
 - 标记为final的方法，不能被代理，无法进行覆盖
   	- JDK动态代理，是针对接口生成子类，接口中的方法不能用final修饰
   	- CGLib是针对目标类生产子类，因此类和方法不能用final修饰
- Spring只提供方法连接点，不提供属性连接点

## Spring AOP增强类型

AOP联盟对通知Advice定义了`org.aopalliance.aop.Interface.Advise`

Spring按照通知Advice在目标类方法的连接点配置，可以分为五类

- 前置通知`org.springframework.aop.MethpdBeforAdvice`在目标方法之前实施增强
- 后置通知 `org.springframework.aop.AfterReturningAdvice`在目标方法之后实施增强
- 环绕通知`org.aopalliance.intercept.MethedInterceptor`在目标方法前后实施增强
- 异常抛出通知`org.springframework.aop.ThrowsAdvice`在方法抛出异常后实施增强
- ~~引介通知~~`org.springframework.aop.IntroductionInterceptor`在目标类添加新的方法和属性，**并非Spring本身提供的类型。**

## Spring AOP切面类型

**Advisor：**一般切面，Advice本身就是一个切面，**对目标类所有方法进行拦截。**

**PointcutAdvisor：**代表具有切点的切面，**可以指定拦截目标类哪些方法**

**IntroductionAdvisor：**代表引介切面，针对引介通知而使用切面

## 以通知作为切面的配置

首先新建一个DAO接口类

```java
public interface StudentDao {
    public void save();
    public void delete();
    public void update();
    public void find();
}
```

实现接口

```java
public class StudentDaoImpl implements StudentDao {
    @Override
    public void save() {
        System.out.println("保存学生...");
    }
    @Override
    public void delete() {
        System.out.println("删除学生...");
    }
    @Override
    public void update() {
        System.out.println("更新学生...");
    }
    @Override
    public void find() {
        System.out.println("查找学生...");
    }
}
```

创建advice前置通知

```java
@Override
    public void before(Method method, Object[] objects, Object o) throws Throwable {
        System.out.println("前置增强================ ");
    }
```

配置代理对象

```xml
		<!--配置一个目标类-->
    <bean id="studentDao" class="com.imooc.aop.demo3.StudentDaoImpl"/>

    <!--前置通知类型-->
    <bean id="myBeforeAdvice" class="com.imooc.aop.demo3.MyBeforeAdvice"/>
		
		<!--创建代理对象-->
    <bean id="studentDaoProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
        <!--目标类-->
        <property name="target" ref="studentDao"/>
        <!--实现的接口-->
        <property name="proxyInterfaces" value="com.imooc.aop.demo3.StudentDao"/>
        <!--采用拦截的名称-->
        <property name="interceptorNames" value="myBeforeAdvice"/>
    </bean>
```

进行代理对象测试

​	添加相关依赖

```xml
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-test</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>
```

​	建立测试类

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class SpringDemo3 {
    
    @Resource(name = "studentDaoProxy")
    private StudentDao studentDao;

    @Test
    public void demo1() {
        studentDao.find();
        studentDao.save();
        studentDao.update();
        studentDao.delete();
    }
}
```

SpringAOP其余配置

`proxyTargetClass`是否对类代理而不是接口，设置为Ture时，使用CGLlib代理

`interceptorNames`需要注入目标的Advice

`singleton`返回代理是否为单实例，默认为单实例

`optimize`	设置为ture时，强制使用CGLib

## 带有切入点的切面

使用普通Advice作为切面，对所有方法进行拦截，不够灵活，在实际开发中常采用带切入点的切面

常用PointcutAdvisor实现类

`DefaultPointAdvisor`可以通过任意PintCut和Advice组合定义切面

`JdkRegexpMethodPointcut`构造**正则表达**式切入点

### 正则表达式切入点案例

创建实体类

```java
public class CustomerDao {
    public void save() {
        System.out.println("保存客户...");
    }
    // ...
}
```

构建环形通知

```java
public class MyAroundAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation methodInvocation) throws Throwable {
        System.out.println("环绕前增强==========");
        Object obj = methodInvocation.proceed();
        System.out.println("环绕后增强==========");
        return obj;
    }
}
```

配置切片

步骤：

​	定义目标类 —> 定义通知 —> 定义切面（配置正则->配置通知）

​								—> 配置产生代理：目标类（接口），接入点

​								注意：配置产生代理时，**如果目标类不存在接口**，则必须属性**proxyTargetClass**的值为**True**

```xml
    <!--配置目标类-->
    <bean id="customerDao" class="com.imooc.aop.demo4.CustomerDao"/>

    <!--配置通知-->
    <bean id="myAroundAdvice" class="com.imooc.aop.demo4.MyAroundAdvice"/>

    <!--一般的切面使用通知作为切面，因为要对目标类的某个方法进行增强就需要配置带有切入点的切面-->
    <bean id="myAdvisor" class="org.springframework.aop.support.RegexpMethodPointcutAdvisor">
        <!--pattern中配置的为正则表达式: .任意字符 * 任意次数-->
        <!--<property name="pattern" value=".*"/>-->
        <!--<property name="pattern" value=".*save.*"/>-->
        <property name="patterns" value=".*save.*,.*find.*"/>
        <property name="advice" ref="myAroundAdvice"/>
    </bean>

    <!--配置产生代理-->
    <bean id="customerDaoProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
        <property name="target" ref="customerDao"/>
        <property name="proxyTargetClass" value="true"/>
        <property name="interceptorNames" value="myAdvisor"/>
    </bean>
```

测试类：

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext2.xml")
public class SpringDemo4 {
    @Resource(name = "customerDaoProxy")
    private CustomerDao customerDao;
    @Test
    public void demo1() {
        customerDao.find();
        customerDao.save();
        customerDao.update();
        customerDao.delete();
    }
}
```

## 自动创建配置

使用自动创建代理可以避免由于频繁使用**ProxyFactory织入切片代理**导致的大量配置，提高开发效率。

自动代理方式：

​	`BeanNameAutoProxyCreator`：根据Bean名称创建代理

```xml
    <!--配置类-->
    <bean id="studentDao" class="com.imooc.aop.demo5.StudentDaoImpl"/>
    <bean id="customerDao" class="com.imooc.aop.demo5.CustomerDao"/>

    <!--配置增强-->
    <bean id="myBeforeAdvice" class="com.imooc.aop.demo5.MyBeforeAdvice"/>
    <bean id="myAroundAdvice" class="com.imooc.aop.demo5.MyAroundAdvice"/>

    <bean class="org.springframework.aop.framework.autoproxy.BeanNameAutoProxyCreator">
        <!--基于bean名称的自动代理,正则表达式指定—-->
        <property name="beanNames" value="*Dao"/>
        <!--指定通知Bean-->
        <property name="interceptorNames" value="myBeforeAdvice"/>
    </bean>
```

​	

