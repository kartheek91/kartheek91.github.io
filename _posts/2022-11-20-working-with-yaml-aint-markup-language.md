---
title: Working with YAML Ain't Markup Language
layout: post
date: '2022-11-20 17:14:59'
tags:
- YAML
- DOCKER
- Kubernetes
- DevOps
---

# Storing data in multiple lines
Hello all, today I will share my knowledge regarding YAML.<br>
**YAML** is a superset of JSON. Any JSON file is a valid YAML file.
To work with Docker, K8s, Ansible, and Prometheus configuration files written in YAML. It is a widely used format for different DevOps tools and applications. It is a data serialization language that is human-readable and intuitive.<br>
**Indentation**: It is done with one or more spaces but not with tabs. <br>
**YAML Comment**:
```
# This is a first comment. 
```
<br>
**Key-Value Pairs**: This is indicated by colon and space. We can also key-value pairs as hash and dictionary.
```
"name": "Kartheek"
"designation": "Senior Software Engineer"
```
<br>
**Lists**:
```
---
# List of Programming languages
- Java
- C
- C#
...
```
<br>
**Block and Flow styles**:
```
# Block Style 
fruits:
 - apple
 - banana
 - guava
 # Flow Style
fruits: [apple, banana]

```
**Documents**:
*  One file can contain multiple documents.
*  Documents are seperated by 3 hyphens (---)  and ended with 3 dots (...)

```
"name": "Kartheek"
"designation": "Senior Software Engineer"
---
# List of Programming languages
- Java
- C
- C#
```
<br>
**Data types in YAML**:
* **Strings**: We can declare string variable in three different ways.
<br>
```
# String Variables
name: "Kartheek"
company: Sails software solutions
location: 'Vizag'
```
*  **Storing data in multiple lines**:
```
"bio": |
 This is Kartheek
 I'm very nice dude.
```
*  **Write a single line in multiple lines**: <br>
```
 # Write a single line in multiple lines
 "message": >
 This will
 be
 in whole single line
 ```
 It will be same as
 ```
# same as
"message1": "This will be in whole single line"
```
*  **Integer**: <br>
```
# Integer datatype
number: 5678
```
*  **Float**: <br>
```
# Float datatype
marks: 98.5
```
*  **Boolean**: <br>
```
# Boolean value
isDeployed: true
deployed: yes
isActive: on
```
<br>
**Specifying data types in YAML:** 
```
physics: !!int 98 
date: !!timestamp "2022-11-11"
time: !!timestamp "2001-12-15T02:59:43.1Z"
```
<br>
**Repeated Nodes:**  Keeping note of DRY principle. (Don't Repeat Yourself). We can use anchor name (&name) and then we can reference with alias (*name) .<br>
```
Name:  &myname Kartheek
myName: *myname
```
**Output:**
```
Name:
Kartheek
myName:
Kartheek
```
<br>
Finally, to validate the .yaml file we make use of this site.
[yamlint](http://www.yamllint.com/) <br>
Regards

***Kartheek Gummaluri***
