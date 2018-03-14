

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from citipy import citipy
import requests as req
import unidecode
from datetime import datetime
import time
```


```python
#API KEYS

#Google
gkey = 'AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE'
#Weather
wkey = '6ef647a7d8716e4de89b8cb73b4b6604'
```


```python
# DataFrame for lat and long
location_data = pd.DataFrame()
location_data['rand_lat'] = [np.random.uniform(-90,90) for x in range(1500)]
location_data['rand_lng'] = [np.random.uniform(-180, 180) for x in range(1500)]

# Closest city and country column
location_data['closest_city'] = ""
location_data['country'] = ""

#find and add closest city and country code
for index, row in location_data.iterrows():
    lat = row['rand_lat']
    lng = row['rand_lng']
    location_data.set_value(index, 'closest_city', citipy.nearest_city(lat, lng).city_name)
    location_data.set_value(index, 'country', citipy.nearest_city(lat, lng).country_code)
```


```python
#Delete Duplicated Cities

location_data = location_data.drop_duplicates(['closest_city', 'country'])
location_data = location_data.dropna()
len(location_data['closest_city'].value_counts())

location_data.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>rand_lat</th>
      <th>rand_lng</th>
      <th>closest_city</th>
      <th>country</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>-35.249426</td>
      <td>-103.654880</td>
      <td>lebu</td>
      <td>cl</td>
    </tr>
    <tr>
      <th>1</th>
      <td>62.524869</td>
      <td>160.622848</td>
      <td>evensk</td>
      <td>ru</td>
    </tr>
    <tr>
      <th>2</th>
      <td>-63.602924</td>
      <td>-6.228133</td>
      <td>cape town</td>
      <td>za</td>
    </tr>
    <tr>
      <th>3</th>
      <td>-52.144154</td>
      <td>-178.132118</td>
      <td>vaini</td>
      <td>to</td>
    </tr>
    <tr>
      <th>4</th>
      <td>48.772329</td>
      <td>133.028190</td>
      <td>birobidzhan</td>
      <td>ru</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Keep city & Country. Lat and Long not Needed
location_data = location_data[['closest_city', 'country']]
#Column Rename to Merge Later
location_data = location_data.rename(columns = {'closest_city': 'city'})
```


```python
api_city_data = pd.read_json('../city.list.json')

for index, row in api_city_data.iterrows():
    lower_city = row['name'].lower() 
    #unidecode city accent
    unaccented = unidecode.unidecode(lower_city) 
    lower_country = row['country'].lower()  
    api_city_data.set_value(index, 'name', unaccented) 
    api_city_data.set_value(index, 'country', lower_country) 
#Rename the DF Columns    
api_city_data = api_city_data.rename(columns = {'name': 'city'})  
```


```python
merged_df = location_data.merge(api_city_data, how = 'left', on = ('city', 'country'))
merged_df = merged_df.drop_duplicates(['city', 'country'])

merged_df.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>city</th>
      <th>country</th>
      <th>coord</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>lebu</td>
      <td>cl</td>
      <td>{'lon': -73.650002, 'lat': -37.616669}</td>
      <td>3883457.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>evensk</td>
      <td>ru</td>
      <td>{'lon': 159.233337, 'lat': 61.950001}</td>
      <td>2125693.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>cape town</td>
      <td>za</td>
      <td>{'lon': 18.42322, 'lat': -33.925838}</td>
      <td>3369157.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>vaini</td>
      <td>to</td>
      <td>{'lon': -175.199997, 'lat': -21.200001}</td>
      <td>4032243.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>birobidzhan</td>
      <td>ru</td>
      <td>{'lon': 132.949997, 'lat': 48.799999}</td>
      <td>2026643.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
merged_df['coord'] = merged_df['coord'].fillna('') #fill na cells with emplty string for coordinates
merged_df['id'] = merged_df['id'].fillna(0) # fill na with 0 for id in order to change to int64
merged_df['id'] = merged_df['id'].astype(dtype = 'int64') # cast id column as type int64 to remove floating .0
merged_df['id'].dtype #check type of id
```




    dtype('int64')




```python
#Countries without an ID
no_id = merged_df[merged_df['id'] == 0]
no_id.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>city</th>
      <th>country</th>
      <th>coord</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>6</th>
      <td>airai</td>
      <td>pw</td>
      <td></td>
      <td>0</td>
    </tr>
    <tr>
      <th>8</th>
      <td>taolanaro</td>
      <td>mg</td>
      <td></td>
      <td>0</td>
    </tr>
    <tr>
      <th>9</th>
      <td>sentyabrskiy</td>
      <td>ru</td>
      <td></td>
      <td>0</td>
    </tr>
    <tr>
      <th>15</th>
      <td>tumannyy</td>
      <td>ru</td>
      <td></td>
      <td>0</td>
    </tr>
    <tr>
      <th>17</th>
      <td>outram</td>
      <td>nz</td>
      <td></td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>




```python
len(no_id)
```




    88




