// Core Types for Kohärenz Protokoll

export interface Span {
  id: string;
  content: string;
  metadata: {
    source: string;
    chapter?: string;
    beat?: string;
    createdAt: Date;
    [key: string]: any;
  };
}

export interface Question {
  id: string;
  content: string;
  spanId: string;
  type: 'atomic' | 'contextual' | 'hypothetical';
  metadata: {
    chapter?: string;
    beat?: string;
    createdAt: Date;
  };
}

export interface Answer {
  id: string;
  questionId: string;
  content: string;
  type: 'short' | 'mid' | 'long';
  citations: string[]; // Span IDs
  metadata: {
    model: string;
    tokens: number;
    createdAt: Date;
  };
}

export interface Tag {
  id: string;
  name: string;
  description?: string;
  vector: number[]; // Embedding for semantic similarity
}

export interface Persona {
  id: string;
  name: string;
  description: string;
  thoughtsNamespace: string;
}

export interface Judgement {
  id: string;
  context: string;
  judgement: string;
  metadata: {
    model: string;
    tokens: number;
    createdAt: Date;
  };
}

export interface SearchResult {
  answer: Answer;
  score: number;
  citations: Span[];
}

export type ModelProvider = 'lm-studio' | 'openrouter';
