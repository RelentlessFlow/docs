# Spring JDBC Template

> 利用JDBC Template简化持久化操作。

## 开发准备：

**porn.xml**

```xml
<dependencies>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.47</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-beans</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-aop</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <!--事务-->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
```

**Spring.xml**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/context
    http://www.springframework.org/schema/context/spring-context.xsd
    http://www.springframework.org/schema/aop
    http://www.springframework.org/schema/aop/spring-aop.xsd
    http://www.springframework.org/schema/tx
    http://www.springframework.org/schema/tx/spring-tx.xsd">
    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/selection_course?useUnicode=true&amp;characterEncoding=UTF-8&amp;useSSL=false"/>
        <property name="username" value="root"/>
        <property name="password" value="root"/>
    </bean>
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <!--自动扫描-->
    <context:component-scan base-package="com.imooc.sc"/>
</beans>
```

**Test.class**

```java
public class Test {
    private JdbcTemplate jdbcTemplate;
    {
        ApplicationContext context = new ClassPathXmlApplicationContext("spring.xml");
        jdbcTemplate = (JdbcTemplate) context.getBean("jdbcTemplate");
    }

    @org.junit.Test
    public void testExecute() {
        jdbcTemplate.execute("create table if not exists user1(id int,name varchar(20))");
    }

    @org.junit.Test
    public void testUpdate() {
        String sql = "insert into student(name,sex) values(?,?)";
        jdbcTemplate.update(sql, new Object[]{"张飞", "男"});
    }

    @org.junit.Test
    public void testUpdate2() {
        String sql = "update student set sex=? where id=?";
        jdbcTemplate.update(sql, new Object[]{"女", "1"});
    }

    @org.junit.Test
    public void testBatchUpdate() {
        String[] sqls = {
                "insert into student(name,sex) values('大表哥','男')",
                "insert into student(name,sex) values('红龙','男')",
                "update student set sex='女' where id=3"
        };
        jdbcTemplate.batchUpdate(sqls);
    }

    @org.junit.Test
    public void testBatchUpdate2() {
        String sql = "insert into selection(student,course) values(?,?)";
        List<Object[]> list = new ArrayList<Object[]>();
        list.add(new Object[]{3,1001});
        list.add(new Object[]{3,1003});
        jdbcTemplate.batchUpdate(sql,list);
    }

    @org.junit.Test
    public void testQuerySimple() {
        String sql = "select count(*) from student";
        // 查询简单数据项：获取一个 查询结果为多行会出错
        int count = jdbcTemplate.queryForObject(sql, Integer.class);
        System.out.println(count);
    }

    @org.junit.Test
    public void testQuerySimple2() {
        String sql = "select name from student where sex=?";
        // 查询多个 查询结果为多列会出错
        List<String> names = jdbcTemplate.queryForList(sql,String.class,"女");
        System.out.println(names);
    }

    @org.junit.Test
    public void testQueryMap1() {
        String sql = "select * from student where id = ?";
        Map<String,Object> stu = jdbcTemplate.queryForMap(sql, 3);
        System.out.println(stu);
    }

    @org.junit.Test
    public void testQueryMap2() {
        String sql = "select * from student";
        List<Map<String,Object>> stus = jdbcTemplate.queryForList(sql);
        System.out.println(stus);
    }

    @org.junit.Test
    public void testQueryEntity1() {
        String sql = "select * from student where id = ?";
        Student stu = jdbcTemplate.queryForObject(sql, new StudentRowMapper(), 3);
        System.out.println(stu);
    }

    @org.junit.Test
    public void testQueryEntity2() {
        String sql = "select * from student";
        List<Student> stus = jdbcTemplate.query(sql,new StudentRowMapper());
        System.out.println(stus);
    }

    private class StudentRowMapper implements RowMapper<Student>{

        @Override
        public Student mapRow(ResultSet resultSet, int i) throws SQLException {
            Student stu = new Student();
            stu.setId(resultSet.getInt("id"));
            stu.setName(resultSet.getString("name"));
            stu.setSex(resultSet.getString("sex"));
            stu.setBorn(resultSet.getDate("born"));
            return stu;
        }
    }
}
```

