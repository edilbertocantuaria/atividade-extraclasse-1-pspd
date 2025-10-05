FROM python:3.12-slim
WORKDIR /app

# Dependências do gRPC (cache melhor)
RUN pip install --no-cache-dir grpcio==1.63.0 grpcio-tools==1.63.0

# Copia proto e o código do serviço a partir da RAIZ do repo
COPY proto/ /app/proto/
COPY services/a_py/ /app/a_py/

# Gera stubs para /app/proto
RUN python -m grpc_tools.protoc -Iproto \
    --python_out=./proto \
    --grpc_python_out=./proto \
    proto/services.proto

# Torna importável
RUN touch /app/proto/__init__.py
ENV PYTHONPATH=/app:/app/proto

EXPOSE 50051
CMD ["python","a_py/server.py"]
