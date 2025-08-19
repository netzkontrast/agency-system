-- Migration 002: Tag Graph System for Kohärenz Protokoll
-- Erweitert das Schema um Tag-Graph, Personas und Jobs

BEGIN;

-- Drop existing tags table to recreate with new structure
DROP TABLE IF EXISTS tag_question CASCADE;
DROP TABLE IF EXISTS tags CASCADE;

-- Enhanced tags table with graph capabilities
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(255) UNIQUE NOT NULL, -- URL-friendly identifier
    title VARCHAR(255) NOT NULL,
    description TEXT, -- Short description (1 sentence)
    long_description TEXT, -- Detailed description for key navigators (2-4 sentences)
    kind VARCHAR(20) NOT NULL CHECK (kind IN ('narrative', 'content')),
    vector VECTOR(1536), -- Embedding vector
    parent_id UUID REFERENCES tags(id),
    meta JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tag edges for graph relationships
CREATE TABLE tag_edges (
    src_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    dst_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('IS_A', 'RELATES_TO', 'PART_OF', 'SUPPORTS', 'CONTRADICTS')),
    weight FLOAT DEFAULT 1.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (src_id, dst_id, type)
);

-- Enhanced tag-question relations with weights
CREATE TABLE tag_question (
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    weight FLOAT DEFAULT 1.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (tag_id, question_id)
);

-- Personas table
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL, -- 'knowledge_manager', 'world_builder', 'co_author', 'lektor'
    guidelines TEXT NOT NULL, -- Persona-specific guidelines
    active BOOLEAN DEFAULT true,
    namespace VARCHAR(255) UNIQUE NOT NULL, -- For Qdrant collections
    meta JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Persona thoughts (separate from main Q/A)
CREATE TABLE persona_thoughts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    persona_id UUID REFERENCES personas(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    vector VECTOR(1536),
    tags UUID[] DEFAULT '{}', -- Array of tag IDs
    meta JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced jobs table for background processing
DROP TABLE IF EXISTS jobs CASCADE;
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    payload JSONB NOT NULL DEFAULT '{}',
    result JSONB,
    error TEXT,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    priority INTEGER DEFAULT 5, -- 1 = highest, 10 = lowest
    run_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Judgements table for LLM-as-judge
CREATE TABLE judgements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    context JSONB NOT NULL, -- Current work context
    scores JSONB NOT NULL, -- Scores per criteria
    nbas JSONB NOT NULL, -- Next-best-actions
    leading_persona_id UUID REFERENCES personas(id),
    model_used VARCHAR(255),
    tokens_used INTEGER,
    meta JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_tags_kind ON tags(kind);
CREATE INDEX idx_tags_parent ON tags(parent_id);
CREATE INDEX idx_tags_vector ON tags USING ivfflat (vector vector_cosine_ops);
CREATE INDEX idx_tags_slug ON tags(slug);

CREATE INDEX idx_tag_edges_src ON tag_edges(src_id);
CREATE INDEX idx_tag_edges_dst ON tag_edges(dst_id);
CREATE INDEX idx_tag_edges_type ON tag_edges(type);

CREATE INDEX idx_tag_question_tag ON tag_question(tag_id);
CREATE INDEX idx_tag_question_question ON tag_question(question_id);
CREATE INDEX idx_tag_question_weight ON tag_question(weight);

CREATE INDEX idx_personas_role ON personas(role);
CREATE INDEX idx_personas_active ON personas(active);
CREATE INDEX idx_personas_namespace ON personas(namespace);

CREATE INDEX idx_persona_thoughts_persona ON persona_thoughts(persona_id);
CREATE INDEX idx_persona_thoughts_vector ON persona_thoughts USING ivfflat (vector vector_cosine_ops);
CREATE INDEX idx_persona_thoughts_tags ON persona_thoughts USING gin(tags);

CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_type ON jobs(type);
CREATE INDEX idx_jobs_priority ON jobs(priority);
CREATE INDEX idx_jobs_run_at ON jobs(run_at);
CREATE INDEX idx_jobs_created_at ON jobs(created_at);

CREATE INDEX idx_judgements_persona ON judgements(leading_persona_id);
CREATE INDEX idx_judgements_created_at ON judgements(created_at);

-- Add update triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tags_updated_at BEFORE UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_personas_updated_at BEFORE UPDATE ON personas
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_persona_thoughts_updated_at BEFORE UPDATE ON persona_thoughts
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

COMMIT;
