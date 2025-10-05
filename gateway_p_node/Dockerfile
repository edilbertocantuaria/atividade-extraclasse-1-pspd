FROM node:20-slim
WORKDIR /app

# 1) Instalar deps com cache
COPY gateway_p_node/package*.json ./
RUN npm install --omit=dev

# 2) Copiar protos e código do gateway
COPY proto/ ./proto/
COPY gateway_p_node/ .

ENV PORT=8080
EXPOSE 8080
CMD ["node","server.js"]
