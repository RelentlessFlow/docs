pglite 使用

```typescript
import "reflect-metadata";
import { DataSource } from "typeorm";
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinColumn } from "typeorm";
import { PGliteDriver } from "typeorm-pglite";
import { PGLiteSocketServer } from '@electric-sql/pglite-socket'
import { PGlite } from "@electric-sql/pglite";

/** ------------------- 实体定义 ------------------- **/
@Entity()
export class Company {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255 })
  name: string;

  @Column({ type: "varchar", length: 255 })
  location: string;

  @OneToMany(() => Employee, (employee) => employee.company)
  employees: Employee[];
}

@Entity()
export class Employee {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255 })
  name: string;

  @Column({ type: "int" })
  age: number;

  @ManyToOne(() => Company, (company) => company.employees)
  @JoinColumn({ name: "company_id" })
  company: Company;
}

/** ------------------- 创建PG数据库实例，创建套接字服务供DBMS访问 ------------------- **/
const db = await PGlite.create({ dataDir: 'pglite', username: 'postgres' })
new PGLiteSocketServer({ db, port: 5433, host: '127.0.0.1', debug: true }).start()

/** ------------------- TypeORM 数据源配置 ------------------- **/
const AppDataSource = new DataSource({
  type: "postgres", // TypeORM 仍需用 postgres type
  driver: new PGliteDriver({
    dataDir: 'pglite'
  }).driver, // 这里是 PGlite 驱动
  synchronize: true, // 自动同步表结构
  logging: false,
  entities: [Company, Employee], // 两张表、职员表、公司表
});

/** ------------------- 主流程 ------------------- **/
async function main() {
  const dataSource = await AppDataSource.initialize();
  console.log("Database initialized!");
  // 1️⃣ 插入公司
  const companyRepo = dataSource.getRepository(Company);
  const acme = companyRepo.create({ name: "Acme Corp", location: "New York" });
  const globex = companyRepo.create({ name: "Globex Inc", location: "San Francisco" });
  await companyRepo.save([acme, globex]);
  // 2️⃣ 插入员工
  const employeeRepo = dataSource.getRepository(Employee);
  const employees = [
    employeeRepo.create({ name: "Alice", age: 30, company: acme }),
    employeeRepo.create({ name: "Bob", age: 25, company: acme }),
    employeeRepo.create({ name: "Charlie", age: 28, company: globex }),
  ];
  await employeeRepo.save(employees);
  // 3️⃣ 查询：带公司信息的员工
  const allEmployees = await employeeRepo.find({ relations: ["company"] });
  console.log("All employees with company info:");
  allEmployees.forEach((e) => {
    console.log(`${e.name} (${e.age}) works at ${e.company.name}`);
  });
  // 4️⃣ 查询：一个公司所有员工
  const acmeWithEmployees = await companyRepo.findOne({
    where: { id: acme.id },
    relations: ["employees"],
  });

  if (acmeWithEmployees) {
    console.log(`Employees at ${acmeWithEmployees.name}:`);
    acmeWithEmployees.employees.forEach((e) => console.log(`- ${e.name}`));
  }
}

/** ------------------- 数据导入导出 ------------------- **/
async function dump() {
  const file = await db.dumpDataDir()
  const restoredPG = new PGlite({ dataDir: 'restoredPgLite', loadDataDir: file })
  const res = await restoredPG.exec("SELECT * from company;")
  console.log('restored company:', JSON.stringify(res))
}


await main()
await dump()
```

