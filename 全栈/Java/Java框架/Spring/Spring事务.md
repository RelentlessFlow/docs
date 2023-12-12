[toc]

#  Spring事务

## 事务简介

> 事务是**正确执行**一系列的操作（或动作），使数据库从一种状态转换为另一种状态，且保证操作**全部成功**，或者**全部失败**。

### 事务原则

事务必须遵循ACID原则：

- 原子性（Atomicity）
  - 即不可分割性，事务要么全部被执行，要么就全部不被执行。
- 一致性（Consistency）
  - 事务的操作使得数据库从一种正确的状态转换为另一种正确的状态。
- 隔离型（Isolation）
  - 在事务正确提交之前，他可能的结果不应显示给任何其他事务。
- 持久性（Durability）
  - 事务正确提交后，其结果将永久保存在数据库中。

## Java事务

- 通过JDBC相应方法间接来实现对数据库的增删改查，把数据库转移到Java程序代码中进行控制
- 确保事务要么全部执行成功，要么撤销不执行。

### Java事务类型

- JDBC事务，用Connection对象控制，包括手动模式和自动模式
- JTA（Java Transaction API）事务，与实现无关的，与协议无关的API
- 容器事务：应用服务器提供的，通过JTA完成的。

### 事务类型差异

- JDBC事务，控制的局限性在一个数据库连接内，但是其使用简单。
- JTA事务，功能强大，可跨越多个数据库或多DAO，使用比较复杂。
- 容器事务，J2EE应用服务器提供的事务管理，局限于EJB。

## Spring事务核心接口

   <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20200311104733161.png" alt="image-20200311104733161" style="zoom:40%;" />

  

## Spring事务属性

### 事务属性范围

>传播行为、隔离规则、回滚规则、事务超时、是否只读、传播行为

### 事务属性定义

```java
public interface TransactionDefinition {
	// 返回数据库的传播行为
	int getPropgationBehavior();
	// 返回事务的隔离级别，事务管理器根据它来控制另外一个事务可以看到本事务内的哪些数据
	int getIsolationLevel();
	// 返回事务必须在多少秒内完成
	int getTimeout();
	// 判断事务是否可读，事务管理器能够根据这个返回值进行优化，确保事务是只读的
	boolean isReadOnly();
}
```

### 数据读取类型说明

#### 脏读

- 事务没提交，提前读取

#### 不可重复读

- 两次读区的数据不一致

#### 幻读

- 事务不是独立执行时发生的一种非预期现象。

#### 隔离级别

- 隔离级别定义了一个事务可能受其他并发事务影响的程度。

### 事务隔离级别

> 隔离级别定义了一个事务可能受其他并发事务影响的程度。

##### ISOLATION_DEFAULT

这是一个PlatfromTransactionManager默认的隔离级别，使用数据库默认的事务隔离级别。 

##### ISOLATION_READ_UNCOMMITTED 

这是事务最低的隔离级别，它充许别外一个事务可以看到这个事务未提交的数据。这种隔离级别会产生脏读，不可重复读和幻像读

##### ISOLATION_READ_COMMITTED

 保证一个事务修改的数据提交后才能被另外一个事务读取。另外一个事务不能读取该事务未提交的数据。这种事务隔离级别可以避免脏读出现，但是可能会出现不可重复读和幻像读。

##### ISOLATION_REPEATABLE_READ 

这种事务隔离级别可以防止脏读，不可重复读。但是可能出现幻像读。它除了保证一个事务不能读取另一个事务未提交的数据外，还保证了避免下面的情况产生(不可重复读)。

##### ISOLATION_SERIALIZABLE 

这是花费最高代价但是最可靠的事务隔离级别。事务被处理为顺序执行。除了防止脏读，不可重复读外，还避免了幻像读。

### 事务传播行为

> 当事务方法被另一个事务方法调用时，必须制定事务如何传播。

在TransactionDefinition接口中定义了七个事务传播行为。

##### PROPAGATION_REQUIRED 

如果存在一个事务，则支持当前事务。如果没有事务则开启一个新的事务。

##### PROPAGATION_SUPPORTS

如果存在一个事务，支持当前事务。如果没有事务，则非事务的执行。但是对于事务同步的事务管理器，PROPAGATION_SUPPORTS与不使用事务有少许不同。

##### PROPAGATION_MANDATORY 

如果已经存在一个事务，支持当前事务。如果没有一个活动的事务，则抛出异常。

##### PROPAGATION_REQUIRES_NEW 

总是开启一个新的事务。如果一个事务已经存在，则将这个存在的事务挂起。

