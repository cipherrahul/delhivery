import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { errorHandler } from './shared/middlewares/error.middleware.js';
import { apiLimiter } from './shared/middlewares/rate-limit.middleware.js';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use('/api/', apiLimiter);

// Routes
app.get('/', (req, res) => {
  res.send('<h1>Welcome to Delhivery API Server! 🚀</h1><p>The backend is running successfully. API endpoints are available under <code>/api/...</code></p>');
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Real-time tracking namespace
const trackingNamespace = io.of('/tracking');
trackingNamespace.on('connection', (socket) => {
  console.log('Client connected to tracking:', socket.id);
  
  socket.on('updateLocation', (data) => {
    // Broadcast location to interested clients (customers)
    trackingNamespace.emit(`locationUpdate:${data.shipmentId}`, data);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected from tracking');
  });
});

// Import and mount modules after Socket.io initialization to avoid circular deps
import { mountModules } from './app_modules.js';
mountModules(app);

export { app, httpServer, io };
