# Step 1: Upgrade to Python SDK v1.2 with pip install --upgrade openai
# Step 2: Install Tavily Python SDK with pip install tavily-python
# Step 3: Build an OpenAI assistant with Python SDK documentation - https://platform.openai.com/docs/assistants/overview
#print_messages_from_thread(THREAD_ID)

import os
import json
import time
from openai import OpenAI
from tavily import TavilyClient

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
tavily_client = TavilyClient(api_key=os.environ["TAVILY_API_KEY"])

ASSISTANT_ID="asst_g5j7uiMOR1FwxDV37cwg8Xn4"

# Function to perform a Tavily search
def tavily_search(query):
    search_result = tavily_client.get_search_context(query, search_depth="advanced", max_tokens=8000)
    return search_result

# Function to wait for a run to complete
def wait_for_run_completion(thread_id, run_id):
    while True:
        time.sleep(1)
        run = client.beta.threads.runs.retrieve(thread_id=thread_id, run_id=run_id)
        print(f"Current run status: {run.status}")
        if run.status in ['completed', 'failed', 'requires_action']:
            return run

# Function to handle tool output submission
def submit_tool_outputs(thread_id, run_id, tools_to_call):
    tool_output_array = []
    for tool in tools_to_call:
        output = None
        tool_call_id = tool.id
        function_name = tool.function.name
        function_args = tool.function.arguments

        if function_name == "tavily_search":
            output = tavily_search(query=json.loads(function_args)["query"])

        if output:
            tool_output_array.append({"tool_call_id": tool_call_id, "output": output})

    return client.beta.threads.runs.submit_tool_outputs(
        thread_id=thread_id,
        run_id=run_id,
        tool_outputs=tool_output_array
    )

# Function to print messages from a thread
def getResponseFromThread(thread_id):
    messages = client.beta.threads.messages.list(thread_id=thread_id)
    return list(messages)[0].content[0].text.value


def postMessageThread(message,THREAD_ID, ASSISTANT_ID):
    run = client.beta.threads.runs.create(
        thread_id=THREAD_ID,
        assistant_id=ASSISTANT_ID,
    )
    run = wait_for_run_completion(THREAD_ID, run.id)
    if run.status == 'failed':
        print(run.error)
    elif run.status == 'requires_action':
        run = submit_tool_outputs(THREAD_ID, run.id, run.required_action.submit_tool_outputs.tool_calls)
        run = wait_for_run_completion(THREAD_ID, run.id)

def askQuestion(question):
    thread = client.beta.threads.create()
    message = client.beta.threads.messages.create(
        thread_id=thread.id,
        role="user",
        content=question,
    )
    postMessageThread(message,thread.id, ASSISTANT_ID)
    print(getResponseFromThread(thread.id))

def checkGenres(title, year):
    askQuestion(f"Can you give me a synopsis of the movie barbie 2023.")
