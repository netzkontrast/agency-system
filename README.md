# Kohärenz Protokoll

Eine Autorensoftware für strukturierte Wissensverarbeitung und -abfrage mit semantischer Suche und KI-gestützter Analyse.

## Architektur

- **Frontend**: Next.js (App Router) mit ai-sdk v5 (Streaming) und shadcn/ui
- **Backend**: Next.js API Routes (Node/Edge) + Background Functions (Jobs)
- **Orchestrierung**: PocketFlow (Python) für kurze, idempotente Steps
- **Agentik**: Fast Agent mit MCP-Tools (filesystem, fetch) für spezialisierte Tasks
- **Vektor**: Qdrant (Base) für semantische Suche; Postgres+pgvector für Tags/Relationen
- **LLM**: Adapter für LM Studio (lokal Dev) und OpenRouter (Prod/Fallback)

## Repository Struktur

```
├── apps/
│   └── web/              # Next.js Frontend und API Routes
├── packages/
│   ├── core/             # Gemeinsames SDK, ModelRegistry, Types
│   ├── flows/            # PocketFlow Orchestrierung
│   └── agents/           # Fast Agent mit MCP-Tools
├── sql/                  # Datenbankschema und Migrationen
└── docs/                 # Dokumentation
```

## Schnellstart

### Voraussetzungen

- Node.js >= 18
- pnpm >= 8
- Python >= 3.8
- Postgres mit pgvector Extension
- Qdrant Vector Database

### Installation

1. Abhängigkeiten installieren:
```bash
pnpm install
```

2. Umgebungsvariablen konfigurieren:
```bash
cp .env.example .env.local
# Passen Sie die Werte in .env.local an
```

3. Datenbankschema anlegen:
```bash
# Führen Sie das SQL-Schema in Ihrer Postgres-Datenbank aus
# sql/schema.sql
```

4. Qdrant Collections erstellen:
```bash
# Verwenden Sie die Konfiguration in sql/qdrant_collections.json
```

### Entwicklung

```bash
pnpm dev
```

Die Anwendung ist unter http://localhost:3000 erreichbar.

## API Endpunkte

- `POST /api/ingest` - Ingestion von Inhalten
- `POST /api/qa-tag` - Generierung von QA-Paaren und Tags
- `POST /api/query` - Fragebasierte Abfrage mit semantischer Suche
- `POST /api/judge/context` - LLM-as-judge für Kontextbewertung
- `POST /api/persona` - Persona Management (CRUD)

## Deployment

### Vercel

Um diese Anwendung auf Vercel zu deployen, klicken Sie auf den folgenden Button:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2netzkontrast2Fagency-system

**Konfiguration in Vercel:**

1.  **Framework Preset**: Next.js
2.  **Root Directory**: `apps/web`
3.  **Build & Development Settings**:
    - **Install Command**: `cd ../.. && pnpm install`
    - **Build Command**: `pnpm build`
    - **Development Command**: `pnpm dev`
4.  **Environment Variables**: Kopieren Sie die Umgebungsvariablen aus Ihrer `.env.local`-Datei in die Vercel-Projekteinstellungen.

## Lizenz

MIT
