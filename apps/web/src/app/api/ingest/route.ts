import { NextRequest } from 'next/server';
import { qdrantDB } from '@kohaerenz/core';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { content, metadata } = body;

    // Validate input
    if (!content) {
      return new Response(
        JSON.stringify({ error: 'Content is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // For now, we'll just return a success response
    // In a real implementation, this would parse the content into spans
    // and upsert them into Qdrant
    
    return new Response(
      JSON.stringify({ 
        message: 'Content ingested successfully',
        contentLength: content.length,
        metadata
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Ingest API Error:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
}
