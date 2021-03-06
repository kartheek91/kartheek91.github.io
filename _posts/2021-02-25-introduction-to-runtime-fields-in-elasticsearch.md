---
title: Introduction to Runtime Fields in ElasticSearch
layout: post
date: '2021-02-25 08:53:15'
tags:
- ELasticSearch
---

Hi, all today I wanted to share with you one of the most awaited topics since I started learning elastic search. We used to have a product called **MyCareer.com** where we used elasticsearch and indexed around 20 million resumes. Every time due to the aggressive timelines and incremental development we are in a situation where we need to add a couple of properties to an existing index. Till now we have only one solution i.e adding new properties to the existing mapping, creating a new index based on the new mapping, and try to reindex the data by passing the source and destination index. It is a tedious job correct so that's the reason elasticsearch came up with **Data Streams** and  I will cover this topic in upcoming posts. In elasticsearch 7.11 release they came with a solution called Runtime Fields. Please make note that  it is available in  **Beta** 

**Runtime Fields**: A runtime field is a field that is evaluated at query time. It enables us with the following features i.e.

* Add fields to existing documents without reindexing your data
* Start working with your data without understanding how it’s structured
* Override the value returned from an indexed field at query time
* Define fields for a specific use without modifying the underlying schema

Queries against runtime fields are considered expensive. If search.**allow_expensive_queries is set to false**, expensive queries are not allowed and Elasticsearch will reject any queries against runtime fields.

**Advantages**:
* Runtime fields aren’t indexed, adding a runtime field doesn’t increase the index size.
*  We can define runtime fields directly in the index mapping, saving storage costs and increasing ingestion speed. 
* When you define a runtime field, you can immediately use it in search requests, aggregations, filtering, and sorting.

**Disadvantages** :
																					*Queries* against runtime fields can be expensive, so data that you commonly search or filter on should still be mapped to indexed fields. Runtime fields can also decrease search speed, even though your index size is smaller.

Now let's make our hands dirty by adding runtime fields.

Creating sample **employee** index:
```
PUT employee
{
  "mappings": {
    "dynamic": "runtime",
    "properties": {
      "name": {
        "type": "text",
        "fields": {
          "raw": {
            "type": "keyword"
          }
        }
      },
      "dob": {
        "type": "date",
        "format": "yyyy-MM-dd"
      }
    }
  }
}
```
Now we will check the employee mapping
```
GET employee/_mapping
Output:
{
  "employee" : {
    "mappings" : {
      "dynamic" : "runtime",
      "properties" : {
        "dob" : {
          "type" : "date",
          "format" : "yyyy-MM-dd"
        },
        "name" : {
          "type" : "text",
          "fields" : {
            "raw" : {
              "type" : "keyword"
            }
          }
        }
      }
    }
  }
}
```
So now we try to insert a couple of sample documents into the employee index.

```
PUT employee/_doc/1
{
  "name":"Kiran Sangita",
  "dob":"1980-04-01",
  "fullname":"kiran appaji sangita",
  "age":"45"
}
PUT employee/_doc/2
{
  "name":"Kartheek Gummaluri",
  "dob":"1991-12-28",
  "fullname":"Sai Srinivasa Kartheek Gummaluri",
  "age":"29"
}
PUT employee/_doc/3
{
  "name":"Pavan Kumar",
  "dob":"1980-12-28",
  "fullname":"Pavan Arya",
  "age":"34"
}
```

Now we will check mapping again and we will see age, full name as runtime fields.

```
GET employee/_mapping
Output: 
{
  "employee" : {
    "mappings" : {
      "dynamic" : "runtime",
      "runtime" : {
        "age" : {
          "type" : "keyword"
        },
        "fullname" : {
          "type" : "keyword"
        }
      },
      "properties" : {
        "dob" : {
          "type" : "date",
          "format" : "yyyy-MM-dd"
        },
        "name" : {
          "type" : "text",
          "fields" : {
            "raw" : {
              "type" : "keyword"
            }
          }
        }
      }
    }
  }
}
```

