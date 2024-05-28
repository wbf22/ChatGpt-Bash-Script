#!/bin/bash


# Set your OpenAI API key
API_KEY="sk-proj-xxxxxxxxxxxxxxxxxxx"








# SCRIPT BELOW


# check for verbose
verbose=false
if [ "$1" = "-v" ]; then 
  verbose=true
fi

# Initial system message
conversation='[{"role": "system", "content": "You are a helpful assistant."}'

while true; do
  # Read user input
  read -p "You: " user_input

  # Check if the user wants to clear the conversation
  if [ "$user_input" = "clear" ]; then
    echo "Conversation cleared."
    conversation='[{"role": "system", "content": "You are a helpful assistant."}'
    continue
  fi

  # check if conversation includes a file
  file_path=$(echo "$user_input" | ggrep -oP '#\K.*?(?=\s|$)')
  file_contents=""
  if [[ "$file_path" != "" ]]; then 
    file_contents=$(cat "$file_path" | sed 's/"/\\"/g')
  fi

  # #test Hey chat, what does this bash file do?

  # Append user message to the conversation
  # conversation+=',{"role": "user", "content": "$user_input"}'
  #conversation='${conversation}
  user_line=',{"role": "user", "content": "'
  user_input=$(echo "$user_input" | sed 's/"/\\"/g')
  cat_value="$conversation$user_line$file_contents$user_input"
  end_value='"}'
  conversation="$cat_value$end_value"

  if $verbose; then
    echo "$file_contents$user_input"
  fi

  body='{ "model": "gpt-3.5-turbo", "messages": '"$conversation]"', "max_tokens": 1000}'

  # Make the API request
  response=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$body")


  if $verbose; then
    echo $body
    echo $response
  fi

  # Extract the assistant's message
  # assistant_message=$(echo "$response" | grep -oP '"content": "\K[^"]+')
  # assistant_message=$(echo "$response" | grep -oP '"content": "\K(([^"\\]|\\.)+)(?=")')
  # ggrep -oP '(?<=X)Y'
  assistant_message=$(echo "$response" | ggrep -oPz '(?s)"content": "\K.*?[^\\](?=")')

  # match until " and not \"

  # Print the assistant's message
  echo "ChatGPT: $assistant_message"

  # Append assistant's message to the conversation
  assist_line=',{"role": "assistant", "content": "'
  cat_value="$conversation$user_line$assistant_message"
  end_value='"}'
done
