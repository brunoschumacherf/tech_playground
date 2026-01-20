'use client';

import { ImportFile } from '@/types';
import Link from 'next/link';

interface ImportListProps {
  items: ImportFile[];
}

export function ImportList({ items }: ImportListProps) {
  if (items.length === 0) {
    return (
      <div className="text-center py-20 bg-white rounded-[2.5rem] border border-dashed border-zinc-200">
        <p className="text-zinc-400 font-medium">Nenhum dataset encontrado. Comece importando um CSV.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-4">
      {items.map((item) => (
        <div 
          key={item.id} 
          className="group flex items-center justify-between p-6 bg-white border border-zinc-100 rounded-[2rem] shadow-sm hover:shadow-md transition-all"
        >
          <div className="flex items-center gap-5">
            <div className="w-14 h-14 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center text-2xl group-hover:scale-110 transition-transform">
              📊
            </div>
            <div>
              <h3 className="font-bold text-zinc-900 text-lg">{item.name}</h3>
              <div className="flex gap-3 text-xs text-zinc-400 font-semibold mt-1">
                <span>📅 {new Date(item.created_at).toLocaleDateString()}</span>
                <span>👥 {item.feedbacks_count} feedbacks</span>
              </div>
            </div>
          </div>

          <Link 
            href={`/dashboard/${item.id}`}
            className="bg-zinc-900 text-white px-8 py-3 rounded-full font-bold text-sm hover:bg-indigo-600 transition-colors shadow-lg shadow-zinc-200"
          >
            Abrir Dashboard
          </Link>
        </div>
      ))}
    </div>
  );
}