Now let's write a small query to search documents having an age greater than 29.
```
GET employee/_search
{
  "query": {
    "range": {
      "age": {
        "gt": 29
      }
    }
  }
}
```
Result:
```
"hits" : [
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "Kiran Sangita",
          "dob" : "1980-04-01",
          "fullname" : "kiran appaji sangita",
          "age" : "45"
        }
      },
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 1.0,
        "_source" : {
          "name" : "Pavan Kumar",
          "dob" : "1980-12-28",
          "fullname" : "Pavan Arya",
          "age" : "34"
        }
      }
    ]
```
This way we simply queried using runtime field and as mentioned earlier this field is not indexed but still, we can retrieve the results.

Now lets something new out of it like we can create the concatenation of two fields with a static string as follows:

```
GET employee/_search
{
  "runtime_mappings": {
    "concatenated_field": {
      "type": "keyword",
      "script": {
        "source": "emit(doc['fullname'].value + '_' +  doc['age'].value.toString())"
      }
    }
  },
  "fields": [
    "concatenated_field"
  ],
  "query": {
    "match": {
      "concatenated_field": "kiran appaji sangita_45"
    }
  }
}
```
We defined the field **concatenated_field** in the runtime_mappings section. We used a short Painless script that defines how the value of concatenated_field will be calculated per document (using + to indicate concatenation of the value of the full name field with the static string ‘:’ and the value of the age field). We then used the field concatenated_field in the query. When defining a Painless script to use with runtime fields, you must include emit to return calculated values.

Result:
```
"hits" : [
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "Kiran Sangita",
          "dob" : "1980-04-01",
          "fullname" : "kiran appaji sangita",
          "age" : "45"
        },
        "fields" : {
          "concatenated_field" : [
            "kiran appaji sangita_45"
          ]
        }
      }
    ]
```
If we find that **concatenated_field** is a field that we want to use in multiple queries without having to define it per query, we can simply add it to the mapping by making the call:

```
 PUT employee/_mapping
 {
   "runtime": {
     "concatenated_field": {
       "type": "keyword",
        "script": {
        "source": "emit(doc['fullname'].value + '_' +  doc['age'].value.toString())"
      }
     } 
   } 
 }
```
Now we will again check the mappings of the employee index, this time you will see **concatenated_field** will be added in the mapping.

***Output***: 
```
GET employee/_mapping
{
  "employee" : {
    "mappings" : {
      "dynamic" : "runtime",
      "runtime" : {
        "age" : {
          "type" : "keyword"
        },
        "concatenated_field" : {
          "type" : "keyword",
          "script" : {
            "source" : "emit(doc['fullname'].value + '_' +  doc['age'].value.toString())",
            "lang" : "painless"
          }
        },
        "fullname" : {
          "type" : "keyword"
        }
      },
      "properties" : {
        "dob" : {
          "type" : "date",
          "format" : "yyyy-MM-dd"
        },
        "name" : {
          "type" : "text",
          "fields" : {
            "raw" : {
              "type" : "keyword"
            }
          }
        }
      }
    }
  }
}
```
And then the query does not have to include the definition of the field, for example:

```
GET employee/_search
{
  "query": {
    "match": {
      "concatenated_field": "kiran appaji sangita_45"
    }
  }
}
```
Now let's see the result as I mentioned earlier we will not see **concatenated_field** in the source document.

***Output***:
```
 {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "Kiran Sangita",
          "dob" : "1980-04-01",
          "fullname" : "kiran appaji sangita",
          "age" : "45"
        }
      }
```
If we want to see **concatenated_field** then we need to specify implicitly in the **fields** section.

```
GET employee/_search
{
  "fields": [
    "concatenated_field"
  ],
  "query": {
    "match": {
      "concatenated_field": "kiran appaji sangita_45"
    }
  }
}
```
***Output***:
```
 "hits" : [
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "Kiran Sangita",
          "dob" : "1980-04-01",
          "fullname" : "kiran appaji sangita",
          "age" : "45"
        },
        "fields" : {
          "concatenated_field" : [
            "kiran appaji sangita_45"
          ]
        }
      }
    ]
```
This is how we can make use of **Runtime Fields**.

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