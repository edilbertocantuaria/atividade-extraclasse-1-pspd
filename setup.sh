#!/usr/bin/env bash
# === setup.sh: cria manifests, garante minikube, builda imagens pelo RAIZ, aplica e valida ===

set -euo pipefail
log() { echo -e "$1" >&2; }

# --------- [0] Pré-checagens ----------
command -v docker >/dev/null || { log "❌ Docker não encontrado no PATH."; exit 1; }
command -v kubectl >/dev/null || { log "❌ kubectl não encontrado no PATH."; exit 1; }
command -v minikube >/dev/null || { log "❌ minikube não encontrado no PATH."; exit 1; }

# --------- [1] Pastas ----------
log "[1/7] Criando pastas…"
mkdir -p k8s k8s/rest

# --------- [2] Manifests ----------
log "[2/7] Escrevendo manifests…"
cat > k8s/namespace.yaml <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: pspd
YAML

cat > k8s/a.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: a-deploy
  namespace: pspd
spec:
  replicas: 1
  selector: { matchLabels: { app: a } }
  template:
    metadata: { labels: { app: a } }
    spec:
      containers:
        - name: a
          image: a-service:local
          imagePullPolicy: IfNotPresent
          ports: [ { containerPort: 50051 } ]
          readinessProbe: { tcpSocket: { port: 50051 }, initialDelaySeconds: 2, periodSeconds: 5 }
          livenessProbe:  { tcpSocket: { port: 50051 }, initialDelaySeconds: 5, periodSeconds: 10 }
---
apiVersion: v1
kind: Service
metadata:
  name: a-svc
  namespace: pspd
spec:
  selector: { app: a }
  ports: [ { port: 50051, targetPort: 50051 } ]
YAML

cat > k8s/b.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: b-deploy
  namespace: pspd
spec:
  replicas: 1
  selector: { matchLabels: { app: b } }
  template:
    metadata: { labels: { app: b } }
    spec:
      containers:
        - name: b
          image: b-service:local
          imagePullPolicy: IfNotPresent
          ports: [ { containerPort: 50052 } ]
          readinessProbe: { tcpSocket: { port: 50052 }, initialDelaySeconds: 2, periodSeconds: 5 }
          livenessProbe:  { tcpSocket: { port: 50052 }, initialDelaySeconds: 5, periodSeconds: 10 }
---
apiVersion: v1
kind: Service
metadata:
  name: b-svc
  namespace: pspd
spec:
  selector: { app: b }
  ports: [ { port: 50052, targetPort: 50052 } ]
YAML

cat > k8s/p.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: p-deploy
  namespace: pspd
spec:
  replicas: 1
  selector: { matchLabels: { app: p } }
  template:
    metadata: { labels: { app: p } }
    spec:
      containers:
        - name: p
          image: p-gateway:local
          imagePullPolicy: IfNotPresent
          env:
            - { name: A_ADDR, value: "a-svc.pspd.svc.cluster.local:50051" }
            - { name: B_ADDR, value: "b-svc.pspd.svc.cluster.local:50052" }
            - { name: PORT,   value: "8080" }
          ports: [ { containerPort: 8080 } ]
          readinessProbe: { httpGet: { path: /healthz, port: 8080 }, initialDelaySeconds: 3, periodSeconds: 5 }
          livenessProbe:  { httpGet: { path: /healthz, port: 8080 }, initialDelaySeconds: 5, periodSeconds: 10 }
---
apiVersion: v1
kind: Service
metadata:
  name: p-svc
  namespace: pspd
spec:
  selector: { app: p }
  ports: [ { port: 80, targetPort: 8080 } ]
YAML

cat > k8s/ingress.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: p-ingress
  namespace: pspd
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - host: pspd.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: p-svc
                port: { number: 80 }
YAML

cat > k8s/rest/a-rest.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: a-rest-deploy
  namespace: pspd
