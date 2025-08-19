import { test, expect, describe, vi } from 'vitest';
import { POST } from '../src/app/api/ingest/route';

describe('POST /api/ingest', () => {
  test('should return 400 if content is missing', async () => {
    const req = {
      json: async () => ({ metadata: {} })
    };

    // @ts-ignore - Mock request object
    const response = await POST(req);
    const body = await response.json();

    expect(response.status).toBe(400);
    expect(body.error).toBe('Content is required');
  });

  test('should return 200 with success message if content is provided', async () => {
    const req = {
      json: async () => ({
        content: 'This is test content',
        metadata: { source: 'test' }
      })
    };

    // @ts-ignore - Mock request object
    const response = await POST(req);
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.message).toBe('Content ingested successfully');
    expect(body.contentLength).toBe(22);
    expect(body.metadata).toEqual({ source: 'test' });
  });

  test('should return 500 if there is an internal server error', async () => {
    const req = {
      json: async () => {
        throw new Error('Test error');
      }
    };

    // @ts-ignore - Mock request object
    const response = await POST(req);
    const body = await response.json();

    expect(response.status).toBe(500);
    expect(body.error).toBe('Internal server error');
  });
});
