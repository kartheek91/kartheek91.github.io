---
title: Painless Scripting Language-Series-1
layout: post
date: '2021-02-07 13:15:20'
tags:
- ELasticSearch
- Painless
---

Today we will learn about very intresting scripting language called **Painless**. So let's jump directy into the topic.

***Painless:***
It is a simple, secure scripting language designed specifically for use with Elasticsearch. It is the default scripting language for Elasticsearch and can safely be used for inline and stored scripts.In fact, most Painless scripts are also valid Groovy, and simple Groovy scripts are typically valid Painless.

Painless scripts are parsed and compiled using the ANTLR4 and ASM libraries. Painless scripts are compiled directly into Java byte code and executed against a standard Java Virtual Machine.
You can use Painless anywhere scripts are used in Elasticsearch. Painless provides:
* It is fast performance.
* Safety: Fine-grained allowlist with method call/field granularity.
* Optional typing: Variables and parameters can use explicit types or the dynamic def type.
* Syntax: Extends a subset of Java’s syntax to provide additional scripting language features.
* Optimizations: Designed specifically for Elasticsearch scripting.

***Painless Evolution:***
Since the earlier versions of ES, it supported scripting, but the scripting language has evolved over the ES releases. Starting with MVEL prior version 1.4, Groovy (post version 1.4), and now the latest entry ***Painless***  starting ES 5.0, the scripting in ES has evolved. A key reason for this evolution is for the above mentioned features.

Prior the release of ***Painless*** in ES 5.0, the majority of the security vulnerabilities that were reported in ES had to deal with vulnerabilities due to the scripting. Painless scripting language addresses these issues and is more secure, and faster than its predecessors. Starting ES 5.0, “Painless” is the default scripting language and its syntax is similar to **Groovy**.

This blog takes it a level further and explains the various usages of scripting that would be very handy.

Before we can start using the scripts lets understand the syntax of scripts in ES.

```
"script": {
 "lang": "...", 
 "inline" | "stored": "...",
 "params": { ... }
 }
```
As shown above, the script syntax consists of three parts:
1. The language the script is written in, which defaults to painless.
2. The script itself which may be specified as source for an inline script or id for a stored script.
3. Any named parameters that should be passed into the script.

Let’s illustrate how Painless works by loading some student stats into an Elasticsearch index:

```
PUT student/_bulk?refresh
{"index":{"_id":1}}
{"first_name":"kiran","last_name":"sangita","score":[9,27,1],"dob":"1980/08/13"}
{"index":{"_id":2}}
{"first_name":"kartheek","last_name":"gummaluri","score":[19,37,12],"dob":"1991/12/28"}
{"index":{"_id":3}}
{"first_name":"pavan","last_name":"arya","score":[22,12,34],"dob":"1989/01/22"}
{"index":{"_id":4}}
{"first_name":"murali","last_name":"sangita","score":[10,2,44],"dob":"1990/04/15"}
{"index":{"_id":5}}
{"first_name":"prudwi","last_name":"seeramreddi","score":[12,22,14],"dob":"1991/08/17"}
```
***Accessing Doc Values from Painless:***
Document values can be accessed from a Map named doc.

For example, the following script calculates a student’s total score who name start's with letter **K**. This example uses a strongly typed int and a for loop.
```
GET student/_search
{
  "query": {
    "prefix": {
      "first_name": {
        "value": "k"
      }
    }
  },
  "script_fields": {
    "total_score": {
      "script": {
        "lang": "painless",
        "source": """
          int total = 0;
          for (int i = 0; i < doc['score'].length; ++i) {
            total += doc['score'][i];
          
          }
          return total;
        """
      }
    }
  }
}
```
***Result***
```
 "hits" : [
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "fields" : {
          "total_score" : [
            37
          ]
        }
      },
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.0,
        "fields" : {
          "total_score" : [
            68
          ]
        }
      }
    ]
```
The following example uses a Painless script to sort the students by their combined first and last names. The names are accessed using doc['first_name'].keyword.value and doc['last_name'].keyword.value.
***Query***
```
GET student/_search
{
  "query": {
    "match_all": {}
  },
  "sort": {
    "_script": {
      "type": "string",
      "order": "asc",
      "script": {
        "lang": "painless",
        "source": "doc['first_name.keyword'].value + ' ' + doc['last_name.keyword'].value"
      }
    }
  }
}
```
***Result***
```
  "hits" : [
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : null,
        "_source" : {
          "first_name" : "kartheek",
          "last_name" : "gummaluri",
          "score" : [
            19,
            37,
            12
          ],
          "dob" : "1991/12/28"
        },
        "sort" : [
          "kartheek gummaluri"
        ]
      },
      {
        "_index" : "student",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : null,
        "_source" : {
          "first_name" : "kiran",
          "last_name" : "sangita",
          "score" : [
            9,
            27,
            1
          ],
          "dob" : "1980/08/13"
        },
        "sort" : [
          "kiran sangita"
        ]
      },....]
```
***Missing Values***

Now let learn how to query if we have missing values either in last_name, first_name.doc['field'].value throws an exception if the field is missing in a document.

To check if a document is missing a value, you can call doc['field'].size() == 0. So let's add another document in the **student** index.
```
PUT student/_doc/6
{"first_name":"bala","score":[11,33,12],"dob":"1971/04/21"}
```
If you observe in the above mentioned document we haven't specified **last_name** and now let's re-run the above mentioned query which concatenates first_name and last_name.

After executing the above mentioned query we end up with run time error.
```
{
        "shard": 0,
        "index": "student",
        "node": "993H1-V5Qk6Qc2nOoZ0iuw",
        "reason": {
          "type": "script_exception",
          "reason": "runtime error",
          "script_stack": [
            "org.elasticsearch.index.fielddata.ScriptDocValues$Strings.get(ScriptDocValues.java:496)",
            "org.elasticsearch.index.fielddata.ScriptDocValues$Strings.getValue(ScriptDocValues.java:503)",
            "doc['first_name.keyword'].value + ' ' + doc['last_name.keyword'].value",
            "                                                                ^---- HERE"
          ],
          "script": "doc['first_name.keyword'].value + ' ' + doc['last_name.keyword'].value",
          "lang": "painless",
          "caused_by": {
            "type": "illegal_state_exception",
            "reason": "A document doesn't have a value for a field! Use doc[<field>].size()==0 to check if a document is missing a field!"
          }
        }
      }
```
If you observe the reason session it clearly saying that we are trying to access document which doesn't have a value for a field. It is also providing recommendation for us.Now let's re-write the query.
```

GET student/_search
{
  "query": {
   "match_all": {}
  },
 "script_fields": {
   "full_name": {
     "script": {
       "lang": "painless",
        "source": """if(doc['last_name.keyword'].size()>0 && doc['first_name.keyword'].size()>0) {  return doc['first_name.keyword'].value + ' ' + doc['last_name.keyword'].value}"""
       
     }
   }
 }
}
```
This way we can overcome the above mentioned exception.Finally I will conclude with an important information and we can learn in depth in upcoming blogs.

The first time Elasticsearch sees a new script, it compiles it and stores the compiled version in a cache. Compilation can be a heavy process.

If you need to pass variables into the script, you should pass them in as named params instead of hard-coding values into the script itself. We will try to learn these topic in upcoming blog post with an real time example.

Thanks,<br>
***Kartheek Gummaluri***
