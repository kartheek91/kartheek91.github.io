---
title: Introduction to "Did You Mean " feature in ElasticSearch
layout: post
date: '2019-04-20 13:12:15 +0530'
categories: jekyll update
---

In this post I will explain you the different types of suggestors that elasticsearch is providing and I will give you brief about "Completion Suggestor".

There are 4 types of suggestors
* Term Suggestor
* Phrase Suggestor
* Completion Suggestor
* Context Suggestor

So in recent times I have used a completion suggestor in one of my projects.The completion suggester provides auto-complete/search-as-you-type functionality. This is a navigational feature to guide users to relevant results as they are typing, improving search precision. It is not meant for spell correction or did-you-mean functionality like the term or phrase suggester

I will expalin with a small example in understand better and here is the sample mapping

```
curl -XPUT "http://localhost:9200/sample" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "doc": {
      "properties": {
        "namesuggest": {
          "type": "completion",
          "analyzer": "standard",
          "preserve_separators": true,
          "preserve_position_increments": true,
          "max_input_length": 50
        },
        "fullname": {
          "type": "text"
        }
      }
    }
  }
}'
```

In the above mapping we defined completion suggestor and we have used standard analyzer,it provides grammar based tokenization (based on the Unicode Text Segmentation algorithm, as specified in Unicode Standard Annex #29) and works well for most languages.

Now we index few documents

```
PUT sample/doc/1?refresh
{
  "namesuggest": [
    {
      "input": "Kartheek Gummaluri",
      "weight": 10
    }
  ],
  "fullname": "Kartheek Gummaluri"
}

PUT sample/doc/2?refresh
{
  "namesuggest": [
    {
      "input": "Kiran Sangita",
      "weight": 6
    }
  ],
  "fullname": "Kiran Sangita"
}
```


So in the above document we have parameter called weight, so weight is used as relevancy tuning of search results.This helps us  which one needs to bubble up first.

Now we will write a sample query to get better idea

```
curl -XPOST "http://localhost:9200/sample/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "suggest": {
    "namesuggest": {
      "prefix": "k",
      "completion": {
        "field": "namesuggest"
      }
    }
  }
}'
```

So based on the above documents document-1 needs to be bubble up first because it has a weight of 10 where as the document -2 as weight 9.It will bubble up second.Please find results below.

```
{
  "took" : 8,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 0,
    "max_score" : 0.0,
    "hits" : [ ]
  },
  "suggest" : {
    "namesuggest" : [
      {
        "text" : "k",
        "offset" : 0,
        "length" : 1,
        "options" : [
          {
            "text" : "Kartheek Gummaluri",
            "_index" : "sample",
            "_type" : "doc",
            "_id" : "1",
            "_score" : 10.0,
            "_source" : {
              "namesuggest" : [
                {
                  "input" : "Kartheek Gummaluri",
                  "weight" : 10
                }
              ],
              "fullname" : "Kartheek Gummaluri"
            }
          },
          {
            "text" : "Kiran Sangita",
            "_index" : "sample",
            "_type" : "doc",
            "_id" : "2",
            "_score" : 6.0,
            "_source" : {
              "namesuggest" : [
                {
                  "input" : "Kiran Sangita",
                  "weight" : 6
                }
              ],
              "fullname" : "Kiran Sangita"
            }
          }
        ]
      }
    ]
  }
}
```

Thanks and stay tuned for further updates.