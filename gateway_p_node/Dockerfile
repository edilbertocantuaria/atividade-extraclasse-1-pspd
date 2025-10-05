FROM node:20-slim
WORKDIR /app
COPY proto /app/proto
COPY gateway_p_node /app
RUN npm install --omit=dev
ENV PORT=8080
EXPOSE 8080
CMD ["node","server.js"]
