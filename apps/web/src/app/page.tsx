'use client';

import { useState } from 'react';
import ChatInterface from './chat/page';

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Kohärenz Protokoll</h1>
        <p className="text-gray-600 mb-8">Guide-Chat Interface für strukturierte Interaktion</p>
        
        <div className="bg-white rounded-lg shadow-md p-6">
          <ChatInterface />
        </div>
      </div>
    </main>
  );
}
