# Usar imagen base de Node.js
FROM node:18

# Crear directorio de la app
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar todos los archivos del proyecto
COPY . .

# Listar contenido para depuración
RUN ls -la
RUN ls -la crud-vendedores

# Exponer el puerto
EXPOSE 3000

# Comando para ejecutar la app desde la subcarpeta
CMD ["node", "crud-vendedores/app.js"]