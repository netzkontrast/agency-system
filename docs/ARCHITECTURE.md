# Architektur des Kohärenz Protokolls

## Überblick

Das Kohärenz Protokoll ist eine mehrschichtige Anwendung zur Verarbeitung und Abfrage strukturierter Inhalte mit KI-unterstützter Analyse. Die Architektur folgt einer modularen, skalierbaren Herangehensweise mit klaren Trennungen zwischen den Schichten.

```mermaid
flowchart TD
    %% Frontend Layer
    subgraph FL["🖥️ Frontend Layer"]
        direction TB
        UI[Next.js 14 App]
        Chat[Guide-Chat Interface]
        Persona[Persona Management]
        UI --> Chat
        UI --> Persona
    end
    
    %% API Layer
    subgraph AL["🔌 API Layer"]
        direction TB
        API[Next.js API Routes]
        subgraph "API Endpoints"
            Ingest[api/ingest]
            Query[api/query]
            Judge[api/judge/context]
            PersonaAPI[api/persona]
            QATag[api/qa-tag]
        end
    end
    
    %% Orchestration Layer
    subgraph OL["⚙️ Orchestration Layer"]
        direction TB
        PF[PocketFlow Engine]
        subgraph "Processing Nodes"
            Parse[ParseNode]
            Segment[SegmentNode]
            GenQ[GenQuestionsNode]
            GenA[GenAnswersNode]
            Embed[EmbedNode]
            Upsert[UpsertRelateNode]
        end
        PF --> Parse
        Parse --> Segment
        Segment --> GenQ
        GenQ --> GenA
        GenA --> Embed
        Embed --> Upsert
    end
    
    %% Agent Layer
    subgraph AgL["🤖 Agent Layer"]
        direction TB
        Agent[Fast Agent]
        subgraph "MCP Tools"
            MCP[MCP Interface]
            FS[Filesystem Access]
            HTTP[HTTP Client]
        end
        Agent --> MCP
        MCP --> FS
        MCP --> HTTP
    end
    
    %% Data Layer
    subgraph DL["💾 Data Layer"]
        direction LR
        subgraph VDB["Vector Database"]
            direction TB
            Qdrant[(Qdrant)]
            Sources[sources]
            ThoughtsQ[thoughts_q]
            ThoughtsA[thoughts_a]
            PersonaThoughts[persona_thoughts]
            Qdrant -.-> Sources
            Qdrant -.-> ThoughtsQ
            Qdrant -.-> ThoughtsA
            Qdrant -.-> PersonaThoughts
        end
        
        subgraph RDB["Relational Database"]
            direction TB
            Postgres[(PostgreSQL + pgvector)]
            Spans[spans]
            Questions[questions]
            Answers[answers]
            Tags[tags]
            Relations[relations]
            Personas[personas]
            Postgres -.-> Spans
            Postgres -.-> Questions
            Postgres -.-> Answers
            Postgres -.-> Tags
            Postgres -.-> Relations
            Postgres -.-> Personas
        end
    end
    
    %% AI Models Layer
    subgraph ML["🧠 AI Models Layer"]
        direction TB
        ModelReg[ModelRegistry]
        LMStudio[LM Studio<br/>Development]
        OpenRouter[OpenRouter<br/>Production]
        ModelReg --> LMStudio
        ModelReg --> OpenRouter
    end
    
    %% Layer Connections
    FL ==> AL
    AL ==> OL
    AL ==> AgL
    OL ==> DL
    AgL ==> DL
    OL ==> ML
    AgL ==> ML
```

## Systemkomponenten

### 1. Frontend (apps/web)

- **Framework**: Next.js 14 mit App Router
- **KI-Integration**: ai-sdk v5 für Streaming und Echtzeit-Interaktion
- **UI-Komponenten**: shadcn/ui für konsistente Benutzeroberfläche
- **Hauptfunktionen**:
  - Guide-Chat Interface mit NBA-Actions
  - Visualisierung von Abfrageergebnissen
  - Persona Management

### 2. API Layer (apps/web/src/app/api)

- **Technologie**: Next.js API Routes (Node/Edge)
- **Endpunkte**:
  - `/api/ingest` - Content Ingestion
  - `/api/qa-tag` - QA-Generierung und Tagging
  - `/api/query` - Semantische Abfrage
  - `/api/judge/context` - Kontextbewertung
  - `/api/persona` - Persona Management
- **Background Jobs**: für rechenintensive Tasks

### 3. Orchestrierung (packages/flows)

- **Framework**: PocketFlow für Workflow-Orchestrierung
- **Nodes**:
  - Parse: Text in Spans zerlegen
  - Segment: Semantisches Clustering
  - GenQuestions: Generierung atomarer Fragen
  - GenAnswers: Erstellung kurzer/mittlerer/langer Antworten
  - Embed: Vektoreinbettung generieren
  - Upsert/Relate: Speichern in Datenbanken
- **Eigenschaften**: Kurze, idempotente Steps

### 4. Agentik (packages/agents)

- **Framework**: Fast Agent mit MCP-Tools
- **Fähigkeiten**:
  - Dateisystemzugriff
  - HTTP-Anfragen
  - Spezialisierte Tasks
- **Integration**: Mit PocketFlow Workflows

