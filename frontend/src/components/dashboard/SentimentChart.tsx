// src/components/dashboard/SentimentChart.tsx
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

export function SentimentChart({ data }: { data: any }) {
  const chartData = [
    { name: 'Positivos', value: data.positive, color: '#10b981' },
    { name: 'Neutros', value: data.neutral, color: '#f59e0b' },
    { name: 'Negativos', value: data.negative, color: '#ef4444' },
  ];

  return (
    <div className="h-[300px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={chartData}
            innerRadius={60}
            outerRadius={80}
            paddingAngle={5}
            dataKey="value"
          >
            {chartData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
          <Tooltip />
          <Legend />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}