# -*- coding: utf-8 -*-
import sys
sys.path.append('F:\openseespy')
from opensees import *

import numpy as np
import matplotlib.pyplot as plt

# ------------------------------
# Start of model generation
# -----------------------------

# remove existing model
wipe()

# set modelbuilder
model('basic', '-ndm', 2, '-ndf', 2)

# create nodes
node(1, 0.0, 0.0)
node(2, 144.0,  0.0)
node(3, 168.0,  0.0)
node(4,  72.0, 96.0)

# set boundary condition
fix(1, 1, 1)
fix(2, 1, 1)
fix(3, 1, 1)

# define materials
uniaxialMaterial("Elastic", 1, 3000.0)

# define elements
element("Truss",1,1,4,10.0,1)
element("Truss",2,2,4,5.0,1)
element("Truss",3,3,4,5.0,1)

# create TimeSeries
timeSeries("Linear", 1)

# create a plain load pattern
pattern("Plain", 1, 1)

# Create the nodal load - command: load nodeID xForce yForce
load(4, 100.0, -50.0)

# ------------------------------
# Start of analysis generation
# ------------------------------

# create SOE
system("BandSPD")

# create DOF number
numberer("RCM")

# create constraint handler
constraints("Plain")

# create integrator
integrator("LoadControl", 1.0)

# create algorithm
algorithm("Linear")

# create analysis object
analysis("Static")

# perform the analysis
analyze(1)

ux = nodeDisp(4,1)
uy = nodeDisp(4,2)
if abs(ux-0.53009277713228375450)<1e-12 and abs(uy+0.17789363846931768864)<1e-12:
    print("Passedddddd!")
else:
    print("Failed!")
    
    
    
    
    
 '''opensees为开源软件，可回归到有限元最基础的部分，有限元软件只是分析运行的途径，有限元理论才是结构分析的核心。掌握其中原理才能灵活运用有限元软件
                             掌握结构概念和有限元软件，借助软件自行研究'''
  '''1. 当一结构为弹性，分析很快可结束，但当结构非线性较强时，可能发生不收敛的情况，如将uniaxialMaterial Elastic 1 1.0e5 
     改为uniaxialMaterial Steel01 1 200. 1.0e5 0.1时增加材料的非线性，单元内力达到200后刚度退化为初始的0.1倍再运行收敛更加困难
     可将analyze 3000 0.01改为analyze 6000 0.005即缩小每一分析步的步长，模型收敛'''  
'''2.计算时间与收敛性平衡：减小分析步长可改善收敛性，但会增加计算时间，两者相互矛盾  在地震作用较小的时段，结构非线性发展较小，可用较大步长快速算过，但在地震
 作用较大的时段结构可能产生强非线性，所以要用足够小的步长来保证收敛。为了平衡模型分析总时间和模型分析收敛性，可在运算过程中动态改变步长，以达到平衡'''

'''3.讲解在opensees中用zerolength或twonodelink单元来模拟只受压单元，避免节点顺序的影响：http://www.hanlindong.com/2017/opensees-5questions-1/ '''
'''4.低纬度空间中指定局部坐标轴方向：有限单元法中，每个单元都有自己的局部坐标轴，若定义为零长度单元，则单元的局部坐标轴方向与整体坐标方向相同，若为非零长度单元，则单元局部轴为inode指向jnode方向
      但局部2轴的方向没有指定，在对twonodelink单元赋方向时，如果坐标数小于3，应对不存在的坐标值赋0.'''

'''5.twonodelink的自由度耦合，如果不希望发生自由度耦合，应定义多个在1方向上的twonodelink单元，而不是使用一个单元的多个方向，可参考例题。 '''

'''6.record输出，周期与振型，结构的位移和速度通常是相对于地面的相对位移和相对速度，而要与牛顿第二定律建立联系需关心结构的加数度为绝对加数度。
recorder Node -file node.txt -node 1 -dof 1 accel输出的为相对加数度，recorder Node -file node.txt -timeSeries 1 -node 1 -dof 1 accel输出为绝对加数度'''

'''7.拟时间输出，单元内力输出：recorder Element -file ele.txt -time -ele 1 force 
输出单元1的内力 第一列为拟时间 第二到第七列为单元受力 前三列为inode节点受的等效外力，后三列为jnode节点受的等效外力，分别按1 2 3 三个方向排序 这些力是定义在全局坐标系下的。还有localforce、basicforce等命令
force命令得到的等效力是建立在全局坐标系下的，localforce语句得到的等效力是建立在单元局部坐标系下的，basicforce命令输出局部坐标系下的轴力和两个端弯矩！'''

'''8.坐标转换：（1）element elasticBeamColumn $eleTag $iNode $jNode $A $E $G $J $Iy $Iz $transfTag  和（2）geomTransf Linear  $transfTag  $vecxzX $vecxzY $vecxzZ 局部坐标轴的定义x y z 的定义
element命令里inode-jnode定义了x轴及其方向，然后vecxz是用户选择的不和x轴平行的任意向量，这两个向量叉乘得到y轴，x轴和y轴再叉乘得到z轴，这就是局部坐标。（1)element命令已经定义了x轴，只需
给出vecxz在整体坐标系下的坐标，就可以知道局部坐标系所有的方向，因此（2）geom命令里$vecxzX $vecxzY $vecxzZ 三分量就是向量vecxz在整体坐标系下的坐标。 
也就是：element里定义x轴，geom里定了向量vecxz，这两个向量定了局部坐标系。需注意，$transfTag代表局部坐标轴矢量编号（vecxz)编号，所以element的$transfTag和geom的$transfTag要对应起来，
为了方便明白，一般每一个element都选一个单独编号。链接###  https://blog.csdn.net/weixin_39233778/article/details/79365694'''
    *********************************************************************************************************************************************
