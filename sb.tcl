tcl script language
tcl面向过程的语言，先被读取后被执行
*******************************************  TCL脚本语言的语法    ************************************************************
tcl解释器对双引号中各种分隔符不做处理，但对换行符及$和[]两种置换符会照常处理。
在花括号中所有特殊字符将成为普通字符，失去特殊意义，tcl解释器不做特殊处理
set x {\n [expr 10+12]}
\n [expr 10+12]

N-M-C-KG为一套单位
tcl基于字符串的命令语言，由 新行 或 分号 ；分隔的命令组成
set foo 0
set bar 
注释
set foo 0; #******

根据分析类型创建适当的文件夹
例如：
	# Define type of analysis:  "pushover" = pushover;  "dynamic" = dynamic
	set analysisType "dynamic";
	if {$analysisType == "pushover"} {
		set dataDir Concentrated-Pushover-Output;	# name of output folder
		file mkdir $dataDir; 						# create output folder
	}
		if {$analysisType == "dynamic"} {
		set dataDir Concentrated-Dynamic-Output;	# name of output folder
		file mkdir $dataDir; 						# create output folder
	}
	
#                       Eigenvalue Analysis                    			   
############################################################################
	set pi [expr 2.0*asin(1.0)];					# Definition of pi
	set nEigenI 1;							# mode i = 1
	set nEigenJ 2;							# mode j = 2
	set lambdaN [eigen [expr $nEigenJ]];				# eigenvalue analysis for nEigenJ modes
	set lambdaI [lindex $lambdaN [expr 0]];				# eigenvalue mode i = 1
	set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];		# eigenvalue mode j = 2
	set w1 [expr pow($lambdaI,0.5)];				# w1 (1st mode circular frequency)
	set w2 [expr pow($lambdaJ,0.5)];				# w2 (2nd mode circular frequency)
	set T1 [expr 2.0*$pi/$w1];					# 1st mode period of the structure
	set T2 [expr 2.0*$pi/$w2];					# 2nd mode period of the structure
	puts "T1 = $T1 s";						# display the first mode period in the command window
	puts "T2 = $T2 s";						# display the second mode period in the command window
	
#                       Gravity_Proc：自重加载
#############################################################################
#Step：Number of Steps.（分析步数）
proc Gravity_Proc { Step } {
    set incr [expr 1./$Step]           # convergence tolerance for test
    set Tol 1.0e-6;                    
    constraints Transformation         # how it handles boundary conditions
    numberer RCM                       # renumber dof's to minimize band-width (optimization)
    system UmfPack                     # how to store and solve the system of equations in the analysis (large model: try UmfPack)
    test NormDispIncr $Tol 6;          # determine if convergence has been achieved at the end of an iteration step
    #test EnergyIncr 1.0e-6 200
    integrator LoadControl $incr       # determine the next time step for an analysis  
    algorithm Newton                   # use Newton's solution algorithm: updates tangent stiffness at every iteration
    analysis Static                    # define type of analysis: static or transient
    analyze $Step                      # apply gravity
    puts "Gravity Done."
    loadConst -time 0.0                # maintain constant gravity loads and reset time to zero
}
Gravity_Proc 10	
	
	
	
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
linsert $ 2 x y z;#把一个或多个元素插入列表，形成新的列表
set x {a b {c d} e};
linsert $x 2 x y z;
a b x y z {c d} e
如果索引值为零，那么新元素就插入到列表的开头，如果是1，新元素就插入到原列表第一个元素之后。
lreplace $x 3 5; #删除列表中对应索引的元素，如果了replace指定更多的参数，参数会被插入被删除元素的位子
set person [lreplace $person 1 1 [list $q]]；
lset person 1 32;#修改已经存在的列表
lappend x $a $b $c;#可改写为 set x [concat $x [list $a $b $c]];
lassign {a b c} x y z;
puts "$x $y $z"
set x {john anne mary jim};

lsearch $x jim;

lsearch -all $x *y;
2
lsearch -all -inline  $x *m; #inline选项指定返回元素，而非元素的索引
jim

lsort 按字典顺序排序
lsort {john fuck honda jackba option guangu look uo sick}
fuck guangu honda jackba john look option sick uo
-decreasing 将“最大”元素放在最前面； -integer 和 -real 将列表元素视为整数或实数，按照值大小排序； -dictionary指定不区分大小写的排序，元素中
-unique 原列表重复出现的元素只会出现一次                                                                  嵌入的数字作为非负整数处理
lsort -integer -index 1 {{first 24} {second 18} {third 30 }}
{second 18} {first 24} {third 30 }

字符串和列表间的转化 split 与join 
split命令将字符串分成几个部分，然后对各个部分独立进行处理
split {a b c} {};
a { } b { } c
join命令是split命令逆操作，把列表元素串接为一个字符串，元素间用指定分隔符隔开
set x {24 112 4}
expr [join $x +]

字典
dict get命令
set prefers {
                joe     {the easy life}
                jeremy  {fast cars}
                {uncle sam}     {motherhood and apple pie}
}
dict get $prefers joe;
the easy life

创建和更新字典
检测字典：子命令size exists keys for 
dict size {firstname anne surname huan title miss}
3
dict size {}
0

dict size {a alpha b bravo c charlie d delta e epsilon}
5

set fuck {a alpha b bravo c charlie d delta e epsilon}
dict exists $fuck a
1
dict exists $fuck f
0
dict keys $fuck; #获得字典中所有关键字的列表
a b c d e
dict values $fuck； #获取字典中关联值的列表
alpha bravo charlie delta epsilon

