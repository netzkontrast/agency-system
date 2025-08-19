# Design Document

## Overview

The Guide-Chat Interface is a modern, responsive web application built with Next.js 14 that provides an interactive conversational experience for knowledge exploration. The interface leverages ai-sdk v5 for real-time streaming responses, shadcn/ui for consistent design components, and integrates seamlessly with the Kohärenz Protokoll backend APIs to deliver contextualized, citation-rich responses with actionable NBA recommendations.

## Architecture

### Component Hierarchy

```
ChatApp
├── ChatLayout
│   ├── PersonaSelector
│   ├── ChatContainer
│   │   ├── MessageList
│   │   │   ├── UserMessage
│   │   │   ├── AssistantMessage
│   │   │   │   ├── StreamingContent
│   │   │   │   ├── CitationList
│   │   │   │   └── NBAActions
│   │   │   └── SystemMessage
│   │   └── ChatInput
│   │       ├── InputField
│   │       ├── SendButton
│   │       └── StatusIndicator
│   ├── Sidebar
│   │   ├── ConversationHistory
│   │   ├── PersonaManager
│   │   └── Settings
│   └── CitationModal
└── ErrorBoundary
```

### State Management Architecture

```typescript
// Global state using Zustand
interface ChatState {
  // Chat state
  messages: Message[];
  currentPersona: Persona | null;
  isStreaming: boolean;
  
  // UI state
  sidebarOpen: boolean;
  citationModalOpen: boolean;
  selectedCitation: Citation | null;
  
  // Actions
  addMessage: (message: Message) => void;
  setPersona: (persona: Persona) => void;
  toggleSidebar: () => void;
  openCitationModal: (citation: Citation) => void;
}

// Local component state for forms and temporary UI
interface ChatInputState {
  input: string;
  isSubmitting: boolean;
  validationError: string | null;
}
```

## Components and Interfaces

### Core Data Models

```typescript
interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Date;
  citations?: Citation[];
  nbas?: NBAAction[];
  personaId?: string;
}

interface Citation {
  id: string;
  content: string;
  source: string;
  metadata: {
    chapter?: string;
    beat?: string;
    spanId: string;
  };
}

interface NBAAction {
  id: string;
  label: string;
  action: string;
  description: string;
  type: 'query' | 'navigation' | 'action';
  payload?: any;
}

interface Persona {
  id: string;
  name: string;
  description: string;
  thoughtsNamespace: string;
  color?: string;
  avatar?: string;
}

interface StreamingResponse {
  content: string;
  citations: Citation[];
  nbas: NBAAction[];
  isComplete: boolean;
}
```

### Main Chat Interface

```typescript
// ChatContainer.tsx
export function ChatContainer() {
  const { messages, isStreaming, currentPersona } = useChatStore();
  const { messages: streamMessages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: '/api/chat',
    initialMessages: messages,
    onFinish: (message) => {
      // Process citations and NBAs from the response
      processCitationsAndNBAs(message);
    }
  });

  return (
    <div className="flex flex-col h-full">
      <ChatHeader persona={currentPersona} />
      <MessageList messages={streamMessages} />
      <ChatInput 
        input={input}
        onChange={handleInputChange}
        onSubmit={handleSubmit}
        isLoading={isLoading}
      />
    </div>
  );
}
```

### Streaming Message Component

```typescript
// AssistantMessage.tsx
export function AssistantMessage({ message }: { message: Message }) {
  const [citations, setCitations] = useState<Citation[]>([]);
  const [nbas, setNBAs] = useState<NBAAction[]>([]);
  
  useEffect(() => {
    // Parse citations and NBAs from message content
    const parsed = parseMessageContent(message.content);
    setCitations(parsed.citations);
    setNBAs(parsed.nbas);
  }, [message.content]);

  return (
    <div className="message assistant">
      <div className="message-content">
        <StreamingText content={message.content} />
      </div>
      
      {citations.length > 0 && (
        <CitationList citations={citations} />
      )}
      
      {nbas.length > 0 && (
        <NBAActionList actions={nbas} />
      )}
    </div>
  );
}
```

### Citation Management

