import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
thread = client.beta.threads.create()
print(f"Thread: {thread}")