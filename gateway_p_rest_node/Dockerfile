FROM node:20-slim
WORKDIR /app
COPY . /app
RUN npm install --omit=dev
ENV PORT=8081
EXPOSE 8081
CMD ["node", "server.js"]