```typescript
// CitationList.tsx
export function CitationList({ citations }: { citations: Citation[] }) {
  const { openCitationModal } = useChatStore();

  return (
    <div className="citations">
      <h4 className="text-sm font-medium text-gray-600 mb-2">Sources</h4>
      <div className="flex flex-wrap gap-2">
        {citations.map((citation, index) => (
          <button
            key={citation.id}
            onClick={() => openCitationModal(citation)}
            className="citation-badge"
          >
            [{index + 1}] {citation.source}
          </button>
        ))}
      </div>
    </div>
  );
}

// CitationModal.tsx
export function CitationModal() {
  const { citationModalOpen, selectedCitation, closeCitationModal } = useChatStore();

  if (!citationModalOpen || !selectedCitation) return null;

  return (
    <Dialog open={citationModalOpen} onOpenChange={closeCitationModal}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Source: {selectedCitation.source}</DialogTitle>
        </DialogHeader>
        <div className="citation-content">
          <p className="text-sm text-gray-600 mb-4">
            {selectedCitation.metadata.chapter && `Chapter: ${selectedCitation.metadata.chapter}`}
            {selectedCitation.metadata.beat && ` • Beat: ${selectedCitation.metadata.beat}`}
          </p>
          <div className="prose prose-sm">
            {selectedCitation.content}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

### NBA Action System

```typescript
// NBAActionList.tsx
export function NBAActionList({ actions }: { actions: NBAAction[] }) {
  const { addMessage } = useChatStore();
  
  const handleNBAAction = async (action: NBAAction) => {
    switch (action.type) {
      case 'query':
        // Add the suggested query as a new user message
        addMessage({
          id: generateId(),
          role: 'user',
          content: action.payload.question,
          timestamp: new Date()
        });
        break;
        
      case 'navigation':
        // Handle navigation actions
        router.push(action.payload.url);
        break;
        
      case 'action':
        // Execute custom actions
        await executeCustomAction(action);
        break;
    }
  };

  return (
    <div className="nba-actions">
      <h4 className="text-sm font-medium text-gray-600 mb-2">Suggested Actions</h4>
      <div className="flex flex-wrap gap-2">
        {actions.map((action) => (
          <Button
            key={action.id}
            variant="outline"
            size="sm"
            onClick={() => handleNBAAction(action)}
            className="nba-action-button"
          >
            {action.label}
          </Button>
        ))}
      </div>
    </div>
  );
}
```

### Persona Management

```typescript
// PersonaSelector.tsx
export function PersonaSelector() {
  const { currentPersona, setPersona } = useChatStore();
  const [personas, setPersonas] = useState<Persona[]>([]);
  
  useEffect(() => {
    fetchPersonas().then(setPersonas);
  }, []);

  return (
    <Select value={currentPersona?.id} onValueChange={(id) => {
      const persona = personas.find(p => p.id === id);
      setPersona(persona || null);
    }}>
      <SelectTrigger className="w-48">
        <SelectValue placeholder="Select persona..." />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="">No persona</SelectItem>
        {personas.map((persona) => (
          <SelectItem key={persona.id} value={persona.id}>
            <div className="flex items-center gap-2">
              <div 
                className="w-3 h-3 rounded-full" 
                style={{ backgroundColor: persona.color }}
              />
              {persona.name}
            </div>
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}
```

## Data Models

### API Integration Layer

```typescript
// lib/api.ts
export class KoharenzAPI {
  private baseURL = '/api';
  
  async query(question: string, personaId?: string): Promise<QueryResponse> {
    const response = await fetch(`${this.baseURL}/query`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question, personaId })
    });
    
    if (!response.ok) {
      throw new Error(`Query failed: ${response.statusText}`);
    }
    
    return response.json();
  }
  
  async judgeContext(context: string, criteria?: string): Promise<JudgeResponse> {
    const response = await fetch(`${this.baseURL}/judge/context`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ context, criteria })
    });
    
    return response.json();
  }
  
  async getPersonas(): Promise<Persona[]> {
    const response = await fetch(`${this.baseURL}/persona`);
    const data = await response.json();
    return data.personas;
  }
  
  async createPersona(name: string, description: string): Promise<Persona> {
    const response = await fetch(`${this.baseURL}/persona`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, description })
    });
    
    const data = await response.json();
    return data.persona;
  }
}

export const api = new KoharenzAPI();
```

### Chat API Route

```typescript
// app/api/chat/route.ts
import { StreamingTextResponse, Message } from 'ai';
import { api as koharenzAPI } from '@/lib/api';

export async function POST(req: Request) {
  const { messages, personaId } = await req.json();
  const lastMessage = messages[messages.length - 1];
  
  if (lastMessage.role !== 'user') {
    return new Response('Invalid message format', { status: 400 });
  }
  
  try {
    // Query the knowledge base
    const queryResult = await koharenzAPI.query(lastMessage.content, personaId);
    
    // Generate context for NBA evaluation
    const context = `
      Question: ${lastMessage.content}
      Answers: ${queryResult.answers.map(a => a.content).join('\n')}
      Citations: ${queryResult.citations.map(c => c.content).join('\n')}
    `;
    
    // Get NBA recommendations
    const nbaResult = await koharenzAPI.judgeContext(context);
    
    // Format response with citations and NBAs
    const responseContent = formatChatResponse(queryResult, nbaResult);
    
    // Return streaming response
    return new StreamingTextResponse(
      createStreamFromText(responseContent)
    );
    
  } catch (error) {
    console.error('Chat API error:', error);
    return new Response('Internal server error', { status: 500 });
  }
}

