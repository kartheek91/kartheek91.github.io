---
title: Apache-NiFi-Series-1 GetFile and PutFile Processors
layout: post
tags:
- APACHE
- NIFI
date: '2020-08-03 21:00:06'
---

# Apache NiFi GetFile and PutFile Processors
Hi, In this post I’ll discuss on how to leverage  ***Get and Put File Processors*** using  ***Apache-NiF*i**

# Introduction 
***Apache NiFi*** is a real time data ingestion platform, which can transfer and manage data transfer between different sources and destination systems. It supports a wide variety of data formats like logs, geo location data, social feeds, etc. It also supports many protocols like SFTP, HDFS, and KAFKA, etc. This support to wide variety of data sources and protocols making this platform popular in many IT organizations.

So we will take two processors i.e. GetFile Processor, PutFile Processor and will try to establish relationship between two procesors. Our goal is to move the files from one location to another.

#  GetFile Processor
***GetFile Processor***  is used to fetch files of a specific format from a specific directory. It also provides other options to user for more control on fetching. We will discuss it in properties section below.So now we will add this processor.

# Steps to add this GetFile Processor to the WorkSpace
* Drag the processor icon from the  menu and you will see the following window.
	
![]({{ 'addProcessor.png' | relative_url }})

* Now we need to add GetFileProcessor, go to the top right corner and  in filter box type **GetFile** and  double click on the result then you willl processor getting added to the workspace.

![]({{ 'getFile1.png' | relative_url }})

*  Now we will set  ***GetFile Properties***  which is important and without we can't start the processor.

![]({{ 'getFile_Properties.png' | relative_url }})

* So the proeprties which are in bold are the mandatory properties, we need to set values for those properties without which we can't      start the processor. Let's fill the properties and click on the **Apply** button.

![]({{ 'getFile_Configuration.png' | relative_url }})

#  PutFile Processor
***PutFile Processor*** The PutFile processor is used to store the file from the data flow to a specific location. We will discuss it in properties section below.So now we will add this processor.

# Steps to add this PutFile Processor to the WorkSpace
* We can replicate the above mentioned steps and try to  filter it out by **PutFilter** double click on it and you will end up with this screen.
![]({{ 'getFile_putFile.png' | relative_url }})

* So the proeprties which are in bold are the mandatory properties, we need to set values for those properties without which we can't      start the processor. Let's fill the properties in properties tab and don't forget to check  ***sucess and failure***  in setting tab.
* Now click  **Apply** button.

![]({{ 'putfile_property.png' | relative_url }})
#  Create Connection 
*  Now we will create connection between two processors and we will end up with the following screen.

![]({{ 'createconnection.png' | relative_url }})

* Now we go to the input directory and I have copied **100 pdf  files**.

![]({{ 'input_directory.png' | relative_url }})

* Now we are ready to start the processors, in order to start the processors right click on the workspace and click start. Then we are are good to go. For our understanding i will start processors individually.

![]({{ 'input_processor_start.png' | relative_url }})

* So now we will see 100 items in the queue.

![]({{ 'quee100.png' | relative_url }})

* Now we will start **Put File Processor**.

![]({{ 'putoutput.png' | relative_url }})

* Finally now we will check  in the **Output Directory**.

![]({{ 'output_direcotry.png' | relative_url }})


So this how we will leverage **GetFile and PutFile Processors**  using **Apache NiFi**

Thanks,<br>
***Kartheek Gummaluri***
