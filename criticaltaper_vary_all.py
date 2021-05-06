# -*- coding: utf-8 -*-
"""
Created on Thu May  6 15:42:34 2021

@author: kogea
cary lamda, phi
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm


#initial parameters ---
rho=2700 #dencity of bulk
rhow=1050 #dencity of water

#calcs tart

cols = ['lamda','mbc_comp','mbc_ext','alpha','beta','phi','rho','rhow']
df = pd.DataFrame(index=[], columns=cols)

cols2 = ['phi','lamda','coeff_weight_alpha','R2']
dg = pd.DataFrame(index=[], columns=cols2)

lam=np.arange(1,1000)/1000
for l in range(1,100,1): #(0,100,1)
    cross_lam=l/100 # pore fluid pressure
    for k in range(20,36,1):  #(20,36,1)
        phi=k #internal friction angle
        for j in range(1,6,1):
            alpha=j #slope angle    
            for i in range(1,6,1):
                #initial parameters ---
                beta=i #basal dip angle
                
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
                
                #calc critical taper
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
                
                #calc cross point, critical taper rim vs pore fluid pressure
                co=np.stack((lamlam,mbc1,mbc2))
                com=pd.DataFrame(co.T,columns=['lamda','mbc_comp','mbc_ext'])
                comcoo=com[com["lamda"] == cross_lam] 
                
                ff=pd.DataFrame(data=np.array([cross_lam,alpha,beta,phi,rho,rhow])).T
                ff.columns=['lamda','alpha','beta','phi','rho','rhow']
                ef=pd.merge(comcoo,ff)
                
                #append the result values
                df = df.append(ef, ignore_index=True)
                
            #OLS regre
        x = pd.get_dummies(df[['alpha','beta']]) 
        y = df['mbc_comp']
        X = sm.add_constant(x)
                    
        model = sm.OLS(y, X)
        result = model.fit()
            #print(result.summary())
                    
        Ca=result.params.alpha/(result.params.alpha + result.params.beta)*100
        R2=result.rsquared
                    
        gg=pd.DataFrame(data=np.array([phi,cross_lam,Ca,R2])).T
        gg.columns=cols2
                    
        dg = dg.append(gg, ignore_index=True)

df.to_csv('result_ct.csv', float_format="%.5f",header=True, index=False);
dg.to_csv('result_ols.csv', float_format="%.5f",header=True, index=False);

                # print(comcoo)
