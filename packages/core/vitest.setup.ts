import { vi } from 'vitest';

// Mock environment variables for testing
process.env.LM_STUDIO_BASE_URL = 'http://localhost:1234/v1';
process.env.LM_STUDIO_API_KEY = 'lm-studio';
process.env.OPENROUTER_API_KEY = 'test-key';
process.env.QDRANT_URL = 'http://localhost:6333';
process.env.POSTGRES_URL = 'postgresql://test:test@localhost:5432/test';
