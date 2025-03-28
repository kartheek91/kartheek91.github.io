---
title: Hands-on Elasticsearch Search Templates
layout: post
date: '2021-07-13 22:00:53'
tags:
- ELasticSearch
---

Hello all, today I'm going to share my knowledge regarding Search Templates in Elasticsearch.Today when I'm going through the  Elastic documentation randomly, I got attention to this feature. I thought if I  could share my thoughts on this feature, it would be very informative for the audience who were working on the ELK stack.

**Search Templates**: A search template is a stored search you can run with different variables.
Let's consider a real-world example where we have two indices employee and the address. We need to populate the default results set when the user clicks on these menu items. The results set should be in descending order and need to show the top 5 documents. These are the criteria that apply to most of the functionalities.

**Solution**:
We will write a filtered search query for an employee as well as the address indices. We will get the top 5 documents.  For example, your functionality needs documents from ten different indices based on the same criteria. So, here we will pass the same filters for ten indices.

**Optimistic Solution**:
We will create a search template by binding the search criteria. Then we will validate the search template. Once validation is successful,  then we will run a template search.

**Creating a Search Template**:
```
PUT _scripts/indices-default-template
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "match_all": {}
      },
      "from": "{{from}}",
      "size": "{{size}}"
    },
    "params": {
      "query_string": "My query string"
    }
  }
}
```
Search templates must use a lang of **mustache**, typically enclosed in double curly brackets: {{my-var}}

**Validating Search Template**
We can validate the search template before executing it. It will give us some insights into your query structure. So that we can modify the template if we have any issues. Let's validate our query.

**Query**:

```
POST _render/template
{
  "source": {
    "query": {
      "match_all": {}
    },
    "from": "{{from}}",
    "size": "{{size}}"
  },
  "params": {
    "from": 20,
    "size": 10
  }
}
```

**Output**:

```
{
  "template_output" : {
    "query" : {
      "match_all" : { }
    },
    "from" : "1",
    "size" : "3"
  }
}
```
**Running the template search**:
Now we will pass index name, template-id, and params for the template search query. We can specify different params for each request based on our requirement.
**Query**:

```
GET employee/_search/template
{
  "id": "indices-default-template",
  "params": {
    "from": 0,
    "size": 2
  }
}
```

Here we are querying employee index with template id i**ndices-default template** and having params from and size as o,2. It means we are asking elasticsearch to fetch two documents with offset as zero.

**Result**:
```
"hits" : {
    "total" : {
      "value" : 4,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "name" : "Murali Sangita",
          "company" : "Sails Software Solutions",
          "age" : 28,
          "experience" : 5,
          "skills" : [
            "angular",
            "aws"
          ],
          "role" : "Senior Software Engineer"
        }
      },
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "Kiran Sangita",
          "company" : "Sails Software Solutions",
          "age" : 50,
          "experience" : 20,
          "skills" : [
            "c#",
            "ELK",
            "Azure"
          ],
          "role" : "CEO"
        }
      }
    ]
  }
```
This way, we can make use of this feature efficiently. Let's call this search template with another index **student**. 
**Query**:

```
GET student/_search/template
{
  "id": "indices-default-template",
  "params": {
    "from": 0,
    "size": 4
  }
}
```
**Result**:

```
"hits" : {
    "total" : {
      "value" : 4,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "Kiran Sangita",
          "class" : "5"
        }
      },
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "name" : "Murali Sangita",
          "class" : "8"
        }
      },
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 1.0,
        "_source" : {
          "name" : "Pavan arya",
          "class" : "12"
        }
      },
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 1.0,
        "_source" : {
          "name" : "kartheek gummaluri",
          "class" : "1"
        }
      }
    ]
  }
```
This way,  we are making use of this search template for multiple indices.
Now let's create another complex search template.
```
PUT _scripts/employee-template
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "company": "{{company}}"
              }
            },
            {
              "range": {
                "experience": {
                  "gt": "{{experience}}"
                }
              }
            }
          ]
        }
      }
    }
  },
  "params": {
    "company": "{{company}}",
    "experience": "{{experience}}"
  }
}
```
**Query**:

```
GET employee/_search/template
{
  "id": "employee-template",
  "params": {
    "company": "sails",
    "experience": 10
  }
}
```

**Result**:
```
"hits" : [
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0870113,
        "_source" : {
          "name" : "Kiran Sangita",
          "company" : "Sails Software Solutions",
          "age" : 50,
          "experience" : 20,
          "skills" : [
            "c#",
            "ELK",
            "Azure"
          ],
          "role" : "CEO"
        }
      },
      {
        "_index" : "employee",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 1.0870113,
        "_source" : {
          "name" : "Pavan Arya",
          "company" : "Sails Software Solutions",
          "age" : 35,
          "experience" : 16,
          "skills" : [
            "elk",
            "aws",
            "azure",
            "c#",
            "docker",
            "Kubernetes"
          ],
          "role" : "CTO"
        }
      }
    ]
```
Here we wrote a query to fetch results, having experience greater than **ten years **and employee should belong to **Sails Software Solutions**.

**To retrieve all Search templated within the cluster**:
```
GET _cluster/state/metadata?pretty&filter_path=metadata.stored_scripts
```
**Result**:

```
{
  "metadata" : {
    "stored_scripts" : {
      "candidate-template" : {
        "lang" : "mustache",
        "source" : """{"query":{"match":{"company":"{{query_string}}"}},"from":"{{from}}","size":"{{size}}"}""",
        "options" : {
          "content_type" : "application/json; charset=UTF-8"
        }
      },
      "indices-default-template" : {
        "lang" : "mustache",
        "source" : """{"query":{"match_all":{}},"from":"{{from}}","size":"{{size}}"}""",
        "options" : {
          "content_type" : "application/json; charset=UTF-8"
        }
      },
      "employee-template" : {
        "lang" : "mustache",
        "source" : """{"query":{"bool":{"must":[{"match":{"company":"{{company}}"}},{"range":{"experience":{"gt":"{{experience}}"}}}]}}}""",
        "options" : {
          "content_type" : "application/json; charset=UTF-8"
        }
      }
    }
  }
}
```

We can explore a lot in this topic, but the above-mentioned examples are more than enough to get started. You can explore from here on your own in order to make your hands dirty. Please check out this link for further reference
https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html#search-template

Regards
***Kartheek G***