##### PROPAGATION_NOT_SUPPORTED

总是非事务地执行，并挂起任何存在的事务。

##### PROPAGATION_NEVER 

总是非事务地执行，如果存在一个活动事务，则抛出异常

##### PROPAGATION_NESTED

如果一个活动的事务存在，则运行在一个嵌套的事务中. 如果没有活动事务, 则按TransactionDefinition.PROPAGATION_REQUIRED 属性执行

### 事务是否可读

- 利用数据库事务的“只读”属性，进行特性优化处理
- 事务的是否“只读属性”，不同的数据库厂商支持不同。
  - Oracle的"readOnly"不起作用，**不影响**其增删改差。
  - Mysql的"readOnly"为ture，只能查，增上改差则抛出异常。

### 事务超时

> 事务超时就是事务的一个定时器，在特定时间内事务如果没有执行完毕，那么就会自动回滚，而不是一直等待结束。

设计事务时注意点：

​	为了使应用程式很好的运行，事务不能运行太长的时间。因为事务可能涉及到对后端数据库的锁定，所以长时间的食物会不必要的占用数据库资源。

### 事务回滚

默认情况下，事务只有遇到运行期异常时才不会回滚，而在遇到检查型异常时不会回滚。

#### 自定义回滚策略

- 声明事务在遇到特定的检查型异常时像遇到运行期异常那样回滚
- 声明事务遇到特定的异常不回滚，即使这些异常是运行期异常。

### Spring事务接口

通过事务管理器获取TransactionStatus实例。

控制事务在回滚提交的时候需要应用相应的状态。

**Spring事务接口**

```java
// Spring事务窗台接口
// 通过调用PlatfotmTransationManager的getTransaction()
// 获取事务状态实例
public interface TransationStatus {
		boolean isNewTransaction(); // 是否是新的事务
		boolean hasSavepoint();	// 是否恢复点
		void setRollbackOnly(); // 设置为只回滚
		boolean isRollbackOnly(); // 是否为只回滚
		boolean isCompleted(); // 是否已完成
}
```

## Spring编程式事务管理

### 实现方式

#### 事务管理器（PlatformTransactionManager）

- 类似应用JTA UserTransaction API方式，异常处理更简洁。
- 核心类：Spring事务管理三个接口，JdbcTemplate

#### 模版事务（TransactionTemplate）

- 主要工具为JdbcTemplate类
- Spring推荐

### 案例

第一步：创建相关数据表

```sql
CREATE TABLE `books` (
  `isbn` varchar(18) NOT NULL,
  `name` varchar(64) NOT NULL,
  `price` float(10,2) NOT NULL,
  `pubdate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

第二步：创建JavaWeb项目（Maven）

第三步：配置Maven依赖

```xml
		<dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-core</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-beans</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-context</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-context-support</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-expression</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-aop</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.aspectj</groupId>
      <artifactId>aspectjrt</artifactId>
      <version>1.9.1</version>
    </dependency>
    <dependency>
      <groupId>org.aspectj</groupId>
      <artifactId>aspectjweaver</artifactId>
      <version>1.9.1</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-aspects</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-jdbc</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-tx</artifactId>
      <version>4.3.7.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.apache.commons</groupId>
      <artifactId>commons-dbcp2</artifactId>
      <version>2.1.1</version>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <version>8.0.19</version>
```



第四步：创建数据库操作类

src/com/mooc/utils/TemplateUtils.java

