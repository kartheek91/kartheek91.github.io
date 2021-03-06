---
title: Hands-on Elasticsearch Specialized Queries
layout: post
date: '2021-05-02 21:52:30'
tags:
- ELasticSearch
---

Hi all, today we will learn about a couple of specialized queries in elasticsearch. This group contains queries that do not fit into the other groups:

***Pinned Query***  is one of the cool features of elasticsearch. To set the context,  I'm working on a medical product where I need to populate specific drugs based on the pharmacist's ease of use irrespective of the business logic in drug dropdown. So, for this problem statement, I came across this query which would be the exact solution.

**Let's create a sample mapping for demonstrating the pinned query**:

```
PUT drug_pinned
{
  "mappings": {
    "properties": {
      "drugname":{
        "type": "text"
      },
      "brand":{
        "type": "text"
      }
    }
  }
}
```

Now let's insert couple of documents to the drug_pinned index by using bulk api.

```
PUT drug_pinned/_bulk?refresh
{"index":{"_id":1}}
{"drugname":"abacavir sulphate","brand":"epzicom"}
{"index":{"_id":2}}
{"drugname":"lasix","brand":"furosemide"}
{"index":{"_id":3}}
{"drugname":"motrin","brand":"ibuprofen"}
{"index":{"_id":4}}
{"drugname":"atorvastatin","brand":"mactor"}
{"index":{"_id":5}}
{"drugname":"abilify","brand":"aripiprazole"}
```

Let's check whether documents got inserted or not by using this query.

```
GET drug_pinned/_search
```

**Output**:
```
   "hits" : [
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "abacavir sulphate",
          "brand" : "epzicom"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "lasix",
          "brand" : "furosemide"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "motrin",
          "brand" : "ibuprofen"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "atorvastatin",
          "brand" : "mactor"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "5",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "abilify",
          "brand" : "aripiprazole"
        }
      }
    ]
```

So, let's start writing a query to promote a set of documents to rank higher than those matching a given query.

**Query**:

```
GET drug_pinned/_search
{
  "query": {
    "pinned": {
      "ids": [
        2,
        4
      ],
      "organic": {
        "prefix": {
          "drugname": {
            "value": "ab"
          }
        }
      }
    }
  }
}
```
**Result**:

```
"hits" : [
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.7014124E38,
        "_source" : {
          "drugname" : "lasix",
          "brand" : "furosemide"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 1.7014122E38,
        "_source" : {
          "drugname" : "atorvastatin",
          "brand" : "mactor"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "abacavir sulphate",
          "brand" : "epzicom"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "5",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "abilify",
          "brand" : "aripiprazole"
        }
      }
    ]
```
In the results set, the second and fourth documents populated first.  Followed by the drugs which matched the query criteria i.e. drug name starts with ab. In this way, we can make use of **Pinned Query**.

**Wrapper Query**: A query that accepts any other query as base64 encoded string.

**Example**:
So let's convert the pinned query to a base64 encoded string. Will pass the string to the wrapper query.

**Query**:

```
GET drug_pinned/_search
{
  "query": {
    "wrapper": {
      "query": "IHsKICAgICJwaW5uZWQiOiB7CiAgICAgICJpZHMiOiBbCiAgICAgICAgMiwKICAgICAgICA0CiAgICAgIF0sCiAgICAgICJvcmdhbmljIjogewogICAgICAgICJwcmVmaXgiOiB7CiAgICAgICAgICAiZHJ1Z25hbWUiOiB7CiAgICAgICAgICAgICJ2YWx1ZSI6ICJhYiIKICAgICAgICAgIH0KICAgICAgICB9CiAgICAgIH0KICAgIH0KICB9"
    }
  }
}
```

**Result**:

```
 "hits" : [
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.7014124E38,
        "_source" : {
          "drugname" : "lasix",
          "brand" : "furosemide"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 1.7014122E38,
        "_source" : {
          "drugname" : "atorvastatin",
          "brand" : "mactor"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "abacavir sulphate",
          "brand" : "epzicom"
        }
      },
      {
        "_index" : "drug_pinned",
        "_type" : "_doc",
        "_id" : "5",
        "_score" : 1.0,
        "_source" : {
          "drugname" : "abilify",
          "brand" : "aripiprazole"
        }
      }
    ]
```
In this way, we can make use of **Wrapper  Query**.

**References**:

https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-wrapper-query.html#query-dsl-wrapper-query

https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-pinned-query.html


Thanks <br>
***Kartheek Gummaluri***

<div id="disqus_thread"></div>
<script>
    /**
    *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
    *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables    */
    /*
    var disqus_config = function () {
    this.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable
    this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };
    */
    (function() { // DON'T EDIT BELOW THIS LINE
    var d = document, s = d.createElement('script');
    s.src = 'https://https-kartheek91-github-io.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
