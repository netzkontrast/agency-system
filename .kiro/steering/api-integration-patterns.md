---
inclusion: fileMatch
fileMatchPattern: "apps/web/**/*.{ts,tsx,js,jsx}"
---

# API and Integration Patterns

## Next.js API Route Patterns

### Standard API Response Format
```typescript
// Successful response
return NextResponse.json({
  message: "Operation completed successfully",
  data: result,
  metadata: {
    timestamp: new Date().toISOString(),
    processingTime: Date.now() - startTime
  }
});

// Error response
return NextResponse.json(
  { error: "Descriptive error message" },
  { status: 400 }
);
```

### API Route Structure
```typescript
// app/api/example/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    
    // Validate input
    if (!body.required_field) {
      return NextResponse.json(
        { error: "Missing required field" },
        { status: 400 }
      );
    }
    
    // Process request
    const result = await processRequest(body);
    
    return NextResponse.json({
      message: "Request processed successfully",
      data: result
    });
    
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

## Core API Endpoints

### Content Ingestion
```typescript
// POST /api/ingest
interface IngestRequest {
  content: string;
  metadata: {
    source: string;
    chapter?: string;
    beat?: string;
  };
}

interface IngestResponse {
  message: string;
  contentLength: number;
  metadata: Record<string, any>;
}
```

### QA Generation
```typescript
// POST /api/qa-tag
interface QATagRequest {
  content: string;
  spanId: string;
}

interface QATagResponse {
  message: string;
  spanId: string;
  questionsGenerated: number;
  answersGenerated: number;
}
```

### Semantic Query
```typescript
// POST /api/query
interface QueryRequest {
  question: string;
  personaId?: string;
}

interface QueryResponse {
  message: string;
  question: string;
  answers: Array<{
    id: string;
    content: string;
    type: 'short' | 'mid' | 'long';
    citations: string[];
  }>;
  citations: Array<{
    id: string;
    content: string;
  }>;
}
```

### Context Judging
```typescript
// POST /api/judge/context
interface JudgeRequest {
  context: string;
  criteria?: string;
}

interface JudgeResponse {
  message: string;
  contextLength: number;
  nbas: Array<{
    id: string;
    label: string;
    action: string;
    description: string;
  }>;
}
```

### Persona Management
```typescript
// POST /api/persona
interface CreatePersonaRequest {
  name: string;
  description: string;
}

interface PersonaResponse {
  message: string;
  persona: {
    id: string;
    name: string;
    description: string;
    thoughtsNamespace: string;
  };
}

// GET /api/persona
interface ListPersonasResponse {
  message: string;
  personas: Array<{
    id: string;
    name: string;
    description: string;
    thoughtsNamespace: string;
  }>;
}
```

## Database Integration Patterns

### Qdrant Vector Operations
```typescript
// Vector search utility
async function vectorSearch(query: string, collection: string = 'sources') {
  const embedding = await getEmbedding(query);
  
  const searchResult = await qdrantClient.search(collection, {
    vector: embedding,
    limit: 10,
    with_payload: true,
    with_vector: false
  });
  
  return searchResult.map(result => ({
    id: result.id,
    content: result.payload?.content,
    score: result.score,
    metadata: result.payload?.metadata
  }));
}

// Vector upsert utility
async function upsertVector(
  collection: string,
  id: string,
  vector: number[],
  payload: Record<string, any>
) {
  await qdrantClient.upsert(collection, {
    wait: true,
    points: [{
      id,
      vector,
      payload
    }]
  });
}
```

### Postgres Operations
```typescript
// Database query utility
async function queryDatabase(sql: string, params: any[] = []) {
  const client = await pool.connect();
  try {
    const result = await client.query(sql, params);
    return result.rows;
  } finally {
    client.release();
  }
}

// Insert with returning
async function insertSpan(content: string, metadata: any) {
  const sql = `
    INSERT INTO spans (content, metadata, created_at)
    VALUES ($1, $2, NOW())
    RETURNING id, created_at
  `;
  
  const result = await queryDatabase(sql, [content, JSON.stringify(metadata)]);
  return result[0];
}
```

## AI Model Integration

### LM Studio (Development)
```typescript
// Local model configuration
const LM_STUDIO_CONFIG = {
  baseURL: 'http://localhost:1234/v1',
  apiKey: 'lm-studio', // placeholder
  model: 'local-model'
};

