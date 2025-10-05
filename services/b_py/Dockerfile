FROM python:3.12-slim
WORKDIR /app

COPY proto /app/proto
COPY services/b_py /app/b_py

RUN pip install --no-cache-dir grpcio==1.63.0 grpcio-tools==1.63.0

RUN python -m grpc_tools.protoc -Iproto --python_out=./proto --grpc_python_out=./proto proto/services.proto

RUN touch /app/proto/__init__.py
ENV PYTHONPATH=/app:/app/proto

EXPOSE 50052
CMD ["python","b_py/server.py"]
