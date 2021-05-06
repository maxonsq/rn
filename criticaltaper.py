# -*- coding: utf-8 -*-
"""
Created on Fri Apr 30 17:49:53 2021

@author: kogea
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

#initial parameters ---
alpha=5.00 #slope angle
beta=5.00 #basal dip angle
phi=20.00 #internal friction angle
rho=2700 #dencity of bulk
rhow=1050 #dencity of water

#
cross_lam=0.80

#calcs tart

cols = ['lamda','mbc_comp','mbc_ext']
df = pd.DataFrame(index=[], columns=cols)

lam=np.arange(1,1000)/1000
for j in range(1,6,1):
    alpha=j #slope angle    
    for i in range(1,6,1):
        #initial parameters ---
        beta=i #slope angle
        #internal friction
        mu=np.tan(np.radians(phi))
        #radians
        alpha_r=np.radians(alpha)
        beta_r=np.radians(beta)
        phi_r=np.radians(phi)
        #
        right=np.tan(np.radians(alpha))
        left=(1-rhow/rho)/(1-lam)
        C=left * right
        alpha_p=np.arctan(C)
        
        # calc critical taper
        psi1=np.where( (np.sin(alpha_p)/np.sin(phi_r) - 1) > 0, np.nan, 0.5*np.arcsin(np.sin(alpha_p)/np.sin(phi_r))-0.5*np.sin(alpha_p))
        psi2=np.where( (np.sin(alpha_p)/np.sin(phi_r) - 1) >0, np.nan,0.5*(np.pi-np.arcsin(np.sin(alpha_p)/np.sin(phi_r)))-0.5*np.sin(alpha_p))
        
        psib1=np.where( psi1==np.nan, np.nan, alpha_r+beta_r+psi1)
        psib2=np.where( psi2==np.nan, np.nan, alpha_r+beta_r+psi2)
        
        k1=np.sin(2*psib1)/(1/np.sin(phi_r)-np.cos(2*psib1))
        tandi_bc1=np.where(psi1==np.nan, np.nan, k1)
        k2=np.sin(2*psib2)/(1/np.sin(phi_r)-np.cos(2*psib2))
        tandi_bc2=np.where(psi2==np.nan, np.nan, k2)
        
        mbc1=np.where(psi1==np.nan,np.nan,np.tan(tandi_bc1)*(1-lam))
        mbc2=np.where(psi2==np.nan,np.nan,np.tan(tandi_bc2)*(1-lam))
        lamlam=np.where(psi1==np.nan,np.nan,lam)
        
        #calc cross point
        co=np.stack((lamlam,mbc1,mbc2))
        com=pd.DataFrame(co.T,columns=['lamda','mbc_comp','mbc_ext'])
        comcoo=com[com["lamda"] == cross_lam] #一致行の抽出
        
        
        df = df.append(comcoo, ignore_index=True)
        
        #plot
        fig=plt.figure(figsize=(10,10))
        
        plt.plot(mbc1,lam, label="Compressional",color='black',  linestyle='solid')
        plt.plot(mbc2, lamlam, label="Extentional",color='black',  linestyle='dashed')
        plt.hlines([cross_lam], 0, 1, color="red", label="Pore fluid pressure")     # hlines
        
        #plt.subplots_adjust(left=0, right=1, bottom=0, top=1)
        # plt.xlim(min(mbc2), max(mbc1))
        # plt.ylim(0, 1)
        
        plt.xlim(0, 0.2)
        plt.ylim(0, 1)
        plt.xlabel('Coefficient of effective friction')
        #plt.ylabel('Porefluid pressurea ratio')
        
        mu_prime=round(comcoo.iloc[0,1],3)
        
        #plt.title("Critical Taper",{"fontsize": 20})
        plt.title('alpha = '+str(alpha)+', beta = '+str(beta)+', phi = '+str(phi)+', lambda = '+str(cross_lam)+', mu_prime ='+str(mu_prime))
        plt.legend(prop={"size": 14},borderaxespad=0, loc="lower left")
        plt.grid()
        
        np.savetxt('ewault.csv', comcoo, fmt="%.5f",delimiter=",");

        # print(comcoo)
