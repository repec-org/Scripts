# What is in RePEc?

One of the RePEc's main assets is a collection of 1,900 archives contributed by members from 93 countires (http://repec.org/)

So what is exactly in these archives?

## 1- ReDIF templates
Get a copy of ReDIF data using rsync 

rsync -va --delete rsync://rsync.repec.org/RePEc-ReDIF/ RePEc

List all files in the ReDIF data and their size

ls RePEc -lR --block-size=1kB | grep '^-'  > ls_ReDIF.txt

Analyze the list 
```python
import pandas as pd
data_path=<the path to ls_ReDIF.txt>
df=pd.read_table(data_path,header=None)
```


rsync -va --include="*/" --include="*.rdf" --include="*.redif" --exclude="*"  --delete rsync://rsync.repec.org/RePEc-ReDIF/ rdf
