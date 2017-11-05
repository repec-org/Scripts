import logging

from eve import Eve
app = Eve()

def on_fetched_resource(resource, response):
    for document in response['_items']:
        del(document['_etag'])
        del(document['_created'])
	del(document['_updated'])
	del(document['_id'])        
# etc.

app = Eve()
app.on_fetched_resource += on_fetched_resource

if __name__ == '__main__':
	app.run(host='0.0.0.0')
