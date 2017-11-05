OPLOG=True
OPLOG_RETURN_EXTRA_FIELD=True
MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DBNAME= 'repec'

schema={
'seriehandle':{'type':'string'},
'seriename':{'type':'string'},
'providername':{'type':'string'},
'items':{'type':'list'}
}

series={
    'datasource': {
        'source': 'series',
'projection':{'seriehandle':1,'seriename':1,'providername':1},
},
'item_title':'serie',
    'additional_lookup': {
        'url': 'regex("[\w]+")',
        'field': 'seriehandle'
    },
'schema':schema
}

items = {
    'datasource': {
        'source': 'series',
'projection':{'seriehandle':1,'items':1},

},
'item_title':'items',
'resource_title':'items',
    'url': 'series/<regex("[\w]+"):seriehandle>/items',
'schema':schema
}

DOMAIN={
'series':series,
'items':items
}
