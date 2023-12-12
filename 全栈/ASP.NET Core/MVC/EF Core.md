# EFCore

## EFCore中的DbContent

要在应用程序中使用DbContent，我们需要创建一个类文件继承自DbContent

```c#
public class AppDbContent:DbContent{}
```

要将应用程序的配置信息传递给DbContent，我们需要对DbContentOptions进行实例化

```c#
public class AppDbContent:DbContent{
	public AppDbContent(DbContentOptions<AppDbContent> options):base(options)
	{}
}
```

在DbContext类中我们要对使用到的每个实体，都添加`DbSet<TEnity>`属性

```c#
public class AppDbContent:DbContent{
	public AppDbContent(DbContentOptions<AppDbContent> options):base(options)
	{}
	public DbSet<Student> Students {get;set;}
}
```

使用此`DbSet<Student>`属性，Students来查询和保存类文件Student的实例。

当对DbSet采用Linq查询的时候，他会自动转换为SQL语句来对基础数据库做查询操作。









## 迁移

1、VS2019种打开程序包管理控制台

2、输入Get-Help about_entityframeworkcore查看帮助信息

3、输入Add-Migration新增一条迁移记录

4、输入迁移名字：InitiaMigration

5、更新迁移：Update-Database

