FROM python:3.12

WORKDIR /src
COPY requirements.txt /src
RUN pip3 install -r requirements.txt

COPY server.py /src

CMD ["python3", "server.py"]