```python
#Lat and Long for cities missing an API
g_url = 'https://maps.googleapis.com/maps/api/geocode/json?address='

counter = 0 
for index,row in merged_df.iterrows():
    if row['id'] == 0:
        city = row['city']
        country = row['country']
        print('Now retrieving coordinates for city #%s: %s, %s' %(index, city, country))
        target_url = '%s%s,+%s&key=%s' % (g_url, city, country, gkey)
        print(target_url)
        try:
            response = req.get(target_url).json()
            response_path = response['results'][0]['geometry']['location']
            merged_df.set_value(index, 'coord', {'lon': response_path['lng'], 'lat': response_path['lat']})
        except:
            print('Missing Data for city #%s: %s,%s' %(index, city, country))
        counter += 1


print(counter)
```

    Now retrieving coordinates for city #6: airai, pw
    https://maps.googleapis.com/maps/api/geocode/json?address=airai,+pw&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #8: taolanaro, mg
    https://maps.googleapis.com/maps/api/geocode/json?address=taolanaro,+mg&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #9: sentyabrskiy, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=sentyabrskiy,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #15: tumannyy, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=tumannyy,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #17: outram, nz
    https://maps.googleapis.com/maps/api/geocode/json?address=outram,+nz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #19: saleaula, ws
    https://maps.googleapis.com/maps/api/geocode/json?address=saleaula,+ws&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #37: asau, tv
    https://maps.googleapis.com/maps/api/geocode/json?address=asau,+tv&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #44: palabuhanratu, id
    https://maps.googleapis.com/maps/api/geocode/json?address=palabuhanratu,+id&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #49: rungata, ki
    https://maps.googleapis.com/maps/api/geocode/json?address=rungata,+ki&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #67: constitucion, mx
    https://maps.googleapis.com/maps/api/geocode/json?address=constitucion,+mx&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #68: mataura, pf
    https://maps.googleapis.com/maps/api/geocode/json?address=mataura,+pf&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #72: sumbawa, id
    https://maps.googleapis.com/maps/api/geocode/json?address=sumbawa,+id&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #87: lasa, cn
    https://maps.googleapis.com/maps/api/geocode/json?address=lasa,+cn&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #95: tsihombe, mg
    https://maps.googleapis.com/maps/api/geocode/json?address=tsihombe,+mg&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #109: muzquiz, mx
    https://maps.googleapis.com/maps/api/geocode/json?address=muzquiz,+mx&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #114: ambulu, id
    https://maps.googleapis.com/maps/api/geocode/json?address=ambulu,+id&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #118: barentsburg, sj
    https://maps.googleapis.com/maps/api/geocode/json?address=barentsburg,+sj&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #127: vaitupu, wf
    https://maps.googleapis.com/maps/api/geocode/json?address=vaitupu,+wf&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #134: illoqqortoormiut, gl
    https://maps.googleapis.com/maps/api/geocode/json?address=illoqqortoormiut,+gl&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #151: chikoy, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=chikoy,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #152: nizhneyansk, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=nizhneyansk,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #155: amderma, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=amderma,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #173: waw, sd
    https://maps.googleapis.com/maps/api/geocode/json?address=waw,+sd&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Missing Data for city #173: waw,sd
    Now retrieving coordinates for city #178: bolonchen, mx
    https://maps.googleapis.com/maps/api/geocode/json?address=bolonchen,+mx&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #191: dolbeau, ca
    https://maps.googleapis.com/maps/api/geocode/json?address=dolbeau,+ca&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #198: belushya guba, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=belushya guba,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #201: nikolskoye, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=nikolskoye,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #203: edendale, nz
    https://maps.googleapis.com/maps/api/geocode/json?address=edendale,+nz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #211: schwedt, de
    https://maps.googleapis.com/maps/api/geocode/json?address=schwedt,+de&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #216: gat, ly
    https://maps.googleapis.com/maps/api/geocode/json?address=gat,+ly&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #236: amapa, br
    https://maps.googleapis.com/maps/api/geocode/json?address=amapa,+br&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #245: makung, tw
    https://maps.googleapis.com/maps/api/geocode/json?address=makung,+tw&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #250: andselv, no
    https://maps.googleapis.com/maps/api/geocode/json?address=andselv,+no&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #256: biak, id
    https://maps.googleapis.com/maps/api/geocode/json?address=biak,+id&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #258: abu samrah, qa
    https://maps.googleapis.com/maps/api/geocode/json?address=abu samrah,+qa&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #260: kaitangata, nz
    https://maps.googleapis.com/maps/api/geocode/json?address=kaitangata,+nz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #276: qui nhon, vn
    https://maps.googleapis.com/maps/api/geocode/json?address=qui nhon,+vn&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #282: nacala, mz
    https://maps.googleapis.com/maps/api/geocode/json?address=nacala,+mz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #285: mahadday weyne, so
    https://maps.googleapis.com/maps/api/geocode/json?address=mahadday weyne,+so&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #286: odweyne, so
    https://maps.googleapis.com/maps/api/geocode/json?address=odweyne,+so&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #298: nuristan, af
    https://maps.googleapis.com/maps/api/geocode/json?address=nuristan,+af&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #302: ituni, gy
    https://maps.googleapis.com/maps/api/geocode/json?address=ituni,+gy&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #303: acapulco, mx
    https://maps.googleapis.com/maps/api/geocode/json?address=acapulco,+mx&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #306: codrington, ag
    https://maps.googleapis.com/maps/api/geocode/json?address=codrington,+ag&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #314: grand river south east, mu
    https://maps.googleapis.com/maps/api/geocode/json?address=grand river south east,+mu&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #318: louisbourg, ca
    https://maps.googleapis.com/maps/api/geocode/json?address=louisbourg,+ca&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #328: galiwinku, au
    https://maps.googleapis.com/maps/api/geocode/json?address=galiwinku,+au&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #336: raudeberg, no
    https://maps.googleapis.com/maps/api/geocode/json?address=raudeberg,+no&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #342: umm durman, sd
    https://maps.googleapis.com/maps/api/geocode/json?address=umm durman,+sd&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #343: mys shmidta, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=mys shmidta,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #344: samusu, ws
    https://maps.googleapis.com/maps/api/geocode/json?address=samusu,+ws&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #346: sento se, br
    https://maps.googleapis.com/maps/api/geocode/json?address=sento se,+br&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #354: roela, ee
    https://maps.googleapis.com/maps/api/geocode/json?address=roela,+ee&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #362: geresk, af
    https://maps.googleapis.com/maps/api/geocode/json?address=geresk,+af&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #392: kazalinsk, kz
    https://maps.googleapis.com/maps/api/geocode/json?address=kazalinsk,+kz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #394: nedjo, et
    https://maps.googleapis.com/maps/api/geocode/json?address=nedjo,+et&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #409: labutta, mm
    https://maps.googleapis.com/maps/api/geocode/json?address=labutta,+mm&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #412: bereda, so
    https://maps.googleapis.com/maps/api/geocode/json?address=bereda,+so&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #424: elat, il
    https://maps.googleapis.com/maps/api/geocode/json?address=elat,+il&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #430: halalo, wf
    https://maps.googleapis.com/maps/api/geocode/json?address=halalo,+wf&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #442: haibowan, cn
    https://maps.googleapis.com/maps/api/geocode/json?address=haibowan,+cn&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #454: hauterive, ca
    https://maps.googleapis.com/maps/api/geocode/json?address=hauterive,+ca&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #489: sturgeon falls, ca
    https://maps.googleapis.com/maps/api/geocode/json?address=sturgeon falls,+ca&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #506: paradwip, in
    https://maps.googleapis.com/maps/api/geocode/json?address=paradwip,+in&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #507: marcona, pe
    https://maps.googleapis.com/maps/api/geocode/json?address=marcona,+pe&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #511: marzuq, ly
    https://maps.googleapis.com/maps/api/geocode/json?address=marzuq,+ly&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #532: barbar, sd
    https://maps.googleapis.com/maps/api/geocode/json?address=barbar,+sd&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #538: babanusah, sd
    https://maps.googleapis.com/maps/api/geocode/json?address=babanusah,+sd&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #562: fairlie, nz
    https://maps.googleapis.com/maps/api/geocode/json?address=fairlie,+nz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #578: itarema, br
    https://maps.googleapis.com/maps/api/geocode/json?address=itarema,+br&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #581: umzimvubu, za
    https://maps.googleapis.com/maps/api/geocode/json?address=umzimvubu,+za&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #585: katha, mm
    https://maps.googleapis.com/maps/api/geocode/json?address=katha,+mm&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #590: kerki, tm
    https://maps.googleapis.com/maps/api/geocode/json?address=kerki,+tm&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #595: lata, sb
    https://maps.googleapis.com/maps/api/geocode/json?address=lata,+sb&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #600: wajid, so
    https://maps.googleapis.com/maps/api/geocode/json?address=wajid,+so&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #609: jijiang, cn
    https://maps.googleapis.com/maps/api/geocode/json?address=jijiang,+cn&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #610: macaboboni, ph
    https://maps.googleapis.com/maps/api/geocode/json?address=macaboboni,+ph&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #614: sobolevo, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=sobolevo,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #652: akyab, mm
    https://maps.googleapis.com/maps/api/geocode/json?address=akyab,+mm&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #655: karaton, kz
    https://maps.googleapis.com/maps/api/geocode/json?address=karaton,+kz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #662: alotau, pg
    https://maps.googleapis.com/maps/api/geocode/json?address=alotau,+pg&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #668: abonnema, ng
    https://maps.googleapis.com/maps/api/geocode/json?address=abonnema,+ng&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #673: temaraia, ki
    https://maps.googleapis.com/maps/api/geocode/json?address=temaraia,+ki&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Missing Data for city #673: temaraia,ki
    Now retrieving coordinates for city #675: tubruq, ly
    https://maps.googleapis.com/maps/api/geocode/json?address=tubruq,+ly&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #677: karamken, ru
    https://maps.googleapis.com/maps/api/geocode/json?address=karamken,+ru&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #718: ruatoria, nz
    https://maps.googleapis.com/maps/api/geocode/json?address=ruatoria,+nz&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #719: samana, do
    https://maps.googleapis.com/maps/api/geocode/json?address=samana,+do&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    Now retrieving coordinates for city #728: faya, td
    https://maps.googleapis.com/maps/api/geocode/json?address=faya,+td&key=AIzaSyAyYDjxeawUWgaxszCPyrj1Q7aGRt4I5pE
    88



```python
merged_df.head(15)
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>city</th>
      <th>country</th>
      <th>coord</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>lebu</td>
      <td>cl</td>
      <td>{'lon': -73.650002, 'lat': -37.616669}</td>
      <td>3883457</td>
    </tr>
    <tr>
      <th>1</th>
      <td>evensk</td>
      <td>ru</td>
      <td>{'lon': 159.233337, 'lat': 61.950001}</td>
      <td>2125693</td>
    </tr>
    <tr>
      <th>2</th>
      <td>cape town</td>
      <td>za</td>
      <td>{'lon': 18.42322, 'lat': -33.925838}</td>
      <td>3369157</td>
    </tr>
    <tr>
      <th>3</th>
      <td>vaini</td>
      <td>to</td>
      <td>{'lon': -175.199997, 'lat': -21.200001}</td>
      <td>4032243</td>
    </tr>
    <tr>
      <th>4</th>
      <td>birobidzhan</td>
      <td>ru</td>
      <td>{'lon': 132.949997, 'lat': 48.799999}</td>
      <td>2026643</td>
    </tr>
    <tr>
      <th>5</th>
      <td>xai-xai</td>
      <td>mz</td>
      <td>{'lon': 33.644169, 'lat': -25.051941}</td>
      <td>1024552</td>
    </tr>
    <tr>
      <th>6</th>
      <td>airai</td>
      <td>pw</td>
      <td>{'lon': 134.5690225, 'lat': 7.396611799999999}</td>
      <td>0</td>
    </tr>
    <tr>
      <th>7</th>
      <td>clyde river</td>
      <td>ca</td>
      <td>{'lon': -68.591431, 'lat': 70.469162}</td>
      <td>5924351</td>
    </tr>
    <tr>
      <th>8</th>
      <td>taolanaro</td>
      <td>mg</td>
      <td>{'lon': 46.9853688, 'lat': -25.0225309}</td>
      <td>0</td>
    </tr>
    <tr>
      <th>9</th>
      <td>sentyabrskiy</td>
      <td>ru</td>
      <td>{'lon': 72.19638909999999, 'lat': 60.493056}</td>
      <td>0</td>
    </tr>
    <tr>
      <th>10</th>
      <td>ribeira grande</td>
      <td>pt</td>
      <td>{'lon': -25.468349, 'lat': 37.804588}</td>
      <td>8010689</td>
    </tr>
    <tr>
      <th>12</th>
      <td>ushuaia</td>
      <td>ar</td>
      <td>{'lon': -68.300003, 'lat': -54.799999}</td>
      <td>3833367</td>
    </tr>
    <tr>
      <th>13</th>
      <td>leningradskiy</td>
      <td>ru</td>
      <td>{'lon': 178.416672, 'lat': 69.383331}</td>
      <td>2123814</td>
    </tr>
    <tr>
      <th>14</th>
      <td>narsaq</td>
      <td>gl</td>
      <td>{'lon': -46.049999, 'lat': 60.916672}</td>
      <td>3421719</td>
    </tr>
    <tr>
      <th>15</th>
      <td>tumannyy</td>
      <td>ru</td>
      <td>{'lon': 90.3269882, 'lat': 54.0873125}</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>




```python
no_coord = merged_df[merged_df['coord'] == ""]
no_coord
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>city</th>
      <th>country</th>
      <th>coord</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>173</th>
      <td>waw</td>
      <td>sd</td>
      <td></td>
      <td>0</td>
    </tr>
    <tr>
      <th>673</th>
      <td>temaraia</td>
      <td>ki</td>
      <td></td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>




