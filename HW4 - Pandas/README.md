

```python
import pandas as pd
import numpy as np
```


```python
purchasedatabase_df = pd.read_json("purchase_data.json")
purchasedatabase_df.head()
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
      <th>Age</th>
      <th>Gender</th>
      <th>Item ID</th>
      <th>Item Name</th>
      <th>Price</th>
      <th>SN</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>38</td>
      <td>Male</td>
      <td>165</td>
      <td>Bone Crushing Silver Skewer</td>
      <td>3.37</td>
      <td>Aelalis34</td>
    </tr>
    <tr>
      <th>1</th>
      <td>21</td>
      <td>Male</td>
      <td>119</td>
      <td>Stormbringer, Dark Blade of Ending Misery</td>
      <td>2.32</td>
      <td>Eolo46</td>
    </tr>
    <tr>
      <th>2</th>
      <td>34</td>
      <td>Male</td>
      <td>174</td>
      <td>Primitive Blade</td>
      <td>2.46</td>
      <td>Assastnya25</td>
    </tr>
    <tr>
      <th>3</th>
      <td>21</td>
      <td>Male</td>
      <td>92</td>
      <td>Final Critic</td>
      <td>1.36</td>
      <td>Pheusrical25</td>
    </tr>
    <tr>
      <th>4</th>
      <td>23</td>
      <td>Male</td>
      <td>63</td>
      <td>Stormfury Mace</td>
      <td>1.27</td>
      <td>Aela59</td>
    </tr>
  </tbody>
</table>
</div>




```python
purchasedatabase_df.columns
```




    Index(['Age', 'Gender', 'Item ID', 'Item Name', 'Price', 'SN'], dtype='object')




```python
#Player Count
playernames_SN = purchasedatabase_df['SN'].nunique()
totalplayercount = pd.DataFrame({"Total Players" : [playernames_SN]}, columns = ["Total Players"])
totalplayercount
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
      <th>Total Players</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>573</td>
    </tr>
  </tbody>
</table>
</div>




```python
#Purchasing Analysis - Unique Items, Avg Purchase Price, Total Number of Purchases, Total Revenue
uniqueitems = purchasedatabase_df['Item ID'].nunique()
avgprice = (purchasedatabase_df['Price'].sum()/purchasedatabase_df['Price'].count()).round(2)
totalpurchases = purchasedatabase_df['Price'].count()
totalrevenue = purchasedatabase_df["Price"].sum()

total_analysis_df = pd.DataFrame({"Number of Unique Items": [uniqueitems], 
                              "Average Purchase Price": [avgprice],
                             "Number of Purchases": [totalpurchases],
                             "Total Revenue": [totalrevenue]}, columns= ["Number of Unique Items", "Average Purchase Price",
                            "Number of Purchases", "Total Revenue"])

total_analysis_df.style.format({"Average Purchase Price": "${:.2f}", "Total Revenue": "${:.2f}"})
```




<style  type="text/css" >
</style>  
<table id="T_36a0c4f4_1900_11e8_b9e1_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Number of Unique Items</th> 
        <th class="col_heading level0 col1" >Average Purchase Price</th> 
        <th class="col_heading level0 col2" >Number of Purchases</th> 
        <th class="col_heading level0 col3" >Total Revenue</th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_36a0c4f4_1900_11e8_b9e1_8c85908350c0level0_row0" class="row_heading level0 row0" >0</th> 
        <td id="T_36a0c4f4_1900_11e8_b9e1_8c85908350c0row0_col0" class="data row0 col0" >183</td> 
        <td id="T_36a0c4f4_1900_11e8_b9e1_8c85908350c0row0_col1" class="data row0 col1" >$2.93</td> 
        <td id="T_36a0c4f4_1900_11e8_b9e1_8c85908350c0row0_col2" class="data row0 col2" >780</td> 
        <td id="T_36a0c4f4_1900_11e8_b9e1_8c85908350c0row0_col3" class="data row0 col3" >$2286.33</td> 
    </tr></tbody> 
