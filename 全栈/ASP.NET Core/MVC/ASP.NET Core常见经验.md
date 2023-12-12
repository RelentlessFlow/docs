# ASP.NET Core常见经验

## 一、C#语法

### 字符串处理

判断字符串为空，空即为True，非空为False

```c#
string.IsNullOrWhiteSpace(parameters.SearchTerm
```

字符串无大小写区分比较大小

```c#
// 忽略当前语言文化 速度更快
String.Equals(string,StringComparison.OrdinalIgnoreCase)
// 结合当前语言文化 速度更快
String.Equals(string,StringComparison.InvariantCultureIgnoreCase)
```

```c#
String.Compare(str1,str2,ture)
```

 ### 异步方法

可通过async、await、Task组成一个支持异步的业务方法，

使用async定义异步方法，await定义异步函数，Task定义异步返回结果

```c#
public async Task<IEnumerable<Company>> GetCompaniesAsync(IEnumerable<Guid> companyIds)
        {
            if (companyIds == null)
            {
                throw new ArgumentNullException(nameof(companyIds));
            }

            return await _context.Companies
                .Where(x => companyIds.Contains(x.Id))
                .OrderBy(x => x.Name)
                .ToListAsync();
        }
```

### 常见异常

```c#
throw new ArgumentNullException(nameof(companyIds));	// 判断方法参数是否为空
```

### Guid类	