```python
weather_data = merged_df.copy()
weather_data.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>city</th>
      <th>country</th>
      <th>coord</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>lebu</td>
      <td>cl</td>
      <td>{'lon': -73.650002, 'lat': -37.616669}</td>
      <td>3883457</td>
    </tr>
    <tr>
      <th>1</th>
      <td>evensk</td>
      <td>ru</td>
      <td>{'lon': 159.233337, 'lat': 61.950001}</td>
      <td>2125693</td>
    </tr>
    <tr>
      <th>2</th>
      <td>cape town</td>
      <td>za</td>
      <td>{'lon': 18.42322, 'lat': -33.925838}</td>
      <td>3369157</td>
    </tr>
    <tr>
      <th>3</th>
      <td>vaini</td>
      <td>to</td>
      <td>{'lon': -175.199997, 'lat': -21.200001}</td>
      <td>4032243</td>
    </tr>
    <tr>
      <th>4</th>
      <td>birobidzhan</td>
      <td>ru</td>
      <td>{'lon': 132.949997, 'lat': 48.799999}</td>
      <td>2026643</td>
    </tr>
  </tbody>
</table>
</div>




```python
counter = 0 
cur_err_list = [] 
for_err_list = [] 
cur_errors = 0  
for_errors = 0 

#Added Weather Column Data

weather_data['lat'] = ""
weather_data['lng'] = ""


weather_data['cur_date'] = ""
weather_data['cur_temp'] = ""
weather_data['cur_humidity'] = ""
weather_data['cur_clouds'] = ""
weather_data['cur_wind'] = ""

# Columns - Highest Temperature 
# 24 hour Forecast 
weather_data['max_date'] = ""
weather_data['max_temp'] = ""
weather_data['max_temp_humidity'] = ""
weather_data['max_temp_clouds'] = ""
weather_data['max_temp_wind'] = ""

# Columns - Average Values
# 5 Day Forecast
weather_data['avg_date0'] = ""
weather_data['avg_date1'] = ""
weather_data['avg_temp'] = ""
weather_data['avg_humidity'] = ""
weather_data['avg_clouds'] = ""
weather_data['avg_wind'] = ""

t0 = time.time() 
for index, row in weather_data.iterrows():
    print('Now retrieving data for city #%s: %s, %s' % (index, row['city'], row['country']))
    
    if ((row['id']) == 0) and (row['coord'] != ""): 
        lat = row['coord']['lat']
        lon = row['coord']['lon']
        cur_url = 'https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&APPID=%s&units=imperial' % (lat, lon, wkey)  
        for_url = 'https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&APPID=%s&units=imperial' % (lat, lon, wkey)  
    elif row['id'] != 0: 
        loc_id = row['id']
        cur_url = 'https://api.openweathermap.org/data/2.5/weather?id=%s&APPID=%s&units=imperial' % (loc_id, wkey)
        for_url = 'https://api.openweathermap.org/data/2.5/forecast?id=%s&APPID=%s&units=imperial' % (loc_id, wkey)
    else: 
        city = row['city']
        country = row['country']
        cur_url = 'https://api.openweathermap.org/data/2.5/weather?q=%s,%s&APPID=%s&units=imperial' % (city, country, wkey)
        for_url = 'https://api.openweathermap.org/data/2.5/forecast?q=%s,%s&APPID=%s&units=imperial' % (city, country, wkey)
    print('Current Weather URL:')
    print(cur_url)
    print('Forecast Weather URL:')
    print(for_url)
    
    
