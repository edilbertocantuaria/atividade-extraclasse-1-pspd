import os
import re
import matplotlib.pyplot as plt

# Diretório base onde estão os resultados
RESULTS_DIR = "test_results"

# Garante que o diretório existe
os.makedirs(RESULTS_DIR, exist_ok=True)

# Função para extrair os dados de cada arquivo
def parse_results(file_path):
    vus, avg_times, total_reqs = [], [], []
    with open(file_path) as f:
        content = f.read()
    # Extrai blocos de texto com "Teste com X VUs", "http_reqs" e "avg="
    matches = re.findall(r'Teste com (\d+).*?http_reqs.*?(\d+).*?http_req_duration.*?avg=([\d.]+)', content, re.S)
    for m in matches:
        vus.append(int(m[0]))
        total_reqs.append(int(m[1]))
        avg_times.append(float(m[2]))
    return vus, avg_times, total_reqs

# Caminhos dos arquivos de entrada
grpc_path = os.path.join(RESULTS_DIR, "results_grpc.txt")
rest_path = os.path.join(RESULTS_DIR, "results_rest.txt")

# Lê e processa os dados
vus_g, avg_g, req_g = parse_results(grpc_path)
vus_r, avg_r, req_r = parse_results(rest_path)

# --- Gráfico 1: Tempo médio ---
plt.figure()
plt.plot(vus_g, avg_g, 'o-', label="gRPC")
plt.plot(vus_r, avg_r, 's--', label="REST")
plt.title("Tempo médio de resposta vs Usuários simultâneos")
plt.xlabel("Usuários virtuais (VUs)")
plt.ylabel("Tempo médio (ms)")
plt.legend()
plt.grid(True)
plt.savefig(os.path.join(RESULTS_DIR, "grafico_tempo_medio.png"))

# --- Gráfico 2: Requisições por segundo ---
plt.figure()
plt.plot(vus_g, req_g, 'o-', label="gRPC")
plt.plot(vus_r, req_r, 's--', label="REST")
plt.title("Requisições processadas vs Usuários simultâneos")
plt.xlabel("Usuários virtuais (VUs)")
plt.ylabel("Total de requisições")
plt.legend()
plt.grid(True)
plt.savefig(os.path.join(RESULTS_DIR, "grafico_requisicoes.png"))

# --- Gráfico 3: Comparativo combinado ---
plt.figure()
plt.plot(vus_g, avg_g, 'o-', label="Tempo médio gRPC")
plt.plot(vus_r, avg_r, 's--', label="Tempo médio REST")
plt.twinx()
plt.plot(vus_g, req_g, '^-', color='gray', alpha=0.4, label="Requisições gRPC")
plt.plot(vus_r, req_r, 'v--', color='lightgray', alpha=0.4, label="Requisições REST")
plt.title("Comparativo combinado: tempo e throughput")
plt.xlabel("Usuários virtuais (VUs)")
plt.legend(loc="upper left")
plt.grid(True)
plt.savefig(os.path.join(RESULTS_DIR, "grafico_comparativo.png"))

print("✅ Gráficos gerados em:")
print(f"  - {os.path.join(RESULTS_DIR, 'grafico_tempo_medio.png')}")
print(f"  - {os.path.join(RESULTS_DIR, 'grafico_requisicoes.png')}")
print(f"  - {os.path.join(RESULTS_DIR, 'grafico_comparativo.png')}")
