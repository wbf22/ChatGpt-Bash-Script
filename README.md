# ChatGpt-Bash-Script
Bash script to access chat gpt in the terminal.

# Usage
First set up an account with open ai and get an api key. https://platform.openai.com. You will probably have to set up billing as the api comes with a charge. Though if you use gpt 3.5 which this script uses, the cost will be almost nothing.
Open the `gpt.h` file or `mac-gpt.sh` file and set the `API_KEY` varaible to you key
```
# Set your OpenAI API key
API_KEY="sk-proj-*********************************"
```

The script uses the commands 'jq' and 'grep' as well as other common commands. Here's the shell commands to install jq if you don't have them:

Linux
```
sudo apt-get install jq
```

Mac
```
brew install jq
brew install grep
```

After that you should be able to run the script with this

Linux
```
sh gpt.sh
```

Mac ( ggrep instead of grep )
```
sh mac-gpt.sh
```
You might prefer to make an alias so you can call just `gpt` or something in your terminal.

In the script you alternate messages with chat gpt. If you'd like to include a file in your request, you can type the pound sign '#' and the path to your file. The contents of the file will then be appended to the front of your message. 
```
Hey chat can you look at this file? #/path/to/my/file.txt
```
(Right now we only support adding one file though. So you'll have to do seperate messages to add more than one)

Anyway hope this doesn't have too many bugs! enjoy
