# -*- coding: utf-8 -*-
"""
Created on Wed Jul 25 14:52:27 2018

@author: msbak
"""

import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt

# In[] certain matlab file import to python

filepath = 'E:\\python\\CNMF_E_noiseFilter\\raw_data.mat'
mat_data = sio.loadmat(filepath)

#1~15 bad
#16, 17, 18, 20, 21, 23, 24, 25 good

tmpSpace_save = np.array([mat_data['tmpSpace_save_nmr']])

bad_list = list(np.arange(16))
good_list = [15, 16, 17, 19, 20, 22, 23, 24] # indexing as -1 for python

# In[] bad samples are saved in 'bad_sample'

bad_sample = np.zeros((len(bad_list),1,tmpSpace_save.shape[1],tmpSpace_save.shape[2]))

for i in range(len(bad_list)):
    bad_sample[i,0,:,:] = tmpSpace_save[0,:,:,bad_list[i]].reshape(200,200)
    
plt.imshow(bad_sample[1,0,:,:])

# In[] good samples are saved in 'good_sample'

good_sample = np.zeros((len(good_list),1,tmpSpace_save.shape[1],tmpSpace_save.shape[2]))

for i in range(len(good_list)):
    good_sample[i,0,:,:] = tmpSpace_save[0,:,:,good_list[i]].reshape(200,200)
    
plt.imshow(good_sample[1,0,:,:])
