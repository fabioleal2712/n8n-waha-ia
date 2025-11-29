#!/usr/bin/env node

const https = require('https');
const http = require('http');

// Configurações
const WPP_HOST = process.env.WPP_HOST || '10.30.0.50';
const WPP_PORT = process.env.WPP_PORT || '21465';
const WPP_TOKEN = process.env.WPP_TOKEN || '';
const SESSION = process.env.WPP_SESSION || 'nova1';
const N8N_WEBHOOK = process.env.N8N_WEBHOOK || 'https://n8n.fabioleal.com.br/webhook/whatsapp-agent';
const POLL_INTERVAL = parseInt(process.env.POLL_INTERVAL || '5000'); // 5 segundos

// Armazena IDs de mensagens já processadas
const processedMessages = new Set();
const MAX_PROCESSED_CACHE = 1000;

console.log('🚀 WPPConnect Polling Forwarder started');
console.log(`📡 Polling WPPConnect: http://${WPP_HOST}:${WPP_PORT}`);
console.log(`🎯 Forwarding to n8n webhook: ${N8N_WEBHOOK}`);
console.log(`⏱️  Poll interval: ${POLL_INTERVAL}ms`);

// Função para fazer requisição HTTP
function makeRequest(options, data = null) {
    return new Promise((resolve, reject) => {
        const client = options.protocol === 'https:' ? https : http;
        const req = client.request(options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    resolve({ status: res.statusCode, data: JSON.parse(body) });
                } catch (e) {
                    resolve({ status: res.statusCode, data: body });
                }
            });
        });

        req.on('error', reject);
        if (data) req.write(JSON.stringify(data));
        req.end();
    });
}

// Função para buscar chats e suas últimas mensagens
async function getRecentMessages() {
    try {
        const options = {
            hostname: WPP_HOST,
            port: WPP_PORT,
            path: `/api/${SESSION}/all-chats`,
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${WPP_TOKEN}`,
                'accept': 'application/json'
            }
        };

        const response = await makeRequest(options);

        if (response.status === 200 && response.data.response) {
            const chats = response.data.response;

            // DEBUG: Imprime o primeiro chat para análise
            if (chats.length > 0) {
                const c = chats[0];
                console.log('🔍 DEBUG Chat structure:', JSON.stringify({
                    id: c.id,
                    lastMessage: c.lastMessage ? {
                        id: c.lastMessage.id,
                        t: c.lastMessage.t,
                        body: c.lastMessage.body
                    } : 'null',
                    unreadCount: c.unreadCount
                }));
            }

            const messages = [];

            // Pega mensagens recentes (últimos 30 segundos)
            const now = Date.now();
            const TIME_WINDOW = 30000; // 30 segundos

            for (const chat of chats) {
                if (chat.lastMessage) {
                    const msgTimestamp = (chat.lastMessage.t * 1000); // converte para ms se necessário

                    // Se a mensagem é recente (independente de lida ou não)
                    if (now - msgTimestamp < TIME_WINDOW) {
                        messages.push({
                            id: chat.lastMessage.id || `${chat.id}_${chat.lastMessage.t}`,
                            from: chat.id,
                            chatId: chat.id,
                            body: chat.lastMessage.body || chat.lastMessage.caption || '',
                            timestamp: msgTimestamp,
                            fromMe: chat.lastMessage.fromMe || false,
                            isGroupMsg: chat.isGroup || false,
                            unreadCount: chat.unreadCount || 0
                        });
                    }
                }
            }

            return messages;
        }
        return [];
    } catch (error) {
        console.error('❌ Error fetching chats:', error.message);
        return [];
    }
}

// Função para enviar mensagem para n8n
async function forwardToN8n(message) {
    try {
        const url = new URL(N8N_WEBHOOK);
        const webhookData = {
            event: 'onMessage',
            sender: message.from || message.chatId,
            body: message.body || message.content || '',
            from: message.from || message.chatId,
            isGroupMsg: message.isGroupMsg || false,
            timestamp: message.timestamp || message.t || Date.now(),
            messageId: message.id
        };

        const options = {
            hostname: url.hostname,
            port: url.protocol === 'https:' ? 443 : 80,
            path: url.pathname,
            method: 'POST',
            protocol: url.protocol,
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(JSON.stringify(webhookData))
            }
        };

        const response = await makeRequest(options, webhookData);

        if (response.status >= 200 && response.status < 300) {
            console.log(`✅ Message forwarded to n8n - ID: ${message.id}`);
            return true;
        } else {
            console.error(`❌ Failed to forward message - Status: ${response.status}`);
            return false;
        }
    } catch (error) {
        console.error('❌ Error forwarding to n8n:', error.message);
        return false;
    }
}

// Função principal de polling
async function poll() {
    try {
        const messages = await getRecentMessages();

        if (messages.length > 0) {
            console.log(`📨 Found ${messages.length} unread message(s)`);

            for (const message of messages) {
                // Verifica se já processamos esta mensagem
                if (processedMessages.has(message.id)) {
                    continue;
                }

                // Ignora mensagens enviadas por nós mesmos
                if (message.fromMe) {
                    processedMessages.add(message.id);
                    continue;
                }

                console.log(`📤 Processing message from ${message.from}: ${message.body?.substring(0, 50)}...`);

                const success = await forwardToN8n(message);

                if (success) {
                    processedMessages.add(message.id);

                    // Limita o tamanho do cache
                    if (processedMessages.size > MAX_PROCESSED_CACHE) {
                        const firstItem = processedMessages.values().next().value;
                        processedMessages.delete(firstItem);
                    }
                }
            }
        }
    } catch (error) {
        console.error('❌ Error in poll cycle:', error.message);
    }
}

// Inicia o polling
console.log('👂 Starting polling...\n');
setInterval(poll, POLL_INTERVAL);

// Primeira execução imediata
poll();

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down...');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down...');
    process.exit(0);
});
