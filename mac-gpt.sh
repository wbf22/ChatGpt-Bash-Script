#!/bin/bash


# Set your OpenAI API key
API_KEY="sk-proj-***********************"








# SCRIPT BELOW


# check for verbose
verbose=false
if [ "$1" = "-v" ]; then 
  verbose=true
fi

# Initial system message
conversation=$(jq -n '[{"role": "system", "content": "You are a helpful assistant."}]')

while true; do
  # Read user input
  echo "\033[31m"
  read -p "You: " user_input
  echo "\033[0m"

  # Check if the user wants to clear the conversation
  if [ "$user_input" = "clear" ]; then
    echo "Conversation cleared."
    conversation=$(jq -n '[{"role": "system", "content": "You are a helpful assistant."}]')
    continue
  fi

  # check if conversation includes a file
  file_path=$(echo "$user_input" | ggrep -oP '#\K.*?(?=\s|$)')
  file_contents=""
  if [[ "$file_path" != "" ]]; then 
    # file_contents=$(cat "$file_path" | sed 's/"/\\"/g')
    file_contents=$(printf '```\n%s\n```' "$(cat "$file_path" | sed 's/"/\\"/g')")
  fi

  # Append user message to the conversation
  user_input=$(echo "$user_input" | sed 's/"/\\"/g')
  user_message=$(jq -n --arg content "$file_contents$user_input" '{"role": "user", "content": $content}')
  conversation=$(echo "$conversation" | jq --argjson message "$user_message" '. += [$message]' | tr -d '\n')

  if $verbose; then
    echo "$file_contents$user_input"
  fi

  body=$(jq -n \
          --arg model "gpt-3.5-turbo" \
          --argjson messages "$conversation" \
          --argjson max_tokens 1000 \
          '{model: $model, messages: $messages, max_tokens: $max_tokens}')


  # Make the API request
  response=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$body")

  # Check if the response contains an error
  if echo "$response" | tr -d '\n' | jq -e 'has("error")' > /dev/null; then
    echo "Error in response:"
    echo "$response" | jq '.error'
    echo $body
    echo $conversation
    conversation=$(jq -n '[{"role": "system", "content": "You are a helpful assistant."}]')
    continue
  fi

  if $verbose; then
    echo $body
    echo $response
  fi

  # Extract the assistant's message
  assistant_message=$(echo "$response" | ggrep -oPz '(?s)"content": "\K.*?[^\\](?=")')
  # assistant_message=$(echo "$response" | tr -d '\n' | jq -r '.choices[0].message.content') # this worked but removed new lines

  # Print the assistant's message
  echo "\033[32m"
  echo "ChatGPT: $assistant_message"
  echo "\033[0m"

  # Append assistant's message to the conversation
  assistant_message=$(echo "$assistant_message" | sed 's/\\"/<quote>/g')
  assistant_message_json=$(jq -n --arg content "$assistant_message" '{"role": "assistant", "content": $content}')
  assistant_message_json=$(echo "$assistant_message_json" | tr -d '\n')
  conversation=$(echo "$conversation" | jq --argjson message "$assistant_message_json" '. += [$message]')
done
