
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
unzip atividade-extraclasse-1-pspd.zip
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
```bash
kubectl -n pspd port-forward svc/p-svc 8080:80
kubectl -n pspd port-forward svc/p-rest-svc 8081:80
```

Acesse:
- `http://localhost:8080` → Gateway gRPC
- `http://localhost:8081` → Gateway REST

#### 🧪 Tentativa com minikube tunnel (sujeito a firewall)
```bash
minikube tunnel
```

Se funcionar, os serviços serão expostos via IP da máquina virtual Minikube.

##### ⚠️ Liberar portas no firewall do Windows

Se ocorrer erro com o `minikube tunnel`, pode ser necessário:

1. Abrir o **Painel de Controle** > **Sistema e Segurança** > **Firewall do Windows Defender**
2. Clique em **Regras de Entrada** > **Nova Regra**
3. Escolha **Porta**, clique em **Avançar**
4. Marque **TCP** e digite `80, 443`
5. Permitir a conexão > Avançar > selecione todos os perfis > nomeie como `Minikube Tunnel`

##### (Opcional) Alterar o arquivo `hosts` do Windows

1. Abrir o Bloco de Notas como **Administrador**
2. Ir em `Arquivo > Abrir` e navegar até:
   ```
   C:\Windows\System32\drivers\etc\hosts
   ```
3. Adicionar ao final:
   ```
   192.168.49.2 pspd.local
   192.168.49.2 pspd-rest.local
   ```

Verifique o IP do minikube com:
```bash
minikube ip
```

Teste o acesso:
- http://pspd.local
- http://pspd-rest.local

Se não funcionar, continue com `localhost:8080` e `localhost:8081` via `port-forward`.

### 3. Testar os serviços
```bash
curl "http://localhost:8080/a/hello?name=FernandoWilliam"
curl "http://localhost:8080/b/numbers?count=5&delay_ms=100"

curl "http://localhost:8081/a/hello?name=FernandoWilliam"
curl "http://localhost:8081/b/numbers?count=5&delay_ms=100"
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
