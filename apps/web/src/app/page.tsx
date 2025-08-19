'use client';

import ChatInterface from './chat/page';
import {
  ResizablePanelGroup,
  ResizablePanel,
  ResizableHandle,
} from '@/components/ui/resizable';

export default function Home() {
  return (
    <main className="min-h-screen bg-background">
      <ResizablePanelGroup direction="horizontal" className="min-h-screen">
        <ResizablePanel defaultSize={33}>
          <div className="p-6 h-full">
            <ChatInterface />
          </div>
        </ResizablePanel>
        <ResizableHandle withHandle />
        <ResizablePanel defaultSize={34}>
          <div className="flex h-full items-center justify-center p-6">
            <span className="font-semibold">Editor / Diff</span>
          </div>
        </ResizablePanel>
        <ResizableHandle withHandle />
        <ResizablePanel defaultSize={33}>
          <div className="flex h-full items-center justify-center p-6">
            <span className="font-semibold">Kontext / Tags</span>
          </div>
        </ResizablePanel>
      </ResizablePanelGroup>
    </main>
  );
}
