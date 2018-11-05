tcl script language
tcl面向过程的语言，先被读取后被执行
*******************************************  TCL脚本语言的语法    ************************************************************
tcl解释器对双引号中各种分隔符不做处理，但对换行符及$和[]两种置换符会照常处理。
在花括号中所有特殊字符将成为普通字符，失去特殊意义，tcl解释器不做特殊处理
set x {\n [expr 10+12]}
\n [expr 10+12]

opensees中单位由用户自己规定，单位在整体模型中必须统一
N-M-C-KG为一套单位
N-mm-C-ton——一套单位

wipeAnalysis:删除之前全部分析命令，如system，numberer，constraints,integrator,algorithm,analysis等命令。

D = $alphaM * M + $betaK * Kcurrent +$betaKinit * Kinit + $betaKcomm * KlastCommit 
rayleigh $alphaM $betaK $betaKinit $betaKcomm 
$alphaM factor applied to elements or nodes mass matrix          #质量矩阵的系数$alphaM
$betaK factor applied to elements current stiffness matrix.      #本时步当前迭代步的刚度矩阵系数
$betaKinit factor applied to elements initial stiffness matrix.  #初始刚度矩阵系数
$betaKcomm factor applied to elements committed stiffness matrix.#上一个时步的刚度系数

geomTransf transfType？ARG1？...

geomTransf Linear $transfTag $vecxzX $vecxzY $vecxzZ 
该命令用于构造线性坐标变换（LinearCrdTransf）对象，该对象执行从基本系统到全局坐标系的梁刚度和抵抗力的线性几何变换

geomTransf PDelta $ transfTag $ vecxzX $ vecxzY $ vecxzZ 
此命令用于构建P-Delta坐标转换（PDeltaCrdTransf）对象，该对象执行梁刚度和抵抗力从基本系统到全局坐标系的线性几何变换，考虑二阶P-Delta效应。注意：P LARGE Delta效果不包括P小三角效应。
将Linear改为PDelta即可计算几何大变形（即：小应变大位移）目前opensees的几何大变形仅限于梁柱框架单元，对板壳合实体单元都未开发，关于剪力墙构件模型可参考陆新征网站。

非线性力插值梁柱单元：nonlinearBeamColumn，关于力插值的理论可参考伯克利filip文章，传统位移插值欧拉梁用dispBeamColumn.

定义刚性楼板中心处的节点坐标
node 9 0.0 0.0 1.0
node 14 0.0 0.0 2.0
node 19 0.0 0.0 3.0
定义刚性楼板
rigidDiaphragm 3 9 5 6 7 8
rigidDiaphragm 3 14 10 11 12 13
rigidDiaphragm 3 19 15 16 17 18
不考虑刚性板z方向位移和绕 x y 轴转动，定义如下约束
fix 9 0 0 1 1 1 0
fix 14 0 0 1 1 1 0
fix 19 0 0 1 1 1 0 
注意：当模型中使用 rigidDiaphragm equalDOF 等约束时必须使用 constraint Transformation 或 constraint penalty,
当模型中只有fix约束才可用plain！具体可参考有限元教材。当使用 Transformation 时只保留主节点自由度，从节点自由度被删除
因此再对其他节点使用其他约束（比如fix）将出错。

在时程分析中改变步长，减少分析步长可以改善收敛性，但会增加计算时间，对于这一矛盾，地震
作用较小时段结构非线性发展很小，可用较大步长算过。但当地震作用较大是时段，结构可产生较强
的非线性，要用足够小的步长来保证收敛。_______在计算时间与收敛性之间取得平衡。
opensees中系统时间总有很小误差（由于c++语言局限导致，如固定时间步长为0.01秒分析，而实际上系统时间可能为0.00999999999
或0.010000000001这样误差不会造成错误错误大，但在最后一步3000.0秒分析可能出错！如系统时间为3000.0000000001超出 pattern
定义的时间长度，系统不再插值，直接返回外力为0！会导致此时步分析错误。

equalDOF 16 34 1 2; 由于16 34 均fix ,此行不用加

foreach theNode {3 4 5 7 9} {
	recorder Node -file  node_reaction_result/node1_reaction.out -time -node $theNode   -dof 1 2 3 4 5 6 reaction;
}


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


################################################################################
#Mode1: First Mode Used to Define Rayleigh Damping.（用于定义瑞利阻尼的第一周期）
#Mode2: Second Mode Used to Define Rayleigh Damping.（用于定义瑞利阻尼的第二周期）
#Damp: Damping Ratio. (阻尼比)

proc Rayleigh_Proc { Mode1 Mode2 Damp } {
    set lambdaN [eigen -fullGenLapack [expr $Mode2]]
    set lambdaI [lindex $lambdaN [expr $Mode1-1]]
    set lambdaJ [lindex $lambdaN [expr $Mode2-1]]
    set omegaI [expr pow($lambdaI,0.5)]
    set omegaJ [expr pow($lambdaJ,0.5)]
    set alphaM [expr $Damp*(2*$omegaI*$omegaJ)/($omegaI+$omegaJ)]
    set betaKcurr [expr 2.*$Damp/($omegaI+$omegaJ)]
    rayleigh $alphaM $betaKcurr 0 0
    puts "Rayleigh Damping Defined"
}
Rayleigh_Proc 1 3 0.05

######################################################################################
set xDamp 0.05;
set nEigenI 1;
set nEigenJ 2;
set lambdaN [eigen [expr $nEigenJ]];                                             《简单版本》
set lambdaI [lindex $lambdaN [expr $nEigenI-1]];
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];
set omegaI [expr pow($lambdaI,0.5)]; 
set omegaJ [expr pow($lambdaJ,0.5)];
set alphaM [expr $xDamp*(2*$omegaI*$omegaJ)/($omegaI+$omegaJ)]; 
set betaKcurr [expr 2.*$xDamp/($omegaI+$omegaJ)];   
rayleigh $alphaM $betaKcurr 0 0 
#######################################################################################

#Mode_Proc：模态分析
#ModeNum: Number of Modes to Solve.（求解的模态数）
proc Mode_Proc { ModeNum } {
    set pi 3.1415926
    set lambda [eigen -fullGenLapack  $ModeNum]
    set period "Periods.txt"
    set Periods [open $period "w"]
    set i 1
    foreach lam $lambda {
        set period [expr 2*$pi / sqrt($lam)]
        set period [format "%.3f" $period]
        set str "Mode "; append str $i; append str ": "; append str $period
        puts $Periods "$str"; puts "$str"
        incr i
    }
    close $Periods
    record
}
Mode_Proc 12
##########################################################################################





	
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

控制结构
if {condition1} {
	statement1
} else
