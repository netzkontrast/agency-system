# Kohärenz Protokoll - AI Assistant Guide

> **CRITICAL**: This is the definitive guide for AI assistants working on the Kohärenz Protokoll project. Read carefully and follow these guidelines precisely.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Architecture & Technology Stack](#architecture--technology-stack)
4. [Development Workflow](#development-workflow)
5. [Agentic Coding Guidelines](#agentic-coding-guidelines)
6. [PocketFlow Development Patterns](#pocketflow-development-patterns)
7. [Frontend Development](#frontend-development)
8. [API Development](#api-development)
9. [Testing Standards](#testing-standards)
10. [Git Workflow](#git-workflow)
11. [Key Conventions](#key-conventions)

---

## Project Overview

### What is Kohärenz Protokoll?

**Kohärenz Protokoll** is an authoring software for structured knowledge processing and querying with semantic search and AI-assisted analysis. It combines modern web technologies with AI orchestration frameworks to enable:

- **Content Ingestion**: Processing and structuring narrative content
- **Semantic Search**: Vector-based retrieval with Qdrant
- **QA Generation**: Automated question-answer pair creation
- **Persona Management**: Context-aware personalized experiences
- **Guide-Chat Interface**: Interactive exploration with NBA (Next Best Action) recommendations

### Dual-Purpose Repository

This repository serves two distinct but related purposes:

1. **Primary: Kohärenz Protokoll Application**
   - Production software for knowledge processing
   - Multi-layered architecture with Next.js, PocketFlow, and AI integration
   - Located in: `apps/`, `packages/`, `sql/`

2. **Secondary: AEGIS Narrative Project**
   - Creative writing project (philosophical science fiction)
   - Story content and planning documents
   - Located in: `narrative/`

### Core Philosophy

**Humans Design, AI Implements**
- Start small and simple
- Design at high level before implementation
- Frequently ask for feedback and clarification
- Iterate on design before scaling up

---

## Repository Structure

```
agency-system/
├── apps/
│   └── web/                 # Next.js 14 frontend and API routes
│       ├── src/
│       │   ├── app/         # App Router pages and API routes
│       │   ├── components/  # React components (shadcn/ui)
│       │   └── lib/         # Client-side utilities
│       └── package.json
│
├── packages/
│   ├── core/                # Shared SDK, ModelRegistry, Types
│   │   ├── src/
│   │   │   ├── db/          # Database clients (Postgres, Qdrant)
│   │   │   ├── models/      # AI model adapters
│   │   │   └── types/       # TypeScript type definitions
│   │   └── package.json
│   │
│   ├── flows/               # PocketFlow orchestration (Python)
│   │   ├── src/
│   │   │   ├── nodes.py     # Node definitions
│   │   │   ├── flows.py     # Flow compositions
│   │   │   └── __init__.py
│   │   └── package.json
│   │
│   └── agents/              # Fast Agent with MCP-Tools
│       ├── src/
│       │   ├── agent.py     # Agent implementation
│       │   └── __init__.py
│       └── package.json
│
├── sql/
│   ├── schema.sql           # PostgreSQL schema
│   ├── migrations/          # Database migrations
│   ├── seeds/               # Seed data
│   └── qdrant_collections.json  # Qdrant configuration
│
├── utils/                   # Python utility functions
│   ├── call_llm.py          # LLM wrapper
│   ├── get_embedding.py     # Embedding generation
│   └── vector_search.py     # Vector search utilities
│
├── docs/                    # Project documentation
│   ├── ARCHITECTURE.md      # System architecture
│   ├── API.md               # API documentation
│   ├── design.md            # High-level design docs
│   └── PROMPTS.md           # Prompt templates
│
├── narrative/               # AEGIS creative writing project
│   ├── chapters/            # Chapter content and planning
│   ├── OVERALL_PLOT.md      # Story structure
│   └── *.md                 # Narrative documentation
│
├── research/                # Research materials and analysis
│
├── .kiro/                   # Kiro spec system
│   ├── steering/            # Development patterns and guidelines
│   │   ├── project-context.md
│   │   ├── development-workflow.md
│   │   ├── pocketflow-patterns.md
│   │   ├── api-integration-patterns.md
│   │   ├── testing-patterns.md
│   │   └── ...
│   └── specs/               # Feature specifications
│
├── main.py                  # Python entry point
├── flow.py                  # Flow definitions
├── nodes.py                 # Node definitions
├── requirements.txt         # Python dependencies
├── package.json             # Root package.json (pnpm workspace)
├── pnpm-workspace.yaml      # PNPM workspace configuration
└── CLAUDE.md                # This file

```

---

## Architecture & Technology Stack

### System Architecture

```mermaid
flowchart TD
    subgraph Frontend["🖥️ Frontend Layer"]
        UI[Next.js 14 App Router]
        Chat[Guide-Chat Interface]
        Persona[Persona Management]
        UI --> Chat
        UI --> Persona
    end

    subgraph API["🔌 API Layer"]
        Routes[Next.js API Routes]
        Ingest[/api/ingest]
        Query[/api/query]
        Judge[/api/judge/context]
        PersonaAPI[/api/persona]
        Routes --> Ingest
        Routes --> Query
        Routes --> Judge
        Routes --> PersonaAPI
    end

    subgraph Orchestration["⚙️ Orchestration"]
        PF[PocketFlow Engine]
        Parse[ParseNode]
        Segment[SegmentNode]
        GenQ[GenQuestionsNode]
        GenA[GenAnswersNode]
        PF --> Parse --> Segment --> GenQ --> GenA
    end

    subgraph Data["💾 Data Layer"]
        Qdrant[(Qdrant Vector DB)]
        Postgres[(PostgreSQL + pgvector)]
    end

    subgraph AI["🧠 AI Models"]
        ModelReg[ModelRegistry]
        LMStudio[LM Studio - Dev]
        OpenRouter[OpenRouter - Prod]
        ModelReg --> LMStudio
        ModelReg --> OpenRouter
    end

    Frontend ==> API
    API ==> Orchestration
    API ==> Data
    Orchestration ==> Data
    Orchestration ==> AI
```

### Technology Stack

#### Frontend (apps/web)
- **Framework**: Next.js 14 with App Router
- **AI Integration**: ai-sdk v5 for streaming
- **UI Components**: shadcn/ui (Radix UI + Tailwind CSS)
- **State Management**: React hooks + Zustand (when needed)
- **Language**: TypeScript 5.x

#### API Layer
- **Technology**: Next.js API Routes (Node/Edge runtime)
- **Format**: RESTful JSON APIs
- **Streaming**: Server-Sent Events (SSE) via ai-sdk

#### Orchestration (packages/flows)
- **Framework**: PocketFlow (Python)
- **Properties**: Short, idempotent steps
- **Patterns**: Map-Reduce, Agent, RAG, Workflow

#### Data Layer
- **Vector Database**: Qdrant
  - Collections: `sources`, `thoughts_q`, `thoughts_a`, `persona_thoughts`
- **Relational Database**: PostgreSQL with pgvector extension
  - Tables: `spans`, `questions`, `answers`, `tags`, `relations`, `personas`

#### AI Models
- **Development**: LM Studio (local models)
- **Production**: OpenRouter (cloud models)
- **Registry**: Central ModelRegistry for configuration

#### Package Management
- **Node.js**: pnpm 8.x (monorepo workspace)
- **Python**: pip with requirements.txt

---

## Development Workflow

### Spec-Driven Development Process

This project follows a rigorous spec-driven approach. **ALL** significant features must go through this process:

#### Phase 1: Requirements Gathering

1. **Create Requirements Document** in `.kiro/specs/[feature-name]/requirements.md`

```markdown
# Requirements Document: [Feature Name]

## Introduction
Brief description of the feature and its purpose

## Requirements

### Requirement 1.1: [Title]
**User Story:** As a [role], I want [feature], so that [benefit]

#### Acceptance Criteria (EARS Format)
1. WHEN [event] THEN [system] SHALL [response]
2. IF [precondition] THEN [system] SHALL [response]
3. WHILE [condition] THE [system] SHALL [behavior]

### Requirement 1.2: [Title]
...
```

2. **Requirements Review Checklist**
   - [ ] All user stories follow standard format
   - [ ] Acceptance criteria use EARS format
   - [ ] Edge cases and error conditions considered
   - [ ] Success criteria are measurable and testable
   - [ ] Requirements are atomic and independent

#### Phase 2: Design Document Creation

1. **Research Phase**
   - Identify knowledge gaps
   - Research technical approaches
   - Analyze existing codebase patterns
   - Document findings

2. **Create Design Document** in `.kiro/specs/[feature-name]/design.md`

```markdown
# Design Document: [Feature Name]

## Overview
High-level summary of the solution

## Architecture
System components and their interactions (include mermaid diagrams)

## Components and Interfaces
Detailed component specifications

## Data Models
Data structures and relationships

## Flow Design (for PocketFlow features)
- Applicable design patterns (Agent/RAG/MapReduce/Workflow)
- High-level node descriptions
- Flow diagram

## Error Handling
Error scenarios and recovery strategies

## Testing Strategy
How the solution will be tested
```

3. **Design Review Checklist**
   - [ ] Addresses all requirements
   - [ ] Follows project architecture patterns
   - [ ] Includes mermaid diagrams
   - [ ] Considers scalability and performance
   - [ ] Documents design decisions and rationales

#### Phase 3: Implementation Planning

1. **Create Task List** in `.kiro/specs/[feature-name]/tasks.md`

```markdown
# Implementation Tasks: [Feature Name]

## Tasks

- [ ] 1. Task Description
  - Specific implementation details and objectives
  - Files to create/modify with clear specifications
  - Testing requirements and acceptance criteria
  - _Requirements: 1.1, 2.3_

- [ ] 2. Next Task
  ...
```

2. **Task Breakdown Principles**
   - Each task completable in 1-2 hours maximum
   - Tasks build incrementally
   - No orphaned code - everything must integrate
   - Focus exclusively on coding tasks
   - Reference specific requirements
   - Include test creation

#### Phase 4: Task Execution

**Pre-Execution Requirements**
- [ ] Requirements document exists and is current
- [ ] Design document exists and addresses all requirements
- [ ] Task list is approved and up-to-date
- [ ] Development environment is properly configured

**Execution Principles**
- **One Task at a Time**: Complete before moving to next
- **Requirements Alignment**: Verify against specific requirements
- **Incremental Progress**: Build on previous tasks
- **Test Integration**: Include testing in task completion
- **Documentation Updates**: Update docs during implementation

**Task Completion Criteria**
- [ ] All acceptance criteria met
- [ ] Code follows established patterns
- [ ] Tests written and passing
- [ ] Integration verified
- [ ] Documentation updated
- [ ] No breaking changes without approval

---

## Agentic Coding Guidelines

### Core Principles

**Humans Design, AI Implements** - This is a collaboration:

| Phase | Human Involvement | AI Involvement | Notes |
|-------|-------------------|----------------|-------|
| 1. Requirements | ★★★ High | ★☆☆ Low | Humans understand context and needs |
| 2. Flow Design | ★★☆ Medium | ★★☆ Medium | Humans specify high-level, AI fills details |
| 3. Utilities | ★★☆ Medium | ★★☆ Medium | Humans provide APIs, AI implements |
| 4. Data Design | ★☆☆ Low | ★★★ High | AI designs schema, humans verify |
| 5. Node Design | ★☆☆ Low | ★★★ High | AI designs based on flow |
| 6. Implementation | ★☆☆ Low | ★★★ High | AI implements based on design |
| 7. Optimization | ★★☆ Medium | ★★☆ Medium | Humans evaluate, AI optimizes |
| 8. Reliability | ★☆☆ Low | ★★★ High | AI writes tests and handles edge cases |

### Development Guidelines

#### 1. Start Simple
- Begin with minimal viable implementation
- Avoid premature optimization
- Add complexity only when needed
- **Example**: Start with in-memory storage before adding database persistence

#### 2. Design Before Code
- Always create or reference design document
- Understand the full flow before implementing
- Draw diagrams for complex interactions
- **Example**: For new API endpoint, document data flow end-to-end first

#### 3. Ask for Feedback
- When requirements are unclear, ask
- When multiple approaches exist, present options
- When stuck, explain the issue and potential solutions
- **Example**: "I see two approaches: A) batch processing or B) streaming. Which fits better?"

#### 4. Minimal Code
- Write only the code needed to meet requirements
- No speculative features
- No complex abstractions unless justified
- **Example**: Don't create a generic framework for a single use case

#### 5. Separation of Concerns
- Keep data schema separate from compute logic
- Use Shared Store pattern in PocketFlow
- Isolate external integrations in utilities
- **Example**: Database queries in utilities, business logic in nodes

#### 6. Fail Fast
- Leverage built-in retry mechanisms
- Add validation to trigger retries
- Log errors with sufficient context
- **Example**: Validate LLM outputs and raise error if malformed

---

## PocketFlow Development Patterns

### Node Structure

Every PocketFlow Node follows this three-phase pattern:

```python
class ExampleNode(Node):
    """
    One-line description of what this node does.
    """

    def prep(self, shared):
        """
        PREP PHASE: Read and preprocess data from shared store.

        Purpose:
        - Read data from shared store
        - Transform/serialize for exec
        - NO external API calls
        - NO LLM calls

        Args:
            shared: The shared store dictionary

        Returns:
            Data needed by exec() (any type)
        """
        return shared["input_key"]

    def exec(self, prep_res):
        """
        EXEC PHASE: Execute core logic with retries.

        Purpose:
        - Core processing logic
        - Call utility functions
        - Call LLMs
        - NO exception handling (let Node retry mechanism handle)
        - Must be idempotent if retries enabled

        Args:
            prep_res: Output from prep()

        Returns:
            Processing result (any type)
        """
        # This is automatically retried on failure
        result = call_llm(f"Process: {prep_res}")

        # Add validation to trigger retry
        if not is_valid(result):
            raise ValueError("Invalid result - will trigger retry")

        return result

    def post(self, shared, prep_res, exec_res):
        """
        POST PHASE: Write results and determine next action.

        Purpose:
        - Write results to shared store
        - Update database
        - Log results
        - Return action for flow transition

        Args:
            shared: The shared store dictionary
            prep_res: Output from prep()
            exec_res: Output from exec()

        Returns:
            Action string for flow transition (default: "default")
        """
        shared["output_key"] = exec_res
        return "default"  # or specific action name

# Usage with retry configuration
node = ExampleNode()
node.max_retries = 3  # Retry up to 3 times
node.wait = 2.0       # Wait 2 seconds between retries
```

### Flow Patterns

#### Sequential Flow
```python
# Simple sequence
parse_node >> segment_node >> embed_node >> store_node

# Create flow
flow = Flow(start=parse_node)
flow.run(shared)
```

#### Branching Flow
```python
# Decision-based branching
decide_node - "search" >> search_node
decide_node - "answer" >> answer_node

# Loop back pattern
search_node - "continue" >> decide_node  # Loop back
search_node - "done" >> answer_node      # Exit loop

# Create flow
flow = Flow(start=decide_node)
```

#### Nested Flow
```python
# Sub-flow composition
file_flow = Flow(start=load_node >> process_node >> save_node)

# Batch flow that runs file_flow multiple times
class ProcessAllFiles(BatchFlow):
    def prep(self, shared):
        return [{"filename": f} for f in shared["files"]]

batch_flow = ProcessAllFiles(start=file_flow)
```

### Shared Store Design

**Hierarchical organization for this project:**

```python
shared = {
    "input": {
        "content": "text to process",
        "metadata": {
            "source": "chapter_1.md",
            "chapter": "chapter_1",
            "beat": "opening",
            "timestamp": "2024-01-01T00:00:00Z"
        }
    },
    "processing": {
        "spans": [],           # List of text spans
        "questions": [],       # Generated questions
        "answers": [],         # Generated answers
        "embeddings": [],      # Vector embeddings
        "citations": []        # Citation references
    },
    "output": {
        "results": [],
        "summary": "",
        "metrics": {
            "processing_time": 0,
            "spans_created": 0,
            "questions_generated": 0
        }
    },
    "context": {
        "persona_id": None,
        "user_preferences": {},
        "session_data": {}
    }
}
```

### Design Patterns

#### 1. RAG (Retrieval Augmented Generation)

**When to use:** Answering questions with context from knowledge base

```python
class RetrieveNode(Node):
    def prep(self, shared):
        return shared["query"]

    def exec(self, query):
        # Semantic search in Qdrant
        return vector_search(query, collection="thoughts_q")

    def post(self, shared, prep_res, exec_res):
        shared["retrieved_context"] = exec_res
        return "default"

class GenerateAnswerNode(Node):
    def prep(self, shared):
        return {
            "query": shared["query"],
            "context": shared["retrieved_context"]
        }

    def exec(self, prep_res):
        prompt = f"""
Query: {prep_res['query']}

Context:
{prep_res['context']}

Answer the query using the context. Include citations.
"""
        return call_llm(prompt)

    def post(self, shared, prep_res, exec_res):
        shared["answer"] = exec_res
        return "default"

# Flow
retrieve >> generate
rag_flow = Flow(start=retrieve)
```

#### 2. Map-Reduce

**When to use:** Processing large datasets or multiple items

```python
class MapQuestions(BatchNode):
    """Generate questions for each span."""

    def prep(self, shared):
        # Return list of spans to process
        return shared["processing"]["spans"]

    def exec(self, span):
        # Process single span
        prompt = f"Generate 3 atomic questions about: {span['content']}"
        questions = call_llm(prompt)
        return parse_questions(questions)

    def post(self, shared, prep_res, exec_res_list):
        # Flatten all question lists
        all_questions = [q for qs in exec_res_list for q in qs]
        shared["processing"]["questions"] = all_questions
        return "default"

class ReduceQuestions(Node):
    """Deduplicate and consolidate questions."""

    def prep(self, shared):
        return shared["processing"]["questions"]

    def exec(self, questions):
        # Use clustering to deduplicate
        return deduplicate_questions(questions)

    def post(self, shared, prep_res, exec_res):
        shared["processing"]["questions"] = exec_res
        return "default"

# Flow
map_node >> reduce_node
mapreduce_flow = Flow(start=map_node)
```

#### 3. Agent Pattern

**When to use:** Dynamic decision-making based on context

```python
class DecideActionNode(Node):
    """Agent decides next action based on context."""

    def prep(self, shared):
        return {
            "task": shared["context"]["task"],
            "previous_actions": shared["context"].get("actions", []),
            "available_actions": ["search", "analyze", "answer", "clarify"]
        }

    def exec(self, prep_res):
        prompt = f"""
Task: {prep_res['task']}
Previous Actions: {prep_res['previous_actions']}
Available Actions: {prep_res['available_actions']}

Choose the next best action and explain why.

Output in YAML:
```yaml
action: [action_name]
reasoning: [explanation]
parameters:
  key: value
```
"""
        response = call_llm(prompt)
        yaml_str = response.split("```yaml")[1].split("```")[0]
        decision = yaml.safe_load(yaml_str)

        # Validate decision
        assert decision["action"] in prep_res["available_actions"]

        return decision

    def post(self, shared, prep_res, exec_res):
        # Store decision
        shared["context"].setdefault("actions", []).append(exec_res)
        # Return action as flow transition
        return exec_res["action"]

# Flow with branching
decide - "search" >> search_node
decide - "analyze" >> analyze_node
decide - "answer" >> answer_node
decide - "clarify" >> clarify_node

# All actions can loop back to decide
search_node >> decide
analyze_node >> decide
clarify_node >> decide
# Only answer completes the flow

agent_flow = Flow(start=decide)
```

### Utility Functions

**Key principle:** NO exception handling in utilities. Let Node retry mechanism handle failures.

```python
# utils/call_llm.py
from core.models import ModelRegistry

def call_llm(prompt: str, model: str = "default") -> str:
    """
    Call LLM with prompt.

    Args:
        prompt: The prompt string
        model: Model identifier (default uses ModelRegistry default)

    Returns:
        Generated text response

    Raises:
        Exception: Any error is raised to trigger Node retry
    """
    # NO try/except - let Node handle retries
    registry = ModelRegistry()
    response = registry.generate(prompt, model=model)
    return response

# Test function
if __name__ == "__main__":
    result = call_llm("Hello, how are you?")
    print(result)
```

```python
# utils/vector_search.py
from core.db import get_qdrant_client
from utils.get_embedding import get_embedding

def vector_search(
    query: str,
    collection: str = "thoughts_q",
    limit: int = 10
) -> list[dict]:
    """
    Semantic search in Qdrant.

    Args:
        query: Search query
        collection: Qdrant collection name
        limit: Maximum results

    Returns:
        List of search results with id, content, score
    """
    # Get embedding
    query_vector = get_embedding(query)

    # Search
    client = get_qdrant_client()
    results = client.search(
        collection_name=collection,
        query_vector=query_vector,
        limit=limit
    )

    return [
        {
            "id": r.id,
            "content": r.payload.get("content"),
            "score": r.score,
            "metadata": r.payload.get("metadata", {})
        }
        for r in results
    ]

if __name__ == "__main__":
    results = vector_search("What is AEGIS?")
    print(f"Found {len(results)} results")
    for r in results:
        print(f"Score: {r['score']:.3f} - {r['content'][:100]}")
```

---

## Frontend Development

### Next.js App Router Patterns

#### Page Structure
```typescript
// app/chat/page.tsx
import { ChatInterface } from '@/components/chat-interface';

export default function ChatPage() {
  return (
    <main className="container mx-auto p-4">
      <ChatInterface />
    </main>
  );
}
```

#### API Route Pattern
```typescript
// app/api/query/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const QuerySchema = z.object({
  query: z.string().min(1),
  personaId: z.string().optional(),
  limit: z.number().int().positive().default(10)
});

export async function POST(request: NextRequest) {
  try {
    // Parse and validate request
    const body = await request.json();
    const { query, personaId, limit } = QuerySchema.parse(body);

    // Process query
    const results = await processQuery(query, personaId, limit);

    // Return response
    return NextResponse.json({
      success: true,
      data: results,
      metadata: {
        timestamp: new Date().toISOString(),
        version: '1.0'
      }
    });

  } catch (error) {
    console.error('Query error:', error);

    return NextResponse.json({
      success: false,
      error: {
        code: 'QUERY_ERROR',
        message: error instanceof Error ? error.message : 'Unknown error',
        details: error
      }
    }, { status: 500 });
  }
}
```

#### Streaming API Route (ai-sdk v5)
```typescript
// app/api/chat/route.ts
import { streamText } from 'ai';
import { openai } from '@ai-sdk/openai';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = await streamText({
    model: openai('gpt-4'),
    messages,
  });

  return result.toAIStreamResponse();
}
```

### Component Patterns

#### shadcn/ui Component Usage
```typescript
// components/chat-interface.tsx
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { useChat } from 'ai/react';

export function ChatInterface() {
  const { messages, input, handleInputChange, handleSubmit } = useChat();

  return (
    <Card className="p-4">
      <div className="space-y-4">
        {messages.map(m => (
          <div key={m.id} className={m.role === 'user' ? 'text-right' : 'text-left'}>
            <div className="inline-block p-2 rounded bg-muted">
              {m.content}
            </div>
          </div>
        ))}
      </div>

      <form onSubmit={handleSubmit} className="mt-4 flex gap-2">
        <Input
          value={input}
          onChange={handleInputChange}
          placeholder="Ask a question..."
          className="flex-1"
        />
        <Button type="submit">Send</Button>
      </form>
    </Card>
  );
}
```

---

## API Development

### Standard API Response Format

All API endpoints should use this consistent format:

```typescript
interface APIResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  metadata?: {
    timestamp: string;
    requestId?: string;
    version: string;
  };
}
```

### API Endpoints

#### 1. POST /api/ingest
**Purpose:** Ingest content for processing

```typescript
// Request
{
  "content": string,
  "metadata": {
    "source": string,
    "chapter": string,
    "beat": string
  }
}

// Response
{
  "success": true,
  "data": {
    "id": string,
    "spans_created": number,
    "processing_time": number
  }
}
```

#### 2. POST /api/qa-tag
**Purpose:** Generate QA pairs and tags

```typescript
// Request
{
  "spanIds": string[]
}

// Response
{
  "success": true,
  "data": {
    "questions_generated": number,
    "answers_generated": number,
    "tags_created": number
  }
}
```

#### 3. POST /api/query
**Purpose:** Semantic query with retrieval

```typescript
// Request
{
  "query": string,
  "personaId"?: string,
  "limit"?: number
}

// Response
{
  "success": true,
  "data": {
    "answer": string,
    "citations": Array<{
      "spanId": string,
      "content": string,
      "score": number
    }>,
    "nba_actions": Array<{
      "type": string,
      "label": string,
      "data": any
    }>
  }
}
```

#### 4. POST /api/judge/context
**Purpose:** Evaluate context quality

```typescript
// Request
{
  "context": string,
  "query": string,
  "criteria": string[]
}

// Response
{
  "success": true,
  "data": {
    "quality_score": number,
    "evaluation": {
      "relevance": number,
      "completeness": number,
      "accuracy": number
    },
    "feedback": string,
    "suggestions": string[]
  }
}
```

---

## Testing Standards

### Node Testing Pattern
```python
# packages/flows/tests/test_nodes.py
import pytest
from src.nodes import ParseNode

def test_parse_node():
    """Test ParseNode splits content into spans."""
    # Arrange
    node = ParseNode()
    shared = {
        "input": {
            "content": "Paragraph 1.\n\nParagraph 2.\n\nParagraph 3.",
            "metadata": {"source": "test.md"}
        },
        "processing": {"spans": []}
    }

    # Act
    node.run(shared)

    # Assert
    assert "spans" in shared["processing"]
    assert len(shared["processing"]["spans"]) == 3
    assert shared["processing"]["spans"][0]["content"] == "Paragraph 1."
```

### Flow Testing Pattern
```python
def test_ingestion_flow():
    """Test complete ingestion flow."""
    # Arrange
    from src.flows import create_ingestion_flow
    flow = create_ingestion_flow()
    shared = {
        "input": {"content": "Test content", "metadata": {}},
        "processing": {},
        "output": {}
    }

    # Act
    flow.run(shared)

    # Assert
    assert shared["output"]["spans_created"] > 0
    assert "summary" in shared["output"]
```

### API Testing Pattern
```typescript
// apps/web/__tests__/api/query.test.ts
import { POST } from '@/app/api/query/route';

describe('POST /api/query', () => {
  it('should return results for valid query', async () => {
    const request = new Request('http://localhost/api/query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: 'What is AEGIS?' })
    });

    const response = await POST(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.success).toBe(true);
    expect(data.data.answer).toBeDefined();
    expect(data.data.citations).toBeInstanceOf(Array);
  });

  it('should return error for invalid query', async () => {
    const request = new Request('http://localhost/api/query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: '' })
    });

    const response = await POST(request);
    const data = await response.json();

    expect(response.status).toBe(500);
    expect(data.success).toBe(false);
    expect(data.error).toBeDefined();
  });
});
```

---

## Git Workflow

### Branch Naming Convention
- `feature/spec-name` - For spec-driven features
- `fix/issue-description` - For bug fixes
- `docs/update-description` - For documentation

### Commit Message Format
```
type(scope): brief description

Longer description if needed

- Requirement: REQ-1.1
- Task: Implement user authentication
- Files: auth.py, user.py
```

**Types:** feat, fix, docs, style, refactor, test, chore

### Pull Request Process

1. Create branch from main
2. Implement changes following spec
3. Write tests
4. Update documentation
5. Create PR with this template:

```markdown
## Changes
Brief description of what was implemented

## Requirements Addressed
- REQ-1.1: User authentication
- REQ-2.3: Session management

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project patterns
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Steering guidelines followed
```

---

## Key Conventions

### File Naming
- **Python**: `snake_case.py`
- **TypeScript**: `kebab-case.tsx` or `kebab-case.ts`
- **Components**: `PascalCase.tsx` (for React components)
- **Documentation**: `SCREAMING_CASE.md` for important docs, `lowercase.md` for others

### Code Style

#### Python
```python
# Use type hints
def process_data(input_data: str, max_items: int = 10) -> list[dict]:
    """Process input data and return results."""
    pass

# Use descriptive variable names
question_embeddings = get_embeddings(questions)

# Prefer list comprehensions
results = [process(item) for item in items if is_valid(item)]
```

#### TypeScript
```typescript
// Use interfaces for object shapes
interface QueryRequest {
  query: string;
  personaId?: string;
  limit?: number;
}

// Use async/await
async function fetchData(): Promise<Data> {
  const response = await fetch('/api/data');
  return response.json();
}

// Use destructuring
const { query, limit = 10 } = request;
```

### Logging Standards

#### Python
```python
import logging

logger = logging.getLogger(__name__)

class ProcessNode(Node):
    def exec(self, prep_res):
        logger.info(f"Processing {len(prep_res)} items")
        result = process_items(prep_res)
        logger.debug(f"Result: {result}")
        return result
```

#### TypeScript
```typescript
// Use console methods appropriately
console.log('Info:', data);        // Development info
console.error('Error:', error);    // Errors
console.warn('Warning:', warning); // Warnings
console.debug('Debug:', details);  // Debug details
```

### Environment Variables

**Required:**
- `DATABASE_URL` - PostgreSQL connection string
- `QDRANT_URL` - Qdrant server URL
- `QDRANT_API_KEY` - Qdrant API key (if needed)
- `LM_STUDIO_URL` - LM Studio API URL (dev)
- `OPENROUTER_API_KEY` - OpenRouter API key (prod)

**Optional:**
- `NODE_ENV` - Environment (development/production)
- `LOG_LEVEL` - Logging level (debug/info/warn/error)

### Quality Standards

#### Code Quality
- **Minimal Code**: Write only what's needed
- **Type Safety**: Use TypeScript/Python type hints
- **Error Handling**: Let PocketFlow handle Node retries
- **Logging**: Add structured logging
- **Documentation**: Comment complex logic

#### Performance
- **Database Queries**: Use indexes, limit results
- **Vector Search**: Tune similarity thresholds
- **LLM Calls**: Cache when appropriate
- **Batch Processing**: Use BatchNode for large datasets

#### Security
- **API Keys**: Never commit to git
- **Input Validation**: Use Zod for TypeScript
- **SQL Injection**: Use parameterized queries
- **XSS**: Sanitize user input

---

## Quick Reference

### Common Commands

```bash
# Install dependencies
pnpm install

# Run development server
pnpm dev

# Run tests
pnpm test

# Type check
pnpm type-check

# Lint
pnpm lint

# Build
pnpm build
```

### Python Virtual Environment

```bash
# Create virtual environment
python -m venv venv

# Activate
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

### Database Setup

```bash
# Create PostgreSQL database
createdb kohaerenz_protokoll

# Run schema
psql kohaerenz_protokoll < sql/schema.sql

# Run migrations
psql kohaerenz_protokoll < sql/migrations/001_initial.sql
```

### Qdrant Setup

```bash
# Start Qdrant (Docker)
docker run -p 6333:6333 qdrant/qdrant

# Create collections (use sql/qdrant_collections.json)
```

---

## Getting Help

### Documentation
- **Architecture**: See `docs/ARCHITECTURE.md`
- **API Docs**: See `docs/API.md`
- **Prompts**: See `docs/PROMPTS.md`
- **Steering Docs**: See `.kiro/steering/`

### Design Patterns
- **PocketFlow**: See `.kiro/steering/pocketflow-patterns.md`
- **API Integration**: See `.kiro/steering/api-integration-patterns.md`
- **Testing**: See `.kiro/steering/testing-patterns.md`

### When in Doubt
1. Check if a spec exists in `.kiro/specs/`
2. Review similar existing code
3. Consult steering documents
4. Ask the human for clarification

---

## Remember

1. **Spec-Driven**: All significant features need requirements → design → tasks
2. **Start Simple**: Minimal implementation first, then iterate
3. **Design First**: High-level design before coding
4. **Ask Questions**: When unclear, ask rather than assume
5. **Test Everything**: Write tests as you code
6. **Document Changes**: Update docs with code changes
7. **Follow Patterns**: Use established patterns from steering docs

---

*This document is the single source of truth for AI assistants working on Kohärenz Protokoll. When in doubt, refer back to this guide.*
