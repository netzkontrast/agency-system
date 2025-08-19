import { describe, it, expect, beforeEach, vi } from 'vitest';
import { ModelRegistry } from '../modelRegistry';

// Mock environment variables
vi.mock('../modelRegistry', async () => {
  const actual = await vi.importActual('../modelRegistry');
  return {
    ...actual,
    MODEL_CONFIGS: {
      'lm-studio': {
        name: 'lm-studio',
        baseUrl: 'http://localhost:1234/v1',
        apiKey: 'lm-studio',
        models: {
          default: 'local-model',
          embedding: 'nomic-ai/nomic-embed-text-v1.5-GGUF'
        }
      },
      'openrouter': {
        name: 'openrouter',
        baseUrl: 'https://openrouter.ai/api/v1',
        apiKey: 'test-key',
        models: {
          default: 'mistralai/mistral-7b-instruct:free',
          embedding: 'openrouter/mistral-7b-instruct:free'
        }
      }
    }
  };
});

describe('ModelRegistry', () => {
  let modelRegistry: ModelRegistry;

  beforeEach(() => {
    // Reset environment variables
    process.env.LM_STUDIO_BASE_URL = 'http://localhost:1234/v1';
    process.env.LM_STUDIO_API_KEY = 'lm-studio';
    process.env.OPENROUTER_API_KEY = 'test-key';
    
    // Create new instance for each test
    modelRegistry = new ModelRegistry();
  });

  it('should initialize with available providers', () => {
    expect(modelRegistry).toBeDefined();
  });

  it('should get client for available provider', () => {
    expect(() => modelRegistry.getClient('lm-studio')).not.toThrow();
    expect(() => modelRegistry.getClient('openrouter')).not.toThrow();
  });

  it('should throw error for unavailable provider', () => {
    // @ts-ignore - Testing invalid provider
    expect(() => modelRegistry.getClient('invalid')).toThrow();
  });

  it('should get default provider', () => {
    // With both providers available, should prefer lm-studio
    expect(modelRegistry.getDefaultProvider()).toBe('lm-studio');
  });

  it('should get model for provider', () => {
    expect(modelRegistry.getModel('lm-studio')).toBe('local-model');
    expect(modelRegistry.getModel('lm-studio', 'embedding')).toBe('nomic-ai/nomic-embed-text-v1.5-GGUF');
    expect(modelRegistry.getModel('openrouter')).toBe('mistralai/mistral-7b-instruct:free');
  });

  it('should throw error for invalid provider model', () => {
    // @ts-ignore - Testing invalid provider
    expect(() => modelRegistry.getModel('invalid')).toThrow();
  });
});
