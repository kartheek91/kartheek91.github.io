---
title: Convert Emojis to text and Emoticons to text using emot package
---

Here I will explain you how to convert emojis and emoticons to text.
```
data_path = "D:/nlp/HelperCodes/"
import sys
import re
import emot

sys.path.append(data_path)
from text_prep_config import UNICODE_EMO, EMOTICONS

def convert_emojis(text):
    for emot in UNICODE_EMO:
#        print("_".join(UNICODE_EMO[emot].replace(",", "").replace(":", "").split()))
        text = re.sub(r'(' + emot + ')', "_".join(UNICODE_EMO[emot].replace(",", "").replace(":", "").split()), text)
    return text

def convert_emoticons(text):
    for emot in EMOTICONS:
        text = re.sub(u'('+emot+')', "_".join(EMOTICONS[emot].replace(",","").split()), text)
    return text

def remove_emoji(string):
  emoji_pattern = re.compile("["
                       u"\U0001F600-\U0001F64F"  # emoticons
                       u"\U0001F300-\U0001F5FF"  # symbols & pictographs
                       u"\U0001F680-\U0001F6FF"  # transport & map symbols
                       u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
                       u"\U00002702-\U000027B0"
                       u"\U000024C2-\U0001F251"
                       "]+", flags=re.UNICODE)
  return emoji_pattern.sub(r'', string)

def remove_emoticons(text):
    emoticon_pattern = re.compile(u'(' + u'|'.join(k for k in EMOTICONS) + u')')
    return emoticon_pattern.sub(r'', text)

emoticons_text = "Hello :-) :-)"
emojis_text = "Game is on 🔥"

print("CONVERTING Emojis to Text:\n*\nInput: " + emojis_text +  "\n"+ "Output: " + convert_emojis(emojis_text) + "\n*")
print("CONVERTING Emoticons to Text:\n*\nInput: " + emoticons_text +  " \n" + "Output: " + convert_emoticons(emoticons_text) + "\n*")
print("Removing Emoticons in the Text:\n*\nInput: " + emoticons_text +  " \n" + "Output: " + remove_emoticons(emoticons_text)+ "\n*")
print("Removing  Emojis in the Text:\nInput: " + emojis_text +  " \n" + "Output: " + remove_emoji(emojis_text))

#Now we will use emot package that is designed by NeelShah

print(emot.emoji(emojis_text))
print(emot.emoticons(emoticons_text))

for code in emot.UNICODE_EMO:
    print( code  + emot.UNICODE_EMO[code] + "\n")
    
for code in emot.EMOTICONS:
    print( code  + "=" +  emot.EMOTICONS[code] + "\n")**
```
So here we  wrote a method called **convert_emojis** where it will accept a string and you will get the text corresponding to emoji and here is the output.