</table> 




```python
#Gender Demographics - % Male, % female, % of other
countfull = purchasedatabase_df["SN"].nunique()
countmale = purchasedatabase_df[purchasedatabase_df["Gender"] == "Male"]["SN"].nunique()
countfemale = purchasedatabase_df[purchasedatabase_df["Gender"] == "Female"]["SN"].nunique()
countother = countfull - countmale - countfemale
malepercent = ((countmale/countfull)*100)
femalepercent = ((countfemale/countfull)*100)
otherpercent = ((countother/countfull)*100)

gender_df = pd.DataFrame({"Gender": ["Male", "Female", "Other / Non-Disclosed"], "Percentage of Players": [malepercent, femalepercent, otherpercent],
                                        "Total Count": [countmale, countfemale, countother]}, columns = 
                                        ["Gender", "Percentage of Players", "Total Count"])
                                        
gender_final = gender_df.set_index("Gender")
gender_final.style.format({"Percentage of Players": "{:.2f}%"})
```




<style  type="text/css" >
</style>  
<table id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Percentage of Players</th> 
        <th class="col_heading level0 col1" >Total Count</th> 
    </tr>    <tr> 
        <th class="index_name level0" >Gender</th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0level0_row0" class="row_heading level0 row0" >Male</th> 
        <td id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0row0_col0" class="data row0 col0" >81.15%</td> 
        <td id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0row0_col1" class="data row0 col1" >465</td> 
    </tr>    <tr> 
        <th id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0level0_row1" class="row_heading level0 row1" >Female</th> 
        <td id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0row1_col0" class="data row1 col0" >17.45%</td> 
        <td id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0row1_col1" class="data row1 col1" >100</td> 
    </tr>    <tr> 
        <th id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0level0_row2" class="row_heading level0 row2" >Other / Non-Disclosed</th> 
        <td id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0row2_col0" class="data row2 col0" >1.40%</td> 
        <td id="T_595b2fb4_1905_11e8_b6a3_8c85908350c0row2_col1" class="data row2 col1" >8</td> 
    </tr></tbody> 
</table> 




```python
#Purchase by Gender
malepurch = purchasedatabase_df[purchasedatabase_df["Gender"] == "Male"]["Price"].count()
femalepurch = purchasedatabase_df[purchasedatabase_df["Gender"] == "Female"]["Price"].count()
otherpurch = totalpurchases - malepurch - femalepurch
mpriceavg = purchasedatabase_df[purchasedatabase_df["Gender"] == "Male"]['Price'].mean()
fpriceavg = purchasedatabase_df[purchasedatabase_df["Gender"] == "Female"]['Price'].mean()
opriceavg = purchasedatabase_df[purchasedatabase_df["Gender"] == "Other / Non-Disclosed"]['Price'].mean()
mpricetot = purchasedatabase_df[purchasedatabase_df["Gender"] == "Male"]['Price'].sum()
fpricetot = purchasedatabase_df[purchasedatabase_df["Gender"] == "Female"]['Price'].sum()
opricetot = purchasedatabase_df[purchasedatabase_df["Gender"] == "Other / Non-Disclosed"]['Price'].sum()
mnorm = mpricetot/countmale
fnorm = fpricetot/countfemale
onorm = opricetot/countother

gender_purch_df = pd.DataFrame({"Gender": ["Male", "Female", "Other / Non-Disclosed"], "Purchase Count": [malepurch, femalepurch, otherpurch],
                                        "Average Purchase Price": [mpriceavg, fpriceavg, opriceavg], "Total Purchase Value": [mpricetot, fpricetot, opricetot],
                                "Normalized Totals": [mnorm, fnorm, onorm]}, columns = 
                                        ["Gender", "Purchase Count", "Average Purchase Price", "Total Purchase Value", "Normalized Totals"])
                                        
gender_purch_final = gender_purch_df.set_index("Gender")
gender_purch_final.style.format({"Average Purchase Price": "${:.2f}", "Total Purchase Value": "${:.2f}", "Normalized Totals": "${:.2f}"})
```