```

    Now retrieving data for city #0: lebu, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3883457&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3883457&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #1: evensk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2125693&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2125693&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #2: cape town, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3369157&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3369157&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #3: vaini, to
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4032243&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4032243&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #4: birobidzhan, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2026643&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2026643&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #5: xai-xai, mz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1024552&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1024552&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #6: airai, pw
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=7.396611799999999&lon=134.5690225&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=7.396611799999999&lon=134.5690225&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #7: clyde river, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5924351&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5924351&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #8: taolanaro, mg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-25.0225309&lon=46.9853688&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-25.0225309&lon=46.9853688&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #9: sentyabrskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=60.493056&lon=72.19638909999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=60.493056&lon=72.19638909999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #10: ribeira grande, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=8010689&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=8010689&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #12: ushuaia, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3833367&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3833367&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #13: leningradskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2123814&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2123814&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #14: narsaq, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3421719&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3421719&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #15: tumannyy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=54.0873125&lon=90.3269882&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=54.0873125&lon=90.3269882&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #16: olafsvik, is
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3414079&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3414079&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #17: outram, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-45.85690899999999&lon=170.2294936&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-45.85690899999999&lon=170.2294936&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #18: sitka, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5557293&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5557293&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #19: saleaula, ws
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-13.4482906&lon=-172.3367114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-13.4482906&lon=-172.3367114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #20: cuenca, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6357429&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6357429&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #22: planeta rica, co
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3672068&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3672068&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #23: hilo, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5855927&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5855927&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #24: margate, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=978895&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=978895&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #25: kichmengskiy gorodok, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=548791&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=548791&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #26: jamestown, sh
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3370903&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3370903&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #27: klaksvik, fo
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2618795&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2618795&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #28: busselton, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839477&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839477&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #30: rikitea, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4030556&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4030556&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #31: tupik, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2014836&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2014836&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #32: new norfolk, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2155415&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2155415&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #33: kavaratti, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1267390&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1267390&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #34: chokurdakh, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2126123&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2126123&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #35: pangody, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1495626&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1495626&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #36: punta arenas, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3874787&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3874787&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #37: asau, tv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-7.488197&lon=178.6807179&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-7.488197&lon=178.6807179&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #38: puerto ayora, ec
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3652764&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3652764&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #39: nome, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5870133&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5870133&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #40: pavilosta, lv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=456827&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=456827&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #41: juruti, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3396979&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3396979&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #42: hithadhoo, mv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1282256&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1282256&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #43: tiksi, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2015306&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2015306&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #44: palabuhanratu, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-6.9852341&lon=106.5475399&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-6.9852341&lon=106.5475399&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #45: voznesenye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=471160&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=471160&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #46: dwarka, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1272140&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1272140&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #47: vila franca do campo, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=8010690&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=8010690&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #49: rungata, ki
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-1.3493599&lon=176.445007&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-1.3493599&lon=176.445007&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #50: zaysan, kz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1517060&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1517060&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #51: puerto del rosario, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6360187&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6360187&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #53: mbarara, ug
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=229268&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=229268&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #54: upernavik, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3418910&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3418910&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #55: yabrud, sy
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=162627&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=162627&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #56: pacific grove, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5380437&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5380437&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #57: castro, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3896218&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3896218&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #58: pisco, pe
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3932145&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3932145&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #59: nekrasovka, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2019388&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2019388&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #61: ballina, ie
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2966778&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2966778&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #63: veselynove, ua
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=689717&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=689717&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #64: saskylakh, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2017155&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2017155&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #65: qaanaaq, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3831208&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3831208&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #66: bluff, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2206939&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2206939&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #67: constitucion, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=20.729735&lon=-103.368837&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=20.729735&lon=-103.368837&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #68: mataura, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-23.3470634&lon=-149.4850445&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-23.3470634&lon=-149.4850445&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #69: naze, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1855540&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1855540&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #70: avarua, ck
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4035715&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4035715&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #71: georgetown, sh
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2411397&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2411397&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #72: sumbawa, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-8.738071999999999&lon=118.1171082&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-8.738071999999999&lon=118.1171082&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #73: isangel, vu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2136825&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2136825&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #74: dingle, ie
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2964782&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2964782&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #75: butaritari, ki
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7521588&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7521588&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #77: boende, cd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=218680&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=218680&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #78: sistranda, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3139597&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3139597&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #79: albany, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839657&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839657&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #81: provideniya, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4031574&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4031574&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #82: bambous virieux, mu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1106677&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1106677&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #83: ovruch, ua
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=698131&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=698131&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #84: hobart, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2163355&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2163355&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #86: port elizabeth, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=964420&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=964420&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #87: lasa, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=29.652491&lon=91.17210999999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=29.652491&lon=91.17210999999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #88: kapaa, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5848280&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5848280&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #89: andenes, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3163146&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3163146&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #90: tasiilaq, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3424607&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3424607&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #91: flinders, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2166453&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2166453&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #95: tsihombe, mg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-25.3168473&lon=45.48630929999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-25.3168473&lon=45.48630929999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #96: kuminskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1501429&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1501429&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #97: ayan, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2027317&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2027317&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #99: eureka, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5563397&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5563397&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #105: saint george, bm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3573062&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3573062&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #107: egvekinot, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4031742&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4031742&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #108: rudnaya pristan, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2017384&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2017384&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #109: muzquiz, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=27.8822402&lon=-101.513999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=27.8822402&lon=-101.513999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #110: lompoc, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5367788&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5367788&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #111: daudnagar, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1273390&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1273390&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #112: sao filipe, cv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3374210&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3374210&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #113: santa lucia, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2511150&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2511150&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #114: ambulu, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-8.3813553&lon=113.6085612&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-8.3813553&lon=113.6085612&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #115: hermanus, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3366880&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3366880&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #116: cumra, tr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=317844&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=317844&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #117: severo-kurilsk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2121385&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2121385&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #118: barentsburg, sj
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=78.0648475&lon=14.2334597&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=78.0648475&lon=14.2334597&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #119: aleksandrovka, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=583087&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=583087&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #127: vaitupu, wf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-13.2308863&lon=-176.1917035&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-13.2308863&lon=-176.1917035&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #128: big spring, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5517061&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5517061&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #129: torbay, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6167817&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6167817&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #130: mar del plata, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3430863&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3430863&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #131: giyon, et
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=336372&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=336372&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #132: mount isa, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2065594&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2065594&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #134: illoqqortoormiut, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=70.48556909999999&lon=-21.9628757&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=70.48556909999999&lon=-21.9628757&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #135: tabriz, ir
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=113646&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=113646&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #136: bredasdorp, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1015776&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1015776&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #137: ponta do sol, cv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3374346&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3374346&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #138: general pico, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3855075&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3855075&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #139: tuatapere, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2180815&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2180815&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #140: kaeo, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2189343&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2189343&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #141: ilebo, cd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=215976&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=215976&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #142: arrifes, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3373329&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3373329&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #143: tuktoyaktuk, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6170031&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6170031&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #144: mitsamiouli, km
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=921786&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=921786&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #145: dzilam gonzalez, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3529654&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3529654&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #146: indapur, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1269761&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1269761&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #147: prince rupert, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6113406&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6113406&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #148: yellowknife, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6185377&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6185377&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #149: talcahuano, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3870282&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3870282&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #150: east london, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1006984&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1006984&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #151: chikoy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=50.2692308&lon=106.9171252&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=50.2692308&lon=106.9171252&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #152: nizhneyansk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=71.450058&lon=136.1122279&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=71.450058&lon=136.1122279&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #153: cabo san lucas, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3985710&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3985710&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #154: jarinu, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3460068&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3460068&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #155: amderma, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=69.751221&lon=61.6636961&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=69.751221&lon=61.6636961&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #156: katsuura, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2112309&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2112309&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #157: ilulissat, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3423146&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3423146&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #158: san patricio, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3985168&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3985168&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #159: port alfred, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=964432&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=964432&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #160: cidreira, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3466165&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3466165&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #161: inhambane, mz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1045114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1045114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #162: guerrero negro, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4021858&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4021858&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #163: atuona, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4020109&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4020109&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #164: baturaja, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1649593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1649593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #165: bengkulu, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1649150&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1649150&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #166: vila velha, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3445026&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3445026&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #167: arrecife, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6360174&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6360174&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #169: cradock, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1012600&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1012600&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #170: rurrenabaque, bo
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3906209&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3906209&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #171: grand-santi, gf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3381538&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3381538&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #172: la libertad, sv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3585157&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3585157&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #173: waw, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?q=waw,sd&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?q=waw,sd&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #174: saint-philippe, re
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6690301&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6690301&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #176: carballo, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6357289&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6357289&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #178: bolonchen, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=20.0060813&lon=-89.7497303&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=20.0060813&lon=-89.7497303&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #179: ambovombe, mg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1079048&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1079048&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #180: inyonga, tz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=159134&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=159134&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #181: thompson, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6165406&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6165406&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #182: barrow, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5880054&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5880054&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #183: sao joao da barra, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3448903&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3448903&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #184: lyngseidet, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=778829&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=778829&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #185: dikson, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1507390&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1507390&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #186: fort nelson, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5955902&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5955902&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #187: tautira, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4033557&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4033557&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #188: mackay, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #190: norman wells, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6089245&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6089245&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #191: dolbeau, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=48.881683&lon=-72.2321138&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=48.881683&lon=-72.2321138&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #192: batagay, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2027044&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2027044&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #193: beringovskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2126710&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2126710&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #194: maltahohe, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3355624&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3355624&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #195: sainte-anne-des-monts, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6137749&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6137749&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #196: san ramon, bo
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3905088&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3905088&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #197: rocha, uy
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3440777&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3440777&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #198: belushya guba, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=71.54555599999999&lon=52.32027799999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=71.54555599999999&lon=52.32027799999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #199: padang, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1633419&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1633419&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #200: sorong, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1626542&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1626542&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #201: nikolskoye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=55.1981604&lon=166.0015368&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=55.1981604&lon=166.0015368&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #202: namibe, ao
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3347019&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3347019&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #203: edendale, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-46.312539&lon=168.7846556&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-46.312539&lon=168.7846556&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #204: praia da vitoria, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=8010692&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=8010692&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #206: oktyabrskoye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=515805&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=515805&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #207: pevek, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2122090&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2122090&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #208: longyearbyen, sj
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2729907&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2729907&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #209: bayeux, fr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6447202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6447202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #211: schwedt, de
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=53.0624695&lon=14.2734639&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=53.0624695&lon=14.2734639&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #212: machico, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=8010676&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=8010676&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #214: kodiak, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5866583&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5866583&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #215: presidencia roque saenz pena, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3840300&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3840300&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #216: gat, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=24.509445&lon=118.1089531&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=24.509445&lon=118.1089531&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #217: kiunga, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2093846&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2093846&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #218: boyolangu, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1648082&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1648082&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #219: tura, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2014833&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2014833&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #220: luxor, eg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=360502&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=360502&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #221: ginir, et
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=336454&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=336454&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #222: coquimbo, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3893629&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3893629&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #223: linxia, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1803331&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1803331&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #224: washougal, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5815136&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5815136&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #225: kiruna, se
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=605155&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=605155&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #226: leshukonskoye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=535839&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=535839&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #227: cayenne, gf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6690689&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6690689&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #229: yar-sale, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1486321&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1486321&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #230: brae, gb
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2654970&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2654970&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #231: chitral, pk
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1181065&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1181065&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #232: mizdah, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2214827&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2214827&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #233: lorengau, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2092164&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2092164&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #234: mazatlan, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3996322&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3996322&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #236: amapa, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=0.9019925&lon=-52.0029565&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=0.9019925&lon=-52.0029565&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #237: maceio, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6320645&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6320645&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #239: ahipara, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2194098&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2194098&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #240: kieta, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2094027&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2094027&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #241: havelock, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4470244&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4470244&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #242: nishihara, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1855342&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1855342&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #243: broome, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839347&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839347&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #245: makung, tw
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=23.5706269&lon=119.5774616&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=23.5706269&lon=119.5774616&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #246: ostrovnoy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=556268&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=556268&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #247: xining, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1788852&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1788852&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #248: hasaki, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2112802&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2112802&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #249: kavieng, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2094342&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2094342&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #250: andselv, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=69.06780859999999&lon=18.5197195&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=69.06780859999999&lon=18.5197195&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #251: bilma, ne
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2446796&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2446796&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #252: cukai, my
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1732945&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1732945&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #253: ponta do sol, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2264557&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2264557&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #254: ojinaga, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3994469&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3994469&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #255: agidel, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=484856&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=484856&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #256: biak, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-1.0381022&lon=135.9800848&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-1.0381022&lon=135.9800848&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #257: broken hill, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2173911&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2173911&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #258: abu samrah, qa
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=24.7466105&lon=50.8460992&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=24.7466105&lon=50.8460992&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #259: channel-port aux basques, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5919815&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5919815&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #260: kaitangata, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-46.28334&lon=169.8470967&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-46.28334&lon=169.8470967&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #261: sao gabriel da cachoeira, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3662342&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3662342&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #262: bethel, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4182260&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4182260&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #273: misratah, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2214846&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2214846&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #274: cogtong, ph
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1717205&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1717205&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #275: kruisfontein, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=986717&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=986717&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #276: qui nhon, vn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=13.7829673&lon=109.2196634&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=13.7829673&lon=109.2196634&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #277: rolla, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4406282&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4406282&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #279: wairoa, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6247603&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6247603&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #281: port keats, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2063039&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2063039&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #282: nacala, mz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-14.5656065&lon=40.6854309&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-14.5656065&lon=40.6854309&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #283: cherskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2126199&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2126199&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #284: scottsbluff, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5699404&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5699404&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #285: mahadday weyne, so
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=2.9716241&lon=45.5334515&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=2.9716241&lon=45.5334515&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #286: odweyne, so
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=9.410198200000002&lon=45.06299019999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=9.410198200000002&lon=45.06299019999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #287: palauig, ph
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1696188&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1696188&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #288: danville, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4889426&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4889426&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #298: nuristan, af
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=35.3250223&lon=70.90712359999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=35.3250223&lon=70.90712359999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #299: victoria, sc
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=241131&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=241131&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #300: sur, om
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=286245&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=286245&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #301: boquira, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3469190&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3469190&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #302: ituni, gy
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=5.5325277&lon=-58.25195799999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=5.5325277&lon=-58.25195799999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #303: acapulco, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=16.8531086&lon=-99.8236533&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=16.8531086&lon=-99.8236533&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #304: okakarara, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3354876&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3354876&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #305: kirakira, sb
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2178753&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2178753&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #306: codrington, ag
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=17.6425736&lon=-61.8204456&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=17.6425736&lon=-61.8204456&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #307: mastic beach, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5126209&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5126209&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #308: odesskoye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1496380&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1496380&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #309: pahrump, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5509851&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5509851&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #310: barinas, ve
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3648546&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3648546&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #311: rumoi, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2128382&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2128382&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #312: hami, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1529484&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1529484&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #313: pensacola, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4168228&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4168228&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #314: grand river south east, mu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-20.2888094&lon=57.78141199999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-20.2888094&lon=57.78141199999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #315: el carmen, co
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3684683&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3684683&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #318: louisbourg, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=45.9221352&lon=-59.9713119&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=45.9221352&lon=-59.9713119&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #319: mackenzie, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6063191&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6063191&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #320: farsund, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6453403&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6453403&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #322: karratha, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6620339&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6620339&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #323: khatanga, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2022572&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2022572&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #324: komsomolskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=545728&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=545728&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #325: aqtobe, kz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=610611&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=610611&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #326: salinas, ec
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3652100&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3652100&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #327: surt, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2210554&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2210554&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #328: galiwinku, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-12.024734&lon=135.5684773&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-12.024734&lon=135.5684773&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #329: labuan, my
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1734240&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1734240&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #330: san juan, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3837213&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3837213&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #331: cascais, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=8012457&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=8012457&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #334: atambua, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1651103&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1651103&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #335: kununurra, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2068110&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2068110&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #336: raudeberg, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=61.9829132&lon=5.1351057&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=61.9829132&lon=5.1351057&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #337: arraial do cabo, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3471451&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3471451&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #338: finschhafen, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2097418&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2097418&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #339: marrakesh, ma
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2542997&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2542997&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #340: alto araguaia, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3472473&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3472473&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #341: varhaug, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3132644&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3132644&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #342: umm durman, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=15.6475782&lon=32.4806894&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=15.6475782&lon=32.4806894&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #343: mys shmidta, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=68.884224&lon=-179.4311219&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=68.884224&lon=-179.4311219&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #344: samusu, ws
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-14.0056774&lon=-171.4299586&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-14.0056774&lon=-171.4299586&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #345: salalah, om
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=286621&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=286621&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #346: sento se, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-9.7417977&lon=-41.8789341&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-9.7417977&lon=-41.8789341&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #347: verkhnyaya inta, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1487332&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1487332&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #348: faanui, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4034551&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4034551&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #349: weligama, lk
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1223738&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1223738&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #350: tagusao, ph
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1684245&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1684245&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #351: elk plain, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5793609&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5793609&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #352: arlit, ne
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2447513&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2447513&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #353: lake charles, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4330236&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4330236&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #354: roela, ee
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=59.1668014&lon=26.5912817&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=59.1668014&lon=26.5912817&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #355: primo tapia, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3979430&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3979430&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #356: sibolga, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1213855&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1213855&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #357: lagoa, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=8010517&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=8010517&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #362: geresk, af
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=31.8299494&lon=64.5681086&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=31.8299494&lon=64.5681086&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #363: mugur-aksy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1498283&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1498283&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #364: puerto madryn, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3840092&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3840092&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #365: sinnar, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=367644&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=367644&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #366: new lenox, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4903535&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4903535&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #367: yorosso, ml
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2448442&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2448442&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #368: martil, ma
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6546337&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6546337&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #370: vestmanna, fo
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2610343&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2610343&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #371: cleveland, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4188377&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4188377&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #382: lanzhou, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1804430&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1804430&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #383: shingu, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1852109&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1852109&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #385: gamba, ga
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2400547&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2400547&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #386: bogorodskoye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2126638&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2126638&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #392: kazalinsk, kz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=45.7640559&lon=62.0999125&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=45.7640559&lon=62.0999125&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #393: rio gallegos, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3838859&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3838859&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #394: nedjo, et
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=9.5022936&lon=35.5028379&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=9.5022936&lon=35.5028379&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #395: fortuna, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5563839&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5563839&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #396: itoman, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1861280&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1861280&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #397: san cristobal, ec
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3651949&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3651949&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #398: bagdarin, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2027244&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2027244&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #399: los llanos de aridane, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2514651&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2514651&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #400: patrocinio, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3454763&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3454763&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #401: harper, lr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2276492&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2276492&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #402: denizli, tr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=317109&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=317109&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #404: flin flon, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5954719&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5954719&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #406: porto nacional, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3452711&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3452711&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #407: belyy yar, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1510370&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1510370&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #409: labutta, mm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=16.149328&lon=94.7562159&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=16.149328&lon=94.7562159&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #410: fairbanks, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5861897&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5861897&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #411: champerico, gt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3598787&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3598787&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #412: bereda, so
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=42.1816509&lon=-94.9769338&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=42.1816509&lon=-94.9769338&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #413: sharlyk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=495670&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=495670&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #414: miri, my
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1738050&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1738050&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #415: lavrentiya, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4031637&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4031637&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #416: gigante, co
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3682047&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3682047&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #417: nieuw nickerie, sr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3383427&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3383427&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #418: sayyan, ye
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=70979&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=70979&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #419: dmitriyevka, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=566027&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=566027&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #421: saint-louis, re
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6690298&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6690298&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #423: quarai, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3452179&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3452179&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #424: elat, il
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=29.557669&lon=34.951925&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=29.557669&lon=34.951925&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #425: half moon bay, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5354943&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5354943&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #426: vostok, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2013279&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2013279&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #428: tsarychanka, ua
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=691155&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=691155&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #429: road town, vg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3577430&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3577430&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #430: halalo, wf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-13.3436344&lon=-176.2171202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-13.3436344&lon=-176.2171202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #431: bayburt, tr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=862471&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=862471&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #433: rochegda, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=501847&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=501847&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #434: kashiwazaki, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1859908&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1859908&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #435: preston, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5061036&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5061036&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #441: ullapool, gb
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2635199&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2635199&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #442: haibowan, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=39.691156&lon=106.822778&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=39.691156&lon=106.822778&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #443: qaqortoq, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3420846&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3420846&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #444: kihei, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5849297&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5849297&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #445: lensk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2020838&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2020838&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #446: dunedin, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2191562&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2191562&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #447: saint-augustin, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6137462&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6137462&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #448: iqaluit, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5983720&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5983720&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #449: seoul, kr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1835848&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1835848&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #450: grand gaube, mu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=934479&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=934479&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #451: luangwa, zm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=909887&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=909887&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #452: carutapera, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3402648&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3402648&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #453: carman, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5917275&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5917275&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #454: hauterive, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=49.195119&lon=-68.263425&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=49.195119&lon=-68.263425&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #455: black river, jm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3491355&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3491355&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #456: oranjestad, aw
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3577154&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3577154&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #457: sibu, my
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1735902&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1735902&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #458: souillac, mu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=933995&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=933995&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #459: abbeville, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4178992&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4178992&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #463: pathein, mm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1328421&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1328421&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #464: newark, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4833930&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4833930&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #472: marawi, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=370481&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=370481&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #473: rio grande, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3451138&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3451138&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #474: maua, ke
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=187231&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=187231&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #475: ranfurly, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2183774&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2183774&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #476: carnarvon, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2074865&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2074865&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #477: tortoli, it
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6540128&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6540128&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #479: trat, th
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1605279&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1605279&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #480: port lincoln, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839452&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839452&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #482: zeya, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2012593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2012593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #483: tiarei, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4033356&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4033356&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #484: meadow lake, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6071421&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6071421&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #485: sinnamary, gf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6690707&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6690707&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #487: muros, es
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6357322&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6357322&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #489: sturgeon falls, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=46.3679478&lon=-79.9247299&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=46.3679478&lon=-79.9247299&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #490: homer, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4273134&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4273134&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #497: rundu, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3353383&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3353383&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #498: mehamn, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=778707&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=778707&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #499: dali, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1814093&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1814093&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #501: lokoja, ng
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2331939&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2331939&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #502: opuwo, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3354077&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3354077&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #503: maxixe, mz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1039536&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1039536&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #504: athabasca, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5887916&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5887916&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #505: dharmadam, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1272856&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1272856&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #506: paradwip, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=20.3165523&lon=86.6113628&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=20.3165523&lon=86.6113628&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #507: marcona, pe
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-15.3439659&lon=-75.0844757&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-15.3439659&lon=-75.0844757&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #508: pangnirtung, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6096551&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6096551&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #509: saldanha, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3361934&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3361934&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #510: staraya toropa, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=489043&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=489043&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #511: marzuq, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=25.552342&lon=15.7820674&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=25.552342&lon=15.7820674&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #512: aberdeen, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5225857&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5225857&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #521: walvis bay, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3359638&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3359638&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #522: aklavik, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5882953&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5882953&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #523: rock sound, bs
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3571592&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3571592&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #524: gurupa, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3398480&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3398480&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #525: nanortalik, gl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3421765&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3421765&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #526: talnakh, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1490256&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1490256&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #527: wasilla, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5877641&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5877641&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #528: hofn, is
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2630299&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2630299&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #529: hualmay, pe
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3939761&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3939761&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #530: coihaique, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3894426&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3894426&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #531: mareeba, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2158767&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2158767&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #532: barbar, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=42.7792646&lon=-96.92988009999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=42.7792646&lon=-96.92988009999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #533: srednekolymsk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2121025&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2121025&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #534: bratsk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2051523&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2051523&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #535: pucallpa, pe
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3693345&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3693345&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #536: nago, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1856068&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1856068&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #537: port blair, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1259385&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1259385&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #538: babanusah, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=11.320725&lon=27.8135579&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=11.320725&lon=27.8135579&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #539: banda aceh, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1215501&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1215501&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #541: manakara, mg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1061605&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1061605&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #542: plettenberg bay, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=964712&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=964712&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #543: husavik, is
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2629833&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2629833&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #544: nushki, pk
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1168749&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1168749&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #545: hambantota, lk
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1244926&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1244926&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #546: mahebourg, mu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=934322&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=934322&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #547: yulara, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6355222&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6355222&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #548: aykhal, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2027296&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2027296&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #549: hay river, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5972762&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5972762&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #550: cururupu, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3401148&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3401148&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #551: puri, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1259184&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1259184&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #552: mirzapur, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1262994&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1262994&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #554: oranjemund, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3354071&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3354071&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #555: beloha, mg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1067565&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1067565&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #556: zhangzhou, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1785018&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1785018&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #557: chivasso, it
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6538052&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6538052&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #559: mount gambier, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839440&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839440&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #561: slobodskoy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=491882&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=491882&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #562: fairlie, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-44.0991203&lon=170.8291141&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-44.0991203&lon=170.8291141&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #563: riyadh, sa
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=108410&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=108410&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #564: conceicao do araguaia, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3401845&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3401845&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #565: alofi, nu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4036284&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4036284&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #566: tazovskiy, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1489853&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1489853&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #567: sambava, mg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1056899&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1056899&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #568: mehran, ir
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=124291&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=124291&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #569: tecoanapa, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3516171&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3516171&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #570: ingham, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2162737&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2162737&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #571: mayo, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6068416&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6068416&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #572: meulaboh, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1214488&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1214488&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #573: khandyga, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2022773&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2022773&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #574: kautokeino, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=779327&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=779327&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #576: nouadhibou, mr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2377457&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2377457&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #577: shakawe, bw
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=933077&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=933077&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #578: itarema, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-2.9209642&lon=-39.91673979999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-2.9209642&lon=-39.91673979999999&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #579: imatra, fi
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=656689&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=656689&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #581: umzimvubu, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-30.7781755&lon=28.9528645&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-30.7781755&lon=28.9528645&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #582: morgan city, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4333811&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4333811&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #583: grootfontein, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3357114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3357114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #584: geraldton, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2070998&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2070998&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #585: katha, mm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=24.1821187&lon=96.3305831&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=24.1821187&lon=96.3305831&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #586: vao, nc
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2137773&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2137773&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #587: uvalde, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4738721&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4738721&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #588: la ronge, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6050066&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6050066&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #589: rio do sul, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3451152&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3451152&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #590: kerki, tm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=37.8099917&lon=65.2026017&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=37.8099917&lon=65.2026017&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #591: sergeyevka, kz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1519386&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1519386&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #593: ust-kut, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2013923&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2013923&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #594: udomlya, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=452949&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=452949&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #595: lata, sb
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=34.075317&lon=-117.294169&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=34.075317&lon=-117.294169&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #596: ancud, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3899695&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3899695&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #597: stornoway, gb
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2636790&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2636790&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #598: daru, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2098329&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2098329&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #599: slave lake, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6149374&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6149374&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #600: wajid, so
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=3.809294&lon=43.2461055&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=3.809294&lon=43.2461055&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #601: bolobo, cd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2316748&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2316748&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #602: taft, ir
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=113632&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=113632&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #603: namatanai, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2090021&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2090021&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #604: portland, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2152667&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2152667&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #606: birao, cf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=240210&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=240210&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #607: kota tinggi, my
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1732738&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1732738&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #608: dudinka, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1507116&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1507116&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #609: jijiang, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=24.781681&lon=118.552365&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=24.781681&lon=118.552365&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #610: macaboboni, ph
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=16.1952956&lon=119.7802409&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=16.1952956&lon=119.7802409&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #611: sorland, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3137469&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3137469&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #612: de-kastri, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2126018&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2126018&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #613: waingapu, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1622318&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1622318&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #614: sobolevo, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=54.300693&lon=155.956757&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=54.300693&lon=155.956757&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #615: skibbereen, ie
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2961459&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2961459&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #616: westport, ie
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2960970&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2960970&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #617: oriximina, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3393471&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3393471&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #618: sola, vu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2134814&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2134814&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #619: pawai, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1260009&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1260009&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #620: chumikan, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2025256&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2025256&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #621: te anau, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2181625&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2181625&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #622: bardiyah, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=80509&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=80509&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #623: severnoye, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=496381&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=496381&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #626: vilhena, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3924679&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3924679&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #627: cochabamba, bo
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3919968&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3919968&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #628: nicoya, cr
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3622716&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3622716&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #629: luena, ao
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3347719&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3347719&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #630: west wendover, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5710035&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5710035&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #631: namanga, ke
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=184570&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=184570&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #632: kahului, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5847411&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5847411&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #633: barra patuca, hn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3614835&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3614835&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #634: chapais, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5919850&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5919850&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #635: wilmington, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4145381&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4145381&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #640: nayoro, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2128983&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2128983&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #641: shunyi, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2034754&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2034754&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #642: shulan, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2034761&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2034761&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #643: tyshkivka, ua
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=691510&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=691510&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #644: parry sound, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6098747&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6098747&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #645: lujan, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3845398&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3845398&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #647: touros, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3386213&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3386213&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #648: aljezur, pt
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2271968&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2271968&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #649: moerai, pf
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4034188&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4034188&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #650: shenjiamen, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1795632&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1795632&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #651: ajdabiya, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=89113&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=89113&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #652: akyab, mm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=20.1527657&lon=92.86768610000001&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=20.1527657&lon=92.86768610000001&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #653: esperance, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2071860&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2071860&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #654: kampene, cd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=214575&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=214575&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #655: karaton, kz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=46.437389&lon=53.504459&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=46.437389&lon=53.504459&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #656: brewster, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4931273&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4931273&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #661: cap malheureux, mu
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=934649&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=934649&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #662: alotau, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-10.3157027&lon=150.4587795&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-10.3157027&lon=150.4587795&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #663: makokou, ga
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2399371&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2399371&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #664: turukhansk, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1488903&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1488903&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #665: rusape, zw
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=882100&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=882100&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #666: san-pedro, ci
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2282006&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2282006&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #667: sabang, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1214026&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1214026&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #668: abonnema, ng
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=4.7231169&lon=6.7788461&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=4.7231169&lon=6.7788461&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #669: george, za
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1002145&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1002145&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #670: turangi, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2180737&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2180737&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #671: marsh harbour, bs
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3571913&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3571913&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #672: cabedelo, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3404558&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3404558&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #673: temaraia, ki
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?q=temaraia,ki&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?q=temaraia,ki&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #674: grenada, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4428539&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4428539&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #675: tubruq, ly
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=32.0681759&lon=23.941751&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=32.0681759&lon=23.941751&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #676: nyurba, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2018735&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2018735&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #677: karamken, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=60.2007108&lon=151.1047187&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=60.2007108&lon=151.1047187&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #678: pringsewu, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1630639&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1630639&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #679: parati, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3455036&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3455036&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #680: altay, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1529651&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1529651&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #681: luanda, ao
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2240449&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2240449&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #682: guiratinga, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3461733&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3461733&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #683: ixtapa, mx
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=4004293&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=4004293&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #686: maputo, mz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1040652&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1040652&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #687: santiago del estero, ar
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3835869&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3835869&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #688: marabba, sd
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=370510&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=370510&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #689: morro bay, us
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5374920&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5374920&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #690: roseto degli abruzzi, it
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6541925&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6541925&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #692: bay roberts, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=5895424&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=5895424&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #693: tessalit, ml
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2449893&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2449893&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #694: muscat, om
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=287286&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=287286&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #695: lieksa, fi
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=648091&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=648091&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #697: havoysund, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=779622&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=779622&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #698: uige, ao
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2236568&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2236568&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #699: sumbe, ao
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3346015&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3346015&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #700: anadyr, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2127202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2127202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #701: khuzdar, pk
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7082481&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7082481&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #702: valparaiso, cl
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3868626&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3868626&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #703: port hedland, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839630&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839630&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #705: zhicheng, cn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1784553&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1784553&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #707: tsumeb, na
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3352593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3352593&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #708: viesite, lv
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=454216&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=454216&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #709: fort william, gb
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2649169&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2649169&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #710: nizwa, om
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=286987&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=286987&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #711: kungurtug, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1501377&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1501377&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #712: ibra, om
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=287832&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=287832&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #713: taoudenni, ml
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2450173&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2450173&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #714: esmeraldas, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3464008&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3464008&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #715: cairns, au
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=7839567&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=7839567&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #717: mandal, no
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3146463&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3146463&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #718: ruatoria, nz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=-37.8927614&lon=178.3194507&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=-37.8927614&lon=178.3194507&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #719: samana, do
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=19.2080704&lon=-69.3324518&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=19.2080704&lon=-69.3324518&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #720: chuy, uy
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3443061&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3443061&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #721: kaberamaido, ug
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=233019&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=233019&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #722: mogocha, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2019912&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2019912&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #723: magrath, ca
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=6064202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=6064202&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #724: bidhuna, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1275732&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1275732&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #725: pavlodar, kz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1520240&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1520240&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #726: olovyannaya, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2018498&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2018498&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #727: laguna, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3459094&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3459094&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #728: faya, td
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?lat=17.9236623&lon=19.1107114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?lat=17.9236623&lon=19.1107114&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #729: nakamura, jp
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1855891&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1855891&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #731: morehead, pg
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2090495&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2090495&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #732: kahama, tz
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=158597&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=158597&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #733: baruun-urt, mn
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2032614&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2032614&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #734: allapalli, in
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1278987&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1278987&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #735: taywarah, af
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1122464&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1122464&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #736: kholtoson, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=2022369&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=2022369&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #737: akdepe, tm
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=601551&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=601551&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #738: tabuk, sa
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=101628&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=101628&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #739: caravelas, br
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=3466980&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=3466980&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #740: aksarka, ru
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1512019&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1512019&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Now retrieving data for city #741: ambon, id
    Current Weather URL:
    https://api.openweathermap.org/data/2.5/weather?id=1651531&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial
    Forecast Weather URL:
    https://api.openweathermap.org/data/2.5/forecast?id=1651531&APPID=6ef647a7d8716e4de89b8cb73b4b6604&units=imperial



```python
weather_data['lat'] = ""
weather_data['lng'] = ""

