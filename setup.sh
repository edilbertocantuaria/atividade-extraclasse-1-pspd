# === setup.sh: cria manifests, faz build gRPC, aplica tudo e valida ===

set -euo pipefail

echo "[1/7] Criando pastas…"
mkdir -p k8s k8s/rest

echo "[2/7] Escrevendo manifests…"
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
          readinessProbe: { httpGet: { path: /a/hello, port: 8000 }, initialDelaySeconds: 3, periodSeconds: 5 }
          livenessProbe:  { httpGet: { path: /a/hello, port: 8000 }, initialDelaySeconds: 5, periodSeconds: 10 }
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
          readinessProbe: { httpGet: { path: /b/numbers, port: 8000 }, initialDelaySeconds: 3, periodSeconds: 5 }
          livenessProbe:  { httpGet: { path: /b/numbers, port: 8000 }, initialDelaySeconds: 5, periodSeconds: 10 }
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
    metadata: { labels: { app: p-rest } }
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
          readinessProbe: { httpGet: { path: /healthz, port: 8081 }, initialDelaySeconds: 3, periodSeconds: 5 }
          livenessProbe:  { httpGet: { path: /healthz, port: 8081 }, initialDelaySeconds: 5, periodSeconds: 10 }
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

echo "[3/7] Conferindo arquivos:"
ls -R k8s

echo "[4/7] Apontando Docker para o minikube…"
eval $(minikube -p minikube docker-env)

echo "[5/7] Build das imagens gRPC (faltavam):"
docker build -t a-service:local -f services/a_py/Dockerfile .
docker build -t b-service:local -f services/b_py/Dockerfile .
docker build -t p-gateway:local -f gateway_p_node/Dockerfile .

echo "[6/7] Aplicando gRPC stack…"
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/a.yaml
kubectl apply -f k8s/b.yaml
kubectl apply -f k8s/p.yaml
kubectl apply -f k8s/ingress.yaml

echo "[6.1/7] Aplicando REST stack (opcional)…"
kubectl apply -f k8s/rest/a-rest.yaml || true
kubectl apply -f k8s/rest/b-rest.yaml || true
kubectl apply -f k8s/rest/p-rest.yaml || true
kubectl apply -f k8s/rest/ingress-rest.yaml || true

echo "[7/7] Status:"
kubectl -n pspd get pods
kubectl -n pspd get svc
kubectl -n pspd get ingress
echo "OK. Aguarde pods ficarem Running (10–40s)."
