'use client';

import { DashboardSummary } from '@/types';

interface StatsCardsProps {
  data: DashboardSummary | null;
}

export function StatsCards({ data }: StatsCardsProps) {
  const stats = [
    {
      label: 'Total de Respostas',
      value: data?.total_responses || 0,
      description: 'Colaboradores que participaram',
      color: 'text-zinc-900',
    },
    {
      label: 'eNPS Global',
      value: data?.enps_score || 0,
      description: 'Score de lealdade (-100 a 100)',
      color: data && data.enps_score >= 50 ? 'text-emerald-600' : 'text-indigo-600',
    },
    {
      label: 'Favorabilidade',
      value: data ? `${data.favorability}%` : '0%',
      description: 'Notas 4 e 5 na pesquisa',
      color: 'text-zinc-900',
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      {stats.map((stat, index) => (
        <div 
          key={index}
          className="bg-white border border-zinc-100 p-8 rounded-[2.5rem] shadow-sm hover:shadow-md transition-all duration-300 group"
        >
          <p className="text-[10px] font-black uppercase tracking-[0.2em] text-zinc-400 mb-4 group-hover:text-indigo-500 transition-colors">
            {stat.label}
          </p>
          <div className="flex items-baseline gap-2">
            <span className={`text-5xl font-black tracking-tighter ${stat.color}`}>
              {stat.value}
            </span>
          </div>
          <p className="text-xs text-zinc-400 font-medium mt-4">
            {stat.description}
          </p>
        </div>
      ))}
    </div>
  );
}