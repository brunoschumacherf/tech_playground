import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';

interface SentimentChartProps {
  data: {
    positive: number;
    neutral: number;
    negative: number;
  }
}

export default function SentimentChart({ data }: SentimentChartProps) {
  const chartData = [
    { name: 'Positivo', value: data.positive, color: '#10b981' },
    { name: 'Neutro', value: data.neutral, color: '#f59e0b' },
    { name: 'Negativo', value: data.negative, color: '#ef4444' },
  ];

  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
      <h2 className="text-xl font-semibold mb-4 italic text-gray-800">Análise de Sentimento (IA)</h2>
      <div className="h-[300px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData} margin={{ top: 20, right: 30, left: 0, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
            <XAxis dataKey="name" axisLine={false} tickLine={false} />
            <YAxis axisLine={false} tickLine={false} />
            <Tooltip cursor={{ fill: '#f8fafc' }} />
            <Bar dataKey="value" radius={[6, 6, 0, 0]} barSize={50}>
              {chartData.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={entry.color} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}