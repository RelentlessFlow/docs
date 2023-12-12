# Velocity语法

### 1. 直接打印数据、对象

```html
$name 
<p>$isMale</p>	
```

如果希望对象不存在时不显示，可以加！修饰符加以修饰。

```
<p>$isMale</p>	
```

### 2、if else语句

```html
	#if($msg1)
    <script>
    	alert("正确");
    </script>
    #else
   	<script>
    	alert("错误");
    </script>
    #end
```

语句以#开头，数据以$显示

### 3、循环语句

```html
#foreach($info in $mylist)
	$info.url
#end
```

