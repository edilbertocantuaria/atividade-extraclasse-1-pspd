# Projeto PSPD: Comunicação entre HTTP e gRPC com Kubernetes

Este repositório demonstra uma arquitetura de microsserviços onde um cliente Web se comunica com um gateway via HTTP, que por sua vez se comunica com dois serviços usando gRPC (A e B). Também incluímos versão REST equivalente para comparação.

---

## 🔧 Tecnologias usadas

- Node.js (HTTP + gRPC + REST)
- gRPC
- Kubernetes (Minikube)
- Docker
- curl

---

## 📦 Pré-requisitos

- WSL com Ubuntu
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) com suporte ao WSL ativado
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- `git`, `curl` e `make` instalados

---

## ▶️ Passo a passo funcional testado

### 0. Clonar o repositório e entrar na pasta
```bash
git clone https://github.com/edilbertocantuaria/atividade-extraclasse-1-pspd.git
cd atividade-extraclasse-1-pspd
```

### 1. Rodar o script de configuração completa
Esse script irá gerar todos os arquivos `YAML`, fazer build local das imagens e aplicar no cluster.
```bash
chmod +x setup.sh
./setup.sh
```

Esse script já cuida do build de todas as imagens com o Docker apontado para o Minikube via:
```bash
eval $(minikube -p minikube docker-env)
```

### 2. Expor os serviços: duas formas possíveis

#### ✅ Opção garantida (port-forward)
Obs.: rode cada linha em um terminal diferente
```bash
kubectl -n pspd port-forward svc/p-svc 8080:80
kubectl -n pspd port-forward svc/p-rest-svc 8081:80
```

Acesse:
- `http://localhost:8080` → Gateway gRPC
- `http://localhost:8081` → Gateway REST


## 3. Testar os serviços
```bash
curl "http://localhost:8080/a/hello?name=FernandoWilliam"
curl "http://localhost:8080/b/numbers?count=5&delay_ms=100"

curl "http://localhost:8081/a/hello?name=FernandoWilliam"
curl "http://localhost:8081/b/numbers?count=5&delay_ms=100"
```

## 4. Testes comparativos gRPC vs REST
Na raiz do projeto, execute
```bash
k6 run load/load_grpc_http.js
k6 run load/load_rest_http.js
```

---

## 📁 Estrutura do projeto
```
atividade-extraclasse-1-pspd/
├── services/               # Códigos dos serviços A e B (gRPC)
├── gateway_p_rest_node/    # Gateway REST
├── proto/                  # Arquivos .proto
├── k8s/                    # Arquivos YAML (gerados pelo script)
├── setup.sh                # Script completo de setup
└── README.md               # Este arquivo
```

---

## ✅ Status final esperado

- Todos os pods com status `Running`
- `http://localhost:8080` e `http://localhost:8081` funcionando
- Comunicação: HTTP → Gateway → Serviços via gRPC
