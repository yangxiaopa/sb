tcl script language
tcl面向过程的语言，先被读取后被执行
*******************************************  TCL脚本语言的语法    ************************************************************ 
N-M-C-KG为一套单位
tcl基于字符串的命令语言，由 新行 或 分号 ；分隔的命令组成
set foo 0
set bar 
注释
set foo 0; #******

tcl反斜线序列：\n 换行符 \b 删除 \f 换页符 \r 回车 \t 制表符 \v 垂直制表符 
双引号引用：双引号可取消其中单词和命令分隔符的特殊解释，大括号取消其中所有特殊字符的特殊解释						 
若想在由双引号括起来的单词中包含双引号字符，则应该使用反斜线替换：set msg "could not open file \"name.out\""   could not open file "name.out"
大括号引用：取消其中所有特殊字符的特殊意义，所有字符都将被原封不动地识别为这个单词的值

 file delete {*}[glob *.txt]；#删除文件夹下面以.txt为后缀的文件
 file mkdir output; #创建output为名称的文件夹

 proc countdown {x} {
                puts "running countdown"
                if 1 {
                   while {$x > 0} {
                         puts "x = $x"
                        incr x -1
                   }
                }
}
countdown 3
#尽量避免在注释中出现大括号，如确实需要在注释中使用大括号，确保他们是配对的。对于每一个左大括号，都保证有一个正确配对的右大括号。

set命令为变量赋值 #  set xdamp 0.05                                                
命令替换 如   # set lambdaN [eigen [expr $nEigen]]；命令替换通过方括号表示，会调用括号中的命令。                                               
数学表达式   # set pi [expr 2*asin(1.0)]
                  
tcl允许打开文件以读入和写出
set file [open tmp.out w]; #将文件tmp.out打开并写入
puts $file1 "calling tcl ok "  #puts与后面内容必须有一空格，便于解释器能识别
puts stdout "Hello, world!";  #stdout使程序在标准输出设备中打印						 
close $file1
                                                
                                                
puts [format "%.2f" $b] #输出保留两位小数的形式。
$ :为变量置换符号。
expr : 进行数学运算都要使用expr命令执行。
puts [format "%.2f" $sqt]：为输出的简洁性，将结果保留2位小数。                  
%s(字符串表示）%d(整数表示) %f(浮点表示) %e(具有尾数指定形式的浮点表示) %x(六进制十进制表示) 
						 
字符串表示
set myVariable "hello world"
puts $myVariable；						 
set myVariable {hello world}
puts $myVariable；#当我们要表示多个字符串时，可使用双引号或大括号，与其他语言不同，在tcl中当单个单词不需要双引号。
						 
set s1 "hello world"
puts "length of string s1 is [string length $s1]";

set s1 {orange blue red green}
puts [llength $var]

set s1 {orange blue red green}
puts [lindex $var 1];#列表索引
blue
   
set var {orange blue red green}
set var [linsert  $var 3 black white]; #在索引处插入项
puts $var   
orange blue red black white green
   
set var {orange blue red green}
set var [lreplace $var 2 3 black white]；#替换索引项目
puts $var   
orange blue black white
   
set var {orange blue red green}
lset var 0 black；#设置项目索引 
puts $var   
black blue red green
   
set var {orange blue red green}
set var [lsort $var]；#排序列表
puts $var
blue green orange red   
   
set s1 "hello"
append s1 "world";#追加命令
puts "$s1"
						 
列表
set myVariable {red green blue}
puts [lindex $myVariable 2]
blue						 
set myVariable "red green blue"
puts [lindex $myVariable 1]；#列表可用双引号或大括号来表示						 
green						 
						 
更改精度
set variableA "10"
set tcl_precision 5；#使用tcl_precision特殊变量来更改精度！！！！！！！！！！！！！！！！！。
set result [expr $variableA / 9.0];
puts $result 						 
1.1111						 
						 
运算符
+ - * / %(取余数) **；#算术运算符
==（检查两个操作数的值是否相等）  ！=（检查两个操作数的值是否不等） >      <     >=        <=     #关系运算符						 
if { [file exists output] == 0 } {
	  file mkdir output;
}						 
&&(and) ||(or) !(not)  #逻辑运算符
tcl数学函数：abs(x) acos(x) asin(x) atan(x) bool(x) ceil(x) double(x) exp(x) floor(x) hypot(x,y) int(x)
            log(x) log10(x) max(arg,...) min(arg,...) pow(x,y) rand() round(x) sqrt(x) 

循环
while循环 for循环 嵌套循环 
#无限循环,如果条件永远为真，则循环变为无限循环，可通过将表达式保留为1进行无限循环，可通过ctrl+c键终止无限循环
while {1} {
	puts "this loop will run forever."  
}
                                                
数组迭代
set languages(0) Tcl
set languages(1) "C Language"
for { set index 0 }  { $index < [array size languages] }  { incr index } {
   puts "languages($index) : $languages($index)"
}
languages(0) : Tcl
languages(1) : C Language
						 
关联数组
set personA(Name) "Dave"
set personA(Age) 14
puts  $personA(Name)
puts  $personA(Age)
Dave
14						 
                                                
程序:提供特定可重用功能的一系列命令的代码块。
proc procedureName {arguments} {
	body
}                                                                                 
#For Example
proc hello { } {
	puts "hello world fuck you"
}
hello #调用程序  
hello world fuck you #程序运行结果                                               
#具有多个参数的程序
proc add {a b} {
   return [expr $a+$b]
}
puts [add 10 30]   
40
#具有可变参数的程序
proc avg {numbers} {
	set sum 0
	foreach number $numbers {
		set sum [expr $sum + $number]
	}
	set average [expr $sum/[llength $numbers]]
	return $average
}
puts [avg {70 80 50 60}]
puts [avg {70 80 50 }]
65
66 


#具有默认参数的程序：默认参数用于提供默认值，如果没有提工值，则可以使用该值。
proc add {a {b 100} } {
   return [expr $a+$b]
}
puts [add 10 30]
puts [add 10]
40
110   
#递归程序   
proc factorial {number} {
	if {$number <=1} {
		return 1
	}
	return [expr $number * [factorial [expr $number-1]]]
}	
puts [factorial 3]
puts [factorial 5]  
6   
120 
或者
proc factorial {val} {
	set result 1
	while {$val>0} {
		set result [expr $result*$val]
		incr val -1
	}
	return $result
}
factorial 3
6
{}大括号，当过程块作为一个参数传递给proc时，不希望发生变量替换和命令替换，我们希望替换在过程块作为tcl脚本处理时发生。大括号保证替换只在过程块内部发生

tcl文件 I/O
set file [open   tmp.out    w+]; #将文件tmp.out打开阅读并写入
          open filename   accessMode(r:读取文件，r+:打开文件进行阅读和写入w:写入文件，w+：打开文件进行阅读和写入a:以附加形式写入文件，原内容保留)
puts $file "hello world fucking you"；#写入文件
r——只读，指定文件必须存在，若不指定访问模式，默认为只读
r+——可读写，指定文件必须存在
w——只写，如果文件存在将其清空，若不纯在创建一个新文件
w+——可读写，如果文件存在将其清空，若不存在创建一个新文件
a——只写，将初始访问文件位置设为文件尾，写入内容直接添加到原文件，不存在则创建一个新空白文件
a+——可读写，将初始访问文件位置设为文件尾，写入内容直接添加到原文件，不存在则创建一个新空白文件

close $file
close fileName #关闭文件  

读文件
set fp [open "input.txt" w+]
puts $fp "test"
close $fp
set fp [open "input.txt" r]
set file_data [read $fp]
puts $file_data
close $fp
   
'''   
逐行读取直至文件末尾，
set fp [open "co.tcl" r]
while { [gets $fp data] >= 0 } {
   puts $data
}
close $fp； #读取co.tcl文件并打印在屏幕上
'''
   
tcl内置函数
namespace import ::tcl::mathfunc::*   #调用包
puts [tan 10]
puts [pow 10 2]
0.6483608274590866
100.0   
abs ceil 等等
   
时钟
#get seconds
set currentTime [clock seconds]
puts $currentTime
#get format 
puts "The time is: [clock format $currentTime -format %H:%M:%S]"； #将秒转换为小时分钟秒
puts "The date is: [clock format $currentTime -format %D]"；#%D数字日期，mm/dd/yy 月日年
   
字符串函数
append:将值追加到字符串尾 format：字符串格式化 scan：字符串分解 string option：字符串操作与命令集

数组
set aa(1) 2; #aa为数组名 括号中1为元素名
要在元素中使用空格，可使用反斜线替换的空格符，或者将整个变量都用双引号括起来。如，set "capital(south dakota)" pierre.另一种在元素名称上使用替换：
set state "new mexico"
set capital($state) "santa fe"

ince命令
set x 43; incr x 12 

append命令   
set msg "calculate now\n"
foreach i {1 2 3 4 5} {
	append msg "$i square is [expr $i*$i]\n"
}
set msg

expr命令
expr {2*sin($x)}; #将表达式用大括号括起来，效率更高更可避免代码中安全漏洞

列表操作
if {“los angeles" in $cities} {
		...
}

字符串操作
取得字符 string index 
string index "sample  string" 3;#索引序号从0开始,若索引参数中含有空白符索引地方超过字符串，string index会返回空字符串
string index "sample  string" end;

取得字符 string range 
string range "sample  string" 3 end;#返回第一个索引指向的位置到第二个索引之间的所有字符。

转换为大写字母 string toupper 
string toupper "watch out!"
WATCH OUT!


转换为小写字母 string tolower
string tolower "WATCH!"
watch!

裁剪字符串 string trim /  string trimleft / string trimright 
string trim aaxxxbab abc; #指定裁剪的字符串与指定裁剪方式，string trim命令把开头和结尾出现的裁剪字符都删去，返回删除后的字符串

字符串重复指定 string repeat 
string repeat "*" 20;
string repeat "a b c d\n" 5;
a b c d
a b c d
a b c d
a b c d
a b c d

简单搜索 string first / string last 
string first th "There is the tub where I bathed today"；#在第二个字符串中搜索与第一个字符串相同的子字符串，如果找不到返回-1

字符串比较 string compare （区分大小写）
string compare michigan michigan; #读入两个字符串操作，并进行比较，如果字符串相同返回0 如果第一个字符串在字典中先于第二个字符串
   			           返回-1，如果第一个字符串在字典中后于第二个字符串返回1
				   

字符串比较 string equal  （区分大小写,除非指定-nocase）string equal -nocase dog Dog
string equal cat cat ; #对两个字符串进行简单的字符串比较，严格相同返回1，否者返回0
string equal -length 4 catalyst cataract; #只对前length个字符进行比较。

字符串置换
string replace "san diego, califoria" 4 8 "francisco"; #参数字符串，删除字符开头与结尾的索引 置换用字符串

format创建字符串
format "the square root of 10 is %.3f" [expr sqrt(10)]；

列表
lindex {john anne mary jim} 1; 
llength {a b c d}; 
 concat {a b c} {d e} f {g h i}; #将参数列表中的所有元素串接为一个大的列表
 a b c d e f g h i
 concat {a b c} {d e} {f {g h i}}；
 a b c d e f {g h i}
 
 set x {a b c};
 set y {d e};
 set z [concat $x $y];
 
lrepeat 3 a;命令重复元素
a a a
lrange $x 1 3;#返回列表$x中范围索引1到3的参数
























