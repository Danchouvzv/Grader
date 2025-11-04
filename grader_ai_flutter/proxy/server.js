// OpenAI Proxy Server
require('dotenv').config();
const express = require('express');
const fetch = require('node-fetch');
const cors = require('cors');

const app = express();
const PORT = 3000;
const OPENAI_API = 'https://api.openai.com/v1';

// Middleware
app.use(cors());
app.use(express.json());

// API Key - используем реальный если есть
const API_KEY = process.env.OPENAI_API_KEY || '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';

// Proxy endpoint
app.post('/api/openai/:endpoint', async (req, res) => {
  const { endpoint } = req.params;
  const url = `${OPENAI_API}/${endpoint}`;
  
  console.log(`📡 Proxy: ${req.method} ${url}`);
  
  try {
    const response = await fetch(url, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`,
      },
      body: JSON.stringify(req.body),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      console.error(`❌ OpenAI Error:`, data);
      return res.status(response.status).json(data);
    }
    
    console.log(`✅ OpenAI Success`);
    res.status(response.status).json(data);
    
  } catch (error) {
    console.error('❌ Proxy Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', key_preview: API_KEY.substring(0, 10) + '...' });
});

app.listen(PORT, () => {
  console.log(`🚀 OpenAI Proxy Server running on http://localhost:${PORT}`);
  console.log(`🔑 Using API Key: ${API_KEY.substring(0, 10)}...`);
});
