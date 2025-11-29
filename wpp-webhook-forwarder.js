#!/usr/bin/env node

const io = require('socket.io-client');
const https = require('https');

const WPPCONNECT_SOCKET = process.env.WPPCONNECT_SOCKET || 'http://10.30.0.50:21466';
const N8N_WEBHOOK = process.env.N8N_WEBHOOK || 'https://n8n.fabioleal.com.br/webhook/whatsapp-agent';
const SESSION = 'nova1';

console.log('🚀 WPPConnect Webhook Forwarder started');
console.log(`📡 Connecting to WPPConnect socket: ${WPPCONNECT_SOCKET}`);
console.log(`🎯 Forwarding to n8n webhook: ${N8N_WEBHOOK}`);

const socket = io(WPPCONNECT_SOCKET, {
    transports: ['websocket', 'polling']
});

console.log('🔍 Tentando conectar ao socket:', WPPCONNECT_SOCKET);

socket.on('connect', () => {
    console.log('✅ Connected to WPPConnect socket');
    socket.emit('join', SESSION);
    console.log(`🔗 Joined session: ${SESSION}`);
});

socket.on('connect_error', (err) => {
    console.error('❌ Erro ao conectar ao socket:', err.message);
});

socket.on('disconnect', () => {
    console.log('❌ Disconnected from WPPConnect socket');
});

socket.on('error', (error) => {
    console.error('❌ Socket error:', error);
});

// Listen for message events
socket.onAny((eventName, payload) => {
    console.log(`🔔 Evento recebido: ${eventName}`);
    console.log('📝 Payload completo:', JSON.stringify(payload));
    if (payload && payload.from) {
        console.log('📦 Forwarding message payload:', payload);
        const webhookData = JSON.stringify({
            event: 'onMessage',
            sender: payload.from,
            body: payload.body || payload.caption || '',
            from: payload.from,
            isGroupMsg: payload.isGroup || false,
            timestamp: payload.t || Date.now()
        });

        const url = new URL(N8N_WEBHOOK);
        const options = {
            hostname: url.hostname,
            port: 443,
            path: url.pathname,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(webhookData)
            }
        };

        const req = https.request(options, (res) => {
            let responseBody = '';
            res.on('data', (chunk) => { responseBody += chunk; });
            res.on('end', () => {
                console.log(`✅ Webhook sent – status ${res.statusCode}`);
                console.log('🔙 Resposta do n8n:', responseBody);
            });
        });
        req.on('error', (e) => console.error('❌ Webhook error:', e.message));
        req.write(webhookData);
        req.end();
    } else {
        console.log('⚠ Payload sem campo "from":', JSON.stringify(payload));
    }
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down...');
    socket.disconnect();
    process.exit(0);
});

console.log('👂 Listening for messages...');
