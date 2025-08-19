'use client';

import { useState, useRef, useEffect } from 'react';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

interface NBA {
  id: string;
  label: string;
  action: string;
  description: string;
}

export default function ChatInterface() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      role: 'assistant',
      content: 'Willkommen beim Kohärenz Protokoll Guide-Chat. Wie kann ich Ihnen helfen?',
      timestamp: new Date(),
    }
  ]);
  const [inputValue, setInputValue] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [suggestedActions, setSuggestedActions] = useState<NBA[]>([]);
  const messagesEndRef = useRef<null | HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async () => {
    if (!inputValue.trim() || isLoading) return;

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: inputValue,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInputValue('');
    setIsLoading(true);

    try {
      // In a real implementation, this would call the API
      // For now, we'll simulate a response
      
      // Simulate API delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Add assistant response
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: `Ich habe Ihre Anfrage "${inputValue}" verstanden. In einem vollständigen System würde ich Ihnen nun eine strukturierte Antwort mit Zitaten aus dem Kohärenz Protokoll geben.`,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, assistantMessage]);
      
      // Add some suggested actions (NBAs)
      setSuggestedActions([
        {
          id: 'nba1',
          label: 'Mehr Details',
          action: 'elaborate',
          description: 'Fordern Sie detailliertere Informationen zu diesem Thema an'
        },
        {
          id: 'nba2',
          label: 'Verwandte Fragen',
          action: 'related',
          description: 'Finden Sie verwandte Fragen im Protokoll'
        },
        {
          id: 'nba3',
          label: 'Quellen anzeigen',
          action: 'sources',
          description: 'Zeigen Sie die zugrundeliegenden Quellen an'
        }
      ]);
    } catch (error) {
      console.error('Error sending message:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: 'Entschuldigung, es gab einen Fehler bei der Verarbeitung Ihrer Anfrage.',
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleNBAAction = (nba: NBA) => {
    // Handle Natural Behavioral Action
    const actionMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: `NBA ausgeführt: ${nba.label} (${nba.description})`,
      timestamp: new Date(),
    };
    
    setMessages(prev => [...prev, actionMessage]);
    setSuggestedActions([]);
    
    // In a real implementation, this would trigger the corresponding flow
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <div className="flex flex-col h-[600px]">
      <div className="flex-1 overflow-y-auto mb-4 space-y-4">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`p-4 rounded-lg ${
              message.role === 'user'
                ? 'bg-blue-100 ml-10'
                : 'bg-gray-100 mr-10'
            }`}
          >
            <div className="font-semibold text-sm text-gray-500 mb-1">
              {message.role === 'user' ? 'Sie' : 'Assistent'}
            </div>
            <div className="text-gray-800">{message.content}</div>
          </div>
        ))}
        {isLoading && (
          <div className="bg-gray-100 mr-10 p-4 rounded-lg">
            <div className="font-semibold text-sm text-gray-500 mb-1">Assistent</div>
            <div className="text-gray-800">Tippen...</div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {suggestedActions.length > 0 && (
        <div className="mb-4 p-4 bg-yellow-50 rounded-lg">
          <h3 className="font-semibold text-yellow-800 mb-2">Vorgeschlagene Aktionen:</h3>
          <div className="flex flex-wrap gap-2">
            {suggestedActions.map((nba) => (
              <button
                key={nba.id}
                onClick={() => handleNBAAction(nba)}
                className="px-3 py-1 bg-yellow-200 hover:bg-yellow-300 text-yellow-800 rounded-full text-sm transition-colors"
              >
                {nba.label}
              </button>
            ))}
          </div>
        </div>
      )}

      <div className="flex">
        <textarea
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyPress={handleKeyPress}
          placeholder="Stellen Sie eine Frage oder beschreiben Sie Ihr Anliegen..."
          className="flex-1 border border-gray-300 rounded-l-lg p-3 resize-none"
          rows={3}
          disabled={isLoading}
        />
        <button
          onClick={handleSendMessage}
          disabled={isLoading || !inputValue.trim()}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 rounded-r-lg disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Senden
        </button>
      </div>
    </div>
  );
}
