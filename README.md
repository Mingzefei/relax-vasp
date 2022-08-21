# record of relax_prom

--------

@File    :   README.md
@Time    :   2022/03/05 21:12:52
@Auth    :   Ming(<3057761608@qq.com>)
@Vers    :   0.1
@Desc    :   整理并重写VASP超算平台的个人脚本，重点在于规范、易迁移
@Refe    :   [vtst·tools](http://theory.cm.utexas.edu/vtsttools/); url2

--------

20220610: 该项目暂时闲置，择期增改。

## 文件夹结构

- environment.sh 文件：路径、环境变量（环境变量hgbPATH为 ../relax 绝对路径）、环境等
- template 目录：其下为**格式化文件**，包括INCAR样板、统一的脚本文件等
- vtst 目录：其下为**vtst·tools**文件，主要在**NEB**计算中使用，为 old_relax/NEB 目录
- 计算前有关的脚本：输入文件生成、检查等
- 计算后有关的脚本：输出文件提取、整理结果等
- 其他

## 编程语言

尽量使用前人造好的轮子，维持原语言

## 计划

- [x] environment.sh ：重写
- [x] vtst ：完整复制；浏览，留意可用到的脚本
- [x] VASP-script-master ：浏览，留意可用到的脚本
- [x] template ：完整复制；核查
  - [ ] AIM_bcp.py test
- [x] 个人脚本：整理、重写
  - [ ] nebzheng.sh test


## 常用脚本

- vtst : [常用脚本](http://theory.cm.utexas.edu/vtsttools/scripts.html)
  - `vef.py` : prints the force and energy for each ionic step of a vasp run
  - `dist.pl` : root sum squared distance between configuration files
  - `nebefs.pl` : force, energy etc of OUTCAR's in immediate subdir of present working directory
  - `nebbarrier.pl` : Generates the file neb.dat which contains the distance between images, the energy of each image, and the force along the band.
  - `nebmovie.pl 0|1` : generate a movie from standard xyz files, generated either by POSCARs (flag=0) or CONTCARs (flag=1) in every directory
- VASP-script-master
  - `ck` : check inform before submit
  - `dir2car.py file_1 file_2 ...` : convert direct to cartesian (need VASP.py)
  - `excoor.py step1 step2 ...` : OUTCAR.pos(every atom's poscar and force of each ionic step) and POSCAR$step(step's poscar)
  - `chgflag.py num_1,num_2,... T/F vaspfile` : mark the num_1,num_2,... atoms with T or F(relax or fix)
  - `nebvtst.py num_image` : neb process info(every ionic step every image's energy, tangent_force, max_force)
  - `VASP.py` : basic functions

## 备注

- NEB可视化
  - [Jsmol网页版](https://chemapps.stolaf.edu/jmol/jsmol/jsmol.htm)
  - Jmol 需要 Java，暂不安装
  - nebopen.bat 批处理脚本不再使用，改为 WSL2 中 `VESTA.exe *`，结合 `ctrl + 方向键` 查看不同 image
- 能带、DOS 等可视化
  - p4vasp 已不再更新
  - WSL 2 需要图形化界面以支持 p4vasp
- vtst : 包含一些 DOS 脚本
- notes 和 history : 因 history 与 linux 命令冲突，改用 notes
- bader 计算 : 参考 [Bader 电荷分析详解](https://zhuanlan.zhihu.com/p/379222933)
  - 需要脚本 bader(编译) 和 chgsum.pl(vtst)
  - INCAR 设置 : `LAECHG=.TRUE.` 和 `LCHARG=.TRUE.` 生成 AECCAR0（原子核电荷）、AECCAR1、AECCAR2（价电荷）
  - `./chgsum.pl AECCAR0 AECCAR2` 获得总电荷 `CHGCAR_sum`
  - `./bader CHGCAR -ref CHGCAR_sum` 生成 ACF.dat、AVF.dat、BCF.dat，其中 ACF.dat 包含价电子电荷信息
  - 将 ACF.dat 中电荷与 POTCAR 中电荷相减，获得转移电荷

## 注意

- 有无固定原子，POSCAR和CONTCAR的行数不一样，影响位置文件的读取
  - `idpp.py` 和个人所写的 POSCAR 读取文件