```java
/**
 * Spring数据库操作工具类
 */
public class TemplateUtils {
	private final static  String dbDriver = "com.mysql.jdbc.Driver" ;
	private final static  String dbUrl = "jdbc:mysql://127.0.0.1:3306/test" ;
	private final static  String dbUser = "root";
	private final static  String dbPwd = "root";
	
	private static BasicDataSource dataSource ;
	//静态初识：创建连接数据源
	static {
	//创建DBCP简单数据源并初始化相关数据源属性
	//private void createSimpleDataSource(){
		dataSource = new BasicDataSource() ;
		dataSource.setDriverClassName(dbDriver);
		dataSource.setUrl(dbUrl);
		dataSource.setUsername(dbUser);
		dataSource.setPassword(dbPwd);
		//指定数据库连接池初始连接数
		dataSource.setInitialSize(10);
		//设定同时向数据库申请的最大连接数
		dataSource.setMaxTotal(50);
		//设置连接池中保持的最少连接数量
		dataSource.setMinIdle(5);
	//}
	}
	public static TransactionTemplate getTransactionTemplate() {  
        PlatformTransactionManager txManager = new DataSourceTransactionManager(  
                dataSource);  
        return new TransactionTemplate(txManager);  
    }  
  
    public static JdbcTemplate getJdbcTemplate() {  
        return new JdbcTemplate(dataSource);  
    }  
  
    public static NamedParameterJdbcTemplate getNamedParameterJdbcTemplate() {  
        return new NamedParameterJdbcTemplate(dataSource);  
    }  
  
    public static SimpleJdbcInsert getSimpleJdbcTemplate() {  
        return new SimpleJdbcInsert(dataSource);  
    }  
    
    /**
     * //获取事务管理器：TransactionManager
     * 根据需要，可以是如JDBC、Hibernate,这里定义JDBC事务管理其
     * @return DataSourceTransactionManager
     */
    public static DataSourceTransactionManager getDataSourceTransactionManager(){
    	 DataSourceTransactionManager dataSourceTransactionManager = new DataSourceTransactionManager();
    	 // 设置数据源:此事务数据源须和正式事务管理器的数据源一致
    	 dataSourceTransactionManager.setDataSource(dataSource);
    	 return dataSourceTransactionManager;
    }
}

```

第五步：创建事务类

src/com/mooc/springtransactions/TransManagerExample.java

```java
public class TransManagerExample {

    public static void main(String[] args) {
        // 第一步：获取JDBC事务管理器
        DataSourceTransactionManager dtm = TemplateUtils.getDataSourceTransactionManager();
        // 第二步：创建事务管理器属性对象
        DefaultTransactionDefinition transDef = new DefaultTransactionDefinition(); // 定义事务属性
        // 根据需要，设置事务管理器的相关属性
        transDef.setPropagationBehavior(DefaultTransactionDefinition.PROPAGATION_REQUIRED); // 设置传播行为属性
        // 第三步：获得事务状态对象
        TransactionStatus ts = dtm.getTransaction(transDef);
        // 第四步：基于当前事务管理器，获取操作数据库的JDBC模板对象
        JdbcTemplate jt = new JdbcTemplate(dtm.getDataSource());
        try {
            // 第五步：执行业务方法
            jt.update("update books set price=112.5,name='炎黄传奇'  where isbn='128-166-890-China' ");
            // 第六步：提交业务
            //其它数据操作如增删
            dtm.commit(ts); //如果不commit，则更新无效果
        } catch (Exception e) {
            //回滚操作
            dtm.rollback(ts);
            e.printStackTrace();
        }
    }
}
```

## Spring声明式事务管理

> 基于AOP模式机制，对方法前后进行拦截。

### 配置类型：

​	独立代理，共享代理，拦截器，tx拦截器，全注释。（前三种不推荐使用）

### 两种开发模式

配置文件方式，注解方式

### 案例

第一步：

​	创建目标服务类：

​	src/main/java/com/company/service/DefaultFooService.java

```java
package com.company.service;

import com.company.beans.Foo;

public class DefaultFooService implements FooService {
    @Override
    public Foo getFoo(String name) {
        Foo f = new Foo();
        f.setName(name);
        f.setLevel(8);
        f.setBarName("默认吧名：Q吧");
        return f;
        // throw new UnsupportedOperationException();
    }

    @Override
    public Foo getFoo(String name, String barname) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void insertFoo(Foo foo) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void updateFoo(Foo foo) {
        throw new UnsupportedOperationException();
    }
}
```

​	第二步，配置连接源

​	src/main/resources/database.properties

```properties
#DBCP数据库连接池配置属性详细内容可参考官网描述：
#http://commons.apache.org/proper/commons-dbcp/configuration.html
#dsName = defaultDataSource
#连接设置
username=root
password=root
driver=com.mysql.jdbc.Driver
url=jdbc:mysql://127.0.0.1:3306/test
#connectionProperties，跟进需要，可参看官方说明进行详细配置:

#<!-- 初始化连接 -->
initialSize=10

#<!-- 最大空闲连接 -->
maxIdle=20

#<!-- 最小空闲连接 -->
minIdle=5

#最大连接数量
maxActive=50

#是否在自动回收超时连接的时候打印连接的超时错误
logAbandoned=true

#是否自动回收超时连接
removeAbandoned=true

#超时时间(以秒数为单位)
#设置超时时间有一个要注意的地方，超时时间=现在的时间-程序中创建Connection的时间，如果maxActive比较大，比如超过100，那么removeAbandonedTimeout可以设置长一点比如180，也就是三分钟无响应的连接进行回收，当然应用的不同设置长度也不同。
removeAbandonedTimeout=180

#<!-- 超时等待时间以毫秒为单位 -->
#maxWait代表当Connection用尽了，多久之后进行回收丢失连接
maxWait=1000
```

