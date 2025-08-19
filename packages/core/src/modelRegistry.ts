import { OpenAI } from 'openai';
import { ModelProvider } from './types';

// Model configurations
const MODEL_CONFIGS = {
  'lm-studio': {
    name: 'lm-studio',
    baseUrl: process.env.LM_STUDIO_BASE_URL || 'http://localhost:1234/v1',
    apiKey: process.env.LM_STUDIO_API_KEY || 'lm-studio',
    models: {
      default: 'local-model',
      embedding: 'nomic-ai/nomic-embed-text-v1.5-GGUF'
    }
  },
  'openrouter': {
    name: 'openrouter',
    baseUrl: process.env.OPENROUTER_BASE_URL || 'https://openrouter.ai/api/v1',
    apiKey: process.env.OPENROUTER_API_KEY || '',
    models: {
      default: 'mistralai/mistral-7b-instruct:free',
      embedding: 'openrouter/mistral-7b-instruct:free'
    }
  }
} as const;

export class ModelRegistry {
  private clients: Map<ModelProvider, OpenAI> = new Map();

  constructor() {
    this.initializeClients();
  }

  private initializeClients() {
    // Initialize LM Studio client
    if (MODEL_CONFIGS['lm-studio'].apiKey) {
      this.clients.set('lm-studio', new OpenAI({
        baseURL: MODEL_CONFIGS['lm-studio'].baseUrl,
        apiKey: MODEL_CONFIGS['lm-studio'].apiKey,
      }));
    }

    // Initialize OpenRouter client
    if (MODEL_CONFIGS['openrouter'].apiKey) {
      this.clients.set('openrouter', new OpenAI({
        baseURL: MODEL_CONFIGS['openrouter'].baseUrl,
        apiKey: MODEL_CONFIGS['openrouter'].apiKey,
      }));
    }
  }

  getClient(provider: ModelProvider): OpenAI {
    const client = this.clients.get(provider);
    if (!client) {
      throw new Error(`Model provider ${provider} not configured or unavailable`);
    }
    return client;
  }

  getDefaultProvider(): ModelProvider {
    // Prefer LM Studio for local development, fallback to OpenRouter
    if (this.clients.has('lm-studio')) {
      return 'lm-studio';
    }
    if (this.clients.has('openrouter')) {
      return 'openrouter';
    }
    throw new Error('No model providers configured');
  }

  getModel(provider: ModelProvider, modelType: 'default' | 'embedding' = 'default'): string {
    const config = MODEL_CONFIGS[provider];
    if (!config) {
      throw new Error(`Model provider ${provider} not found in configuration`);
    }
    return config.models[modelType];
  }

  async generateText(
    prompt: string,
    options: {
      provider?: ModelProvider;
      model?: string;
      temperature?: number;
      maxTokens?: number;
    } = {}
  ): Promise<string> {
    const provider = options.provider || this.getDefaultProvider();
    const model = options.model || this.getModel(provider);
    const client = this.getClient(provider);

    const response = await client.chat.completions.create({
      model,
      messages: [{ role: 'user', content: prompt }],
      temperature: options.temperature ?? 0.7,
      max_tokens: options.maxTokens,
    });

    return response.choices[0]?.message?.content || '';
  }

  async generateEmbedding(
    text: string,
    options: {
      provider?: ModelProvider;
      model?: string;
    } = {}
  ): Promise<number[]> {
    const provider = options.provider || this.getDefaultProvider();
    const model = options.model || this.getModel(provider, 'embedding');
    const client = this.getClient(provider);

    const response = await client.embeddings.create({
      model,
      input: text,
    });

    return response.data[0].embedding;
  }
}

// Export singleton instance
export const modelRegistry = new ModelRegistry();
