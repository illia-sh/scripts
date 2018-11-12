#### REMOVE BY QUERY 
```
POST indexname-2018.01.01/_delete_by_query
{
  "query": { 
    "bool" : {
      "must_not" : {
        "match_phrase" : {
          "key_field" : "key_value"
        }
      }
    }
  }
}
```

##### FIND DUPLICATES(COUNT) by 'id.keyword' field.

```
GET indexname-2018.01.01/_search
{
  "query": {
    "match_phrase" : {
            "myfieldkey" : "myfieldvalue"
        }
  },
  "size": 0,
  "aggs": {
    "duplicateCount": {
      "terms": {
        "field": "id.keyword",
        "min_doc_count": 2
      },
      "aggs": {
        "duplicateDocuments": {
          "top_hits": {
            
          }
        }
      }
    }
  }
}
```


