#!/bin/bash

# Load environment variables from the .env file
if [ -f ~/.vim/.env ]; then
  source ~/.vim/.env
else
  echo "~/.vim/.env file containing OPENAI_API_KEY not found"
  exit 1
fi

# Inputs
API_KEY="$OPENAI_API_KEY"
MODEL="gpt-4o"
CONTENT="$1"
PROMPT="$2"
MAX_SIZE=3000  # Adjust based on token limits
MAX_PARALLEL=5  # Maximum number of parallel jobs

# Temporary directory for storing responses
RESPONSE_DIR=$(mktemp -d)
TEMP_FILE_PREFIX="$RESPONSE_DIR/response"

# Function to send a single chunk to the OpenAI API
function send_chunk {
    local chunk_content="$1"
    local index="$2"
    local temp_file="${TEMP_FILE_PREFIX}_${index}"

    # Create JSON payload using jq
    JSON_PAYLOAD=$(jq -nc \
        --arg content "$chunk_content" \
        --arg prompt "$PROMPT" \
        '{
            model: "gpt-4",
            messages: [
                {role: "system", content: $prompt},
                {role: "user", content: $content}
            ]
        }')

    # Send the request to the OpenAI API
    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content' > "$temp_file"
}

# Main logic to handle chunking
current_size=0
chunk=""
index=0
job_count=0
IFS=$'\n'  # Split by new line
for line in $CONTENT; do
    len=${#line}
    if (( current_size + len > MAX_SIZE )); then
        send_chunk "$chunk" "$index" &
        ((index++))
        ((job_count++))
        if (( job_count >= MAX_PARALLEL )); then
            wait  # Wait for all current jobs to finish
            job_count=0
        fi
        chunk=""
        current_size=0
    fi
    chunk+="$line\n"
    ((current_size += len + 1))  # +1 for the newline character
done

# Send any remaining content
if [[ -n "$chunk" ]]; then
    send_chunk "$chunk" "$index" &
fi

wait  # Ensure all background jobs finish

# Collect and output all responses in order
for file in $(ls "${RESPONSE_DIR}/response_"* | sort -V); do
    cat "$file"
done

# Clean up
rm -r "$RESPONSE_DIR"

