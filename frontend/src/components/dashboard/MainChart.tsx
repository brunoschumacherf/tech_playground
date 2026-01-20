'use client';

import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer, 
  Cell 
} from 'recharts';

interface MainChartProps {
  data: Record<string, string | number> | null;
}

export function MainChart({ data }: MainChartProps) {
  const chartData = data 
    ? Object.entries(data).map(([name, value]) => {
        const numericValue = typeof value === 'string' ? parseFloat(value) : value;
        return {
          name: name.toUpperCase(),
          value: Number(numericValue.toFixed(2))
        };
      })
    : [];

  if (chartData.length === 0) return null;

  return (
    <div className="h-[400px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData} margin={{ top: 20, right: 30, left: 0, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f1f1" />
          <XAxis 
            dataKey="name" 
            axisLine={false} 
            tickLine={false} 
            tick={{ fill: '#a1a1aa', fontSize: 10, fontWeight: 800 }}
          />
          <YAxis 
            axisLine={false} 
            tickLine={false} 
            tick={{ fill: '#a1a1aa', fontSize: 10, fontWeight: 800 }}
            domain={[0, 10]}
          />
          <Tooltip 
            cursor={{ fill: '#f8fafc' }}
            contentStyle={{ borderRadius: '1rem', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
          />
          <Bar dataKey="value" radius={[10, 10, 10, 10]} barSize={50}>
            {chartData.map((entry, index) => (
              <Cell 
                key={`cell-${index}`} 
                fill={entry.value >= 7 ? '#4f46e5' : entry.value >= 5 ? '#f59e0b' : '#ef4444'} 
              />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}