<style  type="text/css" >
</style>  
<table id="T_2b4357e8_1906_11e8_abb5_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Purchase Count</th> 
        <th class="col_heading level0 col1" >Average Purchase Price</th> 
        <th class="col_heading level0 col2" >Total Purchase Value</th> 
        <th class="col_heading level0 col3" >Normalized Totals</th> 
    </tr>    <tr> 
        <th class="index_name level0" >Gender</th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_2b4357e8_1906_11e8_abb5_8c85908350c0level0_row0" class="row_heading level0 row0" >Male</th> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row0_col0" class="data row0 col0" >633</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row0_col1" class="data row0 col1" >$2.95</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row0_col2" class="data row0 col2" >$1867.68</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row0_col3" class="data row0 col3" >$4.02</td> 
    </tr>    <tr> 
        <th id="T_2b4357e8_1906_11e8_abb5_8c85908350c0level0_row1" class="row_heading level0 row1" >Female</th> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row1_col0" class="data row1 col0" >136</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row1_col1" class="data row1 col1" >$2.82</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row1_col2" class="data row1 col2" >$382.91</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row1_col3" class="data row1 col3" >$3.83</td> 
    </tr>    <tr> 
        <th id="T_2b4357e8_1906_11e8_abb5_8c85908350c0level0_row2" class="row_heading level0 row2" >Other / Non-Disclosed</th> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row2_col0" class="data row2 col0" >11</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row2_col1" class="data row2 col1" >$3.25</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row2_col2" class="data row2 col2" >$35.74</td> 
        <td id="T_2b4357e8_1906_11e8_abb5_8c85908350c0row2_col3" class="data row2 col3" >$4.47</td> 
    </tr></tbody> 
</table> 




```python
#Age Demographics
tenyears = purchasedatabase_df[purchasedatabase_df["Age"] <10]
loteens = purchasedatabase_df[(purchasedatabase_df["Age"] >=10) & (purchasedatabase_df["Age"] <=14)]
hiteens = purchasedatabase_df[(purchasedatabase_df["Age"] >=15) & (purchasedatabase_df["Age"] <=19)]
lotwent = purchasedatabase_df[(purchasedatabase_df["Age"] >=20) & (purchasedatabase_df["Age"] <=24)]
hitwent = purchasedatabase_df[(purchasedatabase_df["Age"] >=25) & (purchasedatabase_df["Age"] <=29)]
lothirt = purchasedatabase_df[(purchasedatabase_df["Age"] >=30) & (purchasedatabase_df["Age"] <=34)]
hithirt = purchasedatabase_df[(purchasedatabase_df["Age"] >=35) & (purchasedatabase_df["Age"] <=39)]
loforty = purchasedatabase_df[(purchasedatabase_df["Age"] >=40) & (purchasedatabase_df["Age"] <=44)]
hiforty = purchasedatabase_df[(purchasedatabase_df["Age"] >=45) & (purchasedatabase_df["Age"] <=49)]

age_demo_df = pd.DataFrame({"Age": ["<10", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49"],
                        "Percentage of Players": [(tenyears["SN"].nunique()/countfull)*100, (loteens["SN"].nunique()/countfull)*100, (hiteens["SN"].nunique()/countfull)*100, (lotwent["SN"].nunique()/countfull)*100, (hitwent["SN"].nunique()/countfull)*100, (lothirt["SN"].nunique()/countfull)*100, (hithirt["SN"].nunique()/countfull)*100, (loforty["SN"].nunique()/countfull)*100, (hiforty["SN"].nunique()/countfull)*100],
                        "Total Count": [tenyears["SN"].nunique(), loteens["SN"].nunique(), hiteens["SN"].nunique(), lotwent["SN"].nunique(), hitwent["SN"].nunique(), lothirt["SN"].nunique(), hithirt["SN"].nunique(), loforty["SN"].nunique(), hiforty["SN"].nunique()]
                       })

age_demo_final = age_demo_df.set_index("Age")
age_demo_final.style.format({"Percentage of Players": "{:.2f}%"})
```




