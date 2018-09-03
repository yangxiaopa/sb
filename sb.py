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

                  
TCL文档**************************************************************************************************
model BasicBuilder -ndm $ ndm <-ndf $ ndf>
model BasicBuilder -ndm 3 -ndf 6  #构件模型  
---------------------------------------------------------------------------------                  
node 23945              18.2360              65.9083             137.2250
node $nodeTag $posx $posy $posz #节点坐标
------------------------------------------------------------------------------------
mass $nodeTag $mux $muy $muz $mRx $mRy $mRz
          节点标签        广义质量             转动惯量
mass 2 2.5 2.5 2.5 0.0 0.0 0.0; # define mass in x y and z coordinates
（与大部分有限元程序一样Opensees质量源采用节点质量源的形式）
-----------------------------------------------------------------------------                  
fix $nodeTag  ux  uy  uz  Rx Ry  Rz
fix 109 1 1 1 1 1 1;   #固定支座
--------------------------------------------------------------------------------------                  
EqualDOF command （等自由度命令）
equalDOF $rNodeTag $cNodeTag $dof1 $dof2 ...
                   主节点        从节点       节点上自由度的限制
equalDOF 117 126 3 4 5 6；#连接单元的两点117 126的这几个自由度被固定
------------------------------------------------------------------------------------------------
                  
                  
                  
-------------------------------------------------------------------------                  
uniaxialMaterial Elastic         1000   0.1265625E+11
uniaxialMaterial Elastic 2 2.482E+004
    单轴材料       弹性材料   材料编号   弹性模量值
---------------------------------------------------------------------------                  
#define concrete
uniaxialMaterial Concrete01     1      -50130000.00000             -0.00192      -25060000.00000             -0.00365
---------------------------------------------------------------------------------------------------------------------------------                  
#define steel
uniaxialMaterial Steel02   101      455700000.00000   199999995904.00000
uniaxialMaterial Steel02 $matTag $Fy $E0 $b
uniaxialMaterial Steel02 1              100000              2000              0.15 
                        材料编号         屈服力             弹性刚度           屈服后硬化率
------------------------------------------------------------------------------------------------------------------------                  
geomTransf PDelta     1       1.0000000       0.0000000       0.0000000
geomTransf Linear $ transfTag $ vecxzX $ vecxzY $ vecxzZ  
geomTransf Linear 1 1.000 0.000 0.000 
               转换类型  局部坐标轴矢量编号     局部坐标轴的方向矢量值
(几何变换命令用于构造坐标变换对象，将梁单元刚度和抵抗力从局部坐标系转换为全局坐标系)                                   
-------------------------------------------------------------------------------------------------------------------------                  
element dispBeamColumn 10336     1 11186     3      10000     1 -mass      5625.0000000000                  
element dispBeamColumn 40067 23305  6367     3   82640000    81 -mass         0.0000010000
eleLoad -ele     1 -type -beamUniform 0    -12173.5576171875                  
load  1342         0.0000000000         0.0000000000    -79339.2265625000         0.0000000000         0.0000000000         0.0000000000 
-----------------------------------------------------------------------------------------------------------------------------------------                  
rigidDiaphragm 3       3     77     13      1     59      5     87      7     15      9     21     11     19     17     25     23    111    119     29     27     31    104     33     37     35     73     43     41     45     39    129     49    103     97     63     81     91                  
rigidDiaphragm $perpDirn $masterNodeTag $slaveNodeTag1 $slaveNodeTag2
  刚性隔板     刚性隔板方法为3   主节点 (刚心)     从节点1              从节点2      ……
rigidDiaphragm 3 2 4 5 6;          #从节点4,5,6随主节点2做X-Y plan的平移和旋转   （采用刚性隔板模型时，需与constraint lagrange配合使用，否者运行出错）
---------------------------------------------------------------------------------------------------------------------------------------------                  
                  

                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
