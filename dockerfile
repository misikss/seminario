# Usar imagen base de Node.js
FROM node:18

# Crear directorio de la app
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código
COPY . .

# Exponer el puerto (ajústalo según tu app)
EXPOSE 3000

# Comando para ejecutar la app
CMD ["npm", "start"]