> [GUID](https://www.baidu.com/s?wd=GUID&tn=44039180_cpr&fenlei=mv6quAkxTZn0IZRqIHckPjm4nH00T1YduynzPvuBujRvryF9PHbz0ZwV5Hcvrjm3rH6sPfKWUMw85HfYnjn4nH6sgvPsT6KdThsqpZwYTjCEQLGCpyw9Uz4Bmy-bIi4WUvYETgN-TLwGUv3EnHRYnHbkPWRdnW6snjmkPW6zPs)globally unique identifier（全球唯一标识符）

相当于一种算法生成的ID

` Guid.Empty()`：[Guid](https://docs.microsoft.com/en-us/dotnet/api/system.guid?view=netcore-3.1)结构的只读实例，其值为全零。，一般用来判断Guid是否已被赋值

`new Guid()`：返回由00000000-0000-0000-0000-000000000000组成的Guid对象

`Guid.NewGuid()`：返回一组由随机数生成的Guid对象

`Guid.Parse(string guidString)`：将字符串转为Guid对象

```c#
Console.WriteLine(Guid.Parse("fc6a01da-c1bc-44c6-a36a-d0fb02550af6"));
```

## 二、WebAPI

### 1. 创建WebAPI项目配置

配置Startup.cs

```c#
public class Startup
    {
    		public void ConfigureServices(IServiceCollection services)
        {
          // 添加对内容协商的支持（XML）JSON优先
        	services.AddControllers(setup =>
            {
                setup.ReturnHttpNotAcceptable = true;
            }).AddXmlDataContractSerializerFormatters();
        }
  			public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
          // 添加对异常处理生产环境的简单支持
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler(appBuilder =>
                {
                    appBuilder.Run(async context =>
                    {
                        context.Response.StatusCode = 500;
                        await context.Response.WriteAsync("Unexpected Error");
                    });
                });
            }
          	
          // 将Https转发为Http
          	app.UseHttpsRedirection();
					
            app.UseRouting();

            app.UseAuthorization();
						
          	// 注意：使用路由模版必须在控制器内路由进行单独配置
            app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
        }
    }
```

**注意：使用路由模版必须在控制器内路由进行单独配置**

**注意：**如果想要配置内容协商的XML优先，可以配置如下代码

**Startup.cs**

```c#
public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers(setup =>
            {
                setup.ReturnHttpNotAcceptable = true;
              // OutputFormatters中可以添加不同的对内容协商的支持，第一个即为默认的序列号支持
                setup.OutputFormatters
                  .Add(new XmlDataContractSerializerOutputFormatter());
            });
        }
```

### 2. 配置WebAPI控制器和一般路由配置

路由配置，写在注解上

简易路由配置

```c#
[ApiController]		
[Route("api/companies")]
public class CompaniesController : ControllerBase
{
	[HttpGet("api/companies")]
	public async Task<ActionResult> GetCompanies()
	{
		var companies = await _companyRepository.GetCompaniesAsync();    
		return Ok(companyDtos);
	}
  
  [HttpGet("{companyId}")]
	public async Task<ActionResult> GetCompany(Guid companyId)
	{
		var company = await _companyRepository.GetCompanyAsync(companyId);
    if(company == null)
    {
      return NotFound();
    }      
		return Ok(companyDtos);
	}
}
```

可选`[Route("api/companies")]`配置为`[Route("api/[controller]")]`

这个时候，`[controller]`与控制器名称保持一致。

可将`[HttpGet("{companyId}")]`分开写：

```c#
[HttpGet]
[Route("{companyId}")]
```

可全局简化为

```c#
[ApiController]		
[Route("api/companies")]
public class CompaniesController : ControllerBase
{
	[HttpGet]
	public async Task<ActionResult> GetCompanies()
	{
		var companies = await _companyRepository.GetCompaniesAsync();    
		return Ok(companyDtos);
	}
  
  [HttpGet]
	public async Task<ActionResult> GetCompany(Guid companyId)
	{
		var company = await _companyRepository.GetCompanyAsync(companyId);
    if(company == null)
    {
      return NotFound();
    }      
		return Ok(companyDtos);
	}
}
```

### 3. 配置默认启动页

Properties/launchSettings.json

配置下面的`"launchUrl": "api/companies"`

```json
"profiles": {
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "launchUrl": "api/companies",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "RoutineApi2": {
      "commandName": "Project",
      "launchBrowser": true,
      "launchUrl": "api/companies",
      "applicationUrl": "https://localhost:5001;http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
```

### 4.Enity Model和面向外部的Model

一把情况下，将EF内置的Model，对外输出以及用于接口参数传递的Mode（DTO）分离。

分别创建三个文件夹用来存放三种不同的存放Model的文件夹

- RoutineApi2/Entities
  - Company.cs
  - Employee.cs
  - Gender.cs
- Models
  - CompanyDto.cs
  - EmployeeDto.cs
- DtoParameters
  - CompanyDtoParameters
  - EmployeeDtoParameters

### 1. EFCore创建实体类并完成映射（CodeFirst）

##### 步骤一：建立一对多关系

- RoutineApi2/Entities
  - Company.cs
  - Employee.cs
  - Gender.cs

```c#
public class Company
    {		
  			// 配置ID
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Introduction { get; set; }
  			// 添加Employees集合（一对多）
        public ICollection<Employee> Employees { get; set; }
    }

public class Employee
    {
  			// 配置ID
        public Guid Id { get; set; }
        public Guid CompanyId { get; set; }
        public string EmployeeNo { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public Gender Gender { get; set; }
        public DateTime DataOfBirth { get; set; }
  			// 配置外建关联
        public Company Company { get; set; }
    }

public enum Gender
    {
        男 = 1,
        女 = 2
    }
```

##### 步骤二：添加nuget包：

​	Microsoft.EntityFrameworkCore.SqlServer

​	Microsoft.EntityFrameworkCore.Sqlite

​	Microsoft.EntityFrameworkCore.Tools

##### 步骤三：添加数据源

RoutineApi2/Data/RoutineDbContext.cs

```c#
namespace RoutineApi2.Data
{
    public class RoutineDbContext : DbContext
    {	
      	// 默认配置注入
        public RoutineDbContext(DbContextOptions<RoutineDbContext> options) : base(options)
        {}
				
      	//	数据库数据集集注入
        public DbSet<Company> Companies { get; set; }
        public DbSet<Employee> Employees { get; set; }
				
      	// 配置关联和限制
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Company>()
                .Property(x => x.Name).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<Company>()
                .Property(x => x.Introduction).IsRequired().HasMaxLength(500);
            modelBuilder.Entity<Employee>()
                .Property(x => x.EmployeeNo).IsRequired().HasMaxLength(10);
            modelBuilder.Entity<Employee>()
                .Property(x => x.FirstName).IsRequired().HasMaxLength(50);
            modelBuilder.Entity<Employee>()
                .Property(x => x.LastName).IsRequired().HasMaxLength(50);
            modelBuilder.Entity<Employee>()
                .HasOne(x => x.Company)
                .WithMany(x => x.Employees)
              	// 当Employee存在于Company，不可删除Company
                .HasForeignKey(x => x.CompanyId).OnDelete(DeleteBehavior.Restrict); 
          
            // 配置种子数据
            modelBuilder.Entity<Company>().HasData(
                new Company
                {
                    Id = Guid.Parse("25dbd774-ae0e-44d2-94a1-58d5805da533"),
                    Name = "Microsoft",
                    Introduction = "Great Company",
                },
                new Company
                {
                    Id = Guid.Parse("2aea0972-6a03-4f3c-9672-04fa2ca99110"),
                    Name = "Google",
                    Introduction = "Don't be evil"
                    
                },
                new Company
                {
                    Id = Guid.Parse("c6fbfe31-590f-477f-a87a-3c68423909c6"),
                    Name = "Alipapa",
                    Introduction = "Fubao Company"
                }
            );
            modelBuilder.Entity<Employee>().HasData(
                new Employee
                {
                    Id = Guid.Parse("410f4bbe-e109-49d4-932a-e3cfe29f53ed"),
                    CompanyId = Guid.Parse("25dbd774-ae0e-44d2-94a1-58d5805da533"),
                    DataOfBirth = new DateTime(1966,1,2),
                    EmployeeNo = "MSFT231",
                    FirstName = "Nick",
                    LastName = "Carer",
                    Gender = Gender.男
                },
                new Employee
                {
                    Id = Guid.Parse("ba5790e1-765d-4e71-8795-edd24398f8e4"),
                    CompanyId = Guid.Parse("25dbd774-ae0e-44d2-94a1-58d5805da533"),
                    DataOfBirth = new DateTime(1996,2,3),
                    EmployeeNo = "MSFT245",
                    FirstName = "Vince",
                    LastName = "Carter",
                    Gender = Gender.男
                },
                new Employee
                {
                    Id = Guid.Parse("1a5b77ee-9e43-46ba-b1dc-3b5c32c647d4"),
                    CompanyId = Guid.Parse("2aea0972-6a03-4f3c-9672-04fa2ca99110"),
                    DataOfBirth = new DateTime(1986,2,1),
                    EmployeeNo = "MSFT215",
                    FirstName = "Machal",
                    LastName = "Jeckson",
                    Gender = Gender.男
                }
            );
        }
    }
}
```

##### 步骤四：配置数据库连接字符串

一、SQLServer版本：

​		appsettings.json

```json
"ConnectionStrings": {
    "DockerDBConnection": "Data Source=127.0.0.1;Initial Catalog=CompanyDB;User ID=sa;Password=<Admin123456>",
    "LocalDockerDBConnection": "Data Source=192.168.1.104;Initial Catalog=CompanyDB;User ID=sa;Password=<Admin123456>",
    "MSDBConnection": "Server=(localdb)\\mssqllocaldb;Database=CompanyDB;Trusted_Connection=True;MultipleActiveResultSets=true",
    "SqlServerConnection": "Data Source = myServerAddress;Initial Catalog = myDataBase;User Id = myUsername;Password = myPassword;"
  }
```

​		Startup.cs

```c#
public Startup(IConfiguration configuration)
{
	_configuration = configuration;
}

public void ConfigureServices(IServiceCollection services)
{
	// 数据库连接服务
		services.AddDbContextPool<AppDbContent>(
		option => option
      .UseSqlServer(_configuration.GetConnectionString("LocalDockerDBConnection")));
}
```

二、Sqlite版本

​	Startup.cs

```c#
public void ConfigureServices(IServiceCollection services)
        {
        	services.AddDbContextPool<RoutineDbContext>(
                option =>
                {
                    option.UseSqlite("Data Source=routine.db");
                });
        }
```

##### 步骤五：创建迁移文件

VSCode开发

Shell下输入

```shell
$ dotnet ef migrations add InitialMigration
$ dotnet ef database update
```

可以看到目录中多出了如下文件

- Migrations
  - 20200511033121_InitialMigration.cs
  - RoutineDbContextModelSnapshot.cs

##### 步骤六：启动程序，执行迁移

##### 步骤七：将数据库连接池装载到服务类中

```c#
public class CompanyRepository : ICompanyRepository
{
	private readonly RoutineDbContext _context;
	public CompanyRepository(RoutineDbContext context)
	{
  	_context = context ?? throw new ArgumentException(nameof(context));
  }
}
```

###  2. 常用Linq语句汇总

##### 一、 查询所有数据

无参数，直接返回所有数据集

```c#
public async Task<IEnumerable<Company>> GetCompaniesAsync()
{
	return await _context.Companies.ToListAsync();
}            
```

##### 二、单数据条件查询

单参数，返回单数据

```c#
public Task<Company> GetCompanyAsync(Guid companyId)
{
	if (companyId == Guid.Empty)
	{
		throw new ArgumentNullException(nameof(companyId));
	}
  // FirstOrDefaultAsync ： 异步的返回唯一的对象
	return _context.Companies.FirstOrDefaultAsync(x => x.Id == companyId);
}
```

##### 三、集合参数条件查询

参数为数据集合，返回数据集

```c#
public async Task<IEnumerable<Company>> GetCompaniesAsync(IEnumerable<Guid> companyIds)
{
	if (companyIds == null)
	{
  	throw new ArgumentNullException(nameof(companyIds));
	}
  return await _context.Companies
    .Where(x => companyIds.Contains(x.Id))
		.OrderBy(x => x.Name)
		.ToListAsync();
}
```

##### 四、多参数条件查询

 参数：多参数，返回：单数据对象

```c#
public async Task<Employee> GetEmployeesAsync(Guid companyId, Guid employeeId)
{
	if (companyId == Guid.Empty)
  {
		throw new ArgumentNullException(nameof(companyId));
	}
  
  if (companyId == Guid.Empty)
  {
  	throw new ArgumentNullException(nameof(companyId));
  }
	
  // 多条件查询
  return await _context.Employees
                .FirstOrDefaultAsync(x => x.CompanyId == companyId && x.Id == employeeId);
        }
```

##### 五、添加数据到数据库

```c#
public void AddCompany(Company company)
{
	if (company == null)
	{
  	throw new ArgumentNullException(nameof(company));
	}
  
  // 对传入数据进行处理
  	company.Id = Guid.NewGuid();
    foreach (var employee in company.Employees)
    {
    	employee.Id = Guid.NewGuid();   
    }
   	
  // 添加数据
		_context.Companies.Add(company);
}
```

##### 六、更新数据

```c#
public void UpdateCompany(Company company)
{
	// _context.Entry(company).State = EntityState.Modified; 可不写
}
```

##### 七、删除数据

```c#
public void DeleteCompany(Company company)
{
	if (company == null)
  {
  	throw new ArgumentNullException(nameof(company));
  }
  // 删除数据
	_context.Companies.Remove(company);
}
```

##### 八、验证数据是否存在数据库

```c#
 public async Task<bool> CompanyIsExistsAsync(Guid companyId)
{
	if (companyId == Guid.Empty)
  {
  	throw new ArgumentNullException(nameof(companyId));
	}
	return await _context.Companies.AnyAsync(x => x.Id == companyId);
}
```

##### 九、保存数据库集合

```c#
public async Task<bool> SaveAsync()
{
	return await _context.SaveChangesAsync() >= 0;
}
```

##### 十、复杂查询（过滤），模糊查询（搜索）

```c#
public async Task<IEnumerable<Employee>> 
  					// 公司ID（查询条件），职员性别（过滤），模糊查询（搜索）q
            GetEmployeesAsync(Guid companyId, string genderDisplay,string q)
        {
            if (companyId == Guid.Empty)
            {
                throw new ArgumentNullException(nameof(companyId));
            }
						
  					// 如果传入的过滤和检索条件都为空，常规简答查询
            if (string.IsNullOrWhiteSpace(genderDisplay) && string.IsNullOrWhiteSpace(q))
            {
                return await _context.Employees
                    .Where(x => x.CompanyId == companyId)
                    .OrderBy(x => x.EmployeeNo)
                    .ToListAsync();
            }
            
  					// 先进行简单查询保存结果为items
            var items = 
                _context.Employees.Where(x => x.CompanyId == companyId);
						
            if (!string.IsNullOrWhiteSpace(genderDisplay))
            {
              	// Trim()去除两边的空格
                genderDisplay = genderDisplay.Trim();
              	// 将传入参数转为Enum类型
                var gender = Enum.Parse<Gender>(genderDisplay);

                items = items.Where(x => x.Gender == gender);
            }

            if (!string.IsNullOrWhiteSpace(q))
            {
                q = q.Trim();
              	// 任意那一个匹配都行||或
                items = items.Where(x => x.EmployeeNo.Contains(q)
                                         || x.FirstName.Contains(q)
                                         || x.LastName.Contains(q)
                                         );
            }
  
            return await items.OrderBy(x => x.EmployeeNo)
                .ToListAsync();
        }
```

##### 十一、将对象传入作为查询的参数列表

DtoParameters/CompanyDtoParameters.cs

```c#
public class CompanyDtoParameters
{
		public string CompanyName { get; set; }
  	public string SearchTerm { get; set; }
}
```

````c#
public async Task<IEnumerable<Company>> GetCompaniesAsync(CompanyDtoParameters parameters)
        {
            if (parameters == null)
            {
                throw new ArgumentNullException(nameof(parameters));
            }

            if (string.IsNullOrWhiteSpace(parameters.CompanyName) && 
                string.IsNullOrWhiteSpace(parameters.SearchTerm))
            {
                return await _context.Companies.ToListAsync();
            }
						
  					// 将数据库连接字符串集合临时保存一下，这里不会触发查询方法
            var queryExpression = _context.Companies as IQueryable<Company>;
            if (!string.IsNullOrWhiteSpace(parameters.CompanyName))
            {
                parameters.CompanyName = parameters.CompanyName.Trim();
                queryExpression = queryExpression
                    .Where(x => x.Name == parameters.CompanyName);
            }

            if (!string.IsNullOrWhiteSpace(parameters.SearchTerm))
            {
                parameters.SearchTerm = parameters.SearchTerm.Trim();
              	// 模糊查询
                queryExpression = queryExpression
                    .Where(x => x.Name.Contains(parameters.SearchTerm)
                    || x.Introduction.Contains(parameters.SearchTerm));
            }
            
            // 到这里才真正查询数据库
            return await queryExpression.ToListAsync();
        }
````

##### ！！！经验

​	常用方法汇总：

​	 一、参数传入后要判断是否为空

```c#
// 传入类型为Guid
if (companyId == Guid.Empty)
{
		throw new ArgumentNullException(nameof(companyId));
}
// 传入类型为对象
if (companyIds == null)
{
		throw new ArgumentNullException(nameof(companyIds));
}
// 传入类型为string
if (string.IsNullOrWhiteSpace(genderDisplay) && string.IsNullOrWhiteSpace(q)){}
```

​	二、查询结果唯一，用FirstOrDefaultAsync()，一种特殊的Where

```c#
return _context.Companies.FirstOrDefaultAsync(x => x.Id == companyId);
```

​	三、查询结果不唯一，用Where

​	四、查询结果需要排序，可以使用OrderBy()和OrderByDescending()，排序依据即位参数

```c#
return await _context.Companies
  							.Where(x => companyIds.Contains(x.Id))
                .OrderBy(x => x.Name)
                .ToListAsync();
```

​	五、参数尽量先Trim去除多余的空格再进行查询操作

​	六、判断数据是否存在于数据库，可以使用AnyAsync方法，类似于Where，但是它返回的是个Bool类型

```c#
return await _context.Companies.AnyAsync(x => x.Id == companyId);
```

​	七、增删和删除数据可以使用`DBSet.Add(Object)`和`DBSet.Remove(Object)`

## 四、AutoMapper

当频繁需要对DTO进行数据映射的时候，就需要new大量的DTO对象，这样的代码就是冗余的。

可以使用AutoMapper完成对DTO的自动映射。

##### 步骤一、添加AutoMapper的Nuget包

AutoMapper.Extensions.Microsoft.DependencyInjection

##### 步骤二、在Startup的ConfigureService注册Mapper容器，注册默认配置

```c#
services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
```

##### 步骤三、配置Mapper映射

创建Profiles文件夹

- Profiles
  - RoutineApi2/Profiles/CompanyProfile.cs
  - RoutineApi2/Profiles/EmployeeProfile.cs

源类型：

```c#
public class Company
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Introduction { get; set; }
        public ICollection<Employee> Employees { get; set; }
    }

public class Employee
    {
        public Guid Id { get; set; }
        public Guid CompanyId { get; set; }
        public string EmployeeNo { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public Gender Gender { get; set; }
        public DateTime DataOfBirth { get; set; }
        public Company Company { get; set; }
    }

public enum Gender
    {
        男 = 1,
        女 = 2
    }

public class CompanyDto
    {
        public Guid Id { get; set; }
        public string CompanyName { get; set; }
    }

public class EmployeeDto
    {
        public Guid Id { get; set; }
        public Guid CompanyId { get; set; }
        public string EmployeeNo { get; set; }
        public string Name { get; set; }
        public Gender GenderDisplay { get; set; }
        public int Age { get; set; } 
    }
```

配置Mapper/

```c#
public class CompanyProfile : Profile
    {
        public CompanyProfile()
        {
            // 原类型和目标类型
            CreateMap<Company, CompanyDto>()
                .ForMember(
                    dest => dest.CompanyName,
                    opt 
                        => opt.MapFrom(src => src.Name));
        }  
    }

public class EmployeeProfile : Profile
    {
        public EmployeeProfile()
        {
            CreateMap<Employee, EmployeeDto>()
                .ForMember(
                    dest
                        => dest.Name,
                    opt
                        => opt.MapFrom(src
                            => $"{src.FirstName} {src.LastName}"))
                .ForMember(
                    dest
                        => dest.GenderDisplay,
                    opt
                        => opt.MapFrom(src
                            => src.Gender.ToString()))
                .ForMember(
                    dest
                        => dest.Age,
                    opt
                        => opt.MapFrom(src
                            => DateTime.Now.Year - src.DataOfBirth.Year));
        }
    }
```

##### 步骤五、添加Mapper到控制器

```c#
public class CompaniesController : ControllerBase
    {
        private readonly ICompanyRepository _companyRepository;
        private readonly IMapper _mapper; 

        public CompaniesController(ICompanyRepository companyRepository, IMapper mapper)
        {
            _companyRepository = companyRepository ??
                                 throw new ArgumentNullException(nameof(companyRepository));
            _mapper = mapper ?? throw new ArgumentException(nameof(mapper));
        }
        
        [HttpGet]
        [HttpHead]
        public async Task<ActionResult<IEnumerable<CompanyDto>>> 
            GetCompanies([FromQuery]CompanyDtoParameters parameters)
        {
            var companies = await _companyRepository.GetCompaniesAsync(parameters);
						
          	// 自动完成映射，参数即为源Model，泛型即为目标类型
            var companyDtos = _mapper.Map<IEnumerable<CompanyDto>>(companies);
            
            return Ok(companyDtos);
        }
  		
  		 [HttpGet("{companyId}")]
       public async Task<ActionResult<CompanyDto>> GetCompany(Guid companyId)
       {
            var company = await _companyRepository.GetCompanyAsync(companyId);
            
            if (company == null)
            {
                return NotFound();
            }
            return Ok(_mapper.Map<CompanyDto>(company));
       }
	}
```

