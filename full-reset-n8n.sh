#!/bin/bash

echo "⚠️  ATENÇÃO: Isso vai apagar TODOS os dados do n8n (workflows, credenciais, execuções)."
echo "Você terá que configurar as credenciais novamente."
echo "Pressione Ctrl+C em 5 segundos para cancelar..."
sleep 5

echo "🛑 Parando containers..."
docker-compose down

echo "🗑️  Removendo volume de dados do n8n (Reset do Banco)..."
docker volume rm n8n_n8n_data || echo "Volume não encontrado ou já removido."

echo "🏗️  Construindo nova imagem com AWS CLI..."
docker-compose build --no-cache n8n

echo "🚀 Iniciando n8n..."
docker-compose up -d

echo "⏳ Aguardando n8n iniciar (20s)..."
sleep 20

echo "📜 Provisionando workflows..."
./n8n-manage.sh workflows

echo "✅ Concluído! O n8n foi resetado e o AWS CLI foi instalado."
echo "Acesse: http://n8n.fabioleal.com.br"
echo "Configure suas credenciais (AWS, Gemini, WPP) novamente."