dict for 命令获取一对变量的列表作为一个参数（关键字与关联值），遍历字典的关键字与关联值
dict for {key value} $fuck {
                puts [format "%s: %s" $key $value]
}
a: alpha
b: bravo
c: charlie
d: delta
e: epsilon

dict append fuck a beta；
a alphabeta b bravo c charlie d delta e epsilon

统计一段字中各单词出现的次数
proc computehistogram {text} {
                set frequencies { }
                foreach word [split $text] {
                        #ignore empty words caused by double spaces
                        if { $word eq " " } continue
                        dict incr frequencies [string tolower $word]
                }
                return $frequencies
}
computehistogram "this day is a hanppy happy day"
this 1 day 2 is 1 a 1 hanppy 1 happy 1

在两个关键字之间交换关联值
set fuck {a alpha b bravo c charlie d delta e epsilon}
dict update fuck a s1 b s2 {
                lassign [list $s1 $s2] s2 s1
}

8.流程控制： if while for foreach switch eval
break:终止最内层的循环命令
continue：终止最内层循环的当前迭代步，进行该命令的下一个迭代步
eval 用空格分隔符把所有arg串接起来

if命令
if {$x < 0 } { 
	...
} elseif { $x == 0 } {
	...
} elseif { $x == 1 } {
	...
} else {
	...
}

switch命令
switch $x { 
	a {incr t1}
	b {incr t2}
	c {incr t3}
}
如果x的值为a 将其加t1; 如果x为b 将其加t2;如果x为c 将其加t3

循环命令 while for foreach 
把列表从变量a中复制到变量b中，并在复制时倒转列表中的元素顺序
set b { }
set i [expr {[llength $a] - 1}]
while {$i >= 0} {
	lappend b {lindex $a $i}
	incr i -1
}
或
set b { }
foreach {set i [expr {[llength $a] -1}]} {$i >=0} {incr i -1} {
	lappend b [lindex $a $i]
}

foreach要获取三个参数，变量名 列表 构成循环体的tcl脚本，每次执行循环脚本块前，foreach将变量设为列表的下一个元素

循环控制 break 与 continue 
break命令让引起最内层循环的命令立即终止循环
continue命令只终止最内层循环的当前迭代步

从文件运行：source
source co.tcl;#运行co.tcl文件内容，可以用绝对路径指定文件，或与当前运行的脚本工作目录相对的路径指定文件。允许在文件内的脚本中使用return命令终止过程
             使用source将一个大的脚本分解为小的模块，由一个主脚本用source调用其他的脚本模块，可以通过把过程定义放到一个文件中，把可重用的过程建成库
	     然后可以从多个应用程序中用source调用。
	    

9.0 过程proc :一个tcl过程就是用tcl脚本定义的一个命令。
proc name arglist body 

proc plus {a b} {
	expr {$a+$b}
}
plus 3 4;
7

return命令：让最内层的过程立即返回，return参数就是该过程的后返回值，一个过程在执行完全部脚本前就提前返回。
 proc fac {x} {
                if {$x <=1} {
                        return 1
                }
                return [expr {$x * [fac [expr {$x -1}]]}]
}
fac 4
24

局部与全局变量：传给过程的参数就是局部变量，过程可以使用global命令引用全局变量如：global x y 
set a 1;
set b 2;
 proc printvars { } {
                global a b
                puts "a is $a, b is $b"
} 
printvars;
a is 1, b is 2

参数变量的数目与默认设置：
proc inc {value {increment 1}} {
	expr $value+$increment
}
incr 42 3
45
incr 42
43

参数列表中最后一个元素的特殊名称为args,那么调用过程中可以给出可变数量个参数。
proc sum {args} {
	set total 0
	foreach val $args {
		set total [expr {$total + $val}]
	}
	return $total
}
sum 1 2 3 4
10

11.0访问文件
cd dirname  cd(change directory):将当前工作目录改为dirname
pwd ：返回当前工作目录的完整路径
open name access :#open "input.txt" w+ 打开名为name的文件，access可以为r r+ w w+ a a+

操作文件和目录名
处理磁盘上的文件
创建目录：file mkdir output;#创建output的文件夹
删除文件: file delete a.txt;#删除文件a.txt
	  file delete a.txt b.txt;#删除两个文件
	  file delete {*}[glob *.txt];#删除文件夹下所有的以.txt为后缀的文件

复制文件：file copy 1.txt 2.txt;#file copy命令把文件1.txt复制到2.txt
	  glob *.txt;#glob命令校验以.txt为后缀的文件哪些存在
          可以使用-force选项让file copy命令覆盖已经存在的目标文件：file copy -force 1.txt 2.txt;#-force可避免因2.txt文件存在而报错。

将多个文件复制到目录中
file mkdir bag;#创建bag文件夹
file copy 1.txt 2.txt bag;#将文件1.txt 2.txt复制到目标目录bag中，

重命名和移动文件
file rename 1.txt 11.txt；#将1.txt文件重命名为11.txt

文件信息命令
file option name 
       ||
       ||
       \/
如exists、readable、size,如果制定的文件存在exists返回1， name为指定的文件名
if { [file exists output1]==0} {
      file mkdir output1 ;
}

复制文件内容
file copy使用方便也有限制，其创建的目标文件是源文件逐个字节复制的副本，且只能应用与磁盘上的文件，
chan copy允许复制时进行一些改变，可改变使用的字符编码，可应用于任何tcl通道，如管道、套接字以及磁盘上文件

set input [open a.txt r]；
set output [open 2.txt w]；
chan copy $input $output;
close $input;
close $output

时间延迟