<style  type="text/css" >
</style>  
<table id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Percentage of Players</th> 
        <th class="col_heading level0 col1" >Total Count</th> 
    </tr>    <tr> 
        <th class="index_name level0" >Age</th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row0" class="row_heading level0 row0" ><10</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row0_col0" class="data row0 col0" >3.32%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row0_col1" class="data row0 col1" >19</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row1" class="row_heading level0 row1" >10-14</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row1_col0" class="data row1 col0" >4.01%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row1_col1" class="data row1 col1" >23</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row2" class="row_heading level0 row2" >15-19</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row2_col0" class="data row2 col0" >17.45%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row2_col1" class="data row2 col1" >100</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row3" class="row_heading level0 row3" >20-24</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row3_col0" class="data row3 col0" >45.20%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row3_col1" class="data row3 col1" >259</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row4" class="row_heading level0 row4" >25-29</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row4_col0" class="data row4 col0" >15.18%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row4_col1" class="data row4 col1" >87</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row5" class="row_heading level0 row5" >30-34</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row5_col0" class="data row5 col0" >8.20%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row5_col1" class="data row5 col1" >47</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row6" class="row_heading level0 row6" >35-39</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row6_col0" class="data row6 col0" >4.71%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row6_col1" class="data row6 col1" >27</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row7" class="row_heading level0 row7" >40-44</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row7_col0" class="data row7 col0" >1.75%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row7_col1" class="data row7 col1" >10</td> 
    </tr>    <tr> 
        <th id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0level0_row8" class="row_heading level0 row8" >45-49</th> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row8_col0" class="data row8 col0" >0.17%</td> 
        <td id="T_fd013a0c_1906_11e8_8f0c_8c85908350c0row8_col1" class="data row8 col1" >1</td> 
    </tr></tbody> 
</table> 




```python
#Top Spenders 
sn_total_purchase = purchasedatabase_df.groupby('SN')['Price'].sum().to_frame()
sn_purchase_count = purchasedatabase_df.groupby('SN')['Price'].count().to_frame()
sn_purchase_avg = purchasedatabase_df.groupby('SN')['Price'].mean().to_frame()

sn_total_purchase.columns=["Total Purchase Value"]
join_1 = sn_total_purchase.join(sn_purchase_count, how="left")
join_1.columns=["Total Purchase Value", "Purchase Count"]

join_2 = join_1.join(sn_purchase_avg, how="inner")
join_2.columns=["Total Purchase Value", "Purchase Count", "Average Purchase Price"]

top_spenders_df = join_2[["Purchase Count", "Average Purchase Price", "Total Purchase Value"]]
top_spenders_final = top_spenders_df.sort_values('Total Purchase Value', ascending=False).head()
top_spenders_final.style.format({"Average Purchase Price": "${:.2f}", "Total Purchase Value": "${:.2f}"})
```