#make columns for current weather data 
weather_data['cur_date'] = ""
weather_data['cur_temp'] = ""
weather_data['cur_humidity'] = ""
weather_data['cur_clouds'] = ""
weather_data['cur_wind'] = ""

#make columns for highest temperature 
weather_data['max_date'] = ""
weather_data['max_temp'] = ""
weather_data['max_temp_humidity'] = ""
weather_data['max_temp_clouds'] = ""
weather_data['max_temp_wind'] = ""

#make columns  average values
weather_data['avg_date0'] = ""
weather_data['avg_date1'] = ""
weather_data['avg_temp'] = ""
weather_data['avg_humidity'] = ""
weather_data['avg_clouds'] = ""
weather_data['avg_wind'] = ""
```


```python
dates = {'max_cur': weather_data['cur_date'].max(),
         'min_cur': weather_data['cur_date'].min(),
         'max_max': weather_data['max_date'].max(),
         'min_max': weather_data['max_date'].min(),
         'min_avg': weather_data['avg_date0'].max(),
         'max_avg': weather_data['avg_date1'].min()
        }
```


```python
labels_dic = {"cur_temp": "Current Temperature", 
              'max_temp': 'Maximum Temp 24 Hours', 
              'avg_temp': 'Average Forecasted Temp in 5 Days',
             'cur_humidity': 'Current Humidity',
             'max_temp_humidity': "Forecasted Humidity (%) at the Maximum Temperature in 24 Hours",
             'avg_humidity': 'Average Forecasted Humidity (%) over 5 Days',
             'cur_clouds': 'Current Cloud Cover (%)',
             'max_temp_clouds': 'Forecasted Cloud Cover (%) at the Maximum Forecasted Temperature in 24 Hours',
             'avg_clouds': 'Average Forecasted Cloud Cover (%) over 5 Days',
             'cur_wind': 'Current Wind Speed (mph)',
             'max_temp_wind': 'Forecasted Wind Speed (mph) at the Maximum Forecasted Temperature in 24 Hours',
             'avg_wind': 'Average Forecasted Wind Speed (mph) over 5 Days'}
