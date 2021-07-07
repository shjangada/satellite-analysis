#!/usr/bin/env python
# coding: utf-8

# In[2]:


import h5py
import scipy.interpolate as sc
import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap


# In[3]:


# Open the data file obtained from Terra/Aqua satellite
file = h5py.File('MOD14.A2021087.1335.006.NRT.h5.hdf', 'r')


# In[4]:


# Check what keys are presend int he data
list(file.keys())


# In[5]:


# DO some sanity checks
data = np.array(file['fire mask'])
lat = np.array(file['latitude'])
lon = np.array(file['longitude'])
print('Shapes of the arrays - lat:{}, lon:{}, data:{}'.format(lat.shape, lon.shape, data.shape))


# In[6]:


# Check out the range of the data
print('lat min, max, lon min max: {}, {}, {}, {}'.format(lat.min(), lat.max(), lon.min(), lon.max()))


# In[7]:


# Plot the data on the world map, to verify that the numbers look right
plt.figure(figsize=(30, 10))
worldmap = Basemap(llcrnrlon=-63,llcrnrlat=-28,urcrnrlon=-37,urcrnrlat=-6.9, resolution = 'l')
worldmap.drawcountries()
worldmap.drawcoastlines()
worldmap.pcolormesh(lon, lat, data)
plt.show()


# In[8]:


"""

From the documentation of the data

Following are the meanings of the numbers in data array

0: missing input data
1: not processed (obsolete)
2: not processed(obsolete)
3: non-fire water
4: cloud
5: non-fire land
6: unknown
7: fire (low confidence)
8: fire (nominal confidence)
9: fir (hight confidence)

"""


# In[9]:


"""

Lets do some sanity checks.

First, the sum of all the data values with values from 0 to nine should be the same as the dimensions of the data array.

Data array dimensions are 2030 * 1354

So, is we sum up the instances in data array with values 0 through 9, they ust add up to 2030 * 1354

"""

total = 0
for i in range(0,9):
    total += (data == i).sum()
print(total)


# In[10]:


"""

That establised, the total number of fires detected is the count of entries in data array 
with values matching those for fire

Values 7, 8 and 9 correspond to fire with increasing confidence.

We may or may not want to include the lower confidence values.

"""

fire_values = [7, 8, 9]
total_number_of_fires = 0
for value in fire_values:
    total_number_of_fires += (data == value).sum()
    
print('Total number of fires in the given grid: {}'.format(total_number_of_fires))


# In[32]:


def specificarea(latmin, latmax, lonmin, lonmax):

    lats_mask = ma.masked_where(np.logical_or(lat <= latmin, lat >=latmax), lat)

    #lats_mask = lats_mask[~np.isnan(lats_mask)]

    lats_mask

    #go through values that are not nan and add them to latitude array

    lons_mask = ma.masked_where(np.logical_or(lon <= lonmin, lon >=lonmax), lon)

    filtered_data = np.where(((lat == lats_mask) & (lon == lons_mask)), data, 0)
    Zm = ma.masked_invalid(data)

    # Plot the data on the world map, to verify that the numbers look right
    plt.figure(figsize=(30, 10))
    worldmap = Basemap(llcrnrlon= lonmin,llcrnrlat= latmin,urcrnrlon= lonmax,urcrnrlat= latmax, resolution = 'l')
    worldmap.drawcountries()
    worldmap.drawcoastlines()
    worldmap.pcolormesh(lon, lat, filtered_data)
    plt.show()


# In[40]:


#lat min, max, lon min max: -28.008459091186523, -6.974177837371826, -63.37385940551758, -37.23870849609375

specificarea(-20, -10, -50, -40)

