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
+ - * / %(取余数)；#算术运算符
==（检查两个操作数的值是否相等）  ！=（检查两个操作数的值是否不等） >      <     >=        <=     #关系运算符						 
if { [file exists output] == 0 } {
	  file mkdir output;
}						 
&&(and) ||(or) !(not)  #逻辑运算符
						 
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
   
