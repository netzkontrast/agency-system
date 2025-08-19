---
inclusion: always
---

# Kohärenz Protokoll - Project Context

## Project Overview

The Kohärenz Protokoll is an authoring software for structured knowledge processing and querying with semantic search and AI-assisted analysis. It's a multi-layered application that combines modern web technologies with AI orchestration frameworks.

## Architecture & Technology Stack

### Frontend (apps/web)
- **Framework**: Next.js 14 with App Router
- **AI Integration**: ai-sdk v5 for streaming and real-time interaction
- **UI Components**: shadcn/ui for consistent user interface
- **Main Features**: Guide-Chat Interface with NBA-Actions, Query result visualization, Persona Management

### API Layer (apps/web/src/app/api)
- **Technology**: Next.js API Routes (Node/Edge)
- **Key Endpoints**:
  - `/api/ingest` - Content Ingestion
  - `/api/qa-tag` - QA Generation and Tagging
  - `/api/query` - Semantic Query
  - `/api/judge/context` - Context Evaluation
  - `/api/persona` - Persona Management

### Orchestration (packages/flows)
- **Framework**: PocketFlow for workflow orchestration
- **Key Nodes**: Parse, Segment, GenQuestions, GenAnswers, Embed, Upsert/Relate
- **Properties**: Short, idempotent steps

### Agents (packages/agents)
- **Framework**: Fast Agent with MCP-Tools
- **Capabilities**: Filesystem access, HTTP requests, specialized tasks

### Data Access (packages/core)
- **Vector Store**: Qdrant for semantic search (collections: sources, thoughts_q, thoughts_a, persona_thoughts)
- **Relational Database**: Postgres with pgvector (tags, questions, answers, relations, personas)
- **SDK**: Unified interface for both storage types

### AI Models (packages/core)
- **Provider Adapters**: LM Studio (local dev), OpenRouter (production/fallback)
- **ModelRegistry**: Central configuration and selection

## Development Principles

### Agentic Coding Approach
1. **Start Simple**: Begin with small, simple solutions
2. **Design First**: Always create high-level design (`docs/design.md`) before implementation
3. **Human-AI Collaboration**: Humans design, AI implements
4. **Iterative Development**: Expect to repeat design-implementation cycles frequently

### PocketFlow Best Practices
- **Shared Store Pattern**: Use shared dictionary for node communication
- **Fail Fast**: Leverage built-in retry and fallback mechanisms
- **Separation of Concerns**: Keep data schema separate from compute logic
- **Utility Functions**: Implement external integrations as utilities, not built-ins

### Code Quality Standards
- **Minimal Code**: Write only the absolute minimal code needed
- **No Exception Handling in Utilities**: Let Node retry mechanisms handle failures
- **Logging**: Add comprehensive logging for debugging
- **Idempotent Operations**: Ensure operations can be safely repeated

## File Structure Conventions

```
├── apps/web/              # Next.js Frontend and API Routes
├── packages/
│   ├── core/             # Shared SDK, ModelRegistry, Types
│   ├── flows/            # PocketFlow Orchestration
│   └── agents/           # Fast Agent with MCP-Tools
├── sql/                  # Database schema and migrations
├── docs/                 # Documentation
├── utils/                # Utility functions (Python)
├── main.py               # Entry point
├── flow.py               # Flow definitions
└── nodes.py              # Node definitions
```

## Data Flow Patterns

1. **Ingestion**: Content → Parse → Segment → Store (Qdrant + Postgres)
2. **QA Generation**: Spans → GenQuestions → GenAnswers → Embed → Store
3. **Query**: Question → Semantic Search → Tag Expansion → Results with Citations
4. **Evaluation**: Context → Judge → NBA-Actions → Feedback Storage

## Quality Assurance Requirements

- **Citations**: Every mid-answer must have ≥1 citation
- **Question Limits**: Max 3 questions per span
- **Deduplication**: Use clustering to avoid duplicates
- **Spoiler Gate**: Chapter/beat restrictions before retrieval

## Environment Configuration

- **Development**: LM Studio for local AI models
- **Production**: OpenRouter for AI model access
- **Databases**: Postgres with pgvector + Qdrant vector database
- **Package Manager**: pnpm for Node.js dependencies

## API Standards

- **Format**: RESTful JSON APIs
- **Error Handling**: Consistent error format with descriptive messages
- **Authentication**: Development mode has no auth (implement for production)
- **Rate Limiting**: Should be implemented for production environments

## Development Workflow

1. **Requirements**: Define user-centric problem statements
2. **Flow Design**: Create high-level workflow with mermaid diagrams
3. **Utilities**: Implement necessary external integrations
4. **Data Design**: Design shared store structure
5. **Node Design**: Plan node interactions and data flow
6. **Implementation**: Build nodes and flows
7. **Optimization**: Iterate on design and implementation
8. **Reliability**: Add comprehensive testing and error handling