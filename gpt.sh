#!/bin/bash

# Set your OpenAI API key
API_KEY="sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

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


  # Append user message to the conversation
  # conversation+=',{"role": "user", "content": "$user_input"}'
  #conversation='${conversation}
  user_line=',{"role": "user", "content": "'
  cat_value="$conversation$user_line$user_input"
  end_value='"}'
  conversation="$cat_value$end_value"

  echo "$conversation"

  body='{ "model": "gpt-3.5-turbo", "messages": '"$conversation]"', "max_tokens": 100}'

  echo "$body"

  # Make the API request
  response=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$body")

  echo $response

  # Extract the assistant's message
  # assistant_message=$(echo "$response" | grep -oP '"content": "\K[^"]+')
  # assistant_message=$(echo "$response" | grep -oP '"content": "\K(([^"\\]|\\.)+)(?=")')
  assistant_message=$(echo "$response" | grep -oP '"content": "\K(([^"]|\\")+)(?=")')

  # Print the assistant's message
  echo "ChatGPT: $assistant_message"

  # Append assistant's message to the conversation
  assist_line=',{"role": "assistant", "content": "'
  cat_value="$conversation$user_line$assistant_message"
  end_value='"}'
done
