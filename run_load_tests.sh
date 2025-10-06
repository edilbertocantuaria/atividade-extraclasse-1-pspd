#!/bin/bash

# Diretórios
LOAD_DIR="load"
RESULTS_DIR="test_results"

# Cria diretório de resultados se não existir
mkdir -p "$RESULTS_DIR"

# Arquivos de saída
OUT_GRPC="${RESULTS_DIR}/results_grpc.txt"
OUT_REST="${RESULTS_DIR}/results_rest.txt"

# Limpa resultados antigos
> "$OUT_GRPC"
> "$OUT_REST"

# Lista de usuários virtuais (VUs)
VUS_LIST=(25 50 100 200 400 800 1600 3200)

echo "===============================" | tee -a "$OUT_GRPC" "$OUT_REST"
echo " TESTES AUTOMÁTICOS DE CARGA "  | tee -a "$OUT_GRPC" "$OUT_REST"
echo "===============================" | tee -a "$OUT_GRPC" "$OUT_REST"

for V in "${VUS_LIST[@]}"; do
  echo "" | tee -a "$OUT_GRPC" "$OUT_REST"
  echo "===== Teste com ${V} VUs =====" | tee -a "$OUT_GRPC" "$OUT_REST"

  echo "🚀 Executando teste gRPC (${V} usuários)..."
  k6 run --vus "$V" --duration 30s "${LOAD_DIR}/load_grpc_http.js" | \
    grep -E "http_req_duration|http_reqs" | tee -a "$OUT_GRPC"

  echo "🌐 Executando teste REST (${V} usuários)..."
  k6 run --vus "$V" --duration 30s "${LOAD_DIR}/load_rest_http.js" | \
    grep -E "http_req_duration|http_reqs" | tee -a "$OUT_REST"

  echo "===============================" | tee -a "$OUT_GRPC" "$OUT_REST"
done

echo ""
echo "✅ Testes concluídos com sucesso!"
echo "📂 Resultados salvos em: ${RESULTS_DIR}"
echo ""

# =============================
# Execução do script Python
# =============================

if [ -f "${RESULTS_DIR}/plot_results.py" ]; then
  echo "📊 Gerando gráficos com plot_results.py..."

  # Verifica se Python está instalado
  if ! command -v python3 &> /dev/null; then
    echo "🐍 Python3 não encontrado. Instalando..."
    sudo apt update && sudo apt install -y python3 python3-venv python3-pip
  fi

  # Cria e ativa ambiente virtual
  VENV_DIR="${RESULTS_DIR}/venv"
  if [ ! -d "$VENV_DIR" ]; then
    echo "⚙️  Criando ambiente virtual..."
    python3 -m venv "$VENV_DIR"
  fi

  source "$VENV_DIR/bin/activate"

  # Instala matplotlib e dependências se necessário
  echo "📦 Instalando dependências Python..."
  pip install --upgrade pip >/dev/null 2>&1
  pip install matplotlib pandas numpy >/dev/null 2>&1

  # Executa o script
  python3 "${RESULTS_DIR}/plot_results.py"

  deactivate
  echo "✅ Gráficos gerados em: ${RESULTS_DIR}"
else
  echo "⚠️  O arquivo plot_results.py não foi encontrado em ${RESULTS_DIR}."
  echo "    Copie-o para essa pasta e rode manualmente:"
  echo "    python3 ${RESULTS_DIR}/plot_results.py"
fi

echo ""
echo "🏁 Processo finalizado."
