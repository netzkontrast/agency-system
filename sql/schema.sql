-- Kohärenz Protokoll Database Schema
-- Requires pgvector extension

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Tags for semantic categorization
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    vector VECTOR(1536), -- Assuming 1536-dimension embeddings
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sources (documents, chapters, etc.)
CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL, -- 'chapter', 'beat', 'document', etc.
    identifier VARCHAR(255) NOT NULL, -- chapter number, beat name, etc.
    title VARCHAR(255),
    content TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Spans (text segments)
CREATE TABLE spans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES sources(id),
    content TEXT NOT NULL,
    start_pos INTEGER,
    end_pos INTEGER,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Questions
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'atomic', 'contextual', 'hypothetical'
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Answers
CREATE TABLE answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES questions(id),
    content TEXT NOT NULL,
    type VARCHAR(10) NOT NULL, -- 'short', 'mid', 'long'
    model_used VARCHAR(255),
    tokens_used INTEGER,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tag-Question Relations
CREATE TABLE tag_question (
    tag_id UUID REFERENCES tags(id),
    question_id UUID REFERENCES questions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (tag_id, question_id)
);

-- Span-Question Relations
CREATE TABLE question_span (
    question_id UUID REFERENCES questions(id),
    span_id UUID REFERENCES spans(id),
    relevance_score FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (question_id, span_id)
);

-- Personas
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    thoughts_namespace VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Persona Thoughts
CREATE TABLE persona_thoughts (
    id UUID PRIMARY KEY DEFAULT gen_random_uid(),
    persona_id UUID REFERENCES personas(id),
    content TEXT NOT NULL,
    vector VECTOR(1536),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Judgements
CREATE TABLE judgements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    context TEXT NOT NULL,
    judgement TEXT NOT NULL,
    model_used VARCHAR(255),
    tokens_used INTEGER,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Jobs (for background processing)
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    payload JSONB,
    result JSONB,
    error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX idx_tags_vector ON tags USING ivfflat (vector vector_cosine_ops);
CREATE INDEX idx_questions_type ON questions(type);
CREATE INDEX idx_answers_question ON answers(question_id);
CREATE INDEX idx_answers_type ON answers(type);
CREATE INDEX idx_tag_question_tag ON tag_question(tag_id);
CREATE INDEX idx_tag_question_question ON tag_question(question_id);
CREATE INDEX idx_question_span_question ON question_span(question_id);
CREATE INDEX idx_question_span_span ON question_span(span_id);
CREATE INDEX idx_persona_thoughts_vector ON persona_thoughts USING ivfflat (vector vector_cosine_ops);
CREATE INDEX idx_persona_thoughts_persona ON persona_thoughts(persona_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_type ON jobs(type);
CREATE INDEX idx_sources_type ON sources(type);
CREATE INDEX idx_sources_identifier ON sources(identifier);
