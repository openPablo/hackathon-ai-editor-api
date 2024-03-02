FROM python:3.11-bookworm
RUN pip3 install poetry
WORKDIR /app
COPY . /
EXPOSE 8000
RUN adduser pythonusr
RUN chown -R pythonusr:pythonusr /app/
USER pythonusr

RUN poetry install

ENTRYPOINT [ "poetry" ]
CMD [ "run","uvicorn", "--host", "0.0.0.0","vcpilotbackend.app:app" ]