<style  type="text/css" >
</style>  
<table id="T_a2b01c94_1908_11e8_a803_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Purchase Count</th> 
        <th class="col_heading level0 col1" >Average Purchase Price</th> 
        <th class="col_heading level0 col2" >Total Purchase Value</th> 
    </tr>    <tr> 
        <th class="index_name level0" >SN</th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_a2b01c94_1908_11e8_a803_8c85908350c0level0_row0" class="row_heading level0 row0" >Undirrala66</th> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row0_col0" class="data row0 col0" >5</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row0_col1" class="data row0 col1" >$3.41</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row0_col2" class="data row0 col2" >$17.06</td> 
    </tr>    <tr> 
        <th id="T_a2b01c94_1908_11e8_a803_8c85908350c0level0_row1" class="row_heading level0 row1" >Saedue76</th> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row1_col0" class="data row1 col0" >4</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row1_col1" class="data row1 col1" >$3.39</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row1_col2" class="data row1 col2" >$13.56</td> 
    </tr>    <tr> 
        <th id="T_a2b01c94_1908_11e8_a803_8c85908350c0level0_row2" class="row_heading level0 row2" >Mindimnya67</th> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row2_col0" class="data row2 col0" >4</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row2_col1" class="data row2 col1" >$3.18</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row2_col2" class="data row2 col2" >$12.74</td> 
    </tr>    <tr> 
        <th id="T_a2b01c94_1908_11e8_a803_8c85908350c0level0_row3" class="row_heading level0 row3" >Haellysu29</th> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row3_col0" class="data row3 col0" >3</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row3_col1" class="data row3 col1" >$4.24</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row3_col2" class="data row3 col2" >$12.73</td> 
    </tr>    <tr> 
        <th id="T_a2b01c94_1908_11e8_a803_8c85908350c0level0_row4" class="row_heading level0 row4" >Eoda93</th> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row4_col0" class="data row4 col0" >3</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row4_col1" class="data row4 col1" >$3.86</td> 
        <td id="T_a2b01c94_1908_11e8_a803_8c85908350c0row4_col2" class="data row4 col2" >$11.58</td> 
    </tr></tbody> 
</table> 




```python
#Most Popular Items
mergeone = purchasedatabase_df.groupby("Item Name").sum().reset_index()
mergetwo = purchasedatabase_df.groupby("Item ID").sum().reset_index()
mergethree = purchasedatabase_df.groupby("Item Name").count().reset_index()

merge1 = pd.merge(mergeone, mergetwo, on="Price")
merge2 = pd.merge(mergethree, merge1, on="Item Name")

merge2["Gender"] = (merge2["Price_y"]/merge2["Item ID"]).round(2)

merge2_rename = merge2.rename(columns={"Age": "Purchase Count", "Gender": "Item Price", "Item ID": "null", "Price_y": "Total Purchase Value", "Item ID_y": "Item ID"})

clean_df = merge2_rename[["Item ID", "Item Name", "Purchase Count", "Item Price", "Total Purchase Value"]]

final_df = clean_df.set_index(['Item Name', 'Item ID'])
popular_items_final = final_df.sort_values('Purchase Count', ascending=False).head(6)
popular_items_final.style.format({"Item Price": "${:.2f}", "Total Purchase Value": "${:.2f}"})
```




<style  type="text/css" >
</style>  
<table id="T_ab80a3dc_190a_11e8_a646_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank" ></th> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Purchase Count</th> 
        <th class="col_heading level0 col1" >Item Price</th> 
        <th class="col_heading level0 col2" >Total Purchase Value</th> 
    </tr>    <tr> 
        <th class="index_name level0" >Item Name</th> 
        <th class="index_name level1" >Item ID</th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level0_row0" class="row_heading level0 row0" >Arcane Gem</th> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level1_row0" class="row_heading level1 row0" >84</th> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row0_col0" class="data row0 col0" >11</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row0_col1" class="data row0 col1" >$2.23</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row0_col2" class="data row0 col2" >$24.53</td> 
    </tr>    <tr> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level0_row1" class="row_heading level0 row1" >Betrayal, Whisper of Grieving Widows</th> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level1_row1" class="row_heading level1 row1" >39</th> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row1_col0" class="data row1 col0" >11</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row1_col1" class="data row1 col1" >$2.35</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row1_col2" class="data row1 col2" >$25.85</td> 
    </tr>    <tr> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level0_row2" class="row_heading level0 row2" >Trickster</th> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level1_row2" class="row_heading level1 row2" >31</th> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row2_col0" class="data row2 col0" >9</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row2_col1" class="data row2 col1" >$2.07</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row2_col2" class="data row2 col2" >$18.63</td> 
    </tr>    <tr> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level0_row3" class="row_heading level0 row3" >Woeful Adamantite Claymore</th> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level1_row3" class="row_heading level1 row3" >175</th> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row3_col0" class="data row3 col0" >9</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row3_col1" class="data row3 col1" >$1.24</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row3_col2" class="data row3 col2" >$11.16</td> 
    </tr>    <tr> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level0_row4" class="row_heading level0 row4" >Serenity</th> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level1_row4" class="row_heading level1 row4" >13</th> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row4_col0" class="data row4 col0" >9</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row4_col1" class="data row4 col1" >$1.49</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row4_col2" class="data row4 col2" >$13.41</td> 
    </tr>    <tr> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level0_row5" class="row_heading level0 row5" >Retribution Axe</th> 
        <th id="T_ab80a3dc_190a_11e8_a646_8c85908350c0level1_row5" class="row_heading level1 row5" >34</th> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row5_col0" class="data row5 col0" >9</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row5_col1" class="data row5 col1" >$4.14</td> 
        <td id="T_ab80a3dc_190a_11e8_a646_8c85908350c0row5_col2" class="data row5 col2" >$37.26</td> 
    </tr></tbody> 
