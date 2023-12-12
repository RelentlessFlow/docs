[toc]
# AspectJ AOP

 ## 使用AspectJ注解开发

**开发准备**

porn.xml

```xml
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.12</version>
    </dependency>
    <!--引入Spring的基本开发包-->
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-core</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-context</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-beans</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-expression</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>

    <dependency>
      <groupId>aopalliance</groupId>
      <artifactId>aopalliance</artifactId>
      <version>1.0</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-aop</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>

    <dependency>
      <groupId>org.aspectj</groupId>
      <artifactId>aspectjweaver</artifactId>
      <version>1.8.9</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-aspects</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>

    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-test</artifactId>
      <version>4.2.4.RELEASE</version>
    </dependency>
  </dependencies>
```

XML配置模版：https://docs.spring.io/spring-framework/docs/4.2.4.RELEASE/spring-framework-reference/html/xsd-configuration.html#xsd-config-body-schemas-beans

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop" xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">

    <!--开启aspectj注解开发，自动代理-->
    <aop:aspectj-autoproxy/>

</beans>
```

## @AspectJ提供的通知类型

`@Before`前置通知，相当于BeforeAdvice

`@AfterReturning`后置通知，相当于AfterReturningAdvice

`@Around`环绕通知，相当于MethodInterceptor

`@AfterThrowing`异常抛出通知，相当于ThrowAdvice

`@After`最终通知，不管是否异常，该通知都会执行

`@DeclareParents`引介通知，相当于IntroductionInterceptor 

## 在通知中通过Value属性定义切点

> 通过**execution函数**，可以定义**切点的方法**切入

语法

```java
execution(<访问修饰符>?<返回类型><方法名>(<参数>)<异常>)
```

匹配所以类public方法 `execution(public * *(..))`

匹配指定包下所有类方法`execution(* com.company.dao.*(..))`

包、子孙包下的所有类`execution(* com.company.dao..*(..))`	..*

匹配指定类的所有方法`execution(* com.company.service.UserService.*(..))`

匹配实现特定接口所有类方法`execution(* com.company.dao.GenericDAO+.*(..))`	+表示接口的所有子类

匹配所以save开头的方法`execution(* save*(..))`

## 注解开发基础案例

​	为一个类中的一个方法实现前置代理

**步骤**

1. 定义目标类
2. 为目标类定义切面类
3. 配置Bean
4. 配置测试类

**目标类**ProductDao

```java
public class ProductDao {
    public void save() {
        System.out.println("保存商品");
    }

    public void update() {
        System.out.println("更新商品");
    }

    public void delete() {
        System.out.println("删除商品");
    }

    public void findOne() {
        System.out.println("查找一个商品");
    }

    public void findAll() {
        System.out.println("查找所有商品");
    }
}
```

为目标类定义**切面类**

```java
@Aspect
public class MyAspectAnno {

    @Before(value = "execution(* com.company.aspectJ.ProductDao.save(..))")
    public void before() {
        System.out.println("前置通知========");
    }
}
```

配置Bean：applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop" xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">

    <!--开启AspectJ的注解开发，自动代理-->
    <aop:aspectj-autoproxy/>

    <!--目标类-->
    <bean id="productDao" class="com.company.aspectJ.ProductDao"/>

    <!--定义切面-->
    <bean class="com.company.aspectJ.MyAspectAnno"/>
</beans>
```

配置测试类

```xml
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class Text {
    @Resource(name = "productDao")
    private ProductDao productDao;

    @Test
    public void demo1() {
        productDao.save();
        productDao.delete();
        productDao.update();
        productDao.findOne();
        productDao.findAll();
    }
}
```

## @Before 前置通知：利用JoinPoint获取切点信息

可以在方法中传入JoinPoint对象，**用来获取切点信息。**

```java
@Before(value = "execution(* com.company.aspectJ.ProductDao.save(..))")
    public void before(JoinPoint joinPoint) {
        System.out.println("前置通知========" + joinPoint);
    }
```

```
前置通知========execution(void com.company.aspectJ.ProductDao.save())
保存商品
```

## @AfterReturning后置通知：获取后置通知返回值

由于方法具有返回值类型，后置通知又是在方法执行之后执行的通知，因此可以**后置通知可以拿到目标方法的返回值进行调用。**

通过**returning属性**可以定义方法返回值，作为参数。

1. 目标方法，切入点

   ```java
   public String update() {
           System.out.println("更新商品");
           return "后置通知返回值";
       }
   ```

2. 通知

   ```java
   @AfterReturning(value = "execution(* com.company.aspectJ.ProductDao.update(..))",returning = "result")
       public void afterReturning(Object result) {
           System.out.println("后置通知========" + result);
       }
   ```

3. 打印结果

   ```
   更新商品
   后置通知========后置通知返回值
   ```


## @Around 环绕通知

```java
@Around(value = "execution(* com.company.aspectJ.ProductDao.delete(..))")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("环绕前通知========");
        Object obj = joinPoint.proceed();    //如果不调用该方法，目标方法就会被拦截。
        System.out.println("环绕后通知========");
        return obj;
    }
```

- around方法的返回值就是目标代理方法执行返回值

- 参数为ProceedingJoinPoint可以调用拦截目标方法执行
- 如果不调用ProceedingJoinPoint的proceed()方法，目标方法就会被拦截，就不会被执行。

## @AfterThrowing 异常抛出通知

AspectJ可以在切点发生异常时捕获异常并进行异常抛出通知的处理。常用在事务处理的回滚操作上。

```java
public void findOne() {
        System.out.println("查找一个商品");
        int i = 1/0;
    }
```

定义通知

