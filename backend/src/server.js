import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import config from './config/index.js';
import routes from './routes/index.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';

const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
    origin: config.allowedOrigins,
    credentials: true
}));

// Logging middleware
app.use(morgan(config.nodeEnv === 'development' ? 'dev' : 'combined'));

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API routes
app.use(`/api/${config.apiVersion}`, routes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Handwriting Learning App API',
        version: config.apiVersion,
        endpoints: {
            health: `/api/${config.apiVersion}/health`,
            children: `/api/${config.apiVersion}/children`,
            practice: `/api/${config.apiVersion}/practice`,
            progress: `/api/${config.apiVersion}/progress`
        }
    });
});

// 404 handler
app.use(notFound);

// Error handler (must be last)
app.use(errorHandler);

const PORT = config.port;

app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📝 Environment: ${config.nodeEnv}`);
    console.log(`🔗 API: http://localhost:${PORT}/api/${config.apiVersion}`);
});

export default app;