opensees(open system for earthquake engineering simulation)#面向对象的软件框架，采用有限元方法对地震工程进行仿真）
开源软件，无限潜力。可用于非线性结构，岩土分析的丰富材料，单元库及分析手段。领先不断进步
opensees单元库：
Elastic Beam Column Element （弹性梁柱单元）***为伯努利梁未考虑截面的抗剪变化与Etabs中的铁木辛柯梁考虑截面剪切变形不同！
Zero-Length Element (0长度单元)***零长度构件虽然建模时是零长度，但计算构件变形时却是单位长度！
Elastic Material (弹性材料）***
Elastic-No Tension Material (弹性不受拉材料)
Series Material (串联材料)***
Parallel Material (并联材料)***
Steel01 Material (双折线钢材)***
Steel02 Material (Giuffre-Menegotto-pinto等向硬化钢材)
Hysteretic Material(滞回材料)
Viscous Material(粘性材料)
Fatigue Material(疲劳材料)
Limit State Material(极限状态材料)
截面恢复力模型按照建模细化程度分为：（1.基于构件 2.基于截面 3.基于材料）>>>常规截面恢复力模型有：弹性恢复力模型、理想弹塑性恢复力模型、两折线强化恢复力模型、滞回恢复力模型                  
模型转换步骤：ETABS>>>S2K文件>>>ETO>>>OPENSES的TCL文件
opensees的基本分块：前处理几何数据>>>何在约束段>>>求解控制段>>>数据输出控制段。
                  
截面弯矩-曲率分析练习/////////////////////////////////////////////////////
（opensees将单元沿纵向划分为若干离散的单元，各单元依靠积分控制点（integration point）组装成梁柱单元，opensees为位于截面处的积分控制点提供GAUSS-LEGENDRE和GAUSS-LOBATTO等数值积分方法。通过
 数值积分得到整个结构的刚度。构件弹塑性变形往往集中在构件端部截面。opensees提供的gauss-legendre数值积分方法对结构构件非线性变形的模拟只能随着积分控制点的增加才能逐渐接近单元端部截面，因此积分
 点数目的选择将直接影响该方法对构件弹塑性变形模拟的精确度；而gauss-lobatto数值积分方法始终保持两个积分控制点在单元端部截面处，因此使用该方法能够更加有效的模拟构件非线性行为。）
                  
结构分析///////////////////////////////////////////////////////////////
opensees中非线性方程组的求解采用 增量迭代法 进行。该法将外荷载的施加划分为若干加载步，在每一级荷载步中进行迭代计算，使每一级增量步中计算误差减小到很小范围内。
各级增量步的迭代求解方法：（线性迭代、牛顿线性迭代、newton-raphson方法、改进的newton-raphson方法、krylov-newton方法、broyden方法和BFGS方法）

收敛准则
增量位移、不平衡力、和能量控制等几种不同收敛准则。（通过设置函数的参数收敛容差达到确定判敛精度的目的.）

节点编号的优化方法/////////////////////////////////////////////////////
逆Cuthill-Mckee算法，简称RCM算法，用于非线性分析前对用户编制的节点编号进行优化，以减小结构整体刚度矩阵的带宽与数据存储量，提高计算效率。
                  
多点约束/////////////////////////////////////////////////////////////
opensees提供罚函数、拉格朗日乘子法、transformation等方法处理多点约束情况.（这些方法用来决定在非线性方程求解过程中如何处理约束自由度所对应的行列向量，而且针对刚度矩阵的不同类型（稀疏程度、是否对称、是否正定等
opensees提供各种不同数据存储方式和求解方法，如SparseSPD用于对称的稀疏矩阵，BandGeneral用于非对称的带状矩阵））
                  
结果输出////////////////////////////////////////////////////////////                  
Record类完成结果输出。（可根据需要输出非线性时程分析中各点的位移、速度、加速度、位移增量以及整个过程中各个响应量的包络值）
                  
约束类/////////////////////////////////////////////////////////////                  
SP-Constraint(单点约束) #为节点自由度指定提供指定的值
MP-Constraint(多点约束) #为相关节点一定数量的自由度提供参考值 如，主节点从节点的自由度的约束情况
                  
荷载类///////////////////////////////////////////////////////////
opensees中有限元模型上荷载可以分为两类：节点荷载（nodalload）和单元荷载（elementalload）比如构件自重、表面张力、初始应力、温度变化引起的力等。                  

                  
                  
                  
外荷载的施加////////////////////////////////////////////////////////////
基于位移控制的施加方法、基于荷载控制的施加方法、荷载-位移组合控制方法、弧长控制法

                  
**********************************      TCL文档      *****************************************************
model BasicBuilder -ndm $ ndm <-ndf $ ndf>
model BasicBuilder -ndm 3 -ndf 6  #构件模型  
---------------------------------------------------------------------------------                  
node 23945              18.2360              65.9083             137.2250
node $nodeTag $posx $posy $posz #节点坐标，坐标最好用浮点数表达，而不是用整数
------------------------------------------------------------------------------------
mass $nodeTag $mux $muy $muz $mRx $mRy $mRz
          节点标签        广义质量             转动惯量
mass 2 2.5 2.5 2.5 0.0 0.0 0.0; # define mass in x y and z coordinates
（与大部分有限元程序一样Opensees质量源采用节点质量源的形式）mass用于在节点上创建质量，质量与质量产生的荷载在opensees中为两个不相关概念，mass定义的质量只影响惯性力，不产生荷载。
  如希望考虑结构的自重，额外加入重力的定义，与质量定义完全无关。                
-----------------------------------------------------------------------------                  
fix $nodeTag  ux  uy  uz  Rx Ry  Rz
fix 109 1 1 1 1 1 1;   #固定支座
--------------------------------------------------------------------------------------                  
EqualDOF command （等自由度命令）# equalDOF命令用于建立节点间自由度的相互关系，也就是点与点之间的约束作用（constraint）
equalDOF $rNodeTag $cNodeTag $dof1 $dof2 ...
          主节点     从节点    节点上自由度的限制
equalDOF 117 126 3 4 5 6；# 将节点126的自由度3 4 5 6处的位移强制与节点2的位移相同。
# 只使用equalDOF，锁定两节点自由度的关系，并不能实现铰接，而且会影响计算无法运行下去，因为构件I、J两个节点的扭动自由度，RZi与RZj不能同时取消必须保留一个扭转刚度。                  
---------------------------------------------------------------------------------------------------------------------------
element zeroLength 260        117       126      -mat 1 1     -dir 1 2
element zeroLength 5          2          11      -mat 1 1 1   -dir 4 5 6                  
        零长度单元  单元标签   i端节点  j端节点  单轴材料的标签    材料方向
（节点117和126之间的桁架标签260在连接单元1 2自由度方向采用UniaxialMaterial本构曲线1）
(zerolength元素对象由同一位置上两节点定义，可通过多个UniaxialMaterial对象连接，表示元素的力-变形关系) 零长度单元建模时为零长度，构件变形时为单位长度
#equalDOF 2 11 1 2 3 
#element zeroLength 5 2 11 -mat 1 1 1 -dir 4 5 6
####强制令节点11方向1 2 3的自由度（所有平动位移）等于节点2方向1 2 3的自由度，节点11 2的平动值相等，转动值不相等，也就是空间上的铰接。定义标签为5的零长度单元，其节点2 11 坐标相同，1 1 1 为预先定义的单轴材料标签，4 5 6代表局部坐标轴x y z轴的转动，由于材料4 5 6 方向上的材料1刚度很小，该零长度单元可以轻易发生其局部坐标轴x y z 轴的转动变形！
###在opensees中通过equalDOF命令和zeroLength单元实现铰接时，链接杆件的剪力和弯矩均为0
element zeroLength 1 2 4 -mat 5 6 -dir 1 2; #swss标记1在节点2和4之间，分别用材料5和6作用于方向1和2                  
--------------------------------------------------------------------------------------------------------------------------------------------------                  
uniaxialMaterial Elastic         1000   0.1265625E+11
uniaxialMaterial Elastic          2     2.482E+004
    单轴材料       弹性材料       材料编号   弹性模量值
# uniaxialmaterial命令用于定义一个滞回模型，在opensees中滞回模型不区分应力-应变模型 和 力--位移模型 取决与模型用在什么单元上。                 
---------------------------------------------------------------------------                  
#define concrete
uniaxialMaterial Concrete01     1      -50130000.00000             -0.00192      -25060000.00000             -0.00365
---------------------------------------------------------------------------------------------------------------------------------                  
#define steel
uniaxialMaterial Steel02 $matTag $Fy $E0 $b
uniaxialMaterial Steel02 1              100000              2000              0.15 
                        材料编号         屈服力             弹性刚度           屈服后硬化率
uniaxialMaterial Steel01 4               250                206000            0.01                  
------------------------------------------------------------------------------------------------------------------------                  
geomTransf PDelta     1       1.0000000       0.0000000       0.0000000
geomTransf Linear $ transfTag $ vecxzX $ vecxzY $ vecxzZ  
geomTransf Linear               1              1.000 0.000 0.000 
          转换类型       局部坐标轴矢量编号     局部坐标轴的方向矢量值
(几何变换命令用于构造坐标变换对象，将梁单元刚度和抵抗力从局部坐标系转换为全局坐标系)                                   
-------------------------------------------------------------------------------------------------------------------------                  
element dispBeamColumn 10336     1 11186     3      10000     1 -mass      5625.0000000000                  
element dispBeamColumn 40067 23305  6367     3   82640000    81 -mass         0.0000010000
eleLoad -ele     1 -type -beamUniform 0    -12173.5576171875                  
load  1342         0.0000000000         0.0000000000    -79339.2265625000         0.0000000000       0.0000000000       0.0000000000 
-----------------------------------------------------------------------------------------------------------------------------------------                  
rigidDiaphragm 3       3     77     13      1     59      5     87      7     15      9     21     11     19     17     25     23    111    119     29     27     31    104     33     37     35     73     43     41     45     39    129     49    103     97     63     81     91                  
rigidDiaphragm  $perpDirn     $masterNodeTag  $slaveNodeTag1      $slaveNodeTag2
  刚性隔板     刚性隔板方法为3   主节点 (刚心)      从节点1              从节点2      ……
rigidDiaphragm 3 2 4 5 6; #从节点4,5,6随主节点2做X-Y plan的平移和旋转   （采用刚性隔板模型时，需与constraint lagrange配合使用，否者运行出错）
#  其中$perpdim表示刚性隔板的方法，如楼板刚性隔板的平移方向为u1 u2即1-2平面，改值应该为3 
		  
---------------------------------------------------------------------------------------------------------------------------------------------                  
element elasticBeamColumn $ eleTag $ iNode $ jNode $ A $ E $ G $ J $ Iy $ Iz $ transfTag 
element elasticBeamColumn 10      16         18   1.125E+005  2.482E+004  1.034E+004   1.530E+009   1.898E+009 5.859E+008    10
                       单元标签  单元始点  单元终点  单元截面积   弹性模量      剪切模量    截面惯性扭矩    截面y/z惯性矩Iy/Iz  局部坐标轴编号
-------------------------------------------------------------------------------------------------------------------------------------------- 
pattern UniformExcitation $IDloadTag $iGMdirection -accel $AccelSeries;
#uniformexcitation 模式用于定义施加指定方向的加速度记录，如地震加速度时程文件。
#multiplesupport 模式用于指定节点指定方向施加自定义的位移记录或地震动记录。
pattern 定义荷载工况对象，每个pattern 是一个与timeseries相关联的

pattern UniformExcitation $ patternTag $ dir -accel $ tsTag 
pattern Plain             $ patternTag              $ tsTag
"""                        加载模式的标签       加载模式中使用时间序列的标签
timeSeries Linear 1 ;# 建立一个线性的时间序列
pattern Plain 1 1 { ;# 建立一个荷载工况
	load 1 5.0e3  ;# 给节点1加一个5kN的力
}                  
"""                       
timeSeries Path 1 -dt 0.01 -filePath accel.txt ;# 创建地震加速度时间序列
pattern UniformExcitation 1        1        -accel 1 -fact 9800 ;# 创建地震工况
                        工况编号  时程编号

timeSeries Linear $ tag   ***** 
timeSeries Path $ tag -dt $ dt -filePath $ filePath <-factor $ cFactor> <-useLast> <-prependZero> <-startTime $ tStart>                   
-----------------------------------------------------------------------------------------------------------------------------------------------
recorder Node    -file dispx.txt   -time   -nodeRange  1 23945  -dof 1 disp
recorder Node    -file dispy.txt   -time   -nodeRange  1 23945  -dof 2 disp
recorder Node    -file dispz.txt   -time   -nodeRange  1 23945  -dof 3 disp                  
recorder Node    -file node1.out   -time   -node 1              -dof 1 2 3 disp
                    #输出文件名                               #节点1的X Y Z方向的位移
recorder EnvelopeNode -file nodesD.out -time -node 1 2 3 4 -dof 1 2 disp ;   #求多个节点位移响应的包络值 
 recorder Node <-file $fileName> <-time> <-node ($node1 $node2 -dof ($dof1 $dof2 ...) $respType
###   $respType ：响应类型，如 disp—位移、vel—速度、accel—加速度 reaction—节点反力
 recorder Node -file nodesA.out -timeSeries 1 -time -node 1 2 3 4 -dof 1 accel
#对于UNIFORMexcitation分析，生成nodeA.out文件，包含节点1 2 3 4在x方向上的绝对加数度（地面运动加速度+相对加数度）注意，未提供timeseries且均匀激励进行分析，记录相对加数度。
#recorder EnvelopeNode -file nodesD.out -time -node 2 -dof 1 2 3 disp
6.7 -164.418 3.02 -0.00429913 4.54 -2.08274  
5.58 243.224 12.26 0.00359666 5.6 2.88886
5.58 243.224 3.02 0.00429913 5.6 2.88886
记录节点2在x y z 方向的位移包络值 第一行为为负包络值 第二行为正包络值 第三行为前两者绝对值中的较大值
 recorder EnvelopeNode -file nodesA.out -time -timeSeries 1 -node 1 2 3 4 -dof 1 accel  
"""在时程分析中 accel vel disp 输出都是相对位移，如果要得到accel的绝对值，要在定义中加入-timeseries 1    """
--------------------------------------------------------------------------------------------------------------------------------------------------------                  
recorder EnvelopeElement -file eleD.out -time -ele 2 3 4 localForce  #多个单元局部坐标下的单元力向量
--------------------------------------------------------------------------------------------------------------------------------------------------------
recorder Drift -file drift.out -time -iNode 1 2 -jNode 3 4 -dof 1 -perpDirn 2    'Drift'输出记录层间位移角，节点间平移差与两节点间竖向距离的比值。
 --------------------------------------------------------------------------------------------------------------------------------------------------------                                               
constraints Transformation;  #Transformation Method 不允许节点存在多重约束
constraints Plain;       #Plain Constraint  #执行单点约束(fix command )和等自由度定义(equalDOF command)的多点约束命令                                         
constraints Lagrange; #Lagrange Multipliers #约束处理命令通过将Lagrange乘法引入到等式系统进行强制约束
 （命令用于构造ConstraintHandle对象，确定约束方程在分析中执行方式，约束方程为自由度强制指定值或自由度之间关系。                                               
-------------------------------------------------------------------------------------------------------------------------
numberer RCM; #RCM算法用于非线性分析开始前对用户编制的节点进行优化以减小结构整体刚度矩阵的带宽和数据存储量，提高计算效率。                                                
numberer Plain #节点自由度编号采用输入节点的顺序。
# plain numberer # reverse cuthill-mckee numberer  # alternative minimum degree numberer 
---------------------------------------------------------------------------------------------------------------------------------
#system ProfileSPD;
#system SparseSYM	
system CulaSparse *************************opensees-gpu新增加算法*****************#                                          
#BandSPD SOE    #ProfileSPD SOE   #SuperLU SOE    #UmfPack SOE    #FullGeneral     #SparseSYM SOE   #Mumps     #Cusp
# BandGeneral SOE #bandgeneral类对象用于非对称的带状矩阵
# BandSPD 用于构造方程对象的bandspd线性系统，用于具有带状轮廓的对称正定矩阵系统。用于减小带宽的存储格式。                                                
system Umfpack  用于构造使用Umfpack求解器的稀疏方程组                                                
system 命令用于构造linearSOE和linearSOLVER对象来存储和求解分析中的方程组                                               
--------------------------------------------------------------------------------------------------------------------------------------                                                
test NormDispIncr 1.0e-4 2000 2;  
                                                
test Energyincr 1.0e-4 200; #采用能量准则的收敛准则，容差1.0e-4最大迭代步200                                                 
test命令用于构件convergencetest对象，某些solutionAlgorithm对象需要一个convergencetest对象来确定迭代步骤结束时是否实现了收敛。
"""                                                
Norm Unbalance Test 
Norm Displacement Increment Test 
Energy Increment Test 
Relative Norm Unbalance Test 
Relative Norm Displacement Increment Test 
Total Relative Norm Displacement Increment Test 
Relative Energy Increment Test 
Fixed Number of Iterations
"""                                                
----------------------------------------------------------------------------------------------------------------------------------------                                                
algorithm NewtonLineSearch 0.75;
                                                
algorithm newton; # 用增量迭代法进行非线性方程组求解，将外荷载施加划分为若干加载步，在每一级荷载步中进行迭代计算，使每一级增量步中计算误差减小很小范围。                                                
algorithm 命令用于构造一个SolutionAlgorithm对象，该对象确定解决非线性方程所用步骤的顺序。
"""
Linear Algorithm 
Newton Algorithm 
Newton with Line Search Algorithm 
Modified Newton Algorithm 
Krylov-Newton Algorithm 
Secant Newton Algorithm 
BFGS Algorithm 
Broyden Algorithm
"""                                                
-------------------------------------------------------------------------------------------------------------------------------------------------------------                                                
integrator LoadControl 0.2;                                                
integrator 用于构造integrator对象，integrator对象确定方程对象系统中各项含义                                                
"""                                                
Static Integrators: #静态分析器
Load Control 
Displacement Control 
Minimum Unbalanced Displacement Norm 
Arc-Length Control 

Transient Integrators: #瞬态分析器
Central Difference 
Newmark Method 
Hilber-Hughes-Taylor Method  **************       ****************
Generalized Alpha Method 
TRBDF2 
Explicit Difference
integrator Newmark 0.5 0.25                                                 
"""                                                
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                
analysis Static
analyze 5                                                
analysis用于构造analysis对象，该分析对象由分析人员之前创建的组建对象构建的，所有当前可用的分析对象都"采用增量式"解决方案                                                
"""                                                
static  用于静态分析
Transient  用于恒定时间步长的瞬态分析
Variable Transient  用于可变时间步长的瞬态分析
"""                                                
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                 
zerolength(零长度单元)                                                
#此命令用于构造zeroLength元素对象，该对象由同一位置的两个节点定义。节点由多个UniaxialMaterial对象连接，以表示元素的力 - 变形关系。
#element zeroLength $ eleTag $ iNode $ jNode -mat $ matTag1 $ matTag2 ... -dir $ dir1 $ dir2 ... < - doRayleigh $ rFlag> <-orient $ x1 $ x2 $ x3 $ yp1 $ yp2 $ yp3> 
                                                                                材料方向 1 2 3-分别沿局部x y z轴平移；4 5 6-分别绕局部x y z 轴旋转
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                
地震波中的时间步长为0.01s,若后面分析的步长取为0.005s,则opensees会根据地震波的加速度插值得到实际分析步的地震加数度。
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set numModes 12
set lambda [eigen  $numModes]  # eigen命令用于求解特征值 12为特征值的数量
set period "Periods.txt"
set Periods [open $period "w"]
puts $Periods " $lambda"
close $Periods                                                
-----------------------------------------------------------------------------------------------------------------------------------------------
opensees里结构采用的是瑞利阻尼：
'''						 
set xDamp 0.05;  #设置阻尼比为0.05
set nEigenI 1;  #主振型1为第一振型
set nEigenJ 2;  #主振型2为第二振型
set lambdaN [eigen [expr $nEigenJ]]; #求解两阶振型的特征值
set lambdaI [lindex $lambdaN [expr $nEigenI-1]]; #提取第一阶特征值
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]]; #提取第二阶特征值
set omegaI [expr pow($lambdaI,0.5)]; #从特征值求解圆频率w1
set omegaJ [expr pow($lambdaJ,0.5)]; #从特征值求解圆频率w2
set alphaM [expr $xDamp*(2*$omegaI*$omegaJ)/($omegaI+$omegaJ)]; #质量比例系数 
set betaKcurr [expr 2.*$xDamp/($omegaI+$omegaJ)];   #刚度比例系数
rayleigh $alphaM $betaKcurr 0 0      #定义瑞利阻尼，只需填写α和β，其他为0						 
'''                                             
lindex命令返回list列表中的第index元素，替代时元素从0开始（也就是说索引就是第一个元素）
pow(x , y)函数为幂运算，求解x的y幂次方						 
克拉夫《结构动力学》12-5 比例粘滞阻尼矩阵的建立：
	假设应用于两个控制频率的阻尼比相同，即 ξm=ξn=ξ 给相质量与刚度的相关系数 a0=2ξω1ω2/（ω1+ω2）， a1=2ξ/（ω1+ω2）
	将上述比例阻尼矩阵用于工程实践时，建议ω1取多自由度体系的基频，而ω2则在对动力反应有显著贡献的高阶振型中选取。这样
	可保证对于这两个振型可以得到所需要的阻尼比（ξ1=ξn=ξ），在这两个指定频率之间所对应的振型将具有较低的阻尼比，而频率
	大于ω2的所有振型的阻尼比将大于ξn，并随频率的增加单调增加，最终结构为具有很高频率的振型反应因其高阻尼比而被有效消除。
*******************************************  TCL脚本语言的语法    ************************************************************                                                
tcl基于字符串的命令语言，由 新行 或 分号 ；分隔的命令组成
set foo 0
set bar 
注释
set foo 0; #******
						 
						 
set命令为变量赋值 #  set xdamp 0.05                                                
命令替换 如   # set lambdaN [eigen [expr $nEigen]]                                                
数学表达式   # set pi [expr 2*asin(1.0)]
                  
tcl允许打开文件以读入和写出
set file [open tmp.out w];
puts $file1 "calling tcl ok "                                                
close $file1
                                                
                                                
puts [format "%.2f" $b] #输出保留两位小数的形式。
$ :为变量置换符号。
expr : 进行数学运算都要使用expr命令执行。
puts [format "%.2f" $sqt]：为输出的简洁性，将结果保留2位小数。                  
                  
                  

                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
*************************************************************调用opensees的命令*****************************************************
system （‘opensees co.tcl’） 或       ！OpenSees.exe co.tcl 
-----------------------------------------------------------------------------------------------------------------------------------                                                
# set the test parameters
set testType NormDispIncr
set testTol 1.0e-4
set testIter 25
test $testType $testTol $testIter   
#   test NormDispIncr 1.0e-4 2000 2;
#   test Energyincr 1.0e-4 200; #采用能量准则的收敛准则，容差1.0e-4最大迭代步200                                                
------------------------------------------------------------------------------------------------------------------------------------                                                
# set the algorithm parameters
set algotype krylovNewton
algorithm $algotype
-------------------------------------------------------------------------------------------------------------------------------------                                                
# define ground motion excitation
set IDloadTag 1001;   # 工况编号
set iGMfile "GMX.txt"; # 地震波文件
set iGMdirection "1"; # 定义地震波输入方向
set iGMfact "10"; # 定义地震波峰值放大系数
set dt 0.01; # 定义地震波时间步
set GMfatt [expr $iGMfact]; #   
set AccelSeries "Series -dt $dt -filePath $iGMfile -factor $GMfatt";
pattern UniformExcitation $IDloadTag $iGMdirection -accel $AccelSeries;                                                
pattern UniformExcitation    1001         1        -accel  -dt 0.01 -filepath GMX.txt -factor 10                                          
#对于加载路径，其中在文件中指定因子以获得点之间的恒定时间间隔：
#timeSeries Path $ tag -dt $ dt -filePath $ filePath <-factor $ cFactor> <-useLast> <-prependZero> <-startTime $ tStart>                                                

#UniformExcitation模式允许用户对作用于特定方向的模型应用均匀激励。命令如下：
#pattern UniformExcitation $ patternTag $ dir -accel $ tsTag <-vel0 $ vel0> <-fact $ cFactor>                                                
                                                     $ tsTag	定义加速历史的TimeSeries系列的标记。						 
---------------------------------------------------------------------------------------------------------------------------
set iGMfile "H-E01140 H-E01140" ;		# ground-motion filenames, should be different files
set iGMdirection "1 3";			# ground-motion directions
set iGMfact "1.5 0.75";			# ground-motion scaling factor

set IDloadTag 400;                                                 
set iGMfile "GMX.txt;
set iGMdirection "1";
set iGMfact "10";						 
set dt 0.01;                                                
foreach GMdirection $iGMdirection GMfile $iGMfile GMfact $iGMfact { 
incr IDloadTag; 
set GMfatt [expr 1*$iGMfact]; 
set AccelSeries "Series -dt $dt -filePath $iGMfile -factor $GMfatt";
pattern UniformExcitation $IDloadTag $GMdirection -accel $AccelSeries; 
}    多维地震波的输入标准格式                                                
----------------------------------------------------------------------------------------------------------------------------------------                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
********************************************   ETO程序   ******************************************************************************                                                
ETABS 9.7.2>>>S2k文件>>>ETO>>>opensees的TCL文件（做适当修改）
                                                
实例12 杆件铰接的处理：在腹杆两端定义zerolength单元，并通过equalDOF命令实现节点约束，从而释放腹杆端部弯矩。
""" 为在ETO中实现杆端弯矩释放 1.将需要释放弯矩的一端从整体中分割一段很小距离，该距离导入eto后变成零长度单元，这个零长度单元两点会在同一空间位子，并在这两个节点设置零长度单元！2.将该段截面指定为RIGID,并对其端部进行弯矩释放。"""                                                
实例19 带粘滞阻尼器的框架动力分析：在opensees中通过定义采用MAXWELL材料的纤维截面，并指定给安装了粘滞阻尼器的斜撑来实现粘滞阻尼器的模拟。                                                
# uniaxialMaterial Maxwell $matTag   $K     $C     $a    $Length
# uniaxialMaterial Maxwell    4    100000   3000   1       1
#粘滞阻尼器在etabs中同样采用Maxwell模型，不同是etabs采用FNA快速模态积分法求解个别构件（阻尼器）的非线性。模态积分点也就需要提供非线性阻尼器单元的线性等效刚度，一般做法，先输入一个较小的刚度放入etabs进行第一次非线性计算，计算完取出阻尼器的滞回曲线，采用滞回曲线计算出等效刚度，再代入etabs进行第二次计算，如此类推。
#DR.dimitrios G.lingos(McGill University)在opensees开发了MAXWELL单元，运用该单元可以对粘滞阻尼器进行模拟。粘滞阻尼器的模拟建议采用Maxwell单元，而不是采用Viscous单元，maxwell单元收敛性较好。                                                
实例20 带隔震的框架动力分析：在没有考虑隔震支座阻尼影响的前提下，隔震器的强度、刚度由屈服力Fy、弹性刚度K和屈服后硬化率决定，故在简化前提下采用Steel01材料模拟隔震器。                                                
# 选择首层所有柱，将其分割成两端，选择首层所有柱下半段并指定截面“rigid”（材料为steel）并释放其I端（base那段）的弯矩M2 M3，上述操作为让eto在首层柱底生成零长度单元！                                                
                                                
                                                
*************************                    *******************************                    ********************************
This tutorial will use the following portal frame as driving example:
# SET UP ----------------------------------------------------------------------
# units: kN, m, sec
wipe;        ​​​​  # clear opensees model ------------------------清楚程序之前输入的数据
# import procedure008.tcl supplied with NextFEM Designer
source procedure008.tcl
# required by procedures - they can run also for parallel analysis
set pid 0
file mkdir data;        ​​ ​​​​ # create data directory
model basic -ndm 3 -ndf 6;  ​​ # 2 dimensions, 3 dof per node ------------- 指定三维六节点自由度体系
set modelName "frame_ex"; # model name, best if equal to .tcl filename
 
# define GEOMETRY -------------------------------------------------------------
set LCol 3.0;    # column length
set LBeam 6.0;   # beam length
set Weight 1000.;   # superstructure weight
 
# mechanical properties
set fyk  [expr 235*pow(10,3)]
set ftk   [expr 360*pow(10,3)]
set Es  [expr 210000*pow(10,3)]
set gammaM0  [expr 1.05]
set fyd  [expr $fyk/$gammaM0]
 
# calculated parameters
set PCol $Weight;     # nodal dead-load weight per column
set g 9.81;       ​​ ​​ ​​ ​​​​ # g acceleration
set Mass [expr $PCol/$g];   # nodal mass
 
# calculated geometry parameters
set A  [expr 53.83*pow(10,-4)];   # cross-sectional area
set Iy  [expr 3692.0*pow(10,-8)];  # Column moment of inertia
set Iz  [expr 1336.0*pow(10,-8)]
set d  [expr 190.0*pow(10,-3)]
set bf  [expr 200.0*pow(10,-3)]
set tw  [expr 6.5*pow(10,-3)]
set tf  [expr 10.0*pow(10,-3)]
 
# nodal coordinates:
node 1 0 0 0;   # node coords. X, Y, Z
node 2 0 $LCol ​​ 0  
node 3 $LBeam 0 0
node 4 $LBeam $LCol 0
 
# Single point constraints -- Boundary Conditions
fix 1 1 1 1 1 1 1;    # node DX DY RZ
fix 3 1 1 1 1 1 1;
fix 2 0 0 1 1 1 0 
fix 4 0 0 1 1 1 0 
 
# nodal masses:
mass 2 $Mass $Mass 0. 0 0 0;  # node#, Mx My Mz, Mass=Weight/g, neglect rotational inertia at nodes
mass 4 $Mass $Mass 0. 0 0 0
 
# Define ELEMENTS & SECTIONS -------------------------------------------------------------
set HE200A 1;  # assign a tag number to the column section
set HE200ATemp 2 
 
# MATERIAL parameters -------------------------------------------------------------------
set steelMatID 1;      # material ID tag
 
# -----------
set fyk  [expr 275*pow(10,3)]
set ftk   [expr 430*pow(10,3)]
set Es  [expr 210000*pow(10,3)]
set nus  [expr 0.3]
set Gs  [expr $Es/2/(1+$nus)]
set Gammas  [expr 78.5/pow(10,0)]
set gammaM0  [expr 1.05]
set fyd  [expr $fyk/$gammaM0]
set Bs 0.01;      # strain-hardening ratio 
set R0 18;      # control the transition from elastic to plastic branches
set cR1 0.925;      # control the transition from elastic to plastic branches
set cR2 0.15;      # control the transition from elastic to plastic branches
 
uniaxialMaterial Steel02 $steelMatID $fyd $Es $Bs $R0 $cR1 $cR2;    # Menegotto-Pinto model
 
# FIBER SECTION properties -------------------------------------------------------------
 
set nfdw 5;       # number of fibers along web depth 
set nftw 2;       # number of fibers along web thickness
set nfbf 5;        # number of fibers along flange width 
set nftf 2;        # number of fibers along flange thickness
 ​​​​ 
​​ set dw [expr $d - 2 * $tf]
​​ set y1 [expr -$d/2]
​​ set y2 [expr -$dw/2]
​​ set y3 [expr ​​ $dw/2]
​​ set y4 [expr ​​ $d/2]
 ​​​​ 
​​ set z1 [expr -$bf/2]
​​ set z2 [expr -$tw/2]
​​ set z3 [expr ​​ $tw/2]
​​ set z4 [expr ​​ $bf/2]
 ​​​​ 
#  ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​ ​​​​ 
section fiberSec ​​ $HE200ATemp {
 ​​ ​​ ​​ ​​​​ # ​​ nfIJ  ​​ ​​​​ nfJK    ​​​​ yI  ​​ ​​ ​​​​ zI  ​​​​   yJ  ​​ ​​​​ zJ  ​​ ​​ ​​ ​​ ​​ ​​​​ yK  ​​​​ zK  ​​ ​​ ​​ ​​​​ yL  ​​ ​​​​ zL
patch quadr ​​ $steelMatID $nfbf $nftf ​​   $y1 $z4  ​​​​ $y1 $z1  ​​​​ $y2 $z1  ​​​​ $y2 $z4
patch quadr ​​ $steelMatID $nftw $nfdw  ​​ ​​ ​​​​ $y2 $z3  ​​​​ $y2 $z2  ​​​​ $y3 $z2  ​​​​ $y3 $z3
patch quadr ​​ $steelMatID $nfbf $nftf ​​   $y3 $z4  ​​​​ $y3 $z1  ​​​​ $y4 $z1  ​​​​ $y4 $z4
 ​​​​ } 
set string1 P
set string2 Mz
set string3 Vy
section Aggregator $HE200A $steelMatID $string1 $steelMatID $string2 $steelMatID $string3 -section $HE200ATemp
 
# define geometric transformation: performs a linear geometric transformation of beam stiffness and resisting force from the basic system to the global-coordinate system
set ColTransfTag 1;    # associate a tag to column transformation
geomTransf Linear $ColTransfTag 0 0 1 ;  
set BeamTransfTag 2;    # associate a tag to column transformation
geomTransf Linear $BeamTransfTag 0 0 1 ;  
 
# element connectivity:
set numIntgrPts 5;           # number of integration points for force-based element
element nonlinearBeamColumn 1 1 2 $numIntgrPts $HE200A $ColTransfTag; # self-explanatory when using variables
element nonlinearBeamColumn 2 3 4 $numIntgrPts $HE200A $ColTransfTag
element nonlinearBeamColumn 3 2 4 $numIntgrPts $HE200A $BeamTransfTag
 
# define GRAVITY LOAD -------------------------------------------------------------
pattern Plain 1 Linear {
 ​​ ​​​​ eleLoad -ele 3 -type -beamUniform -20 0; # distributed superstructure-weight on beam
}
 
# define damping proportional to masses and to 1st mode
MDamping 0.05 1
 
# parameters for the subsequent analyses
set Tol 1.0e-3;   # convergence tolerance for test
set Tmax   15.0
set dt   0.005
set filePath  "record10.30.dat"; # string with the 2 columns plain text seismic record
set ampl   1
set dir   1
 
# non-linear static analysis for applying vertical loads
NonLinearStatic $Tol 0.1 10 $modelName
# modal analysis
Modal 3 1 $modelName 1
# dynamic analysis
DynamicAn $Tmax $dt $filePath 1 $dir $Tol $ampl $modelName						 
                                                
                                                
                                                
                                                
                                                
                                                
                                                
