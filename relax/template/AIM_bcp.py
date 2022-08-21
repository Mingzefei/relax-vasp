from email import header


#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File : AIM_bcp.py
@Time : 2022/03/07 08:48:36
@Auth : Ming 
@Vers : 1.2
@Desc : AIM_bcp(from H_AIMbcp.m by matlab)
'''

# here put the import lib
import numpy as np
import pandas as pd
from pandas.core.frame import DataFrame
import scipy.constants as cn
import os
import time

# basic functions
def cpos2npos(cpos, NGF, cell_param):
    """
    trans pos in method of 'C' to 'NGF'
    return npos
    """
    # xc,yc,zc = cpos
    # NGXF,NGYF,NGZF = NGF
    # xv,yv,zv = cell_param
    
    # xn = int(np.around(xc * NGXF / xv))
    # yn = int(np.around(yc * NGYF / yv))
    # zn = int(np.around(zc * NGZF / zv))
    
    dpos = np.matmul(cpos, np.linalg.inv(cell_param))
    npos = list(map(int, np.around(dpos * NGF)))
    return np.array(npos)

def npos2cpos(npos, NGF, cell_param):
    """
    trans pos in method of 'C' to 'NGF'
    return npos
    """
    # xn,yn,zn = npos
    # NGXF,NGYF,NGZF = NGF
    # xv,yv,zv = cell_param
    
    # xc = int(np.around(xn * xv / NGXF))
    # yc = int(np.around(yn * yv / NGYF))
    # zc = int(np.around(zn * zv / NGZF))
    
    dpos = npos / NGF
    cpos = np.matmul(dpos, cell_param)
    
    return cpos

def distAB(a_cpos, b_cpos):
    """distance from a to b"""
    ans = 0
    for i in range(3):
        ans += (a_cpos[i] - b_cpos[i]) ** 2 
    return np.sqrt(ans)

def real_density(chgcar_value, cell_param):
    """trans value of chgcar into real density, S.I. is a.u."""
    volume = np.dot(np.cross(cell_param[0], cell_param[1]), cell_param[2])
    return chgcar_value / (volume / 10**30 / cn.value('Bohr radius')**3)

# read information from CONTCAT 
# cell_param and df
def read_contcar(file_name='CONTCAR'):
    """
    read information from CONTCAR
    :param file_name: the file where to get information
    :return cell_param, cont_df: cell parameters, ndarray of real_xv, real_yv, real_zv; cont_df, dataframe of atoms
    """
    
    def get_floatlist(s:str)->list:
        """turn a string to a float list"""
        return list(map(float, s.split()))
    def get_cpos(dpos, xv, yv, zv, scale_factor)->list:
        """get cpos about x,y,z in C_method with facor=1.0"""
        xtemp,ytemp,ztemp = 0,0,0
        for i in range(len(dpos)):
            xtemp += xv[i] * dpos[i] * scale_factor
            ytemp += yv[i] * dpos[i] * scale_factor
            ztemp += zv[i] * dpos[i] * scale_factor
        anslist = [xtemp, ytemp, ztemp]
        return anslist
        
    # read
    # file_path = 'C:/Users/Hua/1_workbench/AIM/'
    file_path = './'
    file = open(file_path + file_name)
    description = file.readline() # line 1: description
    scale_factor = float(file.readline()) # line 2: universal sacling parameters
    x_vector = get_floatlist(file.readline()) # line 3: lattice vector x
    y_vector = get_floatlist(file.readline()) # line 4: lattice vector y
    z_vector = get_floatlist(file.readline()) # line 5: lattice vector z
    atoms_elem = file.readline().split() # line 6: elements
    atoms_num = list(map(int, file.readline().split())) # line 7: numbers of atoms
    # line 8: selective dynamics or method of postions('C' or 'D')
    temp = file.readline()
    if ('sele' in temp) or ('Sele' in temp):
        selective_dynamics = True
        pos_method = file.readline()[0]
    else:
        selective_dynamics = False
        pos_method = temp[0]
    
    positions = [] # line 9(to the end): positions
    for i in range(sum(atoms_num)):
        pos = get_floatlist(file.readline())
        positions.append(pos)
        
    # zhengli
    cell_param = np.array([x_vector, y_vector, z_vector])*scale_factor
    atoms_index = [] # elemA1, elemA2, ...
    c_pos = [] # [elem, x_cpos, y_cpos, z_cpos]
    for index,atom_elem in enumerate(atoms_elem):
        for atom_num in range(atoms_num[index]):
            atoms_index.append(atom_elem + str(atom_num+1))
            c_pos.append([atom_elem])
    if pos_method == 'D':
        for index,pos in enumerate(positions):
            c_pos[index] += get_cpos(pos,x_vector,y_vector,z_vector,scale_factor)
    elif pos_method == 'C':
        for pos,index in enumerate(positions):
            x_cpos = pos[0] * scale_factor
            y_cpos = pos[1] * scale_factor
            z_cpos = pos[2] * scale_factor
            c_pos[index] += [x_cpos, y_cpos, z_cpos]
    colum_name = ['elem', 'x_cpos', 'y_cpos', 'z_cpos']
    cont_df = pd.DataFrame(c_pos, index=atoms_index, columns=colum_name)
    
    return cell_param, cont_df

def get_cpos_from_df(atom:str, df:DataFrame)->list:
    """return atom's cpos, like [x_cpos, y_cpos, z_cpos]"""
    atom_info = df.loc[atom]
    return [atom_info['x_cpos'], atom_info['y_cpos'], atom_info['z_cpos']]

# read NGXF, NGYF, NGZF and chg from CHGCAR
# axis_x is axis_3, axis_y is axis_2, and axis-z is axis_0
def read_chgcar(file_name='CHGCAR'):
    """
    read NGXF, NGYF, NGZF and chg from CHGCAR
    about chg in CHGCAR: the value in CHGCAR is row_i * V_cell, so the charge density for every point is row_i * V_cell / N_all(=NGXF*NGYF*NGZF), and the I.S. is e.
    :param file_name: the file where to get information
    :return NGF, chg:
    """
    # read
    # file_path = 'C:/Users/Hua/1_workbench/AIM/'
    file_path = './'
    file = open(file_path + file_name)
    
    while file.readline() != ' \n':
        file.readline() # there's a ' \n' above the line of NGF
        
    NGF = np.array(list(map(int,file.readline().split())), dtype=int)
    NGXF, NGYF, NGZF = NGF
    print('NGF: ', NGF)
    
    data_str = ''
    for i in range(int(np.ceil(NGXF*NGYF*NGZF/5))):
        data_str += file.readline()
    chg = np.fromstring(data_str, dtype=float, count=-1, sep=' ')

    chg.shape = (NGXF, NGYF, NGZF)
    
    return NGF, chg

def get_data(chgfile='CHGCAR', datafile='AIM_bcp_data.npz', is_print=True):
    """
    get gradient from datafile 'AIM_bcp_data.npz' or chg(NGXF*NGYF*NGZF) and return NGF, grad(dir|dx,dy,dz) and hess(dir|dxdx, dxdy, ..., dzdz)
    :return NGF, chg, grad, hess
    """
    if datafile not in os.listdir():
        if is_print:
            print('cannot find datafile:', datafile)
            print('get data from chgfile:', chgfile)
        NGF, chg = read_chgcar(chgfile)
        (dz, dy, dx) = np.gradient(chg)
        grad = {'dx':dx, 'dy':dy, 'dz':dz}
        (dxdz, dxdy, dxdx) = np.gradient(dx)
        (dydz, dydy, dydx) = np.gradient(dy)
        (dzdz, dzdy, dzdx) = np.gradient(dz)
        key = ['dxdz', 'dxdy', 'dxdx', 'dydz', 'dydy', 'dydx', 'dzdz', 'dzdy', 'dzdx']
        hess = dict(zip(key, [dxdz, dxdy, dxdx, dydz, dydy, dydx, dzdz, dzdy, dzdx]))
        
        np.savez(datafile, NGF=NGF,chg=chg,dx=dx,dy=dy,dz=dz,dxdx=dxdx,dxdy=dxdy,dxdz=dxdz,dydx=dydx,dydy=dydy,dydz=dydz,dzdx=dzdx,dzdy=dzdy,dzdz=dzdz)
        if is_print:
            print('save data as file:', datafile)
    else:
        if is_print:
            print('load data from datafile:', datafile)
        
        data = np.load(datafile)
        NGF = data['NGF']
        chg = data['chg']
        grad = {'dx':data['dx'], 'dy':data['dy'], 'dz':data['dz']}
        hess = {}
        for key in ['dxdz', 'dxdy', 'dxdx', 'dydz', 'dydy', 'dydx', 'dzdz', 'dzdy', 'dzdx']:
            hess[key] = data[key]
    return NGF, chg, grad, hess

# check 1 and 2
def check_1(index, grad, eps=1e-2):
    """
    norm of grad(index) < eps, and return the True index
    :param index: [start_index, stop_idnex], start_index[x_start,y_start,z_start]
    :return pos[x_pass, y_pass, z_pass], norm
    """
    
    dx, dy, dz = grad['dx'], grad['dy'], grad['dz']
    start_index, stop_index = index
    
    x_pass, y_pass, z_pass = [], [], [] # points passed check_1
    norm = []
    for z_index in range(start_index[2], stop_index[2]+1):
        for y_index in range(start_index[1], stop_index[1]+1):
            for x_index in range(start_index[0], stop_index[0]+1):
                temp = dx[z_index][y_index][x_index]**2 + dy[z_index][y_index][x_index]**2 + dz[z_index][y_index][x_index]**2
                if temp < eps**2:
                    x_pass.append(x_index)
                    y_pass.append(y_index)
                    z_pass.append(z_index)
                    norm.append(np.sqrt(temp))
    
    # print('%d points passed check_1 under eps=%s' % (len(x_pass), str(eps)))
    if len(x_pass) == 0:
        # print('please try to reset eps')
        return [],[]
    else:
        pos = [x_pass, y_pass, z_pass]
        return pos, norm 

def check_2(index, hess, eps=0):
    """
    eigvalue(hess(index)) is two <0 and one >0, and return the list of True index
    :param index: [x_index(list), y_index, z_index]
    :return pos[x_pass, y_pass, z_pass], bool_index[True or False]
    """
    
    if index == []:
        return [],[]
    else:
        x_index, y_index, z_index = index
        num_points = len(x_index)
        
        x_pass, y_pass, z_pass = [], [], [] # points passed check_2
        bool_index = [] # True or False for index input
        
        for point in range(num_points):
            x_npos, y_npos, z_npos = x_index[point], y_index[point], z_index[point] # point position in method of NGF from index
            dxd = [hess['dxdx'][z_npos][y_npos][x_npos], hess['dxdy'][z_npos][y_npos][x_npos], hess['dxdz'][z_npos][y_npos][x_npos]]
            dyd = [hess['dydx'][z_npos][y_npos][x_npos], hess['dydy'][z_npos][y_npos][x_npos], hess['dydz'][z_npos][y_npos][x_npos]]
            dzd = [hess['dzdx'][z_npos][y_npos][x_npos], hess['dzdy'][z_npos][y_npos][x_npos], hess['dzdz'][z_npos][y_npos][x_npos]]
            the_hess = np.array([dxd,dyd,dzd])
            
            the_eig = np.linalg.eig(the_hess)
            eig_values = the_eig[0]
            # print('eig_values:', eig_values, type(eig_values))
            # print('the_hess', the_hess)
            flag = len(eig_values[eig_values < eps]) == 2
            bool_index.append(flag)
            
            if flag: # record npoint passed check 2
                x_pass.append(x_npos)
                y_pass.append(y_npos)
                z_pass.append(z_npos)
        
        # print('%d points passed check_2 under eps=%s' % (len(x_pass), str(eps)))
        if len(x_pass) == 0:
            # print('please try to reset eps')
            return [],bool_index
        else:
            pos = [x_pass, y_pass, z_pass]
            return pos, bool_index

def detail_check_ans(pos, norm, a_cpos, b_cpos, cell_param, NGF, chg, is_print=True):
    """
    return detail information about check 1/2 result
    :param pos, norm: def check_1's return, positon(method of nfg) and norm about points passed check 1
    :param is_print: bool, print more information during calculating
    :return details: list of (density, cpoint, npoint, distA, distB, norm)
    """
    
    if pos == []:
        return []
    else:
        npoints = list(zip(pos[0], pos[1], pos[2]))
        details = []
        
        for count,npoint in enumerate(npoints):
            cpoint = npos2cpos(npoint, NGF, cell_param)
            density = real_density(chg[npoint[2]][npoint[1]][npoint[0]], cell_param)
            the_norm = norm[count]
            
            detail = (density, cpoint, npoint, distAB(a_cpos,cpoint), distAB(b_cpos,cpoint), the_norm)
            details.append(detail)
            
            if is_print:
                # print('%d: density %.4f a.u., cpos %s, npos %s, distA = %.4f A, distB = %.4f A, norm = %.2f' % (count+1, density, cpoint, npoint, distAB(a_cpos,cpoint), distAB(b_cpos,cpoint), ))
                print('%d: density %.4f a.u., cpos %s, npos %s, distA = %.4f A, distB = %.4f A, norm = %.2f' % (count+1, density, cpoint, npoint, distAB(a_cpos,cpoint), distAB(b_cpos,cpoint), the_norm))

        return details

def find_bcp(a_cpos, b_cpos, cell_param, NGF, chg, grad, hess):
    """
    check all points in the bulk of a_cpos to b_cpos, like x in (ax, bx), y in (ay, by) and z in (az, bz)
    check_1: norm(grad(index)) is or close 0
    check_2: eigvalue(hess(index)) is two >0 and one <0
    :param a/b_cpos: pos of A/B point in method of 'C', like [1.1, 2., 2.1]
    :param cell_param: cell's param, the first return of def read_contcar
    :param NGF, chg, grad, hess: data about chg, return of def get_data
    :return ans(list): results of check_1 and check_2  
    """
    
    print('distAB = %.4fA' % distAB(a_cpos, b_cpos))
    
    a_npos = cpos2npos(a_cpos, NGF, cell_param)
    b_npos = cpos2npos(b_cpos, NGF, cell_param)
    start_index, stop_index = [], []
    for i in range(3):
        start_index.append(min(a_npos[i], b_npos[i]))
        stop_index.append(max(a_npos[i], b_npos[i]))
    bulk_index = [start_index, stop_index]
    
    flag = True
    eps = 0 # eps for check 1, strictly eps should be 0, but eps>0 is required for finding potential points; eps=200 may be, depended on your system
    eps2 = 0 # eps for check 2, strictly eps should be 0 and it can solve most cases, and you can value eps2<0 to make the result more strictly(because eig_value<eps in def check_2)
    while flag:
        
        # check 1
        npoints_passC1, norm_passC1 = check_1(bulk_index, grad, eps)
        while npoints_passC1 == []:
            print('0 points passed check_1 under eps=%s' % (str(eps)))
            print('please try to reset eps')
            while True:
                temp = input('Check1: new eps or Q/q to exit: ')
                if 'Q' in temp or 'q' in temp:
                    return []
                else:
                    try:
                        eps = float(temp)
                    except ValueError:
                        print('Wrong Order, please reinput')
                    else:
                        break
            npoints_passC1, norm_passC1 = check_1(bulk_index, grad, eps)
                
        # ans about check 1
        details_passC1 = detail_check_ans(npoints_passC1, norm_passC1, a_cpos, b_cpos, cell_param, NGF, chg, is_print=True)
            
        # check 2
        npoints_passC2, C1_pass_C2 = check_2(npoints_passC1, hess, eps2)
        while npoints_passC2 == []:
            print('0 points passed check_2 under eps2=%s' % (str(eps2)))
            # print('please try to reset eps2')
            while True:
                temp = input('Check2: new eps or Q/q to exit: ')
                if 'Q' in temp or 'q' in temp:
                    return []
                else:
                    try:
                        eps2 = float(temp)
                    except ValueError:
                        print('Wrong Order, please reinput')
                    else:
                        break
            npoints_passC2, C1_pass_C2 = check_2(bulk_index, grad, eps2)
                
        # ans about check 2
        norm_passC2 = [norm for index,norm in enumerate(norm_passC1) if C1_pass_C2[index]] # get the norm pass check2 from result of check 1
        details_passC2 = detail_check_ans(npoints_passC2, norm_passC2, a_cpos, b_cpos, cell_param, NGF, chg, is_print=True)
            
        
        while True:
            order = input('Q/q(exit) | R/r(restart): ')
            if 'Q' in order or 'q' in order:
                flag = False
                break
            elif 'R' in order or 'r' in order:
                eps = float(input('new eps: '))
                break
            else:
                print('Wrong Order, please reinput')

    return details_passC2

def autom_find_bcp(atomA:str, atomB:str, cell_param, df, NGF, chg, grad, hess, is_print=True, is_print_result=True): 
    """
    autom find bcp by atomA and atomB
    find the best point by find_bcp(do not care eps's value)
    :param atomA/B: str, like 'H4' and 'F1'(remember the num)
    :param is_print: bool, print more information during calculating
    :return ans: simplified information about the result(only one best point)
    """
    # cell_param, df = read_contcar(contfile)
    # NGF, chg, grad, hess = get_data(chgfile, datafile, is_print)
    
    if not (atomA in df.index and atomB in df.index):
        if is_print:
            print('cannot find ' + atomA + ' or ' + atomB)
        return 'cannot find ' + atomA + ' or ' + atomB
    
    a_cpos = get_cpos_from_df(atomA, df)
    b_cpos = get_cpos_from_df(atomB, df)
    dist_AB = distAB(a_cpos, b_cpos)
    
    a_npos = cpos2npos(a_cpos, NGF, cell_param)
    b_npos = cpos2npos(b_cpos, NGF, cell_param)
    
    start_index, stop_index = [], [] # the cubic bulk from atomA to atomB
    for i in range(3):
        start_index.append(min(a_npos[i], b_npos[i]))
        stop_index.append(max(a_npos[i], b_npos[i]))
    bulk_index = [start_index, stop_index]
    

    eps = 0 # eps for check 1, strictly eps should be 0, but eps>0 is required for finding potential points; eps=200 may be, depended on your system
    eps2 = 0 # eps for check 2, strictly eps should be 0 and it can solve most cases, and you can value eps2<0 to make the result more strictly(because eig_value<eps in def check_2)
    while True:
        
        # check 1
        npoints_passC1, norm_passC1 = check_1(bulk_index, grad, eps)
        if is_print:
            print('%d points passed check_1 under eps=%s' % (len(norm_passC1), str(eps)))
            
        while npoints_passC1 == [] and eps < 2e3: # find 0 point under check 1
            # reset eps
            eps = eps*2 if eps > 0 else 1
            # eps += 10
            if is_print:
                print('reset eps:', eps)
            # calculate check 1 again
            npoints_passC1, norm_passC1 = check_1(bulk_index, grad, eps)
            if is_print:
                print('%d points passed check_1 under eps=%s' % (len(norm_passC1), str(eps)))
               
        # ans about check 1
        details_passC1 = detail_check_ans(npoints_passC1, norm_passC1, a_cpos, b_cpos, cell_param, NGF, chg, is_print)
            
            
        # check 2
        npoints_passC2, C1_pass_C2 = check_2(npoints_passC1, hess, eps2)
        if is_print:
            print('%d/%d points passed check_2 under eps2=%s' % (C1_pass_C2.count(True), len(C1_pass_C2), str(eps2)))
            
        while npoints_passC2 == [] and eps2 != 10: # find 0 point under check 2
            # reset eps2
            eps2 = eps2 + 2 if eps2 < 10 else 10
            if is_print:
                print('reset eps2:', eps2)
            # calculate check 2 again
            npoints_passC2, C1_pass_C2 = check_2(npoints_passC1, hess, eps2)
            if is_print:
                print('%d/%d points passed check_2 under eps2=%s' % (C1_pass_C2.count(True), len(C1_pass_C2), str(eps2)))
                   
        # ans about check 2
        norm_passC2 = [norm for index,norm in enumerate(norm_passC1) if C1_pass_C2[index]] # get the norm pass check2 from result of check 1
        details_passC2 = detail_check_ans(npoints_passC2, norm_passC2, a_cpos, b_cpos, cell_param, NGF, chg, is_print)
        
        
        # zhengli the result
        if npoints_passC2 == []: # find 0 point under check 2 and the eps2 is too large, try to reset eps of check 1
            if eps > 1e5:
                if is_print or is_print_result:
                    print('find no point satisfied bcp, please check atom: %s %s' % (atomA, atomB))
                return []
            else:
                # reset eps of check 1 and keep checking
                eps *= 10
        elif npoints_passC2 != []: # find the aim bcp
            
            aim_eps = eps # find the min norm of points
            aim_detail = ()
            for detail in details_passC2:
                detail_density, detail_cpoint, detail_npoint, detail_distA, detail_distB, detail_norm = detail
                if 0.1 < detail_distA / detail_distB < 10: # dist of A/B is appropriate
                    if detail_norm < aim_eps: # a more min norm about check 1
                        aim_eps = detail_norm
                        aim_detail = detail
            break
    
    if is_print or is_print_result:
        
        bcp_density, bcp_cpoint, bcp_npoint, bcp_distA, bcp_distB, bcp_norm = aim_detail
        print('find the bcp between %s and %s: ' % (atomA, atomB))
        print('density %.4f a.u., cpos %s, npos %s, distA = %.4f A, distB = %.4f A, norm = %.2f' % (bcp_density, bcp_cpoint, bcp_npoint, bcp_distA, bcp_distB, bcp_norm))
    
    return aim_detail
    
def bat_autom_find_bcp(atoms:list, contfile='CONTCAR', chgfile='CHGCAR', datafile='AIM_bcp_data.npz', is_print=True, is_print_result=True):
    """
    batch getting bcp
    :param atoms: [(atom1A, atom1B), (atom1A, atom2B), ...]
    """
    
    cell_param, df = read_contcar(contfile)
    NGF, chg, grad, hess = get_data(chgfile, datafile, is_print)
    
    results = []
    
    for atomAB in atoms:
        atomA, atomB = atomAB
        the_result = autom_find_bcp(atomA, atomB, cell_param, df, NGF, chg, grad, hess, is_print, is_print_result)
        results.append(the_result)
        
    return results
    

def debug():
    
    # # mean of CHGCAR
    # cell_param, cont_df = read_contcar()
    # print(cont_df)
    # # ngf, chg = read_chgcar()
    # # print(ngf)
    # volume = np.dot(np.cross(cell_param[0], cell_param[1]), cell_param[2])
    # chgsum = 746495963.3891599
    # print(chgsum/360**3)
    # # print('sum pf charge: ', np.sum(chg), np.sum(chg)*(volume/cn.value('Bohr radius')**3))
    # print('sum pf charge: ', chgsum/(volume/(cn.value('Bohr radius') * 10**10)**3))
    # print(chg)
    
    # # find_bcp check
    # NGF, chg, grad, hess = get_data()
    # cell_param, df = read_contcar()
    # # # print('cell_param:', cell_param)
    # # print('atoms:', df)
    # H4 = df.loc['H4']
    # N1 = df.loc['N1']
    # H4_cpos = list(H4[1:4])
    # N1_cpos = list(N1[1:4])
    # find_bcp(H4_cpos, N1_cpos, cell_param, NGF, chg, grad, hess)
    
    # # auto
    # autom_find_bcp('N1','H4', is_print=True, is_print_result=True)
    
    # batch
    begin_time = time.time()
    cell_param, df = read_contcar()
    atoms = []
    for atomA in df.index:
        for atomB in df.index:
            if atomA != atomB:
                # autom_find_bcp(atomA, atomB, is_print=False, is_print_result=True)
                atoms.append((atomA, atomB))
    bat_autom_find_bcp(atoms, is_print=False, is_print_result=True)
    end_time = time.time()
    print('all time:', end_time-begin_time)



    # get help()
    # import AIM_bcp as bcp
    # print(help(bcp))
    
    pass

def main():
    
    from sys import argv, exit
    
    def help_print():
        print('usage    : AIM_bcp.py -h|-all|-part atomA atomB...')
        print('   -h    : print help')
        print('   -all  : autom get all atoms bcp in CONTCAR')
        print('   -part : input list of (atomA, atomB) to find atoms bcp interest, like \'H1\' \'H2\'')
        print('suggest  : after getting AIM_bcp_data.npz, use bat_auto_find_bcp(atoms) in python interact_envir')
    
    if '-h' in argv:
        help_print()
        exit(0)
    elif '-all' in argv:
        print('try to find all the posible AIM_bcp')
        begin_time = time.time()
        cell_param, df = read_contcar()
        atoms = []
        for atomA in df.index:
            for atomB in df.index:
                if atomA != atomB:
                    atoms.append((atomA,atomB))
        bat_autom_find_bcp(atoms, is_print=False, is_print_result=True)
        end_time = time.time()
        print('all time costed:', end_time-begin_time,'sec')
        exit(0)
    elif '-part' in argv:
        atoms_in = argv[1:]
        atoms_in.remove('-part')
        print('try to find posible AIM_bcp between:', atoms_in)
        cell_param, df = read_contcar()
        atoms = []
        for atomA in atoms_in:
            for atomB in atoms_in:
                if atomA != atomB:
                    atoms.append((atomA,atomB))
        bat_autom_find_bcp(atoms, is_print=False, is_print_result=True)
        exit(0)
    else:
        help_print()
        exit(1)


if __name__ == '__main__':
    main()
    # debug() 
    
    