function formatChatResponse(queryResult: QueryResponse, nbaResult: JudgeResponse): string {
  let response = '';
  
  // Add main answers
  queryResult.answers.forEach((answer, index) => {
    response += `${answer.content}\n\n`;
  });
  
  // Add citations metadata
  if (queryResult.citations.length > 0) {
    response += `\n[CITATIONS]\n`;
    queryResult.citations.forEach((citation, index) => {
      response += `${index + 1}. ${citation.content}\n`;
    });
  }
  
  // Add NBA actions metadata
  if (nbaResult.nbas.length > 0) {
    response += `\n[NBAS]\n`;
    nbaResult.nbas.forEach((nba) => {
      response += `${nba.label}: ${nba.description}\n`;
    });
  }
  
  return response;
}
```

## Error Handling

### Error Boundary Component

```typescript
// components/ErrorBoundary.tsx
export class ChatErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error?: Error }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }
  
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Chat error:', error, errorInfo);
    // Log to error reporting service
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <div className="error-fallback">
          <h2>Something went wrong with the chat interface.</h2>
          <button onClick={() => this.setState({ hasError: false })}>
            Try again
          </button>
        </div>
      );
    }
    
    return this.props.children;
  }
}
```

### API Error Handling

```typescript
// hooks/useErrorHandler.ts
export function useErrorHandler() {
  const [error, setError] = useState<string | null>(null);
  
  const handleError = useCallback((error: unknown) => {
    if (error instanceof Error) {
      setError(error.message);
    } else {
      setError('An unexpected error occurred');
    }
    
    // Auto-clear error after 5 seconds
    setTimeout(() => setError(null), 5000);
  }, []);
  
  const clearError = useCallback(() => setError(null), []);
  
  return { error, handleError, clearError };
}
```

## Testing Strategy

### Component Testing

```typescript
// __tests__/ChatContainer.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ChatContainer } from '@/components/ChatContainer';

describe('ChatContainer', () => {
  it('should render chat interface', () => {
    render(<ChatContainer />);
    expect(screen.getByPlaceholderText('Ask a question...')).toBeInTheDocument();
  });
  
  it('should send message when form is submitted', async () => {
    const mockSubmit = jest.fn();
    render(<ChatContainer onSubmit={mockSubmit} />);
    
    const input = screen.getByPlaceholderText('Ask a question...');
    const submitButton = screen.getByRole('button', { name: /send/i });
    
    fireEvent.change(input, { target: { value: 'Test question' } });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockSubmit).toHaveBeenCalledWith('Test question');
    });
  });
});
```

### API Integration Testing

```typescript
// __tests__/api.test.ts
import { api } from '@/lib/api';

describe('KoharenzAPI', () => {
  it('should query knowledge base', async () => {
    const result = await api.query('What is the meaning of life?');
    
    expect(result).toHaveProperty('answers');
    expect(result).toHaveProperty('citations');
    expect(Array.isArray(result.answers)).toBe(true);
  });
  
  it('should handle API errors gracefully', async () => {
    // Mock failed API response
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      statusText: 'Internal Server Error'
    });
    
    await expect(api.query('test')).rejects.toThrow('Query failed');
  });
});
```

### E2E Testing

```typescript
// e2e/chat.spec.ts
import { test, expect } from '@playwright/test';

test('complete chat interaction flow', async ({ page }) => {
  await page.goto('/');
  
  // Type a question
  await page.fill('[placeholder="Ask a question..."]', 'What is machine learning?');
  await page.click('button[type="submit"]');
  
  // Wait for streaming response
  await expect(page.locator('.message.assistant')).toBeVisible();
  
  // Check for citations
  await expect(page.locator('.citations')).toBeVisible();
  
  // Check for NBA actions
  await expect(page.locator('.nba-actions')).toBeVisible();
  
  // Click on a citation
  await page.click('.citation-badge:first-child');
  await expect(page.locator('[role="dialog"]')).toBeVisible();
});
```

## Performance Optimizations

### Streaming and Virtualization

```typescript
// components/VirtualizedMessageList.tsx
import { FixedSizeList as List } from 'react-window';

export function VirtualizedMessageList({ messages }: { messages: Message[] }) {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <MessageComponent message={messages[index]} />
    </div>
  );
  
  return (
    <List
      height={600}
      itemCount={messages.length}
      itemSize={100}
      className="message-list"
    >
      {Row}
    </List>
  );
}
```

### Memoization and Optimization

```typescript
// Memoized components for performance
export const MemoizedAssistantMessage = React.memo(AssistantMessage);
export const MemoizedCitationList = React.memo(CitationList);
export const MemoizedNBAActionList = React.memo(NBAActionList);

// Optimized state updates
const useChatStore = create<ChatState>((set, get) => ({
  messages: [],
  addMessage: (message) => set((state) => ({
    messages: [...state.messages, message]
  })),
  // Use immer for complex state updates
  updateMessage: (id, updates) => set(
    produce((state) => {
      const message = state.messages.find(m => m.id === id);
      if (message) {
        Object.assign(message, updates);
      }
    })
  )
}));
```