import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'People Analytics | Bruno',
  description: 'Dashboard de análise de clima organizacional',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-br">
      <body className="bg-zinc-50 text-zinc-900 antialiased">
        {children}
      </body>
    </html>
  );
}