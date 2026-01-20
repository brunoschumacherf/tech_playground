import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts'

interface EnpsChartProps {
  data: {
    promoters_count: number;
    detractors_count: number;
    total_responses: number;
  }
}

export default function EnpsChart({ data }: EnpsChartProps) {
  const chartData = [
    { name: 'Promotores', value: data.promoters_count },
    { name: 'Detratores', value: data.detractors_count },
    { 
      name: 'Passivos', 
      value: data.total_responses - (data.promoters_count + data.detractors_count) 
    }
  ]

  const COLORS = ['#10b981', '#ef4444', '#f59e0b']

  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
      <h2 className="text-xl font-semibold mb-4 italic">Distribuição eNPS (Company Level)</h2>
      <div className="h-[300px]">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={chartData} innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value">
              {chartData.map((_, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}