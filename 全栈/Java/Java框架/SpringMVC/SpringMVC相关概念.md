# SpringMVC案例

## SpringMVC概念

> **springmvc是spring框架的一个模块，springmvc和spring无需通过中间整合层进行整合。**

SpringMVC是最好的MVC框架

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/70.png)

## SpringMVC流程

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/20180503140150984)

### SpringMVC执行流程

1、用户发送请求至前端控制器DispatcherServlet
2、DispatcherServlet收到请求调用HandlerMapping处理器映射器。
3、处理器映射器根据请求url找到具体的处理器，生成处理器对象及处理器拦截器(如果有则生成)一并返回给DispatcherServlet。
4、DispatcherServlet通过HandlerAdapter处理器适配器调用处理器
5、执行处理器(Controller，也叫后端控制器)。
6、Controller执行完成返回ModelAndView
7、HandlerAdapter将controller执行结果ModelAndView返回给DispatcherServlet
8、DispatcherServlet将ModelAndView传给ViewReslover视图解析器
9、ViewReslover解析后返回具体View
10、DispatcherServlet对View进行渲染视图（即将模型数据填充至视图中）。
11、DispatcherServlet响应用户

### SpringMVC框架原理

1. 前端控制器DispatcherServlet（不需要程序员开发）
   作用接收请求，响应结果，相当于转发器，中央处理器。有了DispatcherServlet减少了其它组件之间的耦合度。
2. 处理器映射器HandlerMapping(不需要程序员开发)
   作用：根据请求的url查找Handler
3. 处理器适配器HandlerAdapter
   作用：按照特定规则（HandlerAdapter要求的规则）去执行Handler
4. 处理器Handler (需要程序员开发)
   注意：编写Handler时按照HandlerAdapter的要求去做，这样适配器才可以去正确执行Handler
5. 视图解析器View resolver(不需要程序员开发)
   作用：进行视图解析，根据逻辑视图名解析成真正的视图（view）
6. 视图View (需要程序员开发)
   View是一个接口，实现类支持不同的View类型（jsp、freemarker、pdf…）

## 第一个SpringMVC项目

#### SpringMVC相关依赖

**porn.xml**

```xml
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.7</maven.compiler.source>
    <maven.compiler.target>1.7</maven.compiler.target>
  </properties>

<dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-webmvc</artifactId>
      <version>4.3.1.RELEASE</version>
    </dependency>

    <dependency>
      <groupId>javax.servlet</groupId>
      <artifactId>javax.servlet-api</artifactId>
      <version>3.1.0</version>
    </dependency>
  </dependencies>
```

#### 前端控制器

**src/main/webapp/WEB-INF/web.xml**

```xml
<web-app>
  <display-name>Archetype Created Web Application</display-name>

  <filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
      <param-name>encoding</param-name>
      <param-value>UTF-8</param-value>
    </init-param>
    <init-param>
      <param-name>forceEncoding</param-name>
      <param-value>true</param-value>
    </init-param>
  </filter>
  <filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>

  <servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>*.css</url-pattern>
  </servlet-mapping>

  <servlet>
    <servlet-name>springmvc</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:springmvc.xml</param-value>
    </init-param>
  </servlet>
  <servlet-mapping>
    <servlet-name>springmvc</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>

</web-app>
```

#### SpringMVC配置

**src/main/resources/springmvc.xml**

```java
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="com.company.handler"></context:component-scan>

    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/"></property>
        <property name="suffix" value=".jsp"></property>
    </bean>
</beans>
```

#### 一个简单的控制器模型

```java
@RequestMapping("/AnnotationHandler")
@Controller
public class AnnotationHandler {
	
    @RequestMapping("/ModelTest")
    public String ModelTest(Model model){
        User user = new User();
        user.setName("Tom");
        model.addAttribute("user",user);
        return "index";
    }

    @RequestMapping("/MapTest")
    public String MapTest(Map<String,User> map){
        User user = new User();
        user.setName("Jerry");
        map.put("user",user);
        return "index";
    }

    @RequestMapping("/ModelAndViewTest")
    public ModelAndView ModelAndViewTest(){
        User user = new User();
        user.setName("Cat");
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.addObject("user",user);
        modelAndView.setViewName("index");
        return modelAndView;
    }

    @RequestMapping("/add")
    public ModelAndView add(Goods goods){
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.addObject("goods",goods);
        modelAndView.setViewName("show");
        return modelAndView;
    }
}
```