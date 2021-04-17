---
title: Hands-on Verbatim Query Usage in elasticsearch using NEST.Net client
layout: post
date: '2021-04-17 13:50:56'
tags:
- ELasticSearch
- c#
- NEST
---

To get started with the usage of **Verbatim**, I will set some context so that everybody will be on the same page. I came across a challenge where we need to fetch the results of an employee having an address as an empty string.

So I created an index called sample with the following mapping with defaults primary and replica shards with  1.

**Mapping:**
```
PUT sample
{
  "sample" : {
    "mappings" : {
      "properties" : {
        "address" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "name" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "role" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    }
  }
}
```

Now we need to insert a couple of documents into the sample index. Once we completed indexing in the sample index.  We can check whether documents got created or not by using the below-mentioned query.

```
GET sample/_search
```

Result:
```
"hits" : [
      {
        "_index" : "sample",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "kiran sangita",
          "address" : "visalakshinagar",
          "role" : "CEO"
        }
      },
      {
        "_index" : "sample",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "name" : "pavan arya",
          "address" : "",
          "role" : "architect"
        }
      },
      {
        "_index" : "sample",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 1.0,
        "_source" : {
          "name" : "kartheek gummaluri",
          "address" : "",
          "role" : "developer"
        }
      },
      {
        "_index" : "sample",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 1.0,
        "_source" : {
          "name" : "pavan arya",
          "address" : "chinnamushidiwada",
          "role" : "developer"
        }
      }
    ]
```
Now we need to write a query to fetch a document having name="pavan arya" and adress= ""

**Query**:
```
GET sample/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "bool": {
          "must": [
            {
              "term": {
                "name.keyword": {
                  "value": "pavan arya"
                }
              }
            },
            {
              "term":{
                "address.keyword":""
              }
            }
          ]
        }
      }
    }
  }
}
```
**Output**:


	"hits" : [
		{
			"_index" : "sample",
			"_type" : "_doc",
			"_id" : "2",
			"_score" : 1.0,
			"_source" : {
				"name" : "pavan arya",
				"address" : "",
				"role" : "architect"
			}
		}
	]

We can see the accurate result based on the filter criteria in the above result. But the actual problem is with the NEST client when we try to write the same query in the c# Nest client we are not able to add a filter with empty string criteria.

So I wrote a small method in the c# console application, to search the sample index with the above-mentioned filters. 

```
 public async Task<bool> VerbatimExample()
        {
            
            var searchResults = await _repository.EsClient().SearchAsync<SampleViewModel>(s => s
             .Index("sample")
             .Query(q => q
                 .ConstantScore(c => c
                     .Filter(f => f
                         .Bool(b => b
                             .Must(m => m.Term(t => t.Field("address.keyword").Value(string.Empty)) &&
                                        m.Term(t=> t.Field("name.keyword").Value("pavan arya"))))))));
            if (searchResults.IsValid)
            {
                foreach (var dcoument in searchResults.Documents)
                {
                    Console.WriteLine(Newtonsoft.Json.JsonConvert.SerializeObject(dcoument, Formatting.Indented));
                }
                return true;
            }
            return false;
        }


        public class SampleViewModel
        {
            public string name { get; set; }
            public string role { get; set; }
            public string address { get; set; }
        }
```

Result from the above method:

![]({{ 'output.png' | relative_url }})

But actually, we need to get only one document rather than we got two documents. Let check how the high-level NEST client internally framed the above-mentioned query.

![]({{ 'debug.png' | relative_url }})

In the above image in the request section, we are not able to see the address filter that we added in our query. Elastic Nest client will follow some conditional checks during the query conversion so that's the reason we are unable to see the address filter in the above-mentioned query.

For me, it took a good amount of time to find the solution. I posted in the elasticsearch forum for the same. I have gone through the .NET elasticsearch NEST API documentation, there we have a section called NEST Specific Queries in that I found **Verbatim** **Query**. 

**Verbatim** 
A verbatim query will be serialized and sent in the request to Elasticsearch, bypassing NEST’s conditionless checks.

So let's add Verbatim to the existing query.

```
  var searchResults = await _repository.EsClient().SearchAsync<SampleViewModel>(s => s
             .Index("sample")
             .Query(q => q
                 .ConstantScore(c => c
                     .Filter(f => f
                         .Bool(b => b
                             .Must(m => m.Term(t => t.Field("address.keyword").Value(string.Empty).Verbatim()) &&
                                        m.Term(t=> t.Field("name.keyword").Value("pavan arya"))))))));
```

![]({{ 'output1.png' | relative_url }})

Now, we can see the address filter and we got accurate results from the query.

**Output:**

![]({{ 'output2.png' | relative_url }})

This way we can make use of Verbatim Query. <br>

**References**: <br>
{%https://www.elastic.co/guide/en/elasticsearch/client/net-api/current/verbatim-and-strict-query-usage.html#verbatim-and-strict-query-usage%}

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
