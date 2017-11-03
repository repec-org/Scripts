# What is in RePEc?

One of the RePEc's main assets is a collection of 1,900 archives contributed by members from 93 countires (http://repec.org/)

So what is exactly in these archives?

## 1- ReDIF templates
Get a copy of ReDIF data using rsync (http://rsync.repec.org/)

```bash 
rsync -va --delete rsync://rsync.repec.org/RePEc-ReDIF/ RePEc
```

List all files in the ReDIF data and their size

```bash
ls RePEc -lR --block-size=1kB | grep '^-'  > ls_ReDIF.txt
```

### Analyze the list 
read the data
```python
import pandas as pd
data_path='../../../../data/ls_ReFID.txt'
df=pd.read_table(data_path,header=None)
```
clean the data
```python
df=df[:-1]
df['split']=df[0].apply(lambda x: x.split())
df['size']=df[0].apply(lambda x: x.split()[4]).astype(int)
df['ext']=df.split.apply(lambda x : x[-1].split('.')[-1])
```
aggregate by extension
```python
dg=df[['ext','size']].groupby('ext').agg(['count','sum'])
dg['size']['sum']=(dg['size']['sum']/1024/1024).round(1)
dg.columns=['Numver of files','Total size of files (GB)']
dg.sort_values([('Total size of files (GB)')],ascending=False).head(10)
```

rsync -va --include="*/" --include="*.rdf" --include="*.redif" --exclude="*"  --delete rsync://rsync.repec.org/RePEc-ReDIF/ rdf
