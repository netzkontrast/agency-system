import { describe, it, expect } from 'vitest';
import { 
  Span, 
  Question, 
  Answer, 
  Tag, 
  Persona, 
  Judgement, 
  SearchResult,
  ModelProvider
} from '../types';

describe('Core Types', () => {
  it('should define Span interface correctly', () => {
    const span: Span = {
      id: 'test-span-1',
      content: 'This is a test span content',
      metadata: {
        source: 'test-source',
        chapter: 'Chapter 1',
        beat: 'Beat 1',
        createdAt: new Date()
      }
    };

    expect(span.id).toBe('test-span-1');
    expect(span.content).toBe('This is a test span content');
    expect(span.metadata.source).toBe('test-source');
  });

  it('should define Question interface correctly', () => {
    const question: Question = {
      id: 'test-question-1',
      content: 'What is the meaning of life?',
      spanId: 'test-span-1',
      type: 'atomic',
      metadata: {
        chapter: 'Chapter 1',
        beat: 'Beat 1',
        createdAt: new Date()
      }
    };

    expect(question.id).toBe('test-question-1');
    expect(question.content).toBe('What is the meaning of life?');
    expect(question.type).toBe('atomic');
  });

  it('should define Answer interface correctly', () => {
    const answer: Answer = {
      id: 'test-answer-1',
      questionId: 'test-question-1',
      content: 'The meaning of life is 42.',
      type: 'short',
      citations: ['test-span-1', 'test-span-2'],
      metadata: {
        model: 'gpt-4',
        tokens: 100,
        createdAt: new Date()
      }
    };

    expect(answer.id).toBe('test-answer-1');
    expect(answer.content).toBe('The meaning of life is 42.');
    expect(answer.type).toBe('short');
    expect(answer.citations).toHaveLength(2);
  });

  it('should define Tag interface correctly', () => {
    const tag: Tag = {
      id: 'test-tag-1',
      name: 'philosophy',
      description: 'Questions about the meaning of life',
      vector: Array(1536).fill(0.5) // Mock embedding vector
    };

    expect(tag.id).toBe('test-tag-1');
    expect(tag.name).toBe('philosophy');
    expect(tag.vector).toHaveLength(1536);
  });

  it('should define Persona interface correctly', () => {
    const persona: Persona = {
      id: 'test-persona-1',
      name: 'Philosopher',
      description: 'A persona interested in philosophical questions',
      thoughtsNamespace: 'philosopher-thoughts'
    };

    expect(persona.id).toBe('test-persona-1');
    expect(persona.name).toBe('Philosopher');
    expect(persona.thoughtsNamespace).toBe('philosopher-thoughts');
  });

  it('should define Judgement interface correctly', () => {
    const judgement: Judgement = {
      id: 'test-judgement-1',
      context: 'The answer provided was accurate and well-reasoned.',
      judgement: 'High quality response with proper citations.',
      metadata: {
        model: 'gpt-4',
        tokens: 50,
        createdAt: new Date()
      }
    };

    expect(judgement.id).toBe('test-judgement-1');
    expect(judgement.context).toBe('The answer provided was accurate and well-reasoned.');
  });

  it('should define SearchResult interface correctly', () => {
    const searchResult: SearchResult = {
      answer: {
        id: 'test-answer-1',
        questionId: 'test-question-1',
        content: 'The meaning of life is 42.',
        type: 'short',
        citations: ['test-span-1'],
        metadata: {
          model: 'gpt-4',
          tokens: 100,
          createdAt: new Date()
        }
      },
      score: 0.95,
      citations: [{
        id: 'test-span-1',
        content: 'This is a test span content',
        metadata: {
          source: 'test-source',
          createdAt: new Date()
        }
      }]
    };

    expect(searchResult.score).toBe(0.95);
    expect(searchResult.answer.id).toBe('test-answer-1');
  });

  it('should define ModelProvider enum correctly', () => {
    const provider1: ModelProvider = 'lm-studio';
    const provider2: ModelProvider = 'openrouter';

    expect(provider1).toBe('lm-studio');
    expect(provider2).toBe('openrouter');
  });
});
