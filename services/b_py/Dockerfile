FROM python:3.12-slim
WORKDIR /app

# 1) Dependências (melhor cache)
RUN pip install --no-cache-dir grpcio==1.63.0 grpcio-tools==1.63.0

# 2) Copia proto e o código do serviço a partir da RAIZ do repo
COPY proto/ /app/proto/
COPY services/b_py/ /app/b_py/

# 3) Gera stubs em /app/proto
RUN python -m grpc_tools.protoc -Iproto \
    --python_out=./proto \
    --grpc_python_out=./proto \
    proto/services.proto

# 4) Torna importável
RUN touch /app/proto/__init__.py
ENV PYTHONPATH=/app:/app/proto

EXPOSE 50052
CMD ["python","b_py/server.py"]