```


```python
# Temp vs Latitude Graphs
temp_list = ['cur_temp', 'max_temp', 'avg_temp']  

xvals = weather_data['lat']

for temp in temp_list:
    
    yvals = weather_data[temp]
    
    plt.title("%s vs Latitude \n Samples Taken from %s to %s UTC" % (labels_dic[temp], dates['min_' + temp.split('_')[0]],  dates['max_' + temp.split('_')[0]]))
    plt.axvline(0, color = 'black', alpha = .25, label = 'Equator') 
    plt.text(1,30,'Equator',rotation=90)
    plt.ylim(15, 120) #to give consistent scale
    plt.xlabel('Latitude')
    plt.ylabel("Temperature (F)")
    plt.scatter(xvals, yvals)
    plt.show()
```


![png](output_18_0.png)



![png](output_18_1.png)



![png](output_18_2.png)



```python
# Humidity vs Latitude Graphs

hum_list = ['cur_humidity', 'max_temp_humidity', 'avg_humidity']

xvals = weather_data['lat']

for hum in hum_list:
    yvals = weather_data[hum]
    plt.title("%s vs Latitude \n Samples Taken from %s to %s UTC" % (labels_dic[hum], dates['min_' + hum.split('_')[0]],  dates['max_' + hum.split('_')[0]]))
    plt.xlabel('Latitude')
    plt.ylabel('Humidity (%)')
    plt.axvline(0, color = 'black', alpha = .25, label = 'Equator')
    plt.text(1,20,'Equator',rotation=90)
    plt.scatter(xvals, yvals)
    plt.show()
