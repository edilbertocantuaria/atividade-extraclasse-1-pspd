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

#### 🧪 Tentativa com minikube tunnel (sujeito a firewall)
```bash
minikube tunnel
```

Se falhar, é por bloqueio de portas (80, 443). Tente o método acima.

### ⚙️ (Opcional) Configurar acesso via domínios locais (`pspd.local` e `pspd-rest.local`)

Essas etapas permitem acessar os serviços do Minikube por domínios amigáveis em vez de `localhost`.

---

#### 1️⃣ Verificar o IP do Minikube
```bash
minikube ip
```

---

#### 2️⃣ Editar o arquivo `hosts` do Windows
1. Abra o **Bloco de Notas como Administrador**
2. Vá em **Arquivo → Abrir** e acesse:
   ```
   C:\Windows\System32\drivers\etc\hosts
   ```
3. No final do arquivo, adicione (substituindo o IP se necessário):
   ```
   192.168.49.2 pspd.local
   192.168.49.2 pspd-rest.local
   ```
4. Salve e feche o arquivo.

---

#### 3️⃣ Testar o acesso
- http://pspd.local  
- http://pspd-rest.local  

Se não funcionar, use `localhost:8080` e `localhost:8081` com `kubectl port-forward`.

---

### 🛡️ (Opcional, mas recomendado) Liberar portas 80 e 443 no Firewall do Windows

Necessário se for usar `minikube tunnel` para acessar via domínios locais (`pspd.local`, etc.).

---

#### Passo a passo:

1. Pressione `Win + S`, digite **firewall** e abra:
   ```
   Firewall do Windows Defender com Segurança Avançada
   ```

2. No menu à esquerda, clique em:
   ```
   Regras de Entrada
   ```

3. No menu à direita, selecione:
   ```
   Nova Regra...
   ```

4. Escolha:
   ```
   Porta → Avançar
   ```

5. Configure:
   - Tipo: **TCP**
   - Porta específica: `80`
   - Clique em **Avançar**

6. Selecione:
   ```
   Permitir a conexão
   ```

7. Marque todos os perfis:
   ```
   ✔️ Domínio ✔️ Particular ✔️ Público
   ```

8. Nomeie a regra:
   ```
   Minikube Tunnel HTTP (porta 80)
   ```

Clique em **Concluir** ✅  

Repita o processo para a porta **443** (HTTPS), nomeando a porta como:
```
Minikube Tunnel HTTPS (porta 443)
```


## 3. Testar os serviços
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
