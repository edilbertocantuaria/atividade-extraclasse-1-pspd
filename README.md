# Placeholder README

# REST Variant & Load Tests (Addendum)

## Build REST images (inside minikube docker-env)
```bash
docker build -t a-rest-service:local -f services/a_rest/Dockerfile services/a_rest
docker build -t b-rest-service:local -f services/b_rest/Dockerfile services/b_rest
docker build -t p-rest-gateway:local -f gateway_p_rest_node/Dockerfile gateway_p_rest_node
```

## Deploy REST stack
```bash
kubectl apply -f k8s/rest/a-rest.yaml
kubectl apply -f k8s/rest/b-rest.yaml
kubectl apply -f k8s/rest/p-rest.yaml
minikube addons enable ingress   # se ainda não fez
kubectl apply -f k8s/rest/ingress-rest.yaml
```

## /etc/hosts
Adicione também:
```
<minikube_ip> pspd-rest.local
```

## Testar REST
```
http://pspd-rest.local/
http://pspd-rest.local/a/hello?name=Edilberto
http://pspd-rest.local/b/numbers?count=10&delay_ms=50
```

## Rodar k6 (comparar gRPC-backed x REST)
# gRPC (via Gateway P HTTP)
k6 run load/load_grpc_http.js

# REST (via Gateway P-REST HTTP)
k6 run load/load_rest_http.js

# Copie média, p(95) e RPS para uma tabela do relatório.
# atividade-extraclasse-1-pspd
# atividade-extraclasse-1-pspd
