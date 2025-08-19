import { Pool, QueryResult } from 'pg';
import { Client as QdrantClient } from '@qdrant/js-client-rest';
import { PointStruct, ScrollPoints } from '@qdrant/js-client-rest';
import { Span, Question, Answer, Tag, Persona, Judgement } from './types';

// Postgres connection
const pgPool = new Pool({
  connectionString: process.env.POSTGRES_URL,
});

// Qdrant connection
const qdrantClient = new QdrantClient({
  url: process.env.QDRANT_URL,
  apiKey: process.env.QDRANT_API_KEY,
});

// PostgreSQL Operations
export class PostgresDB {
  async query(text: string, params: any[] = []): Promise<QueryResult> {
    const client = await pgPool.connect();
    try {
      return await client.query(text, params);
    } finally {
      client.release();
    }
  }

  // Tags
  async createTag(tag: Omit<Tag, 'id' | 'createdAt' | 'updatedAt'>): Promise<Tag> {
    const result = await this.query(
      `INSERT INTO tags (name, description, vector) 
       VALUES ($1, $2, $3) 
       RETURNING *`,
      [tag.name, tag.description, tag.vector]
    );
    return result.rows[0];
  }

  async getTags(): Promise<Tag[]> {
    const result = await this.query('SELECT * FROM tags ORDER BY created_at DESC');
    return result.rows;
  }

  async getTagById(id: string): Promise<Tag | null> {
    const result = await this.query('SELECT * FROM tags WHERE id = $1', [id]);
    return result.rows[0] || null;
  }

  // Questions
  async createQuestion(question: Omit<Question, 'id' | 'createdAt' | 'updatedAt'>): Promise<Question> {
    const result = await this.query(
      `INSERT INTO questions (content, type, metadata) 
       VALUES ($1, $2, $3) 
       RETURNING *`,
      [question.content, question.type, question.metadata]
    );
    return result.rows[0];
  }

  async getQuestionsByTag(tagId: string): Promise<Question[]> {
    const result = await this.query(
      `SELECT q.* FROM questions q
       JOIN tag_question tq ON q.id = tq.question_id
       WHERE tq.tag_id = $1`,
      [tagId]
    );
    return result.rows;
  }

  // Answers
  async createAnswer(answer: Omit<Answer, 'id' | 'createdAt' | 'updatedAt'>): Promise<Answer> {
    const result = await this.query(
      `INSERT INTO answers (question_id, content, type, model_used, tokens_used, metadata) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       RETURNING *`,
      [answer.questionId, answer.content, answer.type, answer.metadata?.model, answer.metadata?.tokens, answer.metadata]
    );
    return result.rows[0];
  }

  // Personas
  async createPersona(persona: Omit<Persona, 'id' | 'createdAt' | 'updatedAt'>): Promise<Persona> {
    const result = await this.query(
      `INSERT INTO personas (name, description, thoughts_namespace) 
       VALUES ($1, $2, $3) 
       RETURNING *`,
      [persona.name, persona.description, persona.thoughtsNamespace]
    );
    return result.rows[0];
  }

  async getPersonas(): Promise<Persona[]> {
    const result = await this.query('SELECT * FROM personas ORDER BY created_at DESC');
    return result.rows;
  }

  // Judgements
  async createJudgement(judgement: Omit<Judgement, 'id' | 'createdAt' | 'updatedAt'>): Promise<Judgement> {
    const result = await this.query(
      `INSERT INTO judgements (context, judgement, model_used, tokens_used, metadata) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [judgement.context, judgement.judgement, judgement.metadata?.model, judgement.metadata?.tokens, judgement.metadata]
    );
    return result.rows[0];
  }

  // Jobs
  async createJob(type: string, payload: any): Promise<any> {
    const result = await this.query(
      `INSERT INTO jobs (type, payload) 
       VALUES ($1, $2) 
       RETURNING *`,
      [type, payload]
    );
    return result.rows[0];
  }

  async updateJobStatus(jobId: string, status: string, result?: any, error?: string): Promise<any> {
    const resultQuery = await this.query(
      `UPDATE jobs 
       SET status = $1, result = $2, error = $3, completed_at = NOW() 
       WHERE id = $4 
       RETURNING *`,
      [status, result, error, jobId]
    );
    return resultQuery.rows[0];
  }
}

// Qdrant Operations
export class QdrantDB {
  private client: QdrantClient;

  constructor() {
    this.client = qdrantClient;
  }

  // Sources collection operations
  async upsertSourcePoints(points: PointStruct[]): Promise<any> {
    return await this.client.upsert('sources', {
      wait: true,
      points,
    });
  }

  // Thoughts_Q collection operations
  async upsertQuestionPoints(points: PointStruct[]): Promise<any> {
    return await this.client.upsert('thoughts_q', {
      wait: true,
      points,
    });
  }

  // Thoughts_A collection operations
  async upsertAnswerPoints(points: PointStruct[]): Promise<any> {
    return await this.client.upsert('thoughts_a', {
      wait: true,
      points,
    });
  }

  // Persona Thoughts collection operations
  async upsertPersonaThoughtPoints(namespace: string, points: PointStruct[]): Promise<any> {
    return await this.client.upsert(namespace, {
      wait: true,
      points,
    });
  }

  // Generic search function
  async searchCollection(
    collectionName: string,
    vector: number[],
    limit: number = 10,
    filter?: any
  ): Promise<any[]> {
    const results = await this.client.search(collectionName, {
      vector,
      limit,
      filter,
      with_payload: true,
      with_vector: false,
    });
    return results;
  }

  // Generic scroll function
  async scrollCollection(
    collectionName: string,
    options?: ScrollPoints
  ): Promise<any> {
    return await this.client.scroll(collectionName, options);
  }
}

// Export instances
export const postgresDB = new PostgresDB();
export const qdrantDB = new QdrantDB();
