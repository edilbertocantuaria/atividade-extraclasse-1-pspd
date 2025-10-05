FROM node:20-slim
WORKDIR /app

# 1) Instalar deps com cache
COPY gateway_p_rest_node/package*.json ./
RUN npm install --omit=dev

# 2) Copiar código do serviço
COPY gateway_p_rest_node/ .

ENV PORT=8081
EXPOSE 8081
CMD ["node", "server.js"]   # ajuste se seu entrypoint tiver outro nome