### 5. Datenzugriff (packages/core)

- **Vektor Store**: Qdrant für semantische Suche
  - Collections: sources, thoughts_q, thoughts_a, persona_thoughts
- **Relationale Datenbank**: Postgres mit pgvector
  - Tags, Fragen, Antworten, Relationen
  - Personas und deren Gedanken
  - Bewertungen und Jobs
- **SDK**: Einheitliche Schnittstelle für beide Speichertypen

### 6. KI-Modelle (packages/core)

- **Provider-Adapter**:
  - LM Studio (lokale Entwicklung)
  - OpenRouter (Produktion/Fallback)
- **ModelRegistry**: Zentrale Konfiguration und Auswahl
- **Funktionen**: Textgenerierung, Embedding

## Datenfluss

### Content Ingestion Flow
```mermaid
sequenceDiagram
    participant Client
    participant API as /api/ingest
    participant Parse as ParseNode
    participant Segment as SegmentNode
    participant Qdrant
    participant Postgres
    
    Client->>API: POST content + metadata
    API->>Parse: Trigger PocketFlow
    Parse->>Parse: Split into semantic spans
    Parse->>Segment: Pass spans
    Segment->>Segment: Group semantically
    Segment->>Qdrant: Store span vectors
    Segment->>Postgres: Store span metadata
    Postgres-->>API: Success response
    API-->>Client: Ingestion complete
```

### QA Generation Flow
```mermaid
sequenceDiagram
    participant API as /api/qa-tag
    participant GenQ as GenQuestionsNode
    participant GenA as GenAnswersNode
    participant Embed as EmbedNode
    participant Upsert as UpsertRelateNode
    participant Qdrant
    participant Postgres
    
    API->>GenQ: Process span
    GenQ->>GenQ: Generate 3 questions max
    GenQ->>GenA: Pass questions
    GenA->>GenA: Generate short/mid/long answers
    GenA->>Embed: Pass Q&A pairs
    Embed->>Embed: Create embeddings
    Embed->>Upsert: Store with relations
    Upsert->>Qdrant: Store vectors
    Upsert->>Postgres: Store relations
    Postgres-->>API: QA generation complete
```

### Semantic Query Flow
```mermaid
sequenceDiagram
    participant Client
    participant API as /api/query
    participant Qdrant
    participant Postgres
    participant LLM as ModelRegistry
    
    Client->>API: POST question + personaId
    API->>Qdrant: Vector similarity search
    Qdrant-->>API: Relevant spans
    API->>Postgres: Tag expansion query
    Postgres-->>API: Related content
    API->>LLM: Generate contextualized answer
    LLM-->>API: Answer with citations
    API-->>Client: Response with NBA actions
```

### Context Evaluation Flow
```mermaid
sequenceDiagram
    participant Client
    participant API as /api/judge/context
    participant LLM as ModelRegistry
    participant Postgres
    
    Client->>API: POST context + criteria
    API->>LLM: Evaluate context quality
    LLM-->>API: Quality assessment
    API->>LLM: Generate NBA actions
    LLM-->>API: Suggested actions
    API->>Postgres: Store feedback
    Postgres-->>API: Storage complete
    API-->>Client: NBA recommendations
```

## Qualitätssicherung

- **Zitationen**: Jede Mid-Antwort hat ≥1 Zitat
- **Fragebegrenzung**: Max 3 Fragen pro Span
- **Deduplikation**: Clustering zur Vermeidung von Duplikaten
- **Spoiler-Gate**: Kapitel-/Beat-Beschränkung vor Retrieval

## Skalierbarkeit

```mermaid
graph LR
    subgraph "Load Balancing"
        LB[Load Balancer]
        API1[API Instance 1]
        API2[API Instance 2]
        API3[API Instance N]
        
        LB --> API1
        LB --> API2
        LB --> API3
    end
    
    subgraph "Processing"
        Queue[Job Queue]
        Worker1[PocketFlow Worker 1]
        Worker2[PocketFlow Worker 2]
        WorkerN[PocketFlow Worker N]
        
        Queue --> Worker1
        Queue --> Worker2
        Queue --> WorkerN
    end
    
    subgraph "Caching Layer"
        Redis[(Redis Cache)]
        CDN[CDN/Edge Cache]
    end
    
    subgraph "Data Persistence"
        QdrantCluster[(Qdrant Cluster)]
        PostgresCluster[(Postgres Cluster)]
    end
    
    API1 --> Queue
    API2 --> Queue
    API3 --> Queue
    
    API1 --> Redis
    API2 --> Redis
    API3 --> Redis
    
    Worker1 --> QdrantCluster
    Worker2 --> QdrantCluster
    WorkerN --> QdrantCluster
    
    Worker1 --> PostgresCluster
    Worker2 --> PostgresCluster
    WorkerN --> PostgresCluster
```

### Skalierungsstrategien:
- **Horizontale Skalierung**: Durch stateless API-Routes und Agents
- **Batch-Processing**: Für große Mengen an Inhalten
- **Caching**: Für häufige Abfragen
- **Background Jobs**: Für asynchrone Verarbeitung
- **Database Sharding**: Für große Datenmengen
- **Vector Index Optimization**: Für schnelle Suche