```


![png](output_19_0.png)



![png](output_19_1.png)



![png](output_19_2.png)



```python
# Clouds vs Latitude Graphs

cloud_list = ['cur_clouds', 'max_temp_clouds', 'avg_clouds']  

xvals = weather_data['lat']

for clo in cloud_list:
    yvals = weather_data[clo]
    plt.title("%s vs Latitude \n Samples Taken from %s to %s UTC" % (labels_dic[clo], dates['min_' + clo.split('_')[0]],  dates['max_' + clo.split('_')[0]]))
    plt.xlabel('Latitude')
    plt.ylabel('Cloud Cover (%)')
    plt.ylim(-5,105)
    plt.axvline(0, color = 'black', alpha = .25, label = 'Equator')
    plt.text(-5,-20,'Equator')
    plt.scatter(xvals, yvals)
    plt.show()
```


    ---------------------------------------------------------------------------

    ValueError                                Traceback (most recent call last)

    ~/anaconda3/lib/python3.6/site-packages/IPython/core/formatters.py in __call__(self, obj)
        330                 pass
        331             else:
    --> 332                 return printer(obj)
        333             # Finally look for special method names
        334             method = get_real_method(obj, self.print_method)


    ~/anaconda3/lib/python3.6/site-packages/IPython/core/pylabtools.py in <lambda>(fig)
        235 
        236     if 'png' in formats:
    --> 237         png_formatter.for_type(Figure, lambda fig: print_figure(fig, 'png', **kwargs))
        238     if 'retina' in formats or 'png2x' in formats:
        239         png_formatter.for_type(Figure, lambda fig: retina_figure(fig, **kwargs))


    ~/anaconda3/lib/python3.6/site-packages/IPython/core/pylabtools.py in print_figure(fig, fmt, bbox_inches, **kwargs)
        119 
        120     bytes_io = BytesIO()
    --> 121     fig.canvas.print_figure(bytes_io, **kw)
        122     data = bytes_io.getvalue()
        123     if fmt == 'svg':


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backend_bases.py in print_figure(self, filename, dpi, facecolor, edgecolor, orientation, format, **kwargs)
       2257                 orientation=orientation,
       2258                 bbox_inches_restore=_bbox_inches_restore,
    -> 2259                 **kwargs)
       2260         finally:
       2261             if bbox_inches and restore_bbox:


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in print_png(self, filename_or_obj, *args, **kwargs)
        505 
        506     def print_png(self, filename_or_obj, *args, **kwargs):
    --> 507         FigureCanvasAgg.draw(self)
        508         renderer = self.get_renderer()
        509         original_dpi = renderer.dpi


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in draw(self)
        420         Draw the figure using the renderer
        421         """
    --> 422         self.renderer = self.get_renderer(cleared=True)
        423         # acquire a lock on the shared font cache
        424         RendererAgg.lock.acquire()


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in get_renderer(self, cleared)
        442 
        443         if need_new_renderer:
    --> 444             self.renderer = RendererAgg(w, h, self.figure.dpi)
        445             self._lastKey = key
        446         elif cleared:


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in __init__(self, width, height, dpi)
         90         self.width = width
         91         self.height = height
    ---> 92         self._renderer = _RendererAgg(int(width), int(height), dpi, debug=False)
         93         self._filter_renderers = []
         94 


    ValueError: Image size of 85102x294 pixels is too large. It must be less than 2^16 in each direction.



    <matplotlib.figure.Figure at 0x1a23fef4a8>



    ---------------------------------------------------------------------------

    ValueError                                Traceback (most recent call last)

    ~/anaconda3/lib/python3.6/site-packages/IPython/core/formatters.py in __call__(self, obj)
        330                 pass
        331             else:
    --> 332                 return printer(obj)
        333             # Finally look for special method names
        334             method = get_real_method(obj, self.print_method)


    ~/anaconda3/lib/python3.6/site-packages/IPython/core/pylabtools.py in <lambda>(fig)
        235 
        236     if 'png' in formats:
    --> 237         png_formatter.for_type(Figure, lambda fig: print_figure(fig, 'png', **kwargs))
        238     if 'retina' in formats or 'png2x' in formats:
        239         png_formatter.for_type(Figure, lambda fig: retina_figure(fig, **kwargs))


    ~/anaconda3/lib/python3.6/site-packages/IPython/core/pylabtools.py in print_figure(fig, fmt, bbox_inches, **kwargs)
        119 
        120     bytes_io = BytesIO()
    --> 121     fig.canvas.print_figure(bytes_io, **kw)
        122     data = bytes_io.getvalue()
        123     if fmt == 'svg':


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backend_bases.py in print_figure(self, filename, dpi, facecolor, edgecolor, orientation, format, **kwargs)
       2257                 orientation=orientation,
       2258                 bbox_inches_restore=_bbox_inches_restore,
    -> 2259                 **kwargs)
       2260         finally:
       2261             if bbox_inches and restore_bbox:


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in print_png(self, filename_or_obj, *args, **kwargs)
        505 
        506     def print_png(self, filename_or_obj, *args, **kwargs):
    --> 507         FigureCanvasAgg.draw(self)
        508         renderer = self.get_renderer()
        509         original_dpi = renderer.dpi


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in draw(self)
        420         Draw the figure using the renderer
        421         """
    --> 422         self.renderer = self.get_renderer(cleared=True)
        423         # acquire a lock on the shared font cache
        424         RendererAgg.lock.acquire()


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in get_renderer(self, cleared)
        442 
        443         if need_new_renderer:
    --> 444             self.renderer = RendererAgg(w, h, self.figure.dpi)
        445             self._lastKey = key
        446         elif cleared:


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in __init__(self, width, height, dpi)
         90         self.width = width
         91         self.height = height
    ---> 92         self._renderer = _RendererAgg(int(width), int(height), dpi, debug=False)
         93         self._filter_renderers = []
         94 


    ValueError: Image size of 85217x294 pixels is too large. It must be less than 2^16 in each direction.



    <matplotlib.figure.Figure at 0x1a23fc5e10>



    ---------------------------------------------------------------------------

    ValueError                                Traceback (most recent call last)

    ~/anaconda3/lib/python3.6/site-packages/IPython/core/formatters.py in __call__(self, obj)
        330                 pass
        331             else:
    --> 332                 return printer(obj)
        333             # Finally look for special method names
        334             method = get_real_method(obj, self.print_method)


    ~/anaconda3/lib/python3.6/site-packages/IPython/core/pylabtools.py in <lambda>(fig)
        235 
        236     if 'png' in formats:
    --> 237         png_formatter.for_type(Figure, lambda fig: print_figure(fig, 'png', **kwargs))
        238     if 'retina' in formats or 'png2x' in formats:
        239         png_formatter.for_type(Figure, lambda fig: retina_figure(fig, **kwargs))


    ~/anaconda3/lib/python3.6/site-packages/IPython/core/pylabtools.py in print_figure(fig, fmt, bbox_inches, **kwargs)
        119 
        120     bytes_io = BytesIO()
    --> 121     fig.canvas.print_figure(bytes_io, **kw)
        122     data = bytes_io.getvalue()
        123     if fmt == 'svg':


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backend_bases.py in print_figure(self, filename, dpi, facecolor, edgecolor, orientation, format, **kwargs)
       2257                 orientation=orientation,
       2258                 bbox_inches_restore=_bbox_inches_restore,
    -> 2259                 **kwargs)
       2260         finally:
       2261             if bbox_inches and restore_bbox:


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in print_png(self, filename_or_obj, *args, **kwargs)
        505 
        506     def print_png(self, filename_or_obj, *args, **kwargs):
    --> 507         FigureCanvasAgg.draw(self)
        508         renderer = self.get_renderer()
        509         original_dpi = renderer.dpi


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in draw(self)
        420         Draw the figure using the renderer
        421         """
    --> 422         self.renderer = self.get_renderer(cleared=True)
        423         # acquire a lock on the shared font cache
        424         RendererAgg.lock.acquire()


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in get_renderer(self, cleared)
        442 
        443         if need_new_renderer:
    --> 444             self.renderer = RendererAgg(w, h, self.figure.dpi)
        445             self._lastKey = key
        446         elif cleared:


    ~/anaconda3/lib/python3.6/site-packages/matplotlib/backends/backend_agg.py in __init__(self, width, height, dpi)
         90         self.width = width
         91         self.height = height
    ---> 92         self._renderer = _RendererAgg(int(width), int(height), dpi, debug=False)
         93         self._filter_renderers = []
         94 


    ValueError: Image size of 85118x294 pixels is too large. It must be less than 2^16 in each direction.



    <matplotlib.figure.Figure at 0x1a240b8400>



```python
# Wind Speed vs Latitude Graphs

win_list = ['cur_wind', 'max_temp_wind', 'avg_wind']  

xvals = weather_data['lat']

for win in win_list:
    yvals = weather_data[win]
    plt.title("%s vs Latitude \n Samples Taken from %s to %s UTC" % (labels_dic[win], dates['min_' + win.split('_')[0]],  dates['max_' + win.split('_')[0]]))
    plt.xlabel('Latitude')
    plt.ylabel('Wind Speed (mph))')
    plt.ylim(-5,60)
    plt.axvline(0, color = 'black', alpha = .25, label = 'Equator')
    plt.text(1,35,'Equator',rotation=90)
    plt.scatter(xvals, yvals)
    plt.show()
```


![png](output_21_0.png)



![png](output_21_1.png)



![png](output_21_2.png)