第三步，配置Spring声明式事务

​	src/main/resources/springContextExample.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
    http://www.springframework.org/schema/aop
    http://www.springframework.org/schema/aop/spring-aop-4.3.xsd
    http://www.springframework.org/schema/tx
    http://www.springframework.org/schema/tx/spring-tx-4.3.xsd">

    <!--第一步 -->
    <!-- 引入数据库连接属性配置文件 -->
    <bean id="propertyConfigurer"
          class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="location" value="classpath:database.properties" />
    </bean>
    <bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource"  destroy-method="close">
        <property name="driverClassName" value="${driver}" />
        <property name="url" value="${url}" />
        <property name="username" value="${username}" />
        <property name="password" value="${password}" />
    </bean>

    <!-- 第二步 -->
    <!-- jdbc事务管理器 -->
    <bean id="txManager"
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource" />
    </bean>

    <!-- 第三步 -->
    <!-- 想创建的服务对象：this is the service object that we want to make transactional -->
    <bean id="fooService" class="com.company.service.DefaultFooService"/>

    <!-- 第四步 -->
    <!-- 1、通过事务通知的模式实现事务
    事务通知：the transactional advice (what 'happens'; see the <aop:advisor/> bean below) -->
    <tx:advice id="txAdvice" transaction-manager="txManager">
        <!-- the transactional semantics... -->
        <!-- 拦截器规范 -->
        <tx:attributes>
            <!-- 以get开头的所有方法都为只读事务：all methods starting with 'get' are read-only -->
            <tx:method name="get*" read-only="true"/>
            <!-- 其它方法使用默认事务设置：other methods use the default transaction settings (see below) -->
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <!-- 第五步 -->
    <!-- 确保上述事务通知对定义在FooService接口中的方法都起作用(
    ensure that the above transactional advice runs for any execution
    of an operation defined by the FooService interface) -->
    <aop:config>
        <aop:pointcut id="fooServiceOperation" expression="execution(* com.company.service.FooService.*(..))"/>
        <aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceOperation"/>
    </aop:config>


</beans>
```

第六步，进行测试

​	src/main/java/com/company/examples/Main.java

```
public class Main {
    public static void main(final String[] args) {
        ApplicationContext ctx =
                new ClassPathXmlApplicationContext("/springContextExample.xml");
        System.out.println(ctx);
        FooService fooService = (FooService) ctx.getBean("fooService");
        System.out.println(fooService.getFoo("123"));
    }
}
```

#### 使用注解进行开发

第一步：定义目标服务类

​	com/company/service/XbeanServiceImpl.java

```java
@Transactional
public class XbeanServiceImpl  implements XbeanService{
    @Override
    public Xbean getXbean(int id) {
        Xbean xb = new Xbean() ;
        xb.setName("业务Bean的ID="+id);
        xb.setName("Bean默认名称");
        return xb ;
    }

    @Override
    public void insertXbean(Xbean xb) {
        throw new UnsupportedOperationException();
    }
}
```

第二步：添加注解声明式事务的支持

​	src/main/resources/springContextExample.xml

```xml
    <!-- 注释模式事务：启动使用注解实现声明式事务管理的支持   -->
    <tx:annotation-driven transaction-manager="txManager" />
```

第三步，定义目标类的bean

```xml
<bean id="xbeanService" class="com.company.service.XbeanServiceImpl"/>
```

第四步，编写测试方法

```java
public static void main(final String[] args) {
        ApplicationContext ctx =
                new ClassPathXmlApplicationContext("/springContextExample.xml");
        System.out.println(ctx);
        XbeanService xbeanService = (XbeanService)ctx.getBean("xbeanService");
        out.println( xbeanService.getXbean(123));
    }
```

## 学习总结

Spring将事务管理分为了两类：

- 编程式事务管理
  - 需要手动编写代码进行事务的管理（一般不用）
- 声明式事务管理：

  - 基于TransactionProxyFactoryBean的方式（很少使用） 

    - 需要为每个事务管理的类配置一个TransactionProxyFactoryBean进行管理。使用时还需要在类中注入该代理类
- 基于AspectJ的方式（常使用）
    - 配置好之后，按照方法的名字进行管理，无需再类中添加任何东西。
  - 基于注解的方式（经常使用）
    - 配置简单，在业务层类上添加注解@Transactional。