async function callLocalLLM(prompt: string) {
  const response = await fetch(`${LM_STUDIO_CONFIG.baseURL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${LM_STUDIO_CONFIG.apiKey}`
    },
    body: JSON.stringify({
      model: LM_STUDIO_CONFIG.model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7
    })
  });
  
  const data = await response.json();
  return data.choices[0].message.content;
}
```

### OpenRouter (Production)
```typescript
// Production model configuration
const OPENROUTER_CONFIG = {
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: process.env.OPENROUTER_API_KEY,
  model: 'anthropic/claude-3-sonnet'
};

async function callProductionLLM(prompt: string) {
  const response = await fetch(`${OPENROUTER_CONFIG.baseURL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${OPENROUTER_CONFIG.apiKey}`,
      'HTTP-Referer': process.env.SITE_URL,
      'X-Title': 'Kohärenz Protokoll'
    },
    body: JSON.stringify({
      model: OPENROUTER_CONFIG.model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7
    })
  });
  
  const data = await response.json();
  return data.choices[0].message.content;
}
```

### Model Registry Pattern
```typescript
interface ModelProvider {
  name: string;
  baseURL: string;
  apiKey: string;
  models: string[];
}

class ModelRegistry {
  private providers: Map<string, ModelProvider> = new Map();
  
  registerProvider(name: string, provider: ModelProvider) {
    this.providers.set(name, provider);
  }
  
  async callModel(
    providerName: string,
    modelName: string,
    prompt: string
  ): Promise<string> {
    const provider = this.providers.get(providerName);
    if (!provider) {
      throw new Error(`Provider ${providerName} not found`);
    }
    
    // Implementation for calling the specific provider
    return await this.makeAPICall(provider, modelName, prompt);
  }
  
  private async makeAPICall(
    provider: ModelProvider,
    model: string,
    prompt: string
  ): Promise<string> {
    // Unified API call logic
    const response = await fetch(`${provider.baseURL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${provider.apiKey}`
      },
      body: JSON.stringify({
        model,
        messages: [{ role: 'user', content: prompt }]
      })
    });
    
    const data = await response.json();
    return data.choices[0].message.content;
  }
}
```

## Frontend Integration Patterns

### AI SDK v5 Streaming
```typescript
// Streaming chat component
import { useChat } from 'ai/react';

export function ChatInterface() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: '/api/chat',
    onError: (error) => {
      console.error('Chat error:', error);
    }
  });
  
  return (
    <div className="chat-container">
      <div className="messages">
        {messages.map((message) => (
          <div key={message.id} className={`message ${message.role}`}>
            {message.content}
          </div>
        ))}
      </div>
      
      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Ask a question..."
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Thinking...' : 'Send'}
        </button>
      </form>
    </div>
  );
}
```

### Query Interface
```typescript
// Query component with results
interface QueryResult {
  answers: Array<{
    id: string;
    content: string;
    type: 'short' | 'mid' | 'long';
    citations: string[];
  }>;
  citations: Array<{
    id: string;
    content: string;
  }>;
}

export function QueryInterface() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<QueryResult | null>(null);
  const [loading, setLoading] = useState(false);
  
  const handleQuery = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: query })
      });
      
      const data = await response.json();
      setResults(data);
    } catch (error) {
      console.error('Query error:', error);
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div className="query-interface">
      <div className="query-input">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Enter your question..."
        />
        <button onClick={handleQuery} disabled={loading}>
          {loading ? 'Searching...' : 'Search'}
        </button>
      </div>
      
      {results && (
        <div className="results">
          <div className="answers">
            {results.answers.map((answer) => (
              <div key={answer.id} className={`answer ${answer.type}`}>
                <p>{answer.content}</p>
                <div className="citations">
                  {answer.citations.map((citationId) => {
                    const citation = results.citations.find(c => c.id === citationId);
                    return citation ? (
                      <span key={citationId} className="citation">
                        {citation.content}
                      </span>
                    ) : null;
                  })}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
```

## Error Handling and Validation

### Input Validation
```typescript
import { z } from 'zod';

const IngestSchema = z.object({
  content: z.string().min(1, "Content is required"),
  metadata: z.object({
    source: z.string().min(1, "Source is required"),
    chapter: z.string().optional(),
    beat: z.string().optional()
  })
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const validatedData = IngestSchema.parse(body);
    
    // Process validated data
    const result = await processIngest(validatedData);
    
    return NextResponse.json({
      message: "Content ingested successfully",
      data: result
    });
    
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: "Validation failed", details: error.errors },
        { status: 400 }
      );
    }
    
    console.error('Ingest error:', error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

### Rate Limiting (Production)
```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 m'), // 10 requests per minute
});

export async function POST(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1';
  const { success } = await ratelimit.limit(ip);
  
  if (!success) {
    return NextResponse.json(
      { error: 'Rate limit exceeded' },
      { status: 429 }
    );
  }
  
  // Continue with normal processing
}
```