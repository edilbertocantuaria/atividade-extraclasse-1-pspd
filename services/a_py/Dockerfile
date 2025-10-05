FROM python:3.12-slim
WORKDIR /app

# Copia o proto e o servidor A
COPY proto /app/proto
COPY services/a_py /app/a_py

# Instala dependências
RUN pip install --no-cache-dir grpcio==1.63.0 grpcio-tools==1.63.0

# Gera os stubs
RUN python -m grpc_tools.protoc -Iproto --python_out=./proto --grpc_python_out=./proto proto/services.proto

# Torna 'proto' um pacote Python e ajusta PYTHONPATH
RUN touch /app/proto/__init__.py
ENV PYTHONPATH=/app:/app/proto

EXPOSE 50051
CMD ["python","a_py/server.py"]
