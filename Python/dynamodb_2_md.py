from __future__ import print_function # Python 2/3 compatibility
import boto3
import json
import decimal
from boto3.dynamodb.conditions import Key, Attr

# Helper class to convert a DynamoDB item to JSON.
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

dynamodb = boto3.resource('dynamodb') # may require parameters if not using default AWS environment vars
table = dynamodb.Table('gitlab-ci')

items=[]
line=[]
output=[]

response = table.scan()
get_keys = list(response['Items'][0].keys())

for i in response['Items']:
    items.append((json.dumps(i, cls=DecimalEncoder)))

i=0
for item in items:
    item = json.loads(item)
    for header in get_keys:
        i=i+1
        line.append(item[header])
        if i%len(get_keys) == 0:
            output.append(line)
            line=[]

def make_markdown_table(array):
    markdown = "\n" + str("| ")

    for e in array[0]:
        to_add = " " + str(e) + str(" |")
        markdown += to_add
    markdown += "\n"

    markdown += '|'
    for i in range(len(array[0])):
        markdown += str("-------------- | ")
    markdown += "\n"

    for entry in array[1:]:
        markdown += str("| ")
        for e in entry:
            to_add = str(e) + str(" | ")
            markdown += to_add
        markdown += "\n"

    return markdown + "\n"

output.insert(0,get_keys)
f = open('items.md', 'a')
f.write(make_markdown_table(output))
f.close()