```java
@AfterThrowing(value = "execution(* com.company.aspectJ.ProductDao.findOne(..))",throwing = "e")
    public void afterThrowing(Throwable e) {
      // e.getMessage())可以捕获异常并获取异常信息
        System.out.println("异常抛出通知========" + e.getMessage());
    }
```

- 通过设置throwing属性，可以设置发生异常对象参数。

## @After 最终通知

无论是否实现异常，最终通知总是被执行的。

```java
public void findAll() {
        System.out.println("查找所有商品");
        int i = 1/0;
    }
```

```java
@After(value = "execution(* com.company.aspectJ.ProductDao.findAll(..))")
    public void after() {
        System.out.println("最终通知========");
    }
```

```
最终通知========

java.lang.ArithmeticException: / by zero
	...
```

## @Pointcut为切点命名

可以使用**@Pointcut**定义切点，提高代码维护性。

切点方法：praivite void **无参数构造方法**，方法名为切点名

当使用多个切点，可以用`||`进行连接。

​	**使用PointCut定义之后的切点**

```java
@Before(value = "myPointCut1()")
    public void before(JoinPoint joinPoint) {
        System.out.println("前置通知========" + joinPoint);
    }

    @AfterReturning(value = "myPointCut2()",returning = "result")
    public void afterReturning(Object result) {
        System.out.println("后置通知========" + result);
    }

    @Around(value = "myPointCut3()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("环绕前通知========");
        Object obj = joinPoint.proceed();    //如果不调用该方法，目标方法就会被拦截。
        System.out.println("环绕后通知========");
        return obj;
    }

    @AfterThrowing(value = "myPointCut4()",throwing = "e")
    public void afterThrowing(Throwable e) {
        System.out.println("异常抛出通知========" + e.getMessage());
    }

    @After(value = "myPointCut5()")
    public void after() {
        System.out.println("最终通知========");
    }

    @Pointcut(value = "execution(* com.company.aspectJ.ProductDao.save(..))")
    public void myPointCut1() {}

    @Pointcut(value = "execution(* com.company.aspectJ.ProductDao.update(..))")
    public void myPointCut2() {}

    @Pointcut(value = "execution(* com.company.aspectJ.ProductDao.delete(..))")
    public void myPointCut3() {}

    @Pointcut(value = "execution(* com.company.aspectJ.ProductDao.findOne(..))")
    public void myPointCut4() {}

    @Pointcut(value = "execution(* com.company.aspectJ.ProductDao.findAll(..))")
    public void myPointCut5() {}
```

## XML方式进行AOP开发

使用XML改写注解方法进行开发。

```
porn.xml参见上面的注解依赖
```

```java
// CustomerDao	接口
public interface CustomerDao {
	public void save();
	...
}
```

```java
// CustomerDaoImpl	接口实现类
public class CustomerDaoImpl implements CustomerDao {
	 @Override
    public void save() {
        System.out.println("save...");
    }
    ...
}
```

```java
// MyAspectXml	通知类
public class MyAspectXml {

    public void before(JoinPoint joinPoint) {
        System.out.println("前置通知========" + joinPoint);
    }

    public void afterReturning(Object result) {
        System.out.println("后置通知========" + result);
    }

    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("环绕前通知========");
        Object obj = joinPoint.proceed();    //如果不调用该方法，目标方法就会被拦截。
        System.out.println("环绕后通知========");
        return obj;
    }

    public void afterThrowing() {
        System.out.println("异常抛出通知========");
    }

    public void after() {
        System.out.println("最终通知========");
    }
}
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--applicationContext2.xml-->
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop" xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">

    <!--XML的配置完成AOP开发-->
    <!--配置目标类-->
    <bean id="customerDao" class="com.company.aspectJ.demo2.CustomerDaoImpl"/>

    <!--配置切面类-->
    <bean id="myAspectXml" class="com.company.aspectJ.demo2.MyAspectXml"/>

    <!--aop的相关配置-->
    <aop:config>
        <!--配置切入点-->
        <aop:pointcut id="pointcut1" expression="execution(* com.company.aspectJ.demo2.CustomerDao.save(..))"/>
        <aop:pointcut id="pointcut2" expression="execution(* com.company.aspectJ.demo2.CustomerDao.update(..))"/>
        <aop:pointcut id="pointcut3" expression="execution(* com.company.aspectJ.demo2.CustomerDao.delete(..))"/>
        <aop:pointcut id="pointcut4" expression="execution(* com.company.aspectJ.demo2.CustomerDao.findOne(..))"/>
        <aop:pointcut id="pointcut5" expression="execution(* com.company.aspectJ.demo2.CustomerDao.findAll(..))"/>

        <!--配置AOP的切面-->
        <aop:aspect ref="myAspectXml">
            <!--配置前置增强-->
            <aop:before method="before" pointcut-ref="pointcut1"/>
            <!--配置后置通知-->
            <aop:after-returning method="afterReturning" pointcut-ref="pointcut2" returning="result"/>
            <!--配置环绕通知-->
            <aop:around method="around" pointcut-ref="pointcut3"/>
            <!--配置异常抛出通知-->
            <aop:after-throwing method="afterThrowing" pointcut-ref="pointcut4"/>
            <!--配置最终通知-->
            <aop:after method="after" pointcut-ref="pointcut5"/>
        </aop:aspect>
    </aop:config>
</beans>
```

```java
// 测试类
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(value = "classpath:applicationContext2.xml")
public class SpringDemo2 {

    @Resource(name = "customerDao")
    private CustomerDao customerDao;

    @Test
    public void demo1() {
        customerDao.save();
        customerDao.update();
        customerDao.delete();
        customerDao.findOne();
        customerDao.findAll();
    }
}
```