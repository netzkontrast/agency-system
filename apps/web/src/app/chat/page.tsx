'use client';

import { useState, useRef, useEffect } from 'react';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';

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
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: `Ich habe Ihre Anfrage "${inputValue}" verstanden. In einem vollständigen System würde ich Ihnen nun eine strukturierte Antwort mit Zitaten aus dem Kohärenz Protokoll geben.`,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, assistantMessage]);
      
      setSuggestedActions([
        { id: 'nba1', label: 'Mehr Details', action: 'elaborate', description: 'Fordern Sie detailliertere Informationen zu diesem Thema an' },
        { id: 'nba2', label: 'Verwandte Fragen', action: 'related', description: 'Finden Sie verwandte Fragen im Protokoll' },
        { id: 'nba3', label: 'Quellen anzeigen', action: 'sources', description: 'Zeigen Sie die zugrundeliegenden Quellen an' }
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
    const actionMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: `NBA ausgeführt: ${nba.label} (${nba.description})`,
      timestamp: new Date(),
    };
    
    setMessages(prev => [...prev, actionMessage]);
    setSuggestedActions([]);
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <Card className="h-full flex flex-col">
      <CardHeader>
        <CardTitle>Guide-Chat</CardTitle>
      </CardHeader>
      <CardContent className="flex-1 overflow-y-auto space-y-4">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex items-start gap-4 ${
              message.role === 'user' ? 'justify-end' : ''
            }`}
          >
            {message.role === 'assistant' && (
              <Avatar className="h-8 w-8">
                <AvatarFallback>A</AvatarFallback>
              </Avatar>
            )}
            <div
              className={`p-3 rounded-lg max-w-[75%] ${
                message.role === 'user'
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted'
              }`}
            >
              <p className="text-sm">{message.content}</p>
            </div>
            {message.role === 'user' && (
              <Avatar className="h-8 w-8">
                <AvatarFallback>S</AvatarFallback>
              </Avatar>
            )}
          </div>
        ))}
        {isLoading && (
          <div className="flex items-start gap-4">
            <Avatar className="h-8 w-8">
              <AvatarFallback>A</AvatarFallback>
            </Avatar>
            <div className="p-3 rounded-lg bg-muted">
              <p className="text-sm">Tippen...</p>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </CardContent>

      {suggestedActions.length > 0 && (
        <CardFooter className="flex flex-col items-start gap-2 border-t pt-4">
          <h3 className="font-semibold text-sm text-foreground mb-2">Vorgeschlagene Aktionen:</h3>
          <div className="flex flex-wrap gap-2">
            {suggestedActions.map((nba) => (
              <Button
                key={nba.id}
                onClick={() => handleNBAAction(nba)}
                variant="outline"
                size="sm"
              >
                {nba.label}
              </Button>
            ))}
          </div>
        </CardFooter>
      )}

      <CardFooter className="border-t pt-4">
        <div className="flex w-full items-center space-x-2">
          <Input
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Stellen Sie eine Frage..."
            className="flex-1"
            disabled={isLoading}
          />
          <Button
            onClick={handleSendMessage}
            disabled={isLoading || !inputValue.trim()}
          >
            Senden
          </Button>
        </div>
      </CardFooter>
    </Card>
  );
}