</table> 




```python
#Most Profitable

profit_items_final = prefinal_df.sort_values('Total Purchase Value', ascending=False).head()
profit_items_final.style.format({"Item Price": "${:.2f}", "Total Purchase Value": "${:.2f}"})
```




<style  type="text/css" >
</style>  
<table id="T_ac63cedc_190a_11e8_bd40_8c85908350c0" > 
<thead>    <tr> 
        <th class="blank" ></th> 
        <th class="blank level0" ></th> 
        <th class="col_heading level0 col0" >Purchase Count</th> 
        <th class="col_heading level0 col1" >Item Price</th> 
        <th class="col_heading level0 col2" >Total Purchase Value</th> 
    </tr>    <tr> 
        <th class="index_name level0" >Item Name</th> 
        <th class="index_name level1" >Item ID</th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
        <th class="blank" ></th> 
    </tr></thead> 
<tbody>    <tr> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level0_row0" class="row_heading level0 row0" >Retribution Axe</th> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level1_row0" class="row_heading level1 row0" >34</th> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row0_col0" class="data row0 col0" >9</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row0_col1" class="data row0 col1" >$4.14</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row0_col2" class="data row0 col2" >$37.26</td> 
    </tr>    <tr> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level0_row1" class="row_heading level0 row1" >Spectral Diamond Doomblade</th> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level1_row1" class="row_heading level1 row1" >115</th> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row1_col0" class="data row1 col0" >7</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row1_col1" class="data row1 col1" >$4.25</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row1_col2" class="data row1 col2" >$29.75</td> 
    </tr>    <tr> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level0_row2" class="row_heading level0 row2" >Orenmir</th> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level1_row2" class="row_heading level1 row2" >32</th> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row2_col0" class="data row2 col0" >6</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row2_col1" class="data row2 col1" >$4.95</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row2_col2" class="data row2 col2" >$29.70</td> 
    </tr>    <tr> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level0_row3" class="row_heading level0 row3" >Singed Scalpel</th> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level1_row3" class="row_heading level1 row3" >103</th> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row3_col0" class="data row3 col0" >6</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row3_col1" class="data row3 col1" >$4.87</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row3_col2" class="data row3 col2" >$29.22</td> 
    </tr>    <tr> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level0_row4" class="row_heading level0 row4" >Splitter, Foe Of Subtlety</th> 
        <th id="T_ac63cedc_190a_11e8_bd40_8c85908350c0level1_row4" class="row_heading level1 row4" >107</th> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row4_col0" class="data row4 col0" >8</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row4_col1" class="data row4 col1" >$3.61</td> 
        <td id="T_ac63cedc_190a_11e8_bd40_8c85908350c0row4_col2" class="data row4 col2" >$28.88</td> 
    </tr></tbody> 
</table> 


