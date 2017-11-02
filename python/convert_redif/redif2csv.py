import json
import os
import pandas as pd

def redif2csv(redif_file):
    ''' A function that gets a ReDIF input and converts it to a CSV'''
    articles=[]
    article={}
    creators=[]
    creator={}
    for i in content:
        pair=i.split(':')
        j=i.replace(pair[0]+':','').strip()
        if pair[0].lower()=='template-type':
            if len(article)>0:
                article['ex:creator']=creators
                creators=[]
                articles.append(article)
            article={};
            article['ex:creator']=[]; article['ex:keywords']=[]; 
            article['@context']={}
            article['ex:template']=i
        elif pair[0].lower()=='author-name':
            if len(creator)>0:
                creators.append(creator)
            creator={}
            creator['ex:name']=j
        elif pair[0]=='Author-Email':
            creator['ex:email']=j
        elif pair[0]=='Author-Workplace-Name':
            creator['ex:affiliation']=j
        elif pair[0].lower()=='title':article['ex:title']=j
        elif pair[0].lower()=='year':article['ex:date']=j
        elif pair[0].lower()=='pages':article['ex:pages']=j
        elif pair[0].lower()=='volume':article['ex:volume']=j
        elif pair[0].lower()=='issue':article['ex:issue']=j
        elif pair[0].lower()=='file-url':article['ex:url']=j
        elif pair[0].lower()=='abstract':article['ex:abstract']=j
        elif pair[0].lower()=='keywords':article['ex:keywords']=[keyword.strip() for keyword in j.split(',')]
    jd=json.dumps(articles,ensure_ascii=False)
    jd = unicode(jd, 'utf-8',errors='ignore')
    jl=json.loads(jd,encoding='utf-8')
    df=pd.DataFrame(jl)
    csv_file=redif_file.replace('.rdf','.csv')
    df.to_csv(csv_file,encoding='utf-8')
    return (df)
#Run: put any number of ReDIF files in the current folder 
#Example: isre-0101-1704-BOM.rdf
for file_name in os.listdir('.'):
    if file_name[-4:]=='.rdf':
        print file_name
        with open(file_name) as f:
            content = f.readlines()
        # you may also want to remove whitespace characters like `\n` at the end of each line
        content = [x.strip() for x in content] 
        df=jsonld_file=redif2csv(file_name)

#check the first rows of your CSV
df.head(2)
