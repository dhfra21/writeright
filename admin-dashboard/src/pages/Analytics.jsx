import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

const CHART_COLORS = ['var(--chart-primary)', 'var(--chart-secondary)'];

export default function Analytics() {
  const [analytics, setAnalytics] = useState({
    characterTypeDistribution: [],
    topPerformers: [],
    averageScoreByCharacter: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAnalytics();
  }, []);

  const fetchAnalytics = async () => {
    try {
      // Mock data for demonstration
      const mockTypeData = [
        { name: 'Letters', value: 782 },
        { name: 'Numbers', value: 465 },
      ];

      const mockTopPerformers = [
        { child_name: 'Ethan Anderson', game_progress: [{ total_xp: 2450, current_level: 14 }] },
        { child_name: 'Sophia Chen', game_progress: [{ total_xp: 2100, current_level: 12 }] },
        { child_name: 'Noah Williams', game_progress: [{ total_xp: 1890, current_level: 11 }] },
        { child_name: 'Lucas Martinez', game_progress: [{ total_xp: 1560, current_level: 9 }] },
        { child_name: 'Emma Johnson', game_progress: [{ total_xp: 1250, current_level: 8 }] },
      ];

      const mockAvgScoreData = [
        { character: 'A', avgScore: '92.5' },
        { character: 'E', avgScore: '91.2' },
        { character: 'O', avgScore: '89.8' },
        { character: 'I', avgScore: '88.4' },
        { character: '5', avgScore: '87.9' },
        { character: 'T', avgScore: '86.7' },
        { character: '3', avgScore: '85.3' },
        { character: 'S', avgScore: '84.1' },
        { character: '7', avgScore: '83.6' },
        { character: 'N', avgScore: '82.8' },
      ];

      setAnalytics({
        characterTypeDistribution: mockTypeData,
        topPerformers: mockTopPerformers,
        averageScoreByCharacter: mockAvgScoreData,
      });

      setLoading(false);

      // Uncomment below to use real Supabase data
      /*
      const { data: sessions } = await supabase
        .from('practice_sessions')
        .select('character_type');

      const typeCount = { letter: 0, number: 0 };
      sessions?.forEach(s => {
        typeCount[s.character_type]++;
      });

      const typeData = [
        { name: 'Letters', value: typeCount.letter },
        { name: 'Numbers', value: typeCount.number },
      ];

      const { data: children } = await supabase
        .from('children')
        .select(`
          child_name,
          game_progress(total_xp, current_level)
        `)
        .order('game_progress(total_xp)', { ascending: false })
        .limit(5);

      const { data: allSessions } = await supabase
        .from('practice_sessions')
        .select('character_value, score');

      const scoresByCharacter = {};
      allSessions?.forEach(s => {
        if (!scoresByCharacter[s.character_value]) {
          scoresByCharacter[s.character_value] = { total: 0, count: 0 };
        }
        scoresByCharacter[s.character_value].total += parseFloat(s.score);
        scoresByCharacter[s.character_value].count++;
      });

      const avgScoreData = Object.entries(scoresByCharacter)
        .map(([char, data]) => ({
          character: char,
          avgScore: (data.total / data.count).toFixed(1),
        }))
        .sort((a, b) => b.avgScore - a.avgScore)
        .slice(0, 10);

      setAnalytics({
        characterTypeDistribution: typeData,
        topPerformers: children || [],
        averageScoreByCharacter: avgScoreData,
      });

      setLoading(false);
      */
    } catch (error) {
      console.error('Error fetching analytics:', error);
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div>
          <Skeleton className="h-8 w-48" />
          <Skeleton className="mt-2 h-4 w-64" />
        </div>
        <div className="grid gap-4 lg:grid-cols-2">
          <Skeleton className="h-80 rounded-lg" />
          <Skeleton className="h-80 rounded-lg" />
        </div>
        <Skeleton className="h-80 rounded-lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Analytics</h1>
        <p className="text-sm text-muted-foreground">Performance metrics and insights</p>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-base font-medium">Practice distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie
                  data={analytics.characterTypeDistribution}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={90}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {analytics.characterTypeDistribution.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={CHART_COLORS[index]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    borderRadius: '8px',
                    border: '1px solid hsl(var(--border))',
                    boxShadow: 'none',
                    fontSize: '13px',
                  }}
                />
                <Legend
                  verticalAlign="bottom"
                  iconType="circle"
                  iconSize={8}
                  formatter={(value) => (
                    <span style={{ color: 'hsl(var(--foreground))', fontSize: '13px' }}>{value}</span>
                  )}
                />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base font-medium">Top performers</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {analytics.topPerformers.map((child, index) => (
                <div key={index} className="flex items-center gap-3">
                  <span className="w-5 text-center text-sm font-medium text-muted-foreground">
                    {index + 1}
                  </span>
                  <Avatar className="h-8 w-8">
                    <AvatarFallback className="text-xs">
                      {(child.child_name || '?')[0].toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{child.child_name}</p>
                    <p className="text-xs text-muted-foreground">
                      Level {child.game_progress?.[0]?.current_level || 1}
                    </p>
                  </div>
                  <Badge variant="secondary">
                    {child.game_progress?.[0]?.total_xp || 0} XP
                  </Badge>
                </div>
              ))}

              {analytics.topPerformers.length === 0 && (
                <p className="py-6 text-center text-sm text-muted-foreground">No data yet</p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base font-medium">Average score by character</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {analytics.averageScoreByCharacter.map((item) => (
              <div key={item.character} className="flex items-center gap-4">
                <span className="w-8 text-center text-lg font-semibold">{item.character}</span>
                <div className="h-2 flex-1 overflow-hidden rounded-full bg-secondary">
                  <div
                    className="h-full rounded-full bg-primary transition-all"
                    style={{ width: `${item.avgScore}%` }}
                  />
                </div>
                <span className="w-12 text-right text-sm font-medium text-muted-foreground">
                  {item.avgScore}%
                </span>
              </div>
            ))}

            {analytics.averageScoreByCharacter.length === 0 && (
              <p className="py-6 text-center text-sm text-muted-foreground">No data yet</p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
