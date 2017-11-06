OPLOG=True
OPLOG_RETURN_EXTRA_FIELD=True
MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DBNAME= 'repec'

schema={
'serie_handle':{'type':'string'},
'serie_name':{'type':'string'},
'provider_name':{'type':'string'},
'items':{'type':'list'}
}

items_schema={
'serie_handle':{'type':'string'},
'title':{'type':'string'}
}

series={
    'datasource': {
        'source': 'series',
'projection':{'serie_handle':1,'serie_name':1,'provider_name':1},
},
'item_title':'serie',
    'additional_lookup': {
        'url': 'regex("[\w]+")',
        'field': 'serie_handle'
    },
'schema':schema
}

serie_items = {
    'datasource': {
        'source': 'series',
'projection':{'serie_handle':1,'items':1},

},
'item_title':'items',
'resource_title':'items',
    'url': 'series/<regex("[\w]+"):serie_handle>/items',
'schema':schema
}

items={
'datasource':{
'source':'items'
},
'schema':items_schema
}



DOMAIN={
'series':series,
'serie_items':serie_items,
'items':items,
}
