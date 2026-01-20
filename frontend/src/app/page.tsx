'use client'
import { useEffect, useState } from 'react'
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, 
  PieChart, Pie, Cell, ResponsiveContainer, 
  Tooltip, Legend 
} from 'recharts'
import { Users, TrendingUp, Activity } from 'lucide-react'

export default function Dashboard() {
  const [data, setData] = useState<any>(null)

  useEffect(() => {
    fetch('http://localhost:3000/api/v1/dashboard')
      .then(res => res.json())
      .then(json => setData(json))
      .catch(err => console.error("Erro ao buscar dados:", err))
  }, [])

  if (!data) return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-pulse text-xl font-medium text-gray-500">
        Carregando métricas do Tech Playground...
      </div>
    </div>
  )

  const chartData = [
    { name: 'Promotores', value: data.summary.promoters_count },
    { name: 'Detratores', value: data.summary.detractors_count },
    { 
      name: 'Passivos', 
      value: data.summary.total_responses - (data.summary.promoters_count + data.summary.detractors_count) 
    }
  ]

  const COLORS = ['#10b981', '#ef4444', '#f59e0b']

  return (
    <div className="p-8 bg-gray-50 min-h-screen">
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <StatCard title="Total Respostas" value={data.summary.total_responses} icon={<Users />} color="blue" />
        <StatCard title="eNPS Score" value={data.summary.enps_score} icon={<TrendingUp />} color="purple" />
        <StatCard title="Áreas Ativas" value={Object.keys(data.by_area).length} icon={<Activity />} color="green" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
          <h2 className="text-xl font-semibold mb-4 italic text-gray-700">Distribuição eNPS</h2>
          <div className="h-[300px]">
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
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
          <h2 className="text-xl font-semibold mb-6 italic text-gray-700">Média por Área</h2>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={Object.entries(data.by_area).map(([name, score]) => ({ 
                name, 
                score: Number(score).toFixed(2) 
              }))}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" fontSize={12} />
                <YAxis domain={[0, 5]} />
                <Tooltip />
                <Bar dataKey="score" fill="#3b82f6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

      </div>
    </div>
  )
}

function StatCard({ title, value, icon, color }: any) {
  const colorClasses: any = {
    blue: "bg-blue-50 text-blue-600",
    purple: "bg-purple-50 text-purple-600",
    green: "bg-green-50 text-green-600"
  }
  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4">
      <div className={`p-4 rounded-xl ${colorClasses[color]}`}>{icon}</div>
      <div>
        <p className="text-sm font-medium text-gray-500 uppercase tracking-wider">{title}</p>
        <p className="text-2xl font-bold text-gray-900">{value}</p>
      </div>
    </div>
  )
}