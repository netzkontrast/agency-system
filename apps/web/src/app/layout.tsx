import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Kohärenz Protokoll',
  description: 'Guide-Chat Interface für strukturierte Interaktion',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="de">
      <body>{children}</body>
    </html>
  );
}
