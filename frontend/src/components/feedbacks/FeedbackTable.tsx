'use client';

import { useState } from 'react';
import { EmployeeFeedback } from '@/types';
import { FeedbackDetailsModal } from './FeedbackDetailsModal';

interface FeedbackTableProps {
  data: EmployeeFeedback[];
  isLoading: boolean;
}

export function FeedbackTable({ data, isLoading }: FeedbackTableProps) {
  const [selectedFeedback, setSelectedFeedback] = useState<EmployeeFeedback | null>(null);

  if (isLoading) {
    return (
      <div className="w-full bg-white rounded-[2rem] border border-zinc-100 p-20 flex flex-col items-center justify-center gap-4">
        <div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" />
        <p className="text-zinc-400 font-bold animate-pulse">Processando feedbacks...</p>
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="w-full bg-white rounded-[2rem] border border-dashed border-zinc-200 p-20 text-center">
        <p className="text-zinc-400 font-medium">Nenhum registro encontrado para este critério.</p>
      </div>
    );
  }

  return (
    <>
      <div className="bg-white rounded-[2rem] border border-zinc-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead className="bg-zinc-50/50 border-b border-zinc-100">
              <tr>
                <th className="px-6 py-5 text-xs font-black uppercase tracking-widest text-zinc-400">Colaborador</th>
                <th className="px-6 py-5 text-xs font-black uppercase tracking-widest text-zinc-400">Área</th>
                <th className="px-6 py-5 text-xs font-black uppercase tracking-widest text-zinc-400 text-center">eNPS</th>
                <th className="px-6 py-5 text-xs font-black uppercase tracking-widest text-zinc-400 text-center">Nota Geral</th>
                <th className="px-6 py-5 text-xs font-black uppercase tracking-widest text-zinc-400 text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {data.map((item) => (
                <tr 
                  key={item.id} 
                  className="hover:bg-zinc-50/50 transition-colors group"
                >
                  <td className="px-6 py-4">
                    <div className="flex flex-col">
                      <span className="font-bold text-zinc-900 group-hover:text-indigo-600 transition-colors">
                        {item.nome}
                      </span>
                      <span className="text-xs text-zinc-400 font-medium">
                        {item.email}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-sm text-zinc-600 font-semibold bg-zinc-100 px-3 py-1 rounded-full">
                      {item.area}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <span className={`text-sm font-black ${item.enps >= 8 ? 'text-emerald-600' : item.enps <= 6 ? 'text-rose-600' : 'text-amber-600'}`}>
                      {item.enps}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <div className="flex items-center justify-center gap-1">
                      <span className="text-sm font-bold text-zinc-700">{item.feedback}</span>
                      <span className="text-[10px] text-zinc-300 font-black">/ 5</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button 
                      onClick={() => setSelectedFeedback(item)}
                      className="inline-flex items-center justify-center px-4 py-2 text-xs font-black uppercase tracking-tighter bg-zinc-900 text-white rounded-xl hover:bg-indigo-600 transition-all active:scale-95 shadow-sm"
                    >
                      Detalhes
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {selectedFeedback && (
        <FeedbackDetailsModal 
          feedback={selectedFeedback} 
          onClose={() => setSelectedFeedback(null)} 
        />
      )}
    </>
  );
}