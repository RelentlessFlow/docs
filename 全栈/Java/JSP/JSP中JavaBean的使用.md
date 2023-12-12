[toc]

# JavaBean的使用

> Java是特殊的Java类，使用Java语言书写。

### JavaBean类与其他Java类的独一无二的特征：

- 提供了无参的构造方法
- 需要被序列化而且实现了Serialzable接口。
- 可读写属性
- getter和setter方法

### JavaBean属性

JavaBean对象可访问，可读写或可读或者可写，而且提供了两个方法来访问。

getPropertyName和setPropertyName.

### 核心方法

#### 示例

CarsBean.java

```java
package cn.edu.hbcit;

public class CarsBean {

    public CarsBean(){

    }
    private String color = "";
    private boolean withAirCondition = true;

    public boolean getWithAirCondition() {
        return withAirCondition;
    }

    public void setWithAirCondition(boolean withAirCondition) {
        this.withAirCondition = withAirCondition;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }
}

```

index.jsp

```jsp
<%@ page import="cn.edu.hbcit.CarsBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>$Title$</title>
  </head>
  <body>
    <jsp:useBean id="cars" class="cn.edu.hbcit.CarsBean" scope = "session">
      <jsp:setProperty name="cars" property="color" value="红色"/>
      <jsp:setProperty name="cars" property="withAirCondition" value="true"/>
    </jsp:useBean>

    这个小汽车是<jsp:getProperty name="cars" property="color"/><hr/>
    是否安装了空调：
    <%
      CarsBean carsBean = (CarsBean) session.getAttribute("cars");
      out.print(carsBean.getWithAirCondition());
    %>

<%--    <jsp:getProperty name="cars" property="withAirCondition"/>--%>
  </body>
</html>

```

![image-20200326143210791](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20200326143210791.png)