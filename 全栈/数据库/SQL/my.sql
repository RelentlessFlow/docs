-- 一、数据库操作
-- 1. 创建数据库
CREATE DATABASE test;
CREATE DATABASE IF NOT EXISTS test;
CREATE DATABASE test DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
-- 2. 查看数据库
SHOW DATABASE;  --查询所有创建的表
SHOW CREATE DATABASE test; --查询已经创建的数据库信息
-- 3. 选择数据库
USE test;
-- 4. 修改编码集（ALTER）
ALTER DATABASE test DEFAULT CHARACTER SET gbk COLLATE gbk_bin;
-- 5. 删除数据库
DROP DATABASE test;

-- 二、数据表操作
-- 1. 创建数据表
CREATE TABLE IF NOT EXISTS `test`(
   `id` INT UNSIGNED AUTO_INCREMENT,
   `title` VARCHAR(100) NOT NULL,
   `author` VARCHAR(40) NOT NULL,
   `date` DATE,
   PRIMARY KEY ( `runoob_id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- 2. 查看当前数据库中的数据表
SHOW TABLE;
-- 3. 查看数据表详情结构（列出该表的CRETE TABLE语句）
SHOW CREATE TABLE test;
-- 4. 查看数据表详情结构（以表格形式列出来，更美观）
DESCRIBE test; -- or DESC test
-- 5. 修改表名
ALTER TABLE books RENAME tb_books;
-- 6. 修改字段名和数据类型
ALTER TABLE 表名 CHANGE 旧字段名 新字段名 新数据类型;
ALTER TABLE books CHANGE Author bookAuthor VARCHAR(10);
-- 7. 修改字段数据类型
ALTER TABLE 表名 MODIFY 字段名 新数据类型;
ALTER TABLE tb_books MODIFY Bookname VARCHAR(100);
-- 8. 添加字段
ALTER TABLE 表名 ADD 新字段名 数据类型 [约束条件] [FIRST|AFTER 已经存在的字段] -- FIRST为第一个字段
ALTER TABLE tb_books ADD column1 AFTER Press;  -- 在已经存在的Press字段后面添加字段column1，数据类型为int
-- 9. 删除字段
ALTER TABLE TABLE 表明 DROP 字段名;
ALTER TABLE TABLE DROP column1;
-- 10. 修改字段的排列位置
ALTER TABLE  MODIFY 字段名 数据类型 [FIRST|AFTER 已经存在的字段]
ALTER TABLE tb_books MODIFY Press AFTER bookAuthor;
-- 11. 删除数据表
DROP TABLE 表明;
DROP TABLE test;

-- 三、数据表约束
/** 套路：
 * 1. 创建表的时候直接写约束。能写字段里的直接写（PRIMARY KEY AUTO_INCREMENT，UNIQUE，NOT NULL，DEFAULT，）。
      不能的写最后：复合主键（PRIMARY KEY(key1,key2),外键（CONSTRAINT XXX FOREIGN KEY XXX REFERENCES XXX） ）
 * 2. 添加约束：ALTER 表名 MODIFY 字段名 数据类型 约束
 * 3. 删除约束
 *    主键，外键，唯一约束： ALTER TABLE 表名 DROP 约束 [字段名] 这个约束可以是PRIMARY KEY，FOREIGN KEY 字段名，INDEX 字段名
 *    非空约束、默认值：删除相当于重新定义字段类型，用ALTER MODIFY添加约束那种方式改
 */
-- 1. 主键
-- 1.1 创建主键
-- 第一种创建表添加主键约束
CREATE TABLE tb_books(
  Bookid char(6) PRIMARY KEY, -- 主键
  Bookname VARCHAR(50),
  Author VARCHAR(50)
);
-- 第二种在已有表的基础上修改字段为主键
ALTER TABLE 表名 MODIFY 字段名 数据类型 PRIMARY KEY;
ALTER TABLE  MODIFY Bookid char(6) PRIMARY KEY;
-- 1.2 删除主键
ALTER TABLE 表名 DROP PRIMARY KEY;
ALTER TABLE tb_books DROP PRIMARY KEY;
-- 1.3. 复合主键
CREATE TABLE tb_books(
  Bookid char(6),
  Bookname VARCHAR(50),
  Author VARCHAR(50),
  PRIMARY KEY(Bookid, Bookname) -- 复合主键
);
ALTER TABLE 表名 ADD PRIMARY KEY(字段名1, 字段名2,...,字段名n);
ALTER TABLE sales ADD PRIMARY KEY (product_id, region_code);
ALTER TABLE 表名 DROP PRIMARY KEY;

-- 2. 外键
CONSTRAINT 外键 FOREIGN KEY (从表的外键字段名) REFERENCES 主表名(主表的主键字段名)
CREATE TABLE borrow(
  Bookid char(6) PRIMARY KEY,
  Borrowbookid char(6),
  Borrowreader char(6),
  Borrowdate datetime,
  Borrownum int(2),
  CONSTRAINT fk_bks_brw FOREIGN KEY(Borrowbookid) REFERENCES books(Bookid) -- 外键约束
)ENGINE=InnoDB;
ALTER TABLE 从表名 ADD CONSTRAINT 外键名 FOREIGN KEY (从表的外键名) REFERENCES 主表名(主表的主要字段名)
ALTER TABLE borrow ADD CONSTRAINT fk_bks_brw FOREIGN KEY (Borrowbookid) REFERENCES books(Bookid);
ALTER TABLE borrow DROP FOREIGN KEY fk_bks_brw;

-- 3. 非空约束
字段名 数据类型 NOT NULL
CREATE TABLE borrow(
  Bookid char(6) PRIMARY KEY,
  Borrowbookid char(6),
  Borrowreader char(6),
  Borrowdate datetime NOT NULL, -- 非空约束
  Borrownum int(2),
  CONSTRAINT fk_bks_brw FOREIGN KEY(Borrowbookid) REFERENCES books(Bookid)
)ENGINE=InnoDB;
-- 删除非空约束
ALTER TABLE 表名 MODIFY 字段名 数据类型;
ALTER TABLE company MODIFY company_address VARCHAR(200);
-- 4. 唯一约束
字段名 数据类型 UNIQUE;
CREATE TABLE company(
  campany_id int(11) PRIMARY KEY,
  campany_name VARCHAR(50) UNIQUE,
  campany_address VARCHAR(200) NOT NULL
);
ALTER TABLE company MODIFY campany_name VARCHAR(50) UNIQUE;
ALTER TABLE company DROP INDEX 字段名
-- 5. 默认约束
字段名 数据类型 DEFAULT 默认值
CREATE TABLE borrow(
  Bookid char(6) PRIMARY KEY,
  Borrowbookid char(6),
  Borrowreader char(6),
  Borrowdate datetime NOT NULL,
  Borrownum int(2),
  Borrowtel VARCHAR(20) DEFAULT '0371-' -- 默认约束
  CONSTRAINT fk_bks_brw FOREIGN KEY(Borrowbookid) REFERENCES books(Bookid)
)ENGINE=InnoDB;
ALTER TABLE 表名 MODIFY 字段名 新数据类型 DEFAULT 默认值;
ALTER TABLE borrow MODIFY Borrowtel VARCHAR(20) DEFAULT '0371-';
ALTER TABLE borrow MODIFY Borrowtel VARCHAR(20); -- 删除约束

-- 6. 字段值自动增加（自增的字段必须为INT相关数据类型）
字段名 数据类型 PRIMARY KEY AUTO_INCREMENT;
CREATE TABLE borrow(
  Bookid int(11) PRIMARY KEY AUTO_INCREMENT, -- 主键自增
  Borrowbookid char(6),
  Borrowreader char(6),
  Borrowdate datetime NOT NULL,
  Borrownum int(2),
  Borrowtel VARCHAR(20) DEFAULT '0371-'
  CONSTRAINT fk_bks_brw FOREIGN KEY(Borrowbookid) REFERENCES books(Bookid)
)ENGINE=InnoDB;
ALTER TABLE 表名 MODIFY 字段名 新数据类型 AUTO_INCREMENT;
ALTER TABLE borrow MODIFY Bookid int(11) AUTO_INCREMENT;
ALTER TABLE borrow MODIFY Bookid int(11); -- 删除约束

-- 四、插入，更新，删除数据（UPDATE，DELETE）
INSERT INFO teacher(tno,tname,tgender,tedu,tpro) VALUES -- 多条插入
('1012', '李连杰', '男', '硕士研究生', '讲师'),
('1013', '黄大法', '男', '大专', '讲师'),
('1014', '李晨', '女', '本科', '讲师');
INSERT INFO teacher(tno,tname,tgender,tedu,tpro) VALUES -- 单条插入
('1012', '李连杰', '男', '硕士研究生', '讲师');
UPDATE teacher SET tedu = '硕士研究生' WHERE tedu = '研究生' -- 更新数据
DELETE FROM teacher WHERE tname = '李晨' -- 删除数据
/**
  * TRUNCATE与DELETE相比： 
  * 1. TRUNCATE会将AUTO_INCREMENT自增清0，DELETE不会。
  * 2. TRUNCATE产生的日志比DELETE少
  * 3. 对于参与了索引和视图的表，不能使用TRUNCATE TABLE删除
 **/
TRUNCATE TABLE tb_teacher; -- 清空表数据（慎用）


-- 五、查询（SELECT）
-- 1. 基本查询语句
SELECT [ALL|DISTINCT]要查询的内容
FROM 表名列表
[WHERE 条件表达式]
[GROUP BY 字段名列表][HAVING逻辑表达式]]
[ORDER BY 字段名[ASC|DESC]]
[LIMIT[OFFSET,] n]

-- 2. 查询语句案例 
SELECT * FROM studentinfo; -- * 表示查询所有字段
SELECT *, now() FROM studentinfo; -- now()可以打印当前时间
SELECT sname,sno,sgender,sbirth,sclass FROM studentinfo;
SELECT sno AS 学号, sname AS 姓名,now() AS 查询日期; -- AS表示重命名查询结果字段名
SELECT DISTINCT sclass FROM studentinfo; -- DISTINCT表示祛除查询中重复的数据项
/**
  * WHERE字句可以指定查询条件，编写一个条件表达式
  * 条件表达式的运算符：
  * 1. 比较运算符：>、>=、=、<=、!=、!>、!< 比较字段值大小
  * 2. 范围运算符：BETWEEN...AND、NOT BETWEEN...AND 判断字段值是否在指定范围内
  * 3. 列表运算符：IN、NOT、IN 判断字段值是否在指定的列表中
  * 4. 模式匹配运算符：LIKE、NOT LIKE 判断字段值是否和指定的模式字符串匹配
  * 5. 空值判断运算符：IS NULL、IS NOT NULL 判断字段值是否为空
  * 6. 逻辑运算符：AND、OR、NOT 用于多个条件表达式的逻辑连接
  */
SELECT * FROM studentinfo WHERE sclass = 'JAVA2001'; -- 比较运算符
SELECT * FROm studentinfo WHERE sbirth BETWEEN '1999-1-1' AND '1999-12-31'; -- 范围运算符
SELECT * FROM studentinfo WHERE sno IN('200101','200106','200108'); -- 列表运算符
SELECT * FROM studentinfo WHERE sname LIKE '张%'; -- 姓张的 模式匹配运算符
SELECT * FROM studentinfo WHERE sname LIKE '张_' -- 姓张的，且长度为2的
SELECT * FORM teacher WHERE tgender IS NULL; -- 空值判断运算符
SELECT * FROM sname WHERE sname LIKE '李%' OR sclass = 'JAVA2001' -- 逻辑运算符
SELECT * FROM studentinfo WHERE NOT(YEAR(sbirth) = 2000) -- 不是2000年出生的学生
SELECT * FROM elective WHERE cno = 'J001' ORDER BY score DESC; -- 按照分数排序
SELECT * FROM studentinfo ORDER BY sno ASC, sbirth DESC -- 按照学号升序排序，按照学生出生日期降序，学号优先
SELECT * FROM studentinfo LIMIT 5; -- 查询前5条学生数据
SELECT * FROM studentinfo LIMIT 4,1; -- 查询第5条学生的数据 4表示OFFSET偏移量，从几条开始打印
SELECT COUNT(*) AS 学生总人数 FROM studentinfo; -- 查询学生数据表数据个数

SELECT COUNT(*) AS 学生总人数, SUM(score) AS 总成绩, 
  AVG(score) AS 平均分,MAX(score) AS 最高分, MIN(score) AS 最低分 
FROM elective WHERE cno = 'J001';

/**  
*     sgender 人数
*     女       37
*     男       63
*/
SELECT sgender, COUNT(*) AS 人数 FROM studentinfo GROUP BY sgender;