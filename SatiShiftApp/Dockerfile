FROM ubuntu:latest
LABEL authors="siango"

ENTRYPOINT ["top", "-b"]
# ใช้ Node.js Alpine image
FROM node:16-alpine

# กำหนด working directory
WORKDIR /app

# คัดลอกไฟล์ package.json และ package-lock.json (ถ้ามี)
COPY package*.json ./

# ติดตั้ง dependencies
RUN npm install

# คัดลอกไฟล์โปรเจกต์ทั้งหมดไปยัง container
COPY . .

# เปิดพอร์ตที่ใช้ใน container (สมมติว่า 4000)
EXPOSE 4000

# คำสั่งที่จะรันเมื่อ container เริ่มต้น
CMD ["npm", "start"]