spec:
  replicas: 1
  selector: { matchLabels: { app: a-rest } }
  template:
    metadata: { labels: { app: a-rest } }
    spec:
      containers:
        - name: a-rest
          image: a-rest-service:local
          imagePullPolicy: IfNotPresent
          ports: [ { containerPort: 8000 } ]
          readinessProbe: { httpGet: { path: /a/hello, port: 8000 }, initialDelaySeconds: 3, periodSeconds: 5, failureThreshold: 10 }
          livenessProbe:  { httpGet: { path: /a/hello, port: 8000 }, initialDelaySeconds: 5, periodSeconds: 10, failureThreshold: 10 }
---
apiVersion: v1
kind: Service
metadata:
  name: a-rest-svc
  namespace: pspd
spec:
  selector: { app: a-rest }
  ports: [ { port: 50061, targetPort: 8000 } ]
YAML

cat > k8s/rest/b-rest.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: b-rest-deploy
  namespace: pspd
spec:
  replicas: 1
  selector: { matchLabels: { app: b-rest } }
  template:
    metadata: { labels: { app: b-rest } }
    spec:
      containers:
        - name: b-rest
          image: b-rest-service:local
          imagePullPolicy: IfNotPresent
          ports: [ { containerPort: 8000 } ]
          readinessProbe: { httpGet: { path: /b/numbers, port: 8000 }, initialDelaySeconds: 3, periodSeconds: 5, failureThreshold: 10 }
          livenessProbe:  { httpGet: { path: /b/numbers, port: 8000 }, initialDelaySeconds: 5, periodSeconds: 10, failureThreshold: 10 }
---
apiVersion: v1
kind: Service
metadata:
  name: b-rest-svc
  namespace: pspd
spec:
  selector: { app: b-rest }
  ports: [ { port: 50062, targetPort: 8000 } ]
YAML

cat > k8s/rest/p-rest.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: p-rest-deploy
  namespace: pspd
spec:
  replicas: 1
  selector: { matchLabels: { app: p-rest } }
  template:
    metadata:
      labels: { app: p-rest }
    spec:
      containers:
        - name: p-rest
          image: p-rest-gateway:local
          imagePullPolicy: IfNotPresent
          env:
            - { name: A_REST, value: "http://a-rest-svc.pspd.svc.cluster.local:50061" }
            - { name: B_REST, value: "http://b-rest-svc.pspd.svc.cluster.local:50062" }
            - { name: PORT, value: "8081" }
          ports: [ { containerPort: 8081 } ]
          readinessProbe:
            tcpSocket: { port: 8081 }
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 10
          livenessProbe:
            tcpSocket: { port: 8081 }
            initialDelaySeconds: 15
            periodSeconds: 10
            failureThreshold: 10
---
apiVersion: v1
kind: Service
metadata:
  name: p-rest-svc
  namespace: pspd
spec:
  selector: { app: p-rest }
  ports: [ { port: 80, targetPort: 8081 } ]
YAML

cat > k8s/rest/ingress-rest.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: p-rest-ingress
  namespace: pspd
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - host: pspd-rest.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: p-rest-svc
                port: { number: 80 }
YAML

# --------- [2.5] Sanitizar .dockerignore ----------
if [ -f .dockerignore ] && grep -qE '^[[:space:]]*\*[[:space:]]*$' .dockerignore; then
  log "→ Ajustando .dockerignore que ignorava tudo (backup em .dockerignore.bak)…"
  cp .dockerignore .dockerignore.bak || true
  cat > .dockerignore <<'EOF'
.git
**/__pycache__/
**/*.pyc
node_modules
dist
build
.env
.DS_Store
EOF
fi

log "[3/7] Conferindo arquivos:"
ls -R k8s

# --------- [4] Garantindo Minikube ----------
log "[4/7] Garantindo Minikube…"

USE_IMAGE_LOAD=false 

docker info >/dev/null 2>&1 || { log "❌ Docker não acessível. Abra o Docker Desktop e tente de novo."; exit 1; }

if ! minikube status -p minikube >/dev/null 2>&1; then
  log "→ Nenhum cluster encontrado. Criando novo…"
  minikube delete --all --purge >/dev/null 2>&1 || true
  docker rm -f minikube >/dev/null 2>&1 || true
  docker network rm minikube >/dev/null 2>&1 || true
  minikube start -p minikube --driver=docker --cpus=2 --memory=4096
else
  log "→ Cluster existente detectado. Pulando criação."
fi

if minikube status -p minikube | grep -q "Running"; then
  log "→ Habilitando addon ingress…"
  minikube -p minikube addons enable ingress >/dev/null
else
  log "⚠️  Cluster não está em execução. Inicie o minikube manualmente e rode novamente o setup."
  exit 1
fi

kubectl config use-context minikube >/dev/null

# --------- [4.5] Conectar Docker ao Minikube ----------
if eval "$(minikube -p minikube docker-env)"; then
  log "✅ Docker apontado para o daemon interno do Minikube."
  USE_IMAGE_LOAD=false
else
  log "⚠️  Falha ao apontar Docker para o Minikube. As imagens serão carregadas manualmente."
  USE_IMAGE_LOAD=true
fi

# --------- [5] Build das imagens ----------
log "[5/7] Build das imagens gRPC/REST…"

docker build -t a-service:local -f services/a_py/Dockerfile .
docker build -t b-service:local -f services/b_py/Dockerfile .
docker build -t p-gateway:local -f gateway_p_node/Dockerfile .

[ -f services/a_rest/Dockerfile ] && docker build -t a-rest-service:local   -f services/a_rest/Dockerfile . || true
[ -f services/b_rest/Dockerfile ] && docker build -t b-rest-service:local   -f services/b_rest/Dockerfile . || true
[ -f gateway_p_rest_node/Dockerfile ] && docker build -t p-rest-gateway:local -f gateway_p_rest_node/Dockerfile . || true

if [ "$USE_IMAGE_LOAD" = true ]; then
  log "→ Carregando imagens no cluster (minikube image load)…"
  minikube -p minikube image load a-service:local || true
  minikube -p minikube image load b-service:local || true
  minikube -p minikube image load p-gateway:local || true
  minikube -p minikube image load a-rest-service:local || true
  minikube -p minikube image load b-rest-service:local || true
  minikube -p minikube image load p-rest-gateway:local || true
fi

# --------- [6] Aplicar manifests ----------
log "[6/7] Aplicando K8s (gRPC + REST)…"
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/a.yaml
kubectl apply -f k8s/b.yaml
kubectl apply -f k8s/p.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/rest/a-rest.yaml || true
kubectl apply -f k8s/rest/b-rest.yaml || true
kubectl apply -f k8s/rest/p-rest.yaml || true
kubectl apply -f k8s/rest/ingress-rest.yaml || true

wait_rollout() {
  local ns="$1"; shift
  for d in "$@"; do
    log "→ Aguardando rollout: $d (ns=$ns)…"
    if ! kubectl -n "$ns" rollout status deploy/"$d" --timeout=180s; then
      log "⚠️  Timeout no rollout de $d. Logs (últimas linhas):"
      kubectl -n "$ns" logs deploy/"$d" --tail=120 --all-containers || true
    fi
  done
}

wait_rollout pspd a-deploy b-deploy p-deploy
wait_rollout pspd a-rest-deploy b-rest-deploy p-rest-deploy

# --------- [7] Status final ----------
log "[7/7] Status:"
kubectl -n pspd get pods -o wide
kubectl -n pspd get svc
kubectl -n pspd get ingress

MINIKUBE_IP="$(minikube -p minikube ip || true)"
if [ -n "${MINIKUBE_IP:-}" ]; then
  log "\n✅ Se necessário, adicione ao /etc/hosts:"
  log "  $MINIKUBE_IP  pspd.local pspd-rest.local"
fi

log "\n🎉 Setup concluído com sucesso!"
log "------------------------------------------"
log "📡 Expor os serviços: duas formas possíveis"
log "✅ Opção garantida (port-forward)"
log "Obs.: rode cada linha em um terminal diferente:"
log ""
log "kubectl -n pspd port-forward svc/p-svc 8080:80"
log "kubectl -n pspd port-forward svc/p-rest-svc 8081:80"
log "------------------------------------------"
log "OK. Aguarde pods ficarem Running/Ready."
