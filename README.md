# 🧩 Projeto PSPD: Comunicação entre HTTP e gRPC com Kubernetes

Este repositório demonstra uma arquitetura de microsserviços onde um cliente Web se comunica com um gateway via **HTTP**, que por sua vez se comunica com dois serviços backend via **gRPC (A e B)**.  
Também foi implementada uma versão equivalente em **REST** para fins de comparação de desempenho.

---

## 🔧 Tecnologias usadas

- **Node.js** (Gateway HTTP + gRPC + REST)
- **Python / FastAPI / gRPC**
- **Protocol Buffers (Protobuf)**
- **Kubernetes (Minikube)**
- **Docker**
- **k6** (teste de carga)
- **Matplotlib / Python** (análise gráfica de desempenho)

---

## 📦 Pré-requisitos

- WSL com Ubuntu
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) com suporte ao WSL ativado
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [k6](https://grafana.com/docs/k6/latest/) instalado
- Python 3.12+ com `matplotlib` e `pandas`

---

## ▶️ Execução completa do projeto

### 1️⃣ Clonar e configurar

```bash
git clone https://github.com/edilbertocantuaria/atividade-extraclasse-1-pspd.git
cd atividade-extraclasse-1-pspd
chmod +x setup.sh
```

### 2️⃣ Rodar o script principal

Cria os manifests Kubernetes, builda as imagens e aplica no cluster:

```bash
./setup.sh
```

O script realiza:
- Build automático das imagens Docker
- Configuração do namespace `pspd`
- Deploy dos pods e services (A, B, P, REST)
- Habilitação do Ingress Controller

---

## 🌐 Acesso aos serviços

### ✅ Opção garantida (port-forward)
```bash
kubectl -n pspd port-forward svc/p-svc 8080:80
kubectl -n pspd port-forward svc/p-rest-svc 8081:80
```

Acesse:
- gRPC Gateway → http://localhost:8080  
- REST Gateway → http://localhost:8081

### 🧪 Opção via Minikube (domínios locais)

Verifique o IP:
```bash
minikube ip
```

Adicione no arquivo `hosts`:
```
192.168.49.2 pspd.local
192.168.49.2 pspd-rest.local
```

---

## ⚙️ Testes de carga e desempenho

Foram realizados testes de desempenho com o **k6** para comparar o comportamento das versões **gRPC** e **REST** sob diferentes níveis de carga (20 e 100 usuários simultâneos).

### 🔹 Teste gRPC
```bash
k6 run load_grpc_http.js
```

### 🔹 Teste REST
```bash
k6 run load_rest_http.js
```

Cada teste executa durante **30 segundos**, simulando múltiplos usuários acessando:
- `/a/hello` (requisição unária)
- `/b/numbers` (requisição streaming)

---

## 📊 Resultados dos testes

| Métrica | gRPC (100 VUs) | REST (100 VUs) |
|----------|----------------|----------------|
| Duração | 30 s | 30 s |
| Requisições processadas | 10.462 | 21.352 |
| Taxa média (req/s) | 355,9 | 735,8 |
| Latência média | 281,56 ms | 139,42 ms |
| Falhas | 0% | 0% |
| Dados recebidos | 3,2 MB | 6,4 MB |

📈 Os resultados mostram que:
- REST tem menor latência e maior taxa de requisições por segundo (vantagem no acesso externo).
- gRPC é mais eficiente internamente, com metade do volume de dados transmitidos.
- Ambos os sistemas mantiveram 0% de falhas, comprovando a estabilidade da orquestração Kubernetes.

---

## 📉 Geração de gráficos comparativos

Todos os resultados são registrados automaticamente em `test_results/` após cada execução.  
Para gerar gráficos de desempenho:

```bash
python test_results/plot_results.py
```

Isso cria figuras em `.png` com:
- **Latência média (ms)**
- **Throughput (req/s)**
- **Volume de dados transmitidos**

Os gráficos ajudam a visualizar o impacto do aumento de usuários simultâneos e o comportamento de cada protocolo.

---

## 🧠 Conclusões

- O **REST** se mostrou mais rápido do ponto de vista do cliente externo.
- O **gRPC** mantém **eficiência binária e estabilidade interna** mesmo sob alta carga.
- A arquitetura híbrida usada (REST + gRPC) une **acessibilidade e desempenho**, sendo ideal para aplicações distribuídas modernas.
- O uso de **Kubernetes** garantiu alta disponibilidade, balanceamento de carga e isolamento entre serviços.

---

## 📁 Estrutura do projeto

```
atividade-extraclasse-1-pspd/
├── gateway_p_node/          # Gateway HTTP → gRPC
├── gateway_p_rest_node/     # Gateway HTTP → REST
├── services/a_py/           # Serviço A (gRPC)
├── services/b_py/           # Serviço B (gRPC)
├── services/a_rest/         # Serviço A (REST)
├── services/b_rest/         # Serviço B (REST)
├── proto/                   # Arquivos .proto
├── k8s/                     # Manifests Kubernetes
├── test_results/            # Dados e gráficos de desempenho
├── setup.sh                 # Script de automação completa
└── README.md                # Este arquivo
```

---

## 🧩 Créditos

Trabalho desenvolvido para a disciplina **Programação para Sistemas Paralelos e Distribuídos (PSPD)** — Universidade de Brasília (UnB), sob orientação do **Prof. Fernando William Cruz**.

Integrantes:
- Débora Caires de Souza Moreira  
- Edilberto Almeida Cantuaria  
- Levi de Oliveira Queiroz  
- Wolfgang Friedrich